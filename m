Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932296AbbLGTNt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 14:13:49 -0500
Date: Mon, 7 Dec 2015 14:13:47 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 02/10] NFS: Move the flock open mode check into
 nfs_flock()
In-Reply-To: <20151207184036.GA28959@infradead.org>
Message-ID: <alpine.OSX.2.19.9992.1512071359370.60717@planck.local>
References: <cover.1449503713.git.bcodding@redhat.com> <cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com> <20151207184036.GA28959@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Dec 2015, Christoph Hellwig wrote:

> On Mon, Dec 07, 2015 at 11:26:01AM -0500, Benjamin Coddington wrote:
> > We only need to check lock exclusive/shared types against open mode when
> > flock() is used on NFS, so move it into the flock-specific path instead of
> > checking it for all locks.
> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfs/file.c     |   15 +++++++++++++++
> >  fs/nfs/nfs4proc.c |   13 -------------
> >  2 files changed, 15 insertions(+), 13 deletions(-)
> >
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 93e2364..ec16abc 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -893,6 +893,21 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
> >  	/* We're simulating flock() locks using posix locks on the server */
> >  	if (fl->fl_type == F_UNLCK)
> >  		return do_unlk(filp, cmd, fl, is_local);
> > +
> > +	/*
> > +	 * Don't rely on the VFS having checked the file open mode,
> > +	 * since it won't do this for flock() locks.
> > +	 */
>
> As this is only called for flock the comment doesn't make sense.  And
> maybe it's also time to ask why the VFS doesn't do this, as I'd expect
> it to perform this instead of every file system.

I can fixup the comment for clarity as I just moved this chunk over.

I'm not aware that flock() has ever had this check, but posix locks requires
it.  My understanding is that since NFS may simulate flock() with posix
locking, the check is necessary for NFS.

I can only speculate what applications out there may be using mis-matched
file modes and flock operations.  Changing that behavior seems beyond the
scope of this work.

Ben
