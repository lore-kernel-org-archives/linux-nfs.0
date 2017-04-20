Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:32993 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945252AbdDTLdG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 07:33:06 -0400
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxirSfVVYBexXrWccDHnE5oqxNgUh3-X5Ey1w4R=nHXDjA@mail.gmail.com>
References: <87inn12urq.fsf@drapion.f-secure.com> <CAOQ4uxjzjFDLmvebHmC4t4_tT8xyWfbHVGfKohEqw7ZjpxfV_w@mail.gmail.com>
 <20170322193122.GV29622@ZenIV.linux.org.uk> <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
 <87a88c2yxq.fsf@drapion.f-secure.com> <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
 <1490270212.3921.10.camel@poochiereds.net> <8760j02mfz.fsf@drapion.f-secure.com>
 <CAOQ4uxja14p02jQurLTGv_fHrs+UBa5qfacrgY_-7tyv6UJqdw@mail.gmail.com>
 <87lgqwa4tg.fsf@drapion.f-secure.com> <CAOQ4uxirSfVVYBexXrWccDHnE5oqxNgUh3-X5Ey1w4R=nHXDjA@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 20 Apr 2017 14:33:04 +0300
Message-ID: <CAOQ4uxjA8Z7wnwuHFCKeKT1xz0Gh-qS40Y6cfPi3fAM0MKsRuQ@mail.gmail.com>
Subject: Re: fanotify read returns with errno == EOPENSTALE
To: Marko Rauhamaa <marko.rauhamaa@f-secure.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jan Kara <jack@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 20, 2017 at 2:06 PM, Amir Goldstein <amir73il@gmail.com> wrote:
> On Wed, Apr 19, 2017 at 4:46 PM, Marko Rauhamaa
> <marko.rauhamaa@f-secure.com> wrote:
>> Amir Goldstein <amir73il@gmail.com>:
>>
>>> On Thu, Mar 23, 2017 at 8:43 AM, Marko Rauhamaa
>>> <marko.rauhamaa@f-secure.com> wrote:
>>>> Jeff Layton <jlayton@poochiereds.net>:
>>>>
>>>>> It was definitely not the intention to leak this error code to
>>>>> userland. EOPENSTALE is not a POSIX sanctioned error code, so
>>>>> applications generally don't know anything about it and will be
>>>>> confused.
>>>>
>>>> Got it. I will try to work on a reproduction and make a proper bug
>>>> report.
>>>
>>> Try this:
>>>
>>> - watch a single file for permissions events (so you will only have
>>> one event in the queue)
>>> - open file from client to generate single event (don't read event yet)
>>> - remove file from server (to make it stale)
>>> - read event (with stale file)
>>
>> I did that and reproduced the problem on a recent development kernel.
>> Happens every time.
>>
>> Just take the example program listed under "man fanotify" ("fantest")
>> and follow these steps:
>>
>>     ==============================================================
>>     NFS Server    NFS Client(1)     NFS Client(2)
>>     ==============================================================
>>     # echo foo >/nfsshare/bar.txt
>>                   # cat /nfsshare/bar.txt
>>                   foo
>>                                     # ./fantest /nfsshare
>>                                     Press enter key to terminate.
>>                                     Listening for events.
>>     # rm -f /nfsshare/bar.txt
>>                   # cat /nfsshare/bar.txt
>>                                     read: Unknown error 518
>>                   cat: /nfsshare/bar.txt: Operation not permitted
>>     ==============================================================
>>
>> where NFS Client (1) and (2) are two terminal sessions on a single NFS
>> Client machine.
>>
>
> Thanks for the reproducer.
> I'll try it myself when I get to it.
>
>> So what do we conclude? Is this a kernel bug or works as designed?
>>
>
> Exposing EOPENSTALE to userspace is definitely a kernel bug.
>
>
>>> Oh my. I completely misread your report before. I though you were
>>> trying to read from the event->fd. Now I understand that you mean read
>>> from fanotify fd. That will definitely return the error, but only in
>>> the special case where open error happened on the first event being
>>> read to the buffer. If error happens after adding some events to the
>>> buffer, fanotify process will not know about this. Regular event will
>>> be silently dropped and permission event will be denied.
>>>
>>> [...]
>>>
>>> You do NOT need to call fanotify_init() again, the next read will read
>>> the next event.
>>
>> It does appear that reading the fanotify fd again does the trick.
>>
>> However, the client gets an EPERM instead of ENOENT, which is a bit
>> weird.
>>
>
> Why would the client get ENOENT? That EOPENSTALE event is already
> consumed, the client reads the next event in the queue.

Sorry, I keep confusing when you refer to read of file and read of fanotify fd
when kernel fails to get response from fanotify daemon it will deny access
to file. That's the default.

>
>>> The fix seems trivial and I can post it once you have the test:
>>> - return EAGAIN for read in case of a single event in queue without fd
>>>   so apps getting the read error will have a good idea what to do
>>> - in case of non single event, maybe copy event with error on event->fd
>>>   to the buffer for specific errors that make sense to report (EMFILE)
>>>   so a watcher checks the values of negative event->fd can maybe do
>>>   something about it (e.g. provide a smaller buffer).
>>
>> EAGAIN would be perfect for me since I'm using fanotify in a nonblocking
>> mode. It might be a bit surprising in the blocking case.
>>
>>
>
> Can you please try this patch?
> Can you please try it with blocking and non-blocking
> Can you please try to add to reproducer the non empty queue case:
> - Add another mark on another mount without PERM events in the mask
> - Populate other mount with some files
> - Before reading from nfsshare, read from other mount to fill the
>    event queue, e.g.:
> # cat /tmp/foo* /nfsshare/bar.txt /tmp/bar*
>
> This should result (depending on number of files) with
>>= 2 buffer reads - first with /tmp/foo* files access
> last with /tmp/bar* files access
>
>

Sorry I messed up the previous patch. please try this one:

diff --git a/fs/notify/fanotify/fanotify_user.c
b/fs/notify/fanotify/fanotify_user.c
index 2b37f27..7864354 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -295,6 +295,16 @@ static ssize_t fanotify_read(struct file *file,
char __user *buf,
                }

                ret = copy_event_to_user(group, kevent, buf);
+               if (unlikely(ret == -EOPENSTALE)) {
+                       /*
+                        * We cannot report events with stale fd so drop it.
+                        * Setting ret to 0 will continue the event loop and
+                        * do the right thing if there are no more events to
+                        * read (i.e. return bytes read, -EAGAIN or wait).
+                        */
+                       ret = 0;
+               }
+
                /*
                 * Permission events get queued to wait for response.  Other
                 * events can be destroyed now.
@@ -305,7 +315,7 @@ static ssize_t fanotify_read(struct file *file,
char __user *buf,
                                break;
                } else {
 #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
-                       if (ret < 0) {
+                       if (ret <= 0) {
                                FANOTIFY_PE(kevent)->response = FAN_DENY;
                                wake_up(&group->fanotify_data.access_waitq);
                                break;
