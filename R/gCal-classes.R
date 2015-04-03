#' @importFrom R6 R6Class
#' @importFrom lubridate now ymd_hms
#' @importFrom plyr alply l_ply
#' @include gcalendar-package.R
#' @include google-apis.R
gcal_scopes <- c(
  read_only = "https://www.googleapis.com/auth/calendar.readonly",
  edit = ""
)

.gCalendarApi <- R6Class(
  ".gCalendarApi",
  inherit = .googleApi,
  private = list(
    scope = gcal_scopes['read_only'],
    write_scope = gcal_scopes["edit"],
    base_url = "https://www.googleapis.com/calendar/v3"
  )
)

.gCalResource <- R6Class(
  ".gCalResource",
  inherit = .googleApiResource,
  private = list(
    scope = gcal_scopes['read_only'],
    write_scope = gcal_scopes["edit"],
    base_url = "https://www.googleapis.com/calendar/v3"
  )
)

.gCalCollection <- R6Class(
  ".gCalCollection",
  inherit = .googleApiCollection,
  private = list(
    scope = gcal_scopes['read_only'],
    write_scope = gcal_scopes["edit"],
    base_url = "https://www.googleapis.com/calendar/v3"
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

