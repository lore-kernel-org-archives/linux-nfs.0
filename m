Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36223 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272AbbJMKw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 06:52:28 -0400
Received: by qgx61 with SMTP id 61so10170659qgx.3
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 03:52:28 -0700 (PDT)
Date: Tue, 13 Oct 2015 06:52:24 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Nick Bowler <nbowler@draconx.ca>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
Message-ID: <20151013065225.44c5581d@synchrony.poochiereds.net>
In-Reply-To: <20151013030136.GA7081@draconx.ca>
References: <20151012164846.GA5017@draconx.ca>
	<20151012192538.GG28755@fieldses.org>
	<20151012194647.GJ28755@fieldses.org>
	<20151013030136.GA7081@draconx.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 12 Oct 2015 23:01:36 -0400
Nick Bowler <nbowler@draconx.ca> wrote:

> On 2015-10-12 15:46 -0400, J. Bruce Fields wrote:
> > On Mon, Oct 12, 2015 at 03:25:38PM -0400, bfields wrote:
> > > On Mon, Oct 12, 2015 at 12:48:56PM -0400, Nick Bowler wrote:
> > > > I'm having a problem where, eventually, the nfs-mounted home directory
> > > > on one of my machines starts failing in a kind of weird way.  The issue
> > > > appears to affect only sqlite; I have two applications that I know of
> > > > which use it:
> > > > 
> > > >   - Firefox, where the symptom is that the browser just hangs randomly,
> > > >   - gmpc, which crashes immediately on startup with I/O error.
> > > > 
> > > > Once the issue occurs these applications remain permanently broken.
> > > > Since the latter is easier to test, I can run it in strace, and the
> > > > failing syscall seems to be:
> > > > 
> > > >   fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}) = -1 EIO (Input/output error)
> > > > 
> > > > When the issue occurs, the client dmesg log is full of messages of the form:
> > > > 
> > > >   [3441972.381211] NFS: v4 server returned a bad sequence-id error on an unconfirmed sequence ffff88007612ae20!
> > > > 
> > > > There are no unusual messages on the server.
> [...]
> > > I wonder if there's some way to make this reproduce more quickly, for
> > > example by running something that makes more aggressive use of sqlite,
> > > or running multiple copies of such a thing simultaneously.  Might be
> > > interesting to know what the pattern of file opens and locking looks
> > > like (so stracing one of those applications might help).
> 
> I could try doing something like using the sqlite3 command-line tool to
> do a lot of database operations, and hope I can reproduce.  I'd have to
> reboot to test though.
> 
> I attached a full strace log (gzipped) from a failing process.  The
> command run is:
> 
>   sqlite3 newfile.sqlite vacuum
> 
> which fails in a similar manner to gmpc.
> 
> > Oh, also I forgot to ask what version of the NFS protocol you're using
> > (4.0, 4.1, or 4.2).
> 
> Looks like 4.0:
> 
>   athena:/home on /home type nfs4 (rw,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=krb5,clientaddr=192.168.0.207,local_lock=none,addr=192.168.0.10)
> 
> Cheers,
>   Nick

Ok, makes sense. The log shows that it occurred in a fcntl call, so
it's probably this from lookup_or_create_lock_state:

        lo = find_lockowner_str(cl, &lock->lk_new_owner);
        if (!lo) {
                strhashval = ownerstr_hashval(&lock->lk_new_owner);
                lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
                if (lo == NULL)
                        return nfserr_jukebox;
        } else {
                /* with an existing lockowner, seqids must be the same */
                status = nfserr_bad_seqid;
                if (!cstate->minorversion &&
                    lock->lk_new_lock_seqid != lo->lo_owner.so_seqid)
                        goto out;
        }

...so we found an existing lockowner, but the seqid in the call is
wrong. It seems like the client ought to try to recover in this case,
but I don't see where it handles BAD_SEQID errors in the locking code.
What kernel versions are the client and server running here?

In any case, the question now is whether this is a client or server
bug. What would tell us that is a network capture of the NFS traffic
between client and server at the time that this occurs. Would it be
possible to collect one? If so, then let Bruce and I know and we can
figure out a way to share it privately.

In the meantime, you may want to consider switching to NFSv4.1+. It
really is a superior protocol to v4.0 as it allows more stateful
operations to run in parallel and would likely sidestep this problem.

-- 
Jeff Layton <jlayton@poochiereds.net>
