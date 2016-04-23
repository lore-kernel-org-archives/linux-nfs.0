Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbcDWVO1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Apr 2016 17:14:27 -0400
Subject: Re: [RFC PATCH v2 2/3] gssd: using syscalls directly to change
 thread's identity
To: Olga Kornievskaia <aglo@umich.edu>, Jeff Layton <layton@primarydata.com>
References: <1461186721-64008-1-git-send-email-kolga@netapp.com>
 <1461186721-64008-3-git-send-email-kolga@netapp.com>
 <571A6FB0.8080709@RedHat.com>
 <CAN-5tyH-JqHTnm+j0XG277qVQVbocR-j6MRn0aq9A8PLh_iMRg@mail.gmail.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <571BE5B0.4050608@RedHat.com>
Date: Sat, 23 Apr 2016 17:14:24 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyH-JqHTnm+j0XG277qVQVbocR-j6MRn0aq9A8PLh_iMRg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/22/2016 04:41 PM, Olga Kornievskaia wrote:
> On Fri, Apr 22, 2016 at 2:38 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>> On 04/20/2016 05:12 PM, Olga Kornievskaia wrote:
>>> For the threaded version we have to set uid,gid per thread instead
>>> of per process. glibc setresuid() when called from a thread, it'll
>>> send a signal to all other threads to synchronize the uid in all
>>> other threads. To bypass this, we have to call syscall() directly.
>>>
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> Reviewed-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  utils/gssd/gssd_proc.c | 10 ++++++++--
>>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>>> index 581a125..5d9a6db 100644
>>> --- a/utils/gssd/gssd_proc.c
>>> +++ b/utils/gssd/gssd_proc.c
>>> @@ -69,6 +69,7 @@
>>>  #include <netdb.h>
>>>  #include <sys/types.h>
>>>  #include <sys/wait.h>
>>> +#include <syscall.h>
>>>
>>>  #include "gssd.h"
>>>  #include "err_util.h"
>>> @@ -457,7 +458,12 @@ change_identity(uid_t uid)
>>>        * Switch the GIDs. Note that we leave the saved-set-gid alone in an
>>>        * attempt to prevent attacks via ptrace()
>>>        */
>>> -     if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
>>> +     /* For the threaded version we have to set uid,gid per thread instead
>>> +      * of per process. glibc setresuid() when called from a thread, it'll
>>> +      * send a signal to all other threads to synchronize the uid in all
>>> +      * other threads. To bypass this, we have to call syscall() directly.
>>> +      */
>>> +     if (syscall(SYS_setresgid, pw->pw_gid) != 0) {
>>>               printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
>>>               return errno;
>>>       }
>>> @@ -466,7 +472,7 @@ change_identity(uid_t uid)
>>>        * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
>>>        * other processes running with this uid.
>>>        */
>>> -     if (setresuid(uid, uid, -1) != 0) {
>>> +     if (syscall(SYS_setresuid, uid) != 0) {
>>>               printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
>>>                               uid);
>>>               return errno;
>>>
>> We also have to do the same thing to the setgroups() call at the
>> top of change_identity(). So add the following diff to this
>> patch and we are good to go...
>>
>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>> index e651d71..2f9f8ab 100644
>> --- a/utils/gssd/gssd_proc.c
>> +++ b/utils/gssd/gssd_proc.c
>> @@ -437,7 +437,7 @@ change_identity(uid_t uid)
>>         struct passwd   *pw;
>>
>>         /* drop list of supplimentary groups first */
>> -       if (setgroups(0, NULL) != 0) {
>> +       if (syscall(SYS_setgroups, 0) != 0) {
>>                 printerr(0, "WARNING: unable to drop supplimentary groups!");
>>                 return errno;
>>         }
>>
> 
> Do you know why we do this before getting the passwd entry?
It came in with commit 6b53fc9c which changed the way gssd
changed the uid/gid from Jeff Layton...

Jeff, what was the thought behind dropping supplementary groups?
I believe it was some type of security thing.

> 
> Doing as you suggest causes problems as in it it fails to drop the
> supplementary groups.
hmm... what are you seeing that I'm not?

steved.

