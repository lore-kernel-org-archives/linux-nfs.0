Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38461 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759860Ab0JZMlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 08:41:24 -0400
Message-ID: <4CC6CC73.6030008@netapp.com>
Date: Tue, 26 Oct 2010 08:41:23 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Schumaker Bryan <Bryan.Schumaker@netapp.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: add nfs.upcall
References: <1288046434-18503-1-git-send-email-Trond.Myklebust@netapp.com> <B7AE3537-6F68-4716-B486-7EC8A44ED882@oracle.com> <61E98BF7-2E64-47D5-A5C0-5701E36B8C99@netapp.com>
In-Reply-To: <61E98BF7-2E64-47D5-A5C0-5701E36B8C99@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sure.  Do you want a patch that renames it in the kernel documentation file too?

Bryan

On 10/25/2010 07:46 PM, Myklebust, Trond wrote:
> Ah, fsck... You're right.
> 
> Bryan, can you instead resend your latest patch for nfs-utils? I've asked Linus to merge the kernel part, so it is time to get the userspace stuff in order too!
> 
> Sent from my iPhone
> 
> On Oct 25, 2010, at 19:21, "Chuck Lever" <chuck.lever@oracle.com> wrote:
> 
>> I thought we were going to call this nfs.idmap ... ?
>>
>> On Oct 25, 2010, at 6:40 PM, Trond Myklebust wrote:
>>
>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>
>>> Add nfs.upcall
>>>
>>> This patch adds the nfs.upcall program to nfs-utils.  This program is called by
>>> the nfs idmapper through request-keys to map between uid / user name and
>>> gid / group name.
>>>
>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>> aclocal/keyutils.m4           |   11 ++++
>>> configure.ac                  |    4 ++
>>> utils/Makefile.am             |    1 +
>>> utils/nfs.upcall/Makefile.am  |    7 +++
>>> utils/nfs.upcall/nfs.upcall.c |  120 +++++++++++++++++++++++++++++++++++++++++
>>> 5 files changed, 143 insertions(+), 0 deletions(-)
>>> create mode 100644 aclocal/keyutils.m4
>>> create mode 100644 utils/nfs.upcall/Makefile.am
>>> create mode 100644 utils/nfs.upcall/nfs.upcall.c
>>>
>>> diff --git a/aclocal/keyutils.m4 b/aclocal/keyutils.m4
>>> new file mode 100644
>>> index 0000000..8aea646
>>> --- /dev/null
>>> +++ b/aclocal/keyutils.m4
>>> @@ -0,0 +1,11 @@
>>> +dnl Checks for keyutils library and headers
>>> +dnl
>>> +AC_DEFUN([AC_KEYUTILS], [
>>> +
>>> +  dnl Check for libkeyutils; do not add to LIBS if found
>>> +  AC_CHECK_LIB([keyutils], [keyctl_instantiate], [LIBKEYUTILS=-lkeyutils], ,)
>>> +  AC_SUBST(LIBKEYUTILS)
>>> +
>>> +  AC_CHECK_HEADERS([keyutils.h], ,
>>> +           [AC_MSG_ERROR([keyutils.h header not found.])])
>>> +])dnl
>>> diff --git a/configure.ac b/configure.ac
>>> index 3058be6..a5e8620 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -247,6 +247,9 @@ if test "$enable_nfsv4" = yes; then
>>>  dnl check for nfsidmap libraries and headers
>>>  AC_LIBNFSIDMAP
>>>
>>> +  dnl check for the keyutils libraries and headers
>>> +  AC_KEYUTILS
>>> +
>>>  dnl librpcsecgss already has a dependency on libgssapi,
>>>  dnl but we need to make sure we get the right version
>>>  if test "$enable_gss" = yes; then
>>> @@ -435,6 +438,7 @@ AC_CONFIG_FILES([
>>>    utils/mountd/Makefile
>>>    utils/nfsd/Makefile
>>>    utils/nfsstat/Makefile
>>> +    utils/nfs.upcall/Makefile
>>>    utils/showmount/Makefile
>>>    utils/statd/Makefile
>>>    tests/Makefile
>>> diff --git a/utils/Makefile.am b/utils/Makefile.am
>>> index 8665183..0104a6c 100644
>>> --- a/utils/Makefile.am
>>> +++ b/utils/Makefile.am
>>> @@ -4,6 +4,7 @@ OPTDIRS =
>>>
>>> if CONFIG_NFSV4
>>> OPTDIRS += idmapd
>>> +OPTDIRS += nfs.upcall
>>> endif
>>>
>>> if CONFIG_GSS
>>> diff --git a/utils/nfs.upcall/Makefile.am b/utils/nfs.upcall/Makefile.am
>>> new file mode 100644
>>> index 0000000..52afd3d
>>> --- /dev/null
>>> +++ b/utils/nfs.upcall/Makefile.am
>>> @@ -0,0 +1,7 @@
>>> +## Process this file with automake to produce Makefile.in
>>> +
>>> +sbin_PROGRAMS    = nfs.upcall
>>> +nfs_upcall_SOURCES = nfs.upcall.c
>>> +nfs_upcall_LDADD = -lnfsidmap -lkeyutils
>>> +
>>> +MAINTAINERCLEANFILES = Makefile.in
>>> diff --git a/utils/nfs.upcall/nfs.upcall.c b/utils/nfs.upcall/nfs.upcall.c
>>> new file mode 100644
>>> index 0000000..11b9a01
>>> --- /dev/null
>>> +++ b/utils/nfs.upcall/nfs.upcall.c
>>> @@ -0,0 +1,120 @@
>>> +
>>> +#include <stdarg.h>
>>> +#include <stdio.h>
>>> +#include <stdlib.h>
>>> +#include <string.h>
>>> +
>>> +#include <pwd.h>
>>> +#include <grp.h>
>>> +#include <keyutils.h>
>>> +#include <nfsidmap.h>
>>> +
>>> +#include <syslog.h>
>>> +
>>> +/* gcc nfs.upcall.c -o nfs.upcall -l nfsidmap -l keyutils */
>>> +
>>> +#define MAX_ID_LEN   11
>>> +#define IDMAP_NAMESZ 128
>>> +#define USER  1
>>> +#define GROUP 0
>>> +
>>> +
>>> +/*
>>> + * Find either a user or group id based on the name@domain string
>>> + */
>>> +int id_lookup(char *name_at_domain, key_serial_t key, int type)
>>> +{
>>> +    char id[MAX_ID_LEN];
>>> +    uid_t uid = 0;
>>> +    gid_t gid = 0;
>>> +
>>> +    if (type == USER) {
>>> +        nfs4_owner_to_uid(name_at_domain, &uid);
>>> +        sprintf(id, "%u", uid);
>>> +    } else {
>>> +        nfs4_group_owner_to_gid(name_at_domain, &gid);
>>> +        sprintf(id, "%u", gid);
>>> +    }
>>> +
>>> +    return keyctl_instantiate(key, id, strlen(id) + 1, 0);
>>> +}
>>> +
>>> +/*
>>> + * Find the name@domain string from either a user or group id
>>> + */
>>> +int name_lookup(char *id, key_serial_t key, int type)
>>> +{
>>> +    char name[IDMAP_NAMESZ];
>>> +    char domain[NFS4_MAX_DOMAIN_LEN];
>>> +    uid_t uid;
>>> +    gid_t gid;
>>> +    int rc = 0;
>>> +
>>> +    rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
>>> +    if (rc != 0) {
>>> +        rc = -1;
>>> +        goto out;
>>> +    }
>>> +
>>> +    if (type == USER) {
>>> +        uid = atoi(id);
>>> +        rc = nfs4_uid_to_name(uid, domain, name, IDMAP_NAMESZ);
>>> +    } else {
>>> +        gid = atoi(id);
>>> +        rc = nfs4_gid_to_name(gid, domain, name, IDMAP_NAMESZ);
>>> +    }
>>> +
>>> +    if (rc == 0)
>>> +        rc = keyctl_instantiate(key, &name, strlen(name), 0);
>>> +
>>> +out:
>>> +    return rc;
>>> +}
>>> +
>>> +int main(int argc, char **argv)
>>> +{
>>> +    char *arg;
>>> +    char *value;
>>> +    char *type;
>>> +    int rc = 1;
>>> +    int timeout = 600;
>>> +    key_serial_t key;
>>> +
>>> +    /*openlog("nfs.upcall", 0, LOG_DAEMON);*/
>>> +
>>> +    if (argc < 3)
>>> +        return 1;
>>> +
>>> +    arg = malloc(sizeof(char) * strlen(argv[2]) + 1);
>>> +    strcpy(arg, argv[2]);
>>> +    type = strtok(arg, ":");
>>> +    value = strtok(NULL, ":");
>>> +
>>> +    if (argc == 4) {
>>> +        timeout = atoi(argv[3]);
>>> +        if (timeout < 0)
>>> +            timeout = 0;
>>> +    }
>>> +
>>> +    /*syslog(LOG_ERR, "type: %s", type);
>>> +    syslog(LOG_ERR, "value: %s", value);
>>> +    syslog(LOG_ERR, "timeout: %d", timeout);*/
>>> +
>>> +    key = strtol(argv[1], NULL, 10);
>>> +
>>> +    if (strcmp(type, "uid") == 0)
>>> +        rc = id_lookup(value, key, USER);
>>> +    else if (strcmp(type, "gid") == 0)
>>> +        rc = id_lookup(value, key, GROUP);
>>> +    else if (strcmp(type, "user") == 0)
>>> +        rc = name_lookup(value, key, USER);
>>> +    else if (strcmp(type, "group") == 0)
>>> +        rc = name_lookup(value, key, GROUP);
>>> +
>>> +    /* Set timeout to 5 (600 seconds) minutes */
>>> +    keyctl_set_timeout(key, timeout);
>>> +
>>> +    free(arg);
>>> +    /*closelog();*/
>>> +    return rc;
>>> +}
>>> -- 
>>> 1.7.2.3
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>

