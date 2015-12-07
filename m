Return-Path: <jlayton@poochiereds.net>
Date: Mon, 7 Dec 2015 14:18:59 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        "J. Bruce Fields"
 <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 02/10] NFS: Move the flock open mode check into
 nfs_flock()
Message-ID: <20151207141859.0cb9ae2e@tlielax.poochiereds.net>
In-Reply-To: <20151207184036.GA28959@infradead.org>
References: <cover.1449503713.git.bcodding@redhat.com>
	<cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com>
	<20151207184036.GA28959@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Dec 2015 10:40:36 -0800
Christoph Hellwig <hch@infradead.org> wrote:

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

IIRC, flock doesn't require this check. You can (for instance) open a
file for read and lock it for write. POSIX locks (and NFSv4 locks, by
extension) don't allow that. Since we're mapping flock locks onto v4
locks here, we have to do that check in the NFS code.

-- 
Jeff Layton <jlayton@poochiereds.net>
