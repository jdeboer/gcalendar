Google Calendar API client for R.

R6 classes for Google Calendar resources and collections.

Example use:

```r
# Load package into workspace
library(gcalendar)

# Provide credentials (requires a Google APIs project with OAuth access)
creds <- GoogleApiCreds(
  userName = "<set to your Google account email address>",
  appCreds = "client_secret.json" # location of the JSON file containing your
                                  # Google APIs project OAuth client id and secret.
)

# Get a list of your calendars using the creds you provided and print a summary
my_cal_lists <- gCalendarLists$new(creds = creds)
calendars <- my_cal_lists$summary[c("id", "summary", "description")]
print(calendars)

# Get the chosen calendar (contact birthdays)
birthdays_calendar <- gCalendar$new(
  creds = creds,
  id = "#contacts@group.v.calendar.google.com"
)

# Get the events from this chosen calendar
birthday_events <- birthdays_calendar$events

# Get a summary of the birthdays and print the results
birthdays <- birthday_events$summary[c("id", "summary", "start")]
print(birthdays)

```
