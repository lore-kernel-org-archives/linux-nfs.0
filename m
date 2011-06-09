Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43846 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416Ab1FIQhW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 12:37:22 -0400
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 09 Jun 2011 12:37:32 -0400
In-Reply-To: <4DEEDECF.4090104@panasas.com>
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
	 <4DEEDECF.4090104@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307637452.20245.11.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-06-07 at 22:30 -0400, Benny Halevy wrote: 
> On 2011-06-06 18:32, Trond Myklebust wrote:
> > We need to ensure that the layouts are set up before we can decide to
> > coalesce requests. To do so, we want to further split up the struct
> > nfs_pageio_descriptor operations into an initialisation callback, a
> > coalescing test callback, and a 'do i/o' callback.
> > 
> > This patch cleans up the existing callback methods before adding the
> > 'initialisation' callback.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  fs/nfs/nfs4filelayout.c      |   15 +++++++++++++--
> >  fs/nfs/objlayout/objio_osd.c |   13 ++++++++++++-
> >  fs/nfs/pagelist.c            |   12 +++++-------
> >  fs/nfs/pnfs.h                |   29 ++++++++++++++++++++++-------
> >  fs/nfs/read.c                |   42 +++++++++++++++++++++++++++++++-----------
> >  fs/nfs/write.c               |   27 +++++++++++++++++++++++----
> >  include/linux/nfs_page.h     |   17 ++++++++++++++---
> >  7 files changed, 120 insertions(+), 35 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> > index 4269088..e9b9b82 100644
> > --- a/fs/nfs/nfs4filelayout.c
> > +++ b/fs/nfs/nfs4filelayout.c
> > @@ -654,7 +654,7 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
> >   * return true  : coalesce page
> >   * return false : don't coalesce page
> >   */
> > -bool
> > +static bool
> >  filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> >  		   struct nfs_page *req)
> >  {
> > @@ -676,6 +676,16 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> >  	return (p_stripe == r_stripe);
> >  }
> >  
> > +static const struct nfs_pageio_ops filelayout_pg_read_ops = {
> > +	.pg_test = filelayout_pg_test,
> > +	.pg_doio = nfs_generic_pg_readpages,
> > +};
> > +
> > +static const struct nfs_pageio_ops filelayout_pg_write_ops = {
> > +	.pg_test = filelayout_pg_test,
> > +	.pg_doio = nfs_generic_pg_writepages,
> > +};
> > +
> >  static bool filelayout_mark_pnfs_commit(struct pnfs_layout_segment *lseg)
> >  {
> >  	return !FILELAYOUT_LSEG(lseg)->commit_through_mds;
> > @@ -873,7 +883,8 @@ static struct pnfs_layoutdriver_type filelayout_type = {
> >  	.owner			= THIS_MODULE,
> >  	.alloc_lseg		= filelayout_alloc_lseg,
> >  	.free_lseg		= filelayout_free_lseg,
> > -	.pg_test		= filelayout_pg_test,
> > +	.pg_read_ops		= &filelayout_pg_read_ops,
> > +	.pg_write_ops		= &filelayout_pg_write_ops,
> >  	.mark_pnfs_commit	= filelayout_mark_pnfs_commit,
> >  	.choose_commit_list	= filelayout_choose_commit_list,
> >  	.commit_pagelist	= filelayout_commit_pagelist,
> > diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> > index 4c41a60..31088f3 100644
> > --- a/fs/nfs/objlayout/objio_osd.c
> > +++ b/fs/nfs/objlayout/objio_osd.c
> > @@ -1008,6 +1008,16 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
> >  			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
> >  }
> >  
> > +static const struct nfs_pageio_ops objio_pg_read_ops = {
> > +	.pg_test = objio_pg_test,
> > +	.pg_doio = nfs_generic_pg_readpages,
> > +};
> > +
> > +static const struct nfs_pageio_ops objio_pg_write_ops = {
> > +	.pg_test = objio_pg_test,
> > +	.pg_doio = nfs_generic_pg_writepages,
> 
> Hmm, for the non-files layouts we should ignore the server's wsize
> for pnfs I/O.
> 
> How about using the follwing?
> 
> int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
> {
> 	return desc->pg_lseg ? nfs_pagein_one(desc) : nfs_generic_pg_readpages(desc);
> }
> EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
> 
> int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
> {
> 	return desc->pg_lseg ? nfs_flush_one(desc) : nfs_generic_pg_writepages(desc);
> }
> EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
> 
> Benny

I'd prefer to have the objects and blocks set desc->pg_bsize correctly
according to their requirements. Otherwise, some of the tests make no
sense...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

