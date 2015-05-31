#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <sys/time.h>


static inline unsigned int
days_in_year (unsigned int year)
{
  if ((year % 400) == 0 || ((year % 100) != 0 && (year % 4) == 0))
    return 366;
  else
    return 365;
}

static unsigned int
days_in_month (unsigned int year, unsigned int month)
{
  switch (month)
    {
    case 1:
    case 3:
    case 5:
    case 7:
    case 8:
    case 10:
    case 12:
      return 31;
      break;
      
    case 4:
    case 6:
    case 9:
    case 11:
      return 30;
      break;

    case 2:
      if ((year % 400) == 0 || ((year % 100) != 0 && (year % 4) == 0))
	return 29;
      else
	return 28;
    }
}

static time_t
convert_date_to_time_t (unsigned int year, unsigned int month, unsigned int day)
{
  unsigned int iter;
  unsigned int days = 0;

  /* Add in days of all years from 1970 to (year - 1). */
  for (iter = 1970; iter < year; iter++)
    days += days_in_year (iter);

  /* Add in all days for all months, except for this one. */
  for (iter = 1; iter < month; iter++)
    days += days_in_month (year, iter);

  /* Add in the days in this month, except for this day. */
  days += day - 1;


  /* Convert to seconds: A day is 24 hours, a hour is 60 minutes, etc. */
  /* Also, add an extra 12 hours, so it's in mid-day. */
  return (days * 24 * 60 * 60) + (12 * 60 * 60);
}

static time_t
parse_date_str (const char *date_str)
{
  unsigned int off;
  int error = 0;

  unsigned int year;
  unsigned int month;
  unsigned int day;
  
  /* Check to make sure that the input format is correct */
  if (strlen (date_str) != 10)
    error = 1;
  else
    for (off = 0; off < 10; off++)
      {
	if (off == 4 || off == 7)
	  {
	    if (date_str[off] != '/')
	      error = 1;
	  }
	else
	  if (!isdigit (date_str[off]))
	    error = 1;
      }

  if (error == 1)
    {
      fprintf (stderr, "Invalid date format!\nSupported: yyyy/mm/dd.\n");
      exit (2);
    }

  /* Change them to numbers. */
  year  = atoi (date_str);
  month = atoi (date_str + 5);
  day   = atoi (date_str + 8);

  /* Check value sanity. */
  if (year < 1970)
    {
      fprintf (stderr, "Years before 1970 are not supported.\n");
      exit (2);
    }

  if (month < 1 || month > 12)
    {
      fprintf (stderr, "There are only 12 months in a year, from 1 to 12.\n");
      exit (2);
    }

  if (day < 1 || day > days_in_month (year, month))
    {
      fprintf (stderr, "Invalid day, this month only has %u days.\n",
	       days_in_month (year, month));
      exit (2);
    }
  
  return convert_date_to_time_t (year, month, day);
}

int
main (int argc, char **argv)
{
  struct timeval times[2];
  
  if (argc != 3)
    {
      fprintf (stderr, "Usage: %s <filename> <date>\n"
	       "The format of the data string: yyyy/mm/dd.\n", argv[0]);
      return 1;
    }

  times[0].tv_sec  = parse_date_str (argv[2]);
  times[0].tv_usec = 0;
  times[1] = times[0];

  if (utimes (argv[1], times) == -1)
    {
      fprintf (stderr, "Failed to set the timestamp on \"%s\": %s.\n",
	       argv[1], strerror (errno));
      return 3;
    }

  return 0;
}