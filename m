Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f178.google.com ([74.125.82.178]:36811 "EHLO
        mail-ot0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933229AbdCWNrJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Mar 2017 09:47:09 -0400
MIME-Version: 1.0
In-Reply-To: <8760j02mfz.fsf@drapion.f-secure.com>
References: <87inn12urq.fsf@drapion.f-secure.com> <CAOQ4uxjzjFDLmvebHmC4t4_tT8xyWfbHVGfKohEqw7ZjpxfV_w@mail.gmail.com>
 <20170322193122.GV29622@ZenIV.linux.org.uk> <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
 <87a88c2yxq.fsf@drapion.f-secure.com> <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
 <1490270212.3921.10.camel@poochiereds.net> <8760j02mfz.fsf@drapion.f-secure.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 23 Mar 2017 09:47:07 -0400
Message-ID: <CAOQ4uxja14p02jQurLTGv_fHrs+UBa5qfacrgY_-7tyv6UJqdw@mail.gmail.com>
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

On Thu, Mar 23, 2017 at 8:43 AM, Marko Rauhamaa
<marko.rauhamaa@f-secure.com> wrote:
> Jeff Layton <jlayton@poochiereds.net>:
>
>> It was definitely not the intention to leak this error code to
>> userland. EOPENSTALE is not a POSIX sanctioned error code, so
>> applications generally don't know anything about it and will be
>> confused.
>
> Got it. I will try to work on a reproduction and make a proper bug
> report.
>

Try this:

- watch a single file for permissions events (so you will only have
one event in the queue)
- open file from client to generate single event (don't read event yet)
- remove file from server (to make it stale)
- read event (with stale file)

>> I haven't looked closely at this particular problem, but IIRC we
>> usually just translate EOPENSTALE to ESTALE, and that may be all that
>> needs to be done here. If this happened in the RHEL kernel, then
>> please do open a bug with Red Hat and we'll get it straightened out.
>
> ESTALE has not been mentioned as a possible error code from an fanotify
> read. Most importantly, since read fails, I suppose there is no recovery
> but you must close the fanotify fd and call fanotify_init() again. Or
> should I just ignore it and read on? If so, why bother returning the
> error from the kernel in the first place?
>

Oh my. I completely misread your report before.
I though you were trying to read from the event->fd.
Now I understand that  you mean read from fanotify fd.
That will definitely return the error, but  only in the special case
where open error
happened on the first event being read to the buffer.
If error happens after adding some events to the buffer, fanotify
process will not know
about this. Regular event will be silently dropped and permission event will be
denied.
