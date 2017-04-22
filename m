Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34193 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041149AbdDVHWW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Apr 2017 03:22:22 -0400
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxgAOJjWP6PHY6WgOkNK0vmaTWnFZN+Jvea7zpjJ_VU8Bw@mail.gmail.com>
References: <20170322193122.GV29622@ZenIV.linux.org.uk> <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
 <87a88c2yxq.fsf@drapion.f-secure.com> <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
 <1490270212.3921.10.camel@poochiereds.net> <8760j02mfz.fsf@drapion.f-secure.com>
 <CAOQ4uxja14p02jQurLTGv_fHrs+UBa5qfacrgY_-7tyv6UJqdw@mail.gmail.com>
 <87lgqwa4tg.fsf@drapion.f-secure.com> <CAOQ4uxirSfVVYBexXrWccDHnE5oqxNgUh3-X5Ey1w4R=nHXDjA@mail.gmail.com>
 <CAOQ4uxjA8Z7wnwuHFCKeKT1xz0Gh-qS40Y6cfPi3fAM0MKsRuQ@mail.gmail.com>
 <20170420142035.GE22135@quack2.suse.cz> <CAOQ4uxgAOJjWP6PHY6WgOkNK0vmaTWnFZN+Jvea7zpjJ_VU8Bw@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sat, 22 Apr 2017 10:22:20 +0300
Message-ID: <CAOQ4uxgkXz+8=m2o_faAh2g2Z21KhAf67WckgPNWhktz1=DaWA@mail.gmail.com>
Subject: Re: fanotify read returns with errno == EOPENSTALE
To: Jan Kara <jack@suse.cz>
Cc: Marko Rauhamaa <marko.rauhamaa@f-secure.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 20, 2017 at 6:06 PM, Amir Goldstein <amir73il@gmail.com> wrote:
> On Thu, Apr 20, 2017 at 5:20 PM, Jan Kara <jack@suse.cz> wrote:
>> On Thu 20-04-17 14:33:04, Amir Goldstein wrote:
>>>
>>> Sorry I messed up the previous patch. please try this one:
>>>
>>> diff --git a/fs/notify/fanotify/fanotify_user.c
>>> b/fs/notify/fanotify/fanotify_user.c
>>> index 2b37f27..7864354 100644
>>> --- a/fs/notify/fanotify/fanotify_user.c
>>> +++ b/fs/notify/fanotify/fanotify_user.c
>>> @@ -295,6 +295,16 @@ static ssize_t fanotify_read(struct file *file,
>>> char __user *buf,
>>>                 }
>>>
>>>                 ret = copy_event_to_user(group, kevent, buf);
>>> +               if (unlikely(ret == -EOPENSTALE)) {
>>> +                       /*
>>> +                        * We cannot report events with stale fd so drop it.
>>> +                        * Setting ret to 0 will continue the event loop and
>>> +                        * do the right thing if there are no more events to
>>> +                        * read (i.e. return bytes read, -EAGAIN or wait).
>>> +                        */
>>> +                       ret = 0;
>>> +               }
>>> +
>>>                 /*
>>>                  * Permission events get queued to wait for response.  Other
>>>                  * events can be destroyed now.
>>> @@ -305,7 +315,7 @@ static ssize_t fanotify_read(struct file *file,
>>> char __user *buf,
>>>                                 break;
>>>                 } else {
>>>  #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
>>> -                       if (ret < 0) {
>>> +                       if (ret <= 0) {
>>>                                 FANOTIFY_PE(kevent)->response = FAN_DENY;
>>>                                 wake_up(&group->fanotify_data.access_waitq);
>>>                                 break;
>>
>> I don't think you want to break out of the reading loop when ret == 0 and
>> the code might be more readable as:
>>
>>                if (!(kevent->mask & FAN_ALL_PERM_EVENTS)) {
>>                         fsnotify_destroy_event(group, kevent);
>>                } else {
>> #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
>>                         if (ret <= 0) {
>>                                 FANOTIFY_PE(kevent)->response = FAN_DENY;
>>                                 wake_up(&group->fanotify_data.access_waitq);
>>                         } else {
>>                                 spin_lock(&group->notification_lock);
>>                                 list_add_tail(&kevent->list,
>>                                               &group->fanotify_data.access_list);
>>                                 spin_unlock(&group->notification_lock);
>>                         }
>> #endif
>>                 }
>>                 if (ret < 0)
>>                         break;
>>
>> Hmm?
>>
>

On Fri, Apr 21, 2017 at 5:27 PM, Marko Rauhamaa
<marko.rauhamaa@f-secure.com> wrote:
> Amir Goldstein <amir73il@gmail.com>:
>
>> Did you notice Jan's comments on my patch? I had a bug that broke out
>> of the loop. Without his corrections read will return even if there
>> are more events in the queue.
>
> Yes, I now tried Jan's fix, and it did the trick.
>
> It will now take months or years before distros have a proper fix. In
> the interim, I will absorb EOPENSTALE and schedule a reread in that
> situation.
>
> Thank you both for your attention.
>
>

Marko,

Were you able to verify that both blocking and non-blocking mode work correctly?
May I add your Tested-by and Reported-by tags?

Thanks!
Amir.
