Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35364 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbcG2QnN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2016 12:43:13 -0400
Received: by mail-oi0-f41.google.com with SMTP id l72so113781669oig.2
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2016 09:43:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com>
References: <20151012164846.GA5017@draconx.ca> <20151012192538.GG28755@fieldses.org>
 <20151012194647.GJ28755@fieldses.org> <20151013030136.GA7081@draconx.ca>
 <20151013065225.44c5581d@synchrony.poochiereds.net> <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com>
From: Nick Bowler <nbowler@draconx.ca>
Date: Fri, 29 Jul 2016 12:43:11 -0400
Message-ID: <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com>
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,

On 2015-10-13, Nick Bowler <nbowler@draconx.ca> wrote:
> On 2015-10-13, Jeff Layton <jlayton@poochiereds.net> wrote:
>> On Mon, 12 Oct 2015 23:01:36 -0400
>> Nick Bowler <nbowler@draconx.ca> wrote:
>>> On 2015-10-12 15:46 -0400, J. Bruce Fields wrote:
>>> > On Mon, Oct 12, 2015 at 03:25:38PM -0400, bfields wrote:
>>> > > On Mon, Oct 12, 2015 at 12:48:56PM -0400, Nick Bowler wrote:
[...]
>>> > > > the failing syscall seems to be:
>>> > > >
>>> > > >   fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET,
>>> > > > start=1073741824, len=1}) = -1 EIO (Input/output error)
>>> > > >
>>> > > > When the issue occurs, the client dmesg log is full of messages of
>>> > > > the form:
>>> > > >
>>> > > >   [3441972.381211] NFS: v4 server returned a bad sequence-id error
>>> > > > on an unconfirmed sequence ffff88007612ae20!
>>> > > >
>>> > > > There are no unusual messages on the server.
>>> [...]
>> Ok, makes sense. The log shows that it occurred in a fcntl call, so
>> it's probably this from lookup_or_create_lock_state:
>>
>>         lo = find_lockowner_str(cl, &lock->lk_new_owner);
>>         if (!lo) {
>>                 strhashval = ownerstr_hashval(&lock->lk_new_owner);
>>                 lo = alloc_init_lock_stateowner(strhashval, cl, ost,
>> lock);
>>                 if (lo == NULL)
>>                         return nfserr_jukebox;
>>         } else {
>>                 /* with an existing lockowner, seqids must be the same */
>>                 status = nfserr_bad_seqid;
>>                 if (!cstate->minorversion &&
>>                     lock->lk_new_lock_seqid != lo->lo_owner.so_seqid)
>>                         goto out;
>>         }
>>
>> ...so we found an existing lockowner, but the seqid in the call is
>> wrong. It seems like the client ought to try to recover in this case,
>> but I don't see where it handles BAD_SEQID errors in the locking code.
[...]
>> In any case, the question now is whether this is a client or server
>> bug. What would tell us that is a network capture of the NFS traffic
>> between client and server at the time that this occurs. Would it be
>> possible to collect one? If so, then let Bruce and I know and we can
>> figure out a way to share it privately.

Hi guys,

Unfortunately I did not manage to perform a network capture last time
due to power loss.  I did not hit this issue again until yesterday (~9
months later), this time after 45 days of uptime.

Kernel versions now are: 4.5.1 on the server, and 4.4.3 on the client.

Since it's now in a failing state again (this situation persists until
a reboot of the client), I captured with strace and tcpdump (on both
client and server) when attempting to start gmpc, the result is quite
small (just 30 packets).  Will that be helpful?

Thanks,
  Nick
