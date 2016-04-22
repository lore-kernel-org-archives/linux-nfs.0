Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:35008 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbcDVUll (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2016 16:41:41 -0400
Received: by mail-ig0-f193.google.com with SMTP id fn8so3631923igb.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Apr 2016 13:41:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <571A6FB0.8080709@RedHat.com>
References: <1461186721-64008-1-git-send-email-kolga@netapp.com>
	<1461186721-64008-3-git-send-email-kolga@netapp.com>
	<571A6FB0.8080709@RedHat.com>
Date: Fri, 22 Apr 2016 16:41:40 -0400
Message-ID: <CAN-5tyH-JqHTnm+j0XG277qVQVbocR-j6MRn0aq9A8PLh_iMRg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 2/3] gssd: using syscalls directly to change
 thread's identity
From: Olga Kornievskaia <aglo@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 22, 2016 at 2:38 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 04/20/2016 05:12 PM, Olga Kornievskaia wrote:
>> For the threaded version we have to set uid,gid per thread instead
>> of per process. glibc setresuid() when called from a thread, it'll
>> send a signal to all other threads to synchronize the uid in all
>> other threads. To bypass this, we have to call syscall() directly.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> Reviewed-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/gssd/gssd_proc.c | 10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>> index 581a125..5d9a6db 100644
>> --- a/utils/gssd/gssd_proc.c
>> +++ b/utils/gssd/gssd_proc.c
>> @@ -69,6 +69,7 @@
>>  #include <netdb.h>
>>  #include <sys/types.h>
>>  #include <sys/wait.h>
>> +#include <syscall.h>
>>
>>  #include "gssd.h"
>>  #include "err_util.h"
>> @@ -457,7 +458,12 @@ change_identity(uid_t uid)
>>        * Switch the GIDs. Note that we leave the saved-set-gid alone in an
>>        * attempt to prevent attacks via ptrace()
>>        */
>> -     if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
>> +     /* For the threaded version we have to set uid,gid per thread instead
>> +      * of per process. glibc setresuid() when called from a thread, it'll
>> +      * send a signal to all other threads to synchronize the uid in all
>> +      * other threads. To bypass this, we have to call syscall() directly.
>> +      */
>> +     if (syscall(SYS_setresgid, pw->pw_gid) != 0) {
>>               printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
>>               return errno;
>>       }
>> @@ -466,7 +472,7 @@ change_identity(uid_t uid)
>>        * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
>>        * other processes running with this uid.
>>        */
>> -     if (setresuid(uid, uid, -1) != 0) {
>> +     if (syscall(SYS_setresuid, uid) != 0) {
>>               printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
>>                               uid);
>>               return errno;
>>
> We also have to do the same thing to the setgroups() call at the
> top of change_identity(). So add the following diff to this
> patch and we are good to go...
>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index e651d71..2f9f8ab 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -437,7 +437,7 @@ change_identity(uid_t uid)
>         struct passwd   *pw;
>
>         /* drop list of supplimentary groups first */
> -       if (setgroups(0, NULL) != 0) {
> +       if (syscall(SYS_setgroups, 0) != 0) {
>                 printerr(0, "WARNING: unable to drop supplimentary groups!");
>                 return errno;
>         }
>

Do you know why we do this before getting the passwd entry?

Doing as you suggest causes problems as in it it fails to drop the
supplementary groups.



> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
