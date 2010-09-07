Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51296 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755475Ab0IGWXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 18:23:44 -0400
Date: Wed, 8 Sep 2010 08:23:36 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
Message-ID: <20100908082336.3efda031@notabene>
In-Reply-To: <1283869039.4291.16.camel@heimdal.trondhjem.org>
References: <4C84DFA7.7050507@suse.de>
	<1283869039.4291.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 07 Sep 2010 10:17:19 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2010-09-06 at 18:03 +0530, Suresh Jayaraman wrote:
> > NFS clients since 2.6.12 support flock()locks by emulating the
> > BSD-style locks in terms of POSIX byte range locks. So the NFS client
> > does not allow to lock the same file using both flock() and fcntl
> > byte-range locks.
> > 
> > For some Windows applications which seem to use both share mode locks
> > (flock()) and fcntl byte range locks sequentially on the same file,
> > the locking is failing as the lock has already been acquired. i.e. the
> > flock mapped as posix locks collide with actual byte range locks from
> > the same process. The problem was observed on a setup with Windows
> > clients accessing Excel files on a Samba exported share which is
> > originally a NFS mount from a NetApp filer. Since kernels < 2.6.12 does
> > not support flock, what was working (as flock locks were local) in
> > older kernels is not working with newer kernels.
> > 
> > This could be seen as a bug in the implementation of the windows
> > application or a NFS client regression, but that is debatable.
> > In the spirit of not breaking existing setups, this patch adds mount
> > options "flock=local" that enables older flock behavior and
> > "flock=fcntl" that allows the current flock behavior.
> 
> So instead of having a special option for flock only, what say we rather
> introduce an option of the form
> 
>   -olocal_lock=
> 
> which can take the values 'none', 'flock', 'fcntl' (or 'posix'?) and
> 'all'?

I observe that the NLM protocol has support for 'share' reservations.
Requesting 'access == READ, mode==DENY_WRITE' is like a shared lock,
and 'access = WRITE, mode== DENY_READ_WRITE' is like an exclusive lock.

As samba maps theh share reservations into flock locks, it could make sense
for NFS to (optionally) map flock locks into share reservations.

The current Linux nfsd handles contention between these reservations entirely
internally, but it could conceivably grow an option to map them into flock
lock, just like samba does.

If this were at all a possible future direction, I would like to ensure that
option names chosen now allowed for that extension.
 flock=local and flock=fcntl naturally extends to flock=share

local_lock= doesn't really extend ... unless shared_lock=flock, but that
seems a bit backwards.

Is that a direction we could ever want to go?

NeilBrown
