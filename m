Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648Ab0J1OKs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 10:10:48 -0400
Date: Thu, 28 Oct 2010 10:10:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [bz 192] Fixed Regression in NFS Direct I/O path
Message-ID: <20101028101044.71d81563@tlielax.poochiereds.net>
In-Reply-To: <1288274603.3194.34.camel@heimdal.trondhjem.org>
References: <1288268274-9444-1-git-send-email-steved@redhat.com>
	<20101028083435.35c990f0@tlielax.poochiereds.net>
	<20101028095507.3a11ee17@tlielax.poochiereds.net>
	<1288274603.3194.34.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 28 Oct 2010 10:03:23 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2010-10-28 at 09:55 -0400, Jeff Layton wrote:
> > On Thu, 28 Oct 2010 08:34:35 -0400
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > On Thu, 28 Oct 2010 08:17:54 -0400
> > > Steve Dickson <steved@redhat.com> wrote:
> > > 
> > > > A typo, introduced by commit f11ac8db, in the nfs_direct_write()
> > > > routine causes writes with O_DIRECT set to fail with a ENOMEM error.
> > > > 
> > > > Found-by: Jeff Layton <jlayton@redhat.com>
> > > > Signed-off-by: Steve Dickson <steved@redhat.com>
> > > > ---
> > > >  fs/nfs/direct.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> > > > index 064a809..84d3c8b 100644
> > > > --- a/fs/nfs/direct.c
> > > > +++ b/fs/nfs/direct.c
> > > > @@ -873,7 +873,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
> > > >  	dreq->inode = inode;
> > > >  	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
> > > >  	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
> > > > -	if (dreq->l_ctx != NULL)
> > > > +	if (dreq->l_ctx == NULL)
> > > >  		goto out_release;
> > > >  	if (!is_sync_kiocb(iocb))
> > > >  		dreq->iocb = iocb;
> > > 
> > > Also, since get_lock_context holds references, this prevents the fs
> > > from being unmounted. It looks like this bug is in 2.6.36 too, so this
> > > may be suitable for stable series as well.
> > > 
> > 
> > Oh...and another thing I noticed too...
> > 
> > nfs_create_request doesn't check for a NULL return from
> > nfs_get_lock_context. If it ever does, it looks like that will likely
> > trickle down to an oops in encode_stateid.
> > 
> > It might be good to fix that as well. Maybe something like this
> > compile-tested-only patch?
> > 
> > --------------------[snip]---------------------
> > 
> > nfs: handle lock context allocation failures in nfs_create_request
> > 
> > nfs_get_lock_context can return NULL on an allocation failure.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/pagelist.c |    8 +++++++-
> >  1 files changed, 7 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > index 9194902..137b549 100644
> > --- a/fs/nfs/pagelist.c
> > +++ b/fs/nfs/pagelist.c
> > @@ -65,6 +65,13 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
> >  	if (req == NULL)
> >  		return ERR_PTR(-ENOMEM);
> >  
> > +	/* get lock context early so we can deal with alloc failures */
> > +	req->wb_lock_context = nfs_get_lock_context(ctx);
> > +	if (req->wb_lock_context == NULL) {
> > +		nfs_page_free(req);
> > +		return ERR_PTR(-ENOMEM);
> > +	}
> > +
> >  	/* Initialize the request struct. Initially, we assume a
> >  	 * long write-back delay. This will be adjusted in
> >  	 * update_nfs_request below if the region is not locked. */
> > @@ -79,7 +86,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
> >  	req->wb_pgbase	= offset;
> >  	req->wb_bytes   = count;
> >  	req->wb_context = get_nfs_open_context(ctx);
> > -	req->wb_lock_context = nfs_get_lock_context(ctx);
> >  	kref_init(&req->wb_kref);
> >  	return req;
> >  }
> 
> Yup. That looks as if it should be required...
> 

Actually...Steve noticed this yesterday. I'll resend as an "official"
patch separate from this thread...

-- 
Jeff Layton <jlayton@redhat.com>
