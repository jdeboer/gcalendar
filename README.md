#Google Calendar API client for R
R6 classes for Google Calendar resources and collections.

##Before you start
This package is in early development (incomplete and has bugs) but is open for testing. Refer to the MIT-licence file before downloading, installing or using.

##Installation
Install the latest version using the devtools package as follows:
```r
install.packages("devtools") # In case you haven't installed devtools already
devtools::install_github("jdeboer/gcalendar")
```

If you haven't already, visit the [Google APIs Console](https://code.google.com/apis/console/) to create a Google APIs project to use the Google Calendar API with this R package. Remember to enable the Google Calendar API for your project. Also within the Google APIs Console you will need to create credentials for an 'installed application' and download the resulting JSON file containing your application's client ID and client secret.

Once the package is installed in R and you have your Google API Project client ID and client secret, then try out the following example script that gets a list of birthdays from your Google Calendar.

##Example use
```r
# Load package into workspace.
library(gcalendar)

# Provide credentials:
# - Requires a Google APIs project with OAuth access
#   and the Google Calendar API enabled.
creds <- GoogleApiCreds(
  userName = "<set to your Google account email address>", # An optional hint to
                                                           # simplify login.
  appCreds = "client_secret.json" # Location of the JSON file containing your
                                  # Google APIs project OAuth client ID and
                                  # secret. Optionally set to a list with named
                                  # values for client_id and/or client_secret,
                                  # and/or provide an appname to fetch omitted
                                  # values from OS environment variables
                                  # <appname>_CONSUMER_ID and
                                  # <appname>_CONSUMER_SECRET.
                                  # Default for appname is "GOOGLE_APIS".
)

# Get a list of your calendars using the credentials you provided,
# then print a summary.
my_cal_list <- gCalendarLists$new(creds = creds)
calendars <- my_cal_list$summary[c("id", "summary", "description")]
print(calendars)

# Get the chosen calendar (contact birthdays).
birthdays_calendar <- gCalendar$new(
  creds = creds,
  id = "#contacts@group.v.calendar.google.com"
)

# Get the events from this chosen calendar.
birthday_events <- birthdays_calendar$events

# Get a summary of the birthdays and print the results.
birthdays <- birthday_events$summary[c("id", "summary", "start")]
print(birthdays)

```

## Support and feedback
Any feedback, issues you have or other questions specifically about this package should be posted to the [issues page on Github](https://github.com/jdeboer/gcalendar/issues).
