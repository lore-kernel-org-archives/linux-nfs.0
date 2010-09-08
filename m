Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53415 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab0IHAEv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 20:04:51 -0400
Date: Wed, 8 Sep 2010 10:04:43 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
Message-ID: <20100908100443.55dee7e0@notabene>
In-Reply-To: <1283899362.9097.42.camel@heimdal.trondhjem.org>
References: <4C84DFA7.7050507@suse.de>
	<1283869039.4291.16.camel@heimdal.trondhjem.org>
	<20100908082336.3efda031@notabene>
	<1283899362.9097.42.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 07 Sep 2010 18:42:42 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2010-09-08 at 08:23 +1000, Neil Brown wrote:
> > On Tue, 07 Sep 2010 10:17:19 -0400
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Mon, 2010-09-06 at 18:03 +0530, Suresh Jayaraman wrote:
> > > > NFS clients since 2.6.12 support flock()locks by emulating the
> > > > BSD-style locks in terms of POSIX byte range locks. So the NFS client
> > > > does not allow to lock the same file using both flock() and fcntl
> > > > byte-range locks.
> > > > 
> > > > For some Windows applications which seem to use both share mode locks
> > > > (flock()) and fcntl byte range locks sequentially on the same file,
> > > > the locking is failing as the lock has already been acquired. i.e. the
> > > > flock mapped as posix locks collide with actual byte range locks from
> > > > the same process. The problem was observed on a setup with Windows
> > > > clients accessing Excel files on a Samba exported share which is
> > > > originally a NFS mount from a NetApp filer. Since kernels < 2.6.12 does
> > > > not support flock, what was working (as flock locks were local) in
> > > > older kernels is not working with newer kernels.
> > > > 
> > > > This could be seen as a bug in the implementation of the windows
> > > > application or a NFS client regression, but that is debatable.
> > > > In the spirit of not breaking existing setups, this patch adds mount
> > > > options "flock=local" that enables older flock behavior and
> > > > "flock=fcntl" that allows the current flock behavior.
> > > 
> > > So instead of having a special option for flock only, what say we rather
> > > introduce an option of the form
> > > 
> > >   -olocal_lock=
> > > 
> > > which can take the values 'none', 'flock', 'fcntl' (or 'posix'?) and
> > > 'all'?
> > 
> > I observe that the NLM protocol has support for 'share' reservations.
> > Requesting 'access == READ, mode==DENY_WRITE' is like a shared lock,
> > and 'access = WRITE, mode== DENY_READ_WRITE' is like an exclusive lock.
> > 
> > As samba maps theh share reservations into flock locks, it could make sense
> > for NFS to (optionally) map flock locks into share reservations.
> > 
> > The current Linux nfsd handles contention between these reservations entirely
> > internally, but it could conceivably grow an option to map them into flock
> > lock, just like samba does.
> > 
> > If this were at all a possible future direction, I would like to ensure that
> > option names chosen now allowed for that extension.
> >  flock=local and flock=fcntl naturally extends to flock=share
> > 
> > local_lock= doesn't really extend ... unless shared_lock=flock, but that
> > seems a bit backwards.
> > 
> > Is that a direction we could ever want to go?
> 
> I'd be against it for several reasons:
> 
>       * Ordinary flock locks are advisory, whereas deny share
>         reservations are special mandatory locks. In fact if you look at
>         the Samba implementation, it uses a special 'LOCK_MAND' flag in
>         addition to the usual flock() flag.
>       * DENY_WRITE and DENY_BOTH share reservation modes break unlink()
>         behaviour on posix systems.
>       * Once the file has been opened with a given access mode, my
>         interpretation of the protocol is that you cannot change the
>         deny mode without closing any conflicting shares first. (Section
>         8.9 says: This checking of share reservations on OPEN is done
>         with no exception for an existing OPEN for the same open_owner.)

This all seems to assume NFSv4 rather than NFSv3 and NLM - I don't think NLM
is nearly that specific on how shares should work and doesn't mention 'open'
at all.

However I can understand your desire to implement it the same way for v4 as
v3 and in that case your arguments stand.

My other idea was for flock to just lock one byte of the file at a very high
offset, so it would interact properly with other flocks but almost never with
any fcntl lock.  That would probably have other problems though....

I guess 'local' or 'fcntl' are really the only options for flock.

oh well...

NeilBrown

> 
> Cheers
>   Trond

