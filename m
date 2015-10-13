Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34278 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbbJMMyF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 08:54:05 -0400
Received: by oiak8 with SMTP id k8so8737875oia.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 05:54:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151013065225.44c5581d@synchrony.poochiereds.net>
References: <20151012164846.GA5017@draconx.ca>
	<20151012192538.GG28755@fieldses.org>
	<20151012194647.GJ28755@fieldses.org>
	<20151013030136.GA7081@draconx.ca>
	<20151013065225.44c5581d@synchrony.poochiereds.net>
Date: Tue, 13 Oct 2015 08:54:05 -0400
Message-ID: <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com>
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
From: Nick Bowler <nbowler@draconx.ca>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2015-10-13, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Mon, 12 Oct 2015 23:01:36 -0400
> Nick Bowler <nbowler@draconx.ca> wrote:
>> On 2015-10-12 15:46 -0400, J. Bruce Fields wrote:
>> > On Mon, Oct 12, 2015 at 03:25:38PM -0400, bfields wrote:
>> > > On Mon, Oct 12, 2015 at 12:48:56PM -0400, Nick Bowler wrote:
>> > > > I'm having a problem where, eventually, the nfs-mounted home
>> > > > directory on one of my machines starts failing in a kind of weird
>> > > > way.  The issue appears to affect only sqlite; I have two
>> > > > applications that I know of which use it:
>> > > >
>> > > >   - Firefox, where the symptom is that the browser just hangs
>> > > >     randomly,
>> > > >   - gmpc, which crashes immediately on startup with I/O error.
>> > > >
>> > > > Once the issue occurs these applications remain permanently broken.
>> > > > Since the latter is easier to test, I can run it in strace, and the
>> > > > failing syscall seems to be:
>> > > >
>> > > >   fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET,
>> > > > start=1073741824, len=1}) = -1 EIO (Input/output error)
>> > > >
>> > > > When the issue occurs, the client dmesg log is full of messages of
>> > > > the form:
>> > > >
>> > > >   [3441972.381211] NFS: v4 server returned a bad sequence-id error
>> > > > on an unconfirmed sequence ffff88007612ae20!
>> > > >
>> > > > There are no unusual messages on the server.
>> [...]
> Ok, makes sense. The log shows that it occurred in a fcntl call, so
> it's probably this from lookup_or_create_lock_state:
>
>         lo = find_lockowner_str(cl, &lock->lk_new_owner);
>         if (!lo) {
>                 strhashval = ownerstr_hashval(&lock->lk_new_owner);
>                 lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
>                 if (lo == NULL)
>                         return nfserr_jukebox;
>         } else {
>                 /* with an existing lockowner, seqids must be the same */
>                 status = nfserr_bad_seqid;
>                 if (!cstate->minorversion &&
>                     lock->lk_new_lock_seqid != lo->lo_owner.so_seqid)
>                         goto out;
>         }
>
> ...so we found an existing lockowner, but the seqid in the call is
> wrong. It seems like the client ought to try to recover in this case,
> but I don't see where it handles BAD_SEQID errors in the locking code.
> What kernel versions are the client and server running here?

It was in my original mail but got snipped (by me).  The client is
running Linux 4.2.  The server is running Linux 4.1.4.  But that's
just what they're running right now; I've been seeing this issue
for a while now and both machines have been updated several times.

> In any case, the question now is whether this is a client or server
> bug. What would tell us that is a network capture of the NFS traffic
> between client and server at the time that this occurs. Would it be
> possible to collect one? If so, then let Bruce and I know and we can
> figure out a way to share it privately.

This should be possible.

> In the meantime, you may want to consider switching to NFSv4.1+. It
> really is a superior protocol to v4.0 as it allows more stateful
> operations to run in parallel and would likely sidestep this problem.

Certainly something to look into!
