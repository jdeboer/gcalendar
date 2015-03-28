#' @importFrom R6 R6Class
#' @importFrom lubridate now ymd_hms
#' @importFrom plyr alply l_ply
#' @include gcalendar-package.R
#' @include google-apis.R
gcal_scopes <- c(
  read_only = "https://www.googleapis.com/auth/calendar.readonly"
)

.gCalendarApi <- R6Class(
  ".gCalendarApi",
  public = list(
    creds = GoogleApiCreds(),
    get = function(maxResults = NULL, pageToken = NULL) {
      req_type <- "GET"
      queries <- c(maxResults = maxResults, pageToken = pageToken)
      google_api_request(
        creds = self$creds,
        scope = private$scope,
        request = self$.req_path,
        base_url = private$base_url,
        queries = queries,
        req_type = req_type
      )
    },
    initialize = function(creds = GoogleApiCreds()) {
      self$creds = creds
    }
  ),
  private = list(
    request = NULL,
    scope = gcal_scopes['read_only'],
    base_url = "https://www.googleapis.com/calendar/v3",
    parent_class_name = "NULL",
    field_corrections = function(field_list) {
      if(is.data.frame(field_list)) {
        if(exists("created", field_list)) {
          field_list$created <- ymd_hms(field_list$created)
        }
        if(exists("updated", field_list)) {
          field_list$updated <- ymd_hms(field_list$updated)
        }
        field_list[!(names(field_list) %in% c("kind", "selfLink", "childLink", "parentLink"))]
      } else {
        field_list
      }
    }
  )
)

.gCalResource <- R6Class(
  ".gCalResource",
  inherit = .gCalendarApi,
  public = list(
    id = NA,
    name = NA,
    created = NA,
    updated = NA,
    parent = NULL,
    modify = function(field_list) {
      l_ply(names(field_list), function(field_name) {
        if (exists(field_name, self)) {
          self[[field_name]] <- field_list[[field_name]]
        }
      })
      self
    },
    initialize = function(creds = GoogleApiCreds(), parent = NULL, id = NULL, ...) {
      super$initialize(creds, ...)
      stopifnot(is(parent, private$parent_class_name) | is(parent, "NULL"))
      self$parent <- parent
      self$id <- id
      if(is.null(id)) {
        self
      } else {
        self$get()
      }
    },
    get = function() {
      if (!is.null(self$.req_path)) {
        response <- super$get()
        updated_fields <- private$field_corrections(response)
        self$modify(updated_fields)
      }
      self
    },
    .child_nodes = function(class_generator) {
      class_name <- class_generator$classname
      if (is(private$cache[[class_name]], class_name)) {
        private$cache[[class_name]]
      } else {
        private$cache[[class_name]] <- class_generator$new(parent = self, creds = self$creds)
      }
    }
  ),
  active = list(
    .req_path = function() {
      if (is.null(self$id)) {
        NULL
      } else {
        c(self$parent$.req_path, private$request, URLencode(self$id, reserved = TRUE))
      }
    }
  ),
  private = list(
    cache = list()
  )
)

.gCalCollection <- R6Class(
  ".gCalCollection",
  inherit = .gCalendarApi,
  public = list(
    summary = data.frame(),
    parent = NULL,
    get_entity = function(id) {
      entity <- private$entity_class$new(parent = self$parent, id = id)
      private$entities_cache[[id]] <- entity
      entity
    },
    get = function() {
      if (!is.null(self$.req_path)) {
        maxResults <- private$maxResults
        pageToken <- NULL
        ### TO DO - Add pagination iterator
        response <- super$get(maxResults = maxResults, pageToken = pageToken)
        ###
        self$summary <- private$field_corrections(response$items)
      }
      self
    },
    initialize = function(creds = GoogleApiCreds(), parent = NULL, ...) {
      super$initialize(creds, ...)
      entity_class_private <- with(private$entity_class, c(private_fields, private_methods))
      private$request <- entity_class_private$request
      private$parent_class_name <- entity_class_private$parent_class_name
      stopifnot(is(parent, private$parent_class_name) | is(parent, "NULL"))
      self$parent <- parent
      self$get()
    }
  ),
  active = list(
    entities = function() {
      if (is.data.frame(self$summary)) {
        ret <- alply(self$summary, 1, function(summary_row) {
          field_list <- as.list(summary_row)
          id <- summary_row$id
          updated <- summary_row$updated
          entity <- private$entities_cache[[id]]
          if (
            !is(entity, private$entity_class$classname) |
              identical(entity$updated != updated, TRUE)
          ) {
            entity <- private$entity_class$new(parent = self$parent)
            entity$modify(field_list = field_list)
            private$entities_cache[[id]] <- entity
          }
          entity
        })
        attributes(ret) <- NULL
        names(ret) <- self$summary$id
        return(ret)
      } else {
        return(NULL)
      }
    },
    .req_path = function() {
      if (!is.null(self$parent) & is.null(self$parent$.req_path)) {
        return(NULL)
      } else if (is(self$parent, private$parent_class_name)) {
        return(c(self$parent$.req_path, private$request))
      } else {
        return(NULL)
      }
    }
  ),
  private = list(
    entity_class = .gCalResource,
    entities_cache = list(),
    maxResults = NULL
  )
)

#' @export
gCalendarList <- R6Class(
  "gCalendarList",
  inherit = .gCalResource,
  private = list(
    parent_class_name = "NULL",
    request = c("users", "me", "calendarList")
  )
)

#' @export
gCalendarLists <- R6Class(
  "gCalendarLists",
  inherit = .gCalCollection,
  private = list(
    entity_class = gCalendarList
  )
)

#' @export
gCalendar <- R6Class(
  "gCalendar",
  inherit = .gCalResource,
  active = list(
    events = function() {self$.child_nodes(gCalEvents)}
  ),
  private = list(
    parent_class_name = "NULL",
    request = "calendars"
  )
)

#' @export
gCalendars <- R6Class(
  "gCalendars",
  inherit = .gCalCollection,
  private = list(
    entity_class = gCalendar
  )
)

#' @export
gCalEvent <- R6Class(
  "gCalEvent",
  inherit = .gCalResource,
  active = list(
    instances = function() {self$.child_nodes(gCalInstances)}
  ),
  private = list(
    parent_class_name = "gCalendar",
    request = "events"
  )
)

#' @export
gCalEvents <- R6Class(
  "gCalEvents",
  inherit = .gCalCollection,
  private = list(
    entity_class = gCalEvent,
    maxResults = 2500
  )
)

#' @export
gCalInstance <- R6Class(
  "gCalInstance",
  inherit = .gCalResource,
  private = list(
    parent_class_name = "gCalEvent",
    request = "instances"
  )
)

#' @export
gCalInstances <- R6Class(
  "gCalEvents",
  inherit = .gCalCollection,
  private = list(
    entity_class = gCalInstance
  )
)

