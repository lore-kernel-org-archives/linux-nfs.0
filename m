Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab1KQVgz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Nov 2011 16:36:55 -0500
Message-ID: <4EC57E74.7010700@RedHat.com>
Date: Thu, 17 Nov 2011 16:36:52 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsidmap: Allow all keys to clear on the keyring
References: <1321561563-5862-1-git-send-email-steved@redhat.com>	<1321561563-5862-2-git-send-email-steved@redhat.com> <CAGue13rrgKUiiWEF47ixjhWuZ9AK9Ax7UWmSMqkzPAe_rPqMFg@mail.gmail.com>
In-Reply-To: <CAGue13rrgKUiiWEF47ixjhWuZ9AK9Ax7UWmSMqkzPAe_rPqMFg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/17/2011 03:36 PM, Tigran Mkrtchyan wrote:
> On Thu, Nov 17, 2011 at 9:26 PM, Steve Dickson <steved@redhat.com> wrote:
>> Introduce the '-c [keyring]' command line argument
>> which will clear the giving keyring of the keys.
>> If a keyring not supplied the default 'id_resolver'
>> keyring will be used.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/nfsidmap/nfsidmap.c   |   62 +++++++++++++++++++++++++++++++++++++++---
>>  utils/nfsidmap/nfsidmap.man |   14 ++++++++-
>>  2 files changed, 69 insertions(+), 7 deletions(-)
>>
>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>> index 6a09f38..2625dc1 100644
>> --- a/utils/nfsidmap/nfsidmap.c
>> +++ b/utils/nfsidmap/nfsidmap.c
>> @@ -13,12 +13,14 @@
>>  #include "xlog.h"
>>
>>  int verbose = 0;
>> -char *usage="Usage: %s [-v] [-t timeout] key desc";
>> +char *usage="Usage: %s [-v] [-c [keyring]] [-t timeout] key desc";
>>
>>  #define MAX_ID_LEN   11
>>  #define IDMAP_NAMESZ 128
>>  #define USER  1
>>  #define GROUP 0
>> +#define DEFAULT_KEYRING "id_resolver"
>> +#define PROCKEYS "/proc/keys"
>>
>>  /*
>>  * Find either a user or group id based on the name@domain string
>> @@ -87,6 +89,47 @@ int name_lookup(char *id, key_serial_t key, int type)
>>  out:
>>        return rc;
>>  }
>> +/*
>> + * Clear all the keys on the given keyring
>> + */
>> +static int keyring_clear(char *keyring)
>> +{
>> +       FILE *fp;
>> +       char buf[BUFSIZ];
>> +       key_serial_t key;
>> +
>> +       xlog_syslog(0);
>> +       if (keyring == NULL)
>> +               keyring = DEFAULT_KEYRING;
>> +
>> +       if ((fp = fopen(PROCKEYS, "r")) == NULL) {
> 
> The same comment here: fp never closed.
Got it..

steved.
> 
> Tigran.
>> +               xlog_err("fopen(%s) failed: %m", PROCKEYS);
>> +               return 1;
>> +       }
>> +
>> +       while(fgets(buf, BUFSIZ, fp) != NULL) {
>> +               if (strstr(buf, "keyring") == NULL)
>> +                       continue;
>> +               if (strstr(buf, keyring) == NULL)
>> +                       continue;
>> +               if (verbose) {
>> +                       *(strchr(buf, '\n')) = '\0';
>> +                       xlog_warn("clearing '%s'", buf);
>> +               }
>> +               /*
>> +                * The key is the first arugment in the string
>> +                */
>> +               *(strchr(buf, ' ')) = '\0';
>> +               sscanf(buf, "%x", &key);
>> +               if (keyctl_clear(key) < 0) {
>> +                       xlog_err("keyctl_clear(0x%x) failed: %m", key);
>> +                       return 1;
>> +               }
>> +               return 0;
>> +       }
>> +       xlog_err("'%s' keyring was not found.", keyring);
>> +       return 1;
>> +}
>>
>>  int main(int argc, char **argv)
>>  {
>> @@ -96,7 +139,8 @@ int main(int argc, char **argv)
>>        int rc = 1, opt;
>>        int timeout = 600;
>>        key_serial_t key;
>> -       char *progname;
>> +       char *progname, *keyring = NULL;
>> +       int clearring;
>>
>>        /* Set the basename */
>>        if ((progname = strrchr(argv[0], '/')) != NULL)
>> @@ -105,11 +149,12 @@ int main(int argc, char **argv)
>>                progname = argv[0];
>>
>>        xlog_open(progname);
>> -       xlog_syslog(1);
>> -       xlog_stderr(0);
>>
>> -       while ((opt = getopt(argc, argv, "t:v")) != -1) {
>> +       while ((opt = getopt(argc, argv, "ct:v")) != -1) {
>>                switch (opt) {
>> +               case 'c':
>> +                       clearring++;
>> +                       break;
>>                case 'v':
>>                        verbose++;
>>                        break;
>> @@ -122,6 +167,13 @@ int main(int argc, char **argv)
>>                }
>>        }
>>
>> +       if (clearring) {
>> +               keyring = ((argc - optind) ? argv[optind] : NULL);
>> +               rc = keyring_clear(keyring);
>> +               return rc;
>> +       }
>> +
>> +       xlog_stderr(0);
>>        if ((argc - optind) != 2) {
>>                xlog_err("Bad arg count. Check /etc/request-key.conf");
>>                xlog_warn(usage, progname);
>> diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
>> index c67aab6..db65a1f 100644
>> --- a/utils/nfsidmap/nfsidmap.man
>> +++ b/utils/nfsidmap/nfsidmap.man
>> @@ -6,7 +6,7 @@
>>  .SH NAME
>>  nfsidmap \- The NFS idmapper upcall program
>>  .SH SYNOPSIS
>> -.B "nfsidmap [-v] [-t timeout] key desc"
>> +.B "nfsidmap [-v] [-c [keyring]] [-t timeout] key desc"
>>  .SH DESCRIPTION
>>  The file
>>  .I /usr/sbin/nfsidmap
>> @@ -14,10 +14,20 @@ is used by the NFS idmapper to translate user and group ids into names, and to
>>  translate user and group names into ids. Idmapper uses request-key to perform
>>  the upcall and cache the result.
>>  .I /usr/sbin/nfsidmap
>> -should only be called by request-key, and will perform the translation and
>> +is called by /sbin/request-key, and will perform the translation and
>>  initialize a key with the resulting information.
>> +.PP
>> +.I nfsidmap
>> +can also used to clear the keyring of all the keys.
>> +This is useful when all the mappings have failed to due to an DNS outage
>> +or some other error resulting in all the cached uid/gid to be invalid.
>>  .SH OPTIONS
>>  .TP
>> +.B -c [keyring]
>> +Clear the keyring of all the keys. If a
>> +keyring is not supplied the default
>> +keyring 'id_resolver' will be used.
>> +.TP
>>  .B -t timeout
>>  Set the expiration timer, in seconds, on the key.
>>  The default is 600 seconds (10 mins).
>> --
>> 1.7.7
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
