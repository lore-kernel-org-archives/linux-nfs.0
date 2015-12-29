Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbbL2NeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Dec 2015 08:34:07 -0500
Date: Tue, 29 Dec 2015 08:34:04 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jeff.layton@primarydata.com>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 02/10] NFS: Move the flock open mode check into
 nfs_flock()
In-Reply-To: <20151228143721.7fca2516@tlielax.poochiereds.net>
Message-ID: <alpine.OSX.2.19.9992.1512290832170.87866@planck.local>
References: <cover.1451319354.git.bcodding@redhat.com> <7d9792cc96113c508fb45e5aa88f8afc40c9f00b.1451319354.git.bcodding@redhat.com> <20151228143721.7fca2516@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Dec 2015, Jeff Layton wrote:

> On Mon, 28 Dec 2015 11:27:58 -0500
> Benjamin Coddington <bcodding@redhat.com> wrote:
>
> > We only need to check lock exclusive/shared types against open mode when
> > flock() is used on NFS, so move it into the flock-specific path instead of
> > checking it for all locks.
> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfs/file.c     |   16 ++++++++++++++++
> >  fs/nfs/nfs4proc.c |   13 -------------
> >  2 files changed, 16 insertions(+), 13 deletions(-)
> >
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 93e2364..1e4804b 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -893,6 +893,22 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
> >  	/* We're simulating flock() locks using posix locks on the server */
> >  	if (fl->fl_type == F_UNLCK)
> >  		return do_unlk(filp, cmd, fl, is_local);
> > +
>
> nit: maybe make the above and below part of the same switch?

Ok, I will do that in a v4.

Ben

> > +	/*
> > +	 * VFS doesn't require the open mode to match a flock() lock's type.
> > +	 * NFS, however, may simulate flock() locking with posix locking which
> > +	 * requires the open mode to match the lock type.
> > +	 */
> > +	switch (fl->fl_type) {
> > +	case F_RDLCK:
> > +		if (!(filp->f_mode & FMODE_READ))
> > +			return -EBADF;
> > +		break;
> > +	case F_WRLCK:
> > +		if (!(filp->f_mode & FMODE_WRITE))
> > +			return -EBADF;
> > +	}
> > +
> >  	return do_setlk(filp, cmd, fl, is_local);
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_flock);
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 2231d7d..05ea1e1 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -6125,19 +6125,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
> >
> >  	if (state == NULL)
> >  		return -ENOLCK;
> > -	/*
> > -	 * Don't rely on the VFS having checked the file open mode,
> > -	 * since it won't do this for flock() locks.
> > -	 */
> > -	switch (request->fl_type) {
> > -	case F_RDLCK:
> > -		if (!(filp->f_mode & FMODE_READ))
> > -			return -EBADF;
> > -		break;
> > -	case F_WRLCK:
> > -		if (!(filp->f_mode & FMODE_WRITE))
> > -			return -EBADF;
> > -	}
> >
> >  	do {
> >  		status = nfs4_proc_setlk(state, cmd, request);
>
> Looks correct other than the nit above:
>
> Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
