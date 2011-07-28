Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab1G1Dwo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 23:52:44 -0400
Subject: RE: [PATCH v3 23/25] pnfsblock: use pageio_ops api
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: tao.peng@emc.com
Cc: rees@umich.edu, linux-nfs@vger.kernel.org, honey@citi.umich.edu
Date: Wed, 27 Jul 2011 23:52:44 -0400
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BF061890@MX09A.corp.emc.com>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-24-git-send-email-rees@umich.edu>
	 <1311797712.25645.27.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805BF061890@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311825164.5633.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 22:27 -0400, tao.peng@emc.com wrote: 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> > On Behalf Of Trond Myklebust
> > Sent: Thursday, July 28, 2011 4:15 AM
> > To: Jim Rees
> > Cc: linux-nfs@vger.kernel.org; peter honeyman
> > Subject: Re: [PATCH v3 23/25] pnfsblock: use pageio_ops api
> > 
> > On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote:
> > > From: Benny Halevy <bhalevy@panasas.com>
> > >
> > > [pnfsblock: use pnfs_generic_pg_init_read/write]
> > > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > > ---
> > >  fs/nfs/blocklayout/blocklayout.c |   14 ++++++++++++++
> > >  1 files changed, 14 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> > > index 22de05c..502d384 100644
> > > --- a/fs/nfs/blocklayout/blocklayout.c
> > > +++ b/fs/nfs/blocklayout/blocklayout.c
> > > @@ -762,6 +762,18 @@ bl_clear_layoutdriver(struct nfs_server *server)
> > >  	return 0;
> > >  }
> > >
> > > +static const struct nfs_pageio_ops bl_pg_read_ops = {
> > > +	.pg_init = pnfs_generic_pg_init_read,
> > > +	.pg_test = pnfs_generic_pg_test,
> > > +	.pg_doio = pnfs_generic_pg_readpages,
> > > +};
> > > +
> > > +static const struct nfs_pageio_ops bl_pg_write_ops = {
> > > +	.pg_init = pnfs_generic_pg_init_write,
> > > +	.pg_test = pnfs_generic_pg_test,
> > > +	.pg_doio = pnfs_generic_pg_writepages,
> > > +};
> > > +
> > >  static struct pnfs_layoutdriver_type blocklayout_type = {
> > >  	.id				= LAYOUT_BLOCK_VOLUME,
> > >  	.name				= "LAYOUT_BLOCK_VOLUME",
> > > @@ -775,6 +787,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
> > >  	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
> > >  	.set_layoutdriver		= bl_set_layoutdriver,
> > >  	.clear_layoutdriver		= bl_clear_layoutdriver,
> > > +	.pg_read_ops			= &bl_pg_read_ops,
> > > +	.pg_write_ops			= &bl_pg_write_ops,
> > >  };
> > >
> > How did this work previously?
> block layout used to use .pg_test interface in pnfs_layoutdriver_type but it got removed in the 3.0 merge window.

Right, but won't the entire blocks interface blow up in your face until
you merge this patch? If it just falls back to write through MDS, then
I'm fine, but my worry is that someone who git bisects in order to track
down a patch may end up seeing new panics due to the lack of a
well-defined struct nfs_pageio_ops in blocks.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

