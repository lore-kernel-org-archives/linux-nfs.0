Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:57188 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbcCKJYQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Mar 2016 04:24:16 -0500
Date: Fri, 11 Mar 2016 10:24:14 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] nfsd: add SCSI layout support
Message-ID: <20160311092414.GE28498@lst.de>
References: <1457120777-30687-1-git-send-email-hch@lst.de> <1457120777-30687-5-git-send-email-hch@lst.de> <20160310222618.GA4210@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160310222618.GA4210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 10, 2016 at 05:26:18PM -0500, J. Bruce Fields wrote:
> On Fri, Mar 04, 2016 at 08:46:17PM +0100, Christoph Hellwig wrote:
> > This is a simple extension to the block layout driver to use SCSI
> > persistent reservations for access control and fencing, as well as
> > SCSI VPD pages for device identification.
> > 
> > For this we need to pass the nfs4_client to the proc_getdeviceinfo method
> > to generate the reservation key, and add a new fence_client method
> > to allow for fence actions in the layout driver.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  Documentation/filesystems/nfs/pnfs-scsi-server.txt |  22 ++
> >  fs/nfsd/Kconfig                                    |  13 +
> >  fs/nfsd/Makefile                                   |   1 +
> >  fs/nfsd/blocklayout.c                              | 298 ++++++++++++++++++---
> >  fs/nfsd/blocklayoutxdr.c                           |  65 ++++-
> >  fs/nfsd/blocklayoutxdr.h                           |  14 +
> >  fs/nfsd/nfs4layouts.c                              |  27 +-
> >  fs/nfsd/nfs4proc.c                                 |   6 +-
> >  fs/nfsd/pnfs.h                                     |   6 +
> >  fs/xfs/Makefile                                    |   1 +
> >  fs/xfs/xfs_pnfs.h                                  |   2 +-
> >  11 files changed, 407 insertions(+), 48 deletions(-)
> >  create mode 100644 Documentation/filesystems/nfs/pnfs-scsi-server.txt
> > 
> > diff --git a/Documentation/filesystems/nfs/pnfs-scsi-server.txt b/Documentation/filesystems/nfs/pnfs-scsi-server.txt
> > new file mode 100644
> > index 0000000..4150979
> > --- /dev/null
> > +++ b/Documentation/filesystems/nfs/pnfs-scsi-server.txt
> > @@ -0,0 +1,22 @@
> > +
> > +pNFS SCSI layout server user guide
> > +==================================
> > +
> > +This document describes support for pNFS SCSI layouts in the Linux NFS server.
> > +With pNFS SCSI layouts, the NFS server acts as Metadata Server (MDS) for pNFS,
> > +which in addition to handling all the metadata access to the NFS export,
> > +also hands out layouts to the clients so that they can directly access the
> > +underlying SCSI LUNs that are shared with the client.
> > +
> > +To use pNFS SCSI layouts with with the Linux NFS server, the exported file
> > +system needs to support the pNFS SCSI layouts (currently just XFS), and the
> > +file system must sit on a SCSI LUN that is accessible to the clients in
> > +addition to the MDS.  As of now the file system needs to sit directly on the
> > +exported LUN, striping or concatenation of LUNs on the MDS and clients
> > +is not supported yet.
> > +
> > +On the server, pNFS SCSI volume support is automatically enabled if the
> > +file system is exported using the "pnfs" option and the underlying SCSI
> > +device support persistent reservations.  On the client make sure the kernel
> > +has the CONFIG_PNFS_BLOCK option enabled, and the file system is mounted
> > +using the NFSv4.1 protocol version (mount -o vers=4.1).
> > diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> > index eb70d91..a30a313 100644
> > --- a/fs/nfsd/Kconfig
> > +++ b/fs/nfsd/Kconfig
> > @@ -98,6 +98,19 @@ config NFSD_BLOCKLAYOUT
> >  
> >  	  If unsure, say N.
> >  
> > +config NFSD_SCSILAYOUT
> > +	bool "NFSv4.1 server support for pNFS SCSI layouts"
> > +	depends on NFSD_V4
> > +	select NFSD_PNFS
> > +	help
> > +	  This option enables support for the exporting pNFS SCSI layouts
> > +	  in the kernel's NFS server. The pNFS SCSI layout enables NFS
> > +	  clients to directly perform I/O to SCSI devices accesible to both
> > +	  the server and the clients.  See draft-ietf-nfsv4-scsi-layout for
> > +	  more details.
> > +
> > +	  If unsure, say N.
> > +
> >  config NFSD_V4_SECURITY_LABEL
> >  	bool "Provide Security Label support for NFSv4 server"
> >  	depends on NFSD_V4 && SECURITY
> > diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
> > index 679cdc6..3ae5f3c 100644
> > --- a/fs/nfsd/Makefile
> > +++ b/fs/nfsd/Makefile
> > @@ -19,3 +19,4 @@ nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
> >  			   nfs4acl.o nfs4callback.o nfs4recover.o
> >  nfsd-$(CONFIG_NFSD_PNFS) += nfs4layouts.o
> >  nfsd-$(CONFIG_NFSD_BLOCKLAYOUT) += blocklayout.o blocklayoutxdr.o
> > +nfsd-$(CONFIG_NFSD_SCSILAYOUT) += blocklayout.o blocklayoutxdr.o
> > diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> > index c29d942..0e87e3e 100644
> > --- a/fs/nfsd/blocklayout.c
> > +++ b/fs/nfsd/blocklayout.c
> > @@ -1,11 +1,14 @@
> >  /*
> > - * Copyright (c) 2014 Christoph Hellwig.
> > + * Copyright (c) 2014-2016 Christoph Hellwig.
> >   */
> >  #include <linux/exportfs.h>
> >  #include <linux/genhd.h>
> >  #include <linux/slab.h>
> > +#include <linux/pr.h>
> >  
> >  #include <linux/nfsd/debug.h>
> > +#include <scsi/scsi_proto.h>
> > +#include <scsi/scsi_common.h>
> >  
> >  #include "blocklayoutxdr.h"
> >  #include "pnfs.h"
> > @@ -13,37 +16,6 @@
> >  #define NFSDDBG_FACILITY	NFSDDBG_PNFS
> >  
> >  
> > -static int
> > -nfsd4_block_get_device_info_simple(struct super_block *sb,
> > -		struct nfsd4_getdeviceinfo *gdp)
> > -{
> > -	struct pnfs_block_deviceaddr *dev;
> > -	struct pnfs_block_volume *b;
> > -
> > -	dev = kzalloc(sizeof(struct pnfs_block_deviceaddr) +
> > -		      sizeof(struct pnfs_block_volume), GFP_KERNEL);
> > -	if (!dev)
> > -		return -ENOMEM;
> > -	gdp->gd_device = dev;
> > -
> > -	dev->nr_volumes = 1;
> > -	b = &dev->volumes[0];
> > -
> > -	b->type = PNFS_BLOCK_VOLUME_SIMPLE;
> > -	b->simple.sig_len = PNFS_BLOCK_UUID_LEN;
> > -	return sb->s_export_op->get_uuid(sb, b->simple.sig, &b->simple.sig_len,
> > -			&b->simple.offset);
> > -}
> > -
> > -static __be32
> > -nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
> > -		struct nfsd4_getdeviceinfo *gdp)
> > -{
> > -	if (sb->s_bdev != sb->s_bdev->bd_contains)
> > -		return nfserr_inval;
> > -	return nfserrno(nfsd4_block_get_device_info_simple(sb, gdp));
> > -}
> > -
> >  static __be32
> >  nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
> >  		struct nfsd4_layoutget *args)
> > @@ -141,20 +113,13 @@ out_layoutunavailable:
> >  }
> >  
> >  static __be32
> > -nfsd4_block_proc_layoutcommit(struct inode *inode,
> > -		struct nfsd4_layoutcommit *lcp)
> > +nfsd4_block_commit_blocks(struct inode *inode, struct nfsd4_layoutcommit *lcp,
> > +		struct iomap *iomaps, int nr_iomaps)
> >  {
> >  	loff_t new_size = lcp->lc_last_wr + 1;
> >  	struct iattr iattr = { .ia_valid = 0 };
> > -	struct iomap *iomaps;
> > -	int nr_iomaps;
> >  	int error;
> >  
> > -	nr_iomaps = nfsd4_block_decode_layoutupdate(lcp->lc_up_layout,
> > -			lcp->lc_up_len, &iomaps, 1 << inode->i_blkbits);
> > -	if (nr_iomaps < 0)
> > -		return nfserrno(nr_iomaps);
> > -
> >  	if (lcp->lc_mtime.tv_nsec == UTIME_NOW ||
> >  	    timespec_compare(&lcp->lc_mtime, &inode->i_mtime) < 0)
> >  		lcp->lc_mtime = current_fs_time(inode->i_sb);
> > @@ -172,6 +137,54 @@ nfsd4_block_proc_layoutcommit(struct inode *inode,
> >  	return nfserrno(error);
> >  }
> >  
> > +#ifdef CONFIG_NFSD_BLOCKLAYOUT
> > +static int
> > +nfsd4_block_get_device_info_simple(struct super_block *sb,
> > +		struct nfsd4_getdeviceinfo *gdp)
> > +{
> > +	struct pnfs_block_deviceaddr *dev;
> > +	struct pnfs_block_volume *b;
> > +
> > +	dev = kzalloc(sizeof(struct pnfs_block_deviceaddr) +
> > +		      sizeof(struct pnfs_block_volume), GFP_KERNEL);
> > +	if (!dev)
> > +		return -ENOMEM;
> > +	gdp->gd_device = dev;
> > +
> > +	dev->nr_volumes = 1;
> > +	b = &dev->volumes[0];
> > +
> > +	b->type = PNFS_BLOCK_VOLUME_SIMPLE;
> > +	b->simple.sig_len = PNFS_BLOCK_UUID_LEN;
> > +	return sb->s_export_op->get_uuid(sb, b->simple.sig, &b->simple.sig_len,
> > +			&b->simple.offset);
> > +}
> > +
> > +static __be32
> > +nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
> > +		struct nfs4_client *clp,
> > +		struct nfsd4_getdeviceinfo *gdp)
> > +{
> > +	if (sb->s_bdev != sb->s_bdev->bd_contains)
> > +		return nfserr_inval;
> > +	return nfserrno(nfsd4_block_get_device_info_simple(sb, gdp));
> > +}
> > +
> > +static __be32
> > +nfsd4_block_proc_layoutcommit(struct inode *inode,
> > +		struct nfsd4_layoutcommit *lcp)
> > +{
> > +	struct iomap *iomaps;
> > +	int nr_iomaps;
> > +
> > +	nr_iomaps = nfsd4_block_decode_layoutupdate(lcp->lc_up_layout,
> > +			lcp->lc_up_len, &iomaps, 1 << inode->i_blkbits);
> > +	if (nr_iomaps < 0)
> > +		return nfserrno(nr_iomaps);
> > +
> > +	return nfsd4_block_commit_blocks(inode, lcp, iomaps, nr_iomaps);
> > +}
> > +
> >  const struct nfsd4_layout_ops bl_layout_ops = {
> >  	/*
> >  	 * Pretend that we send notification to the client.  This is a blatant
> > @@ -190,3 +203,206 @@ const struct nfsd4_layout_ops bl_layout_ops = {
> >  	.encode_layoutget	= nfsd4_block_encode_layoutget,
> >  	.proc_layoutcommit	= nfsd4_block_proc_layoutcommit,
> >  };
> > +#endif /* CONFIG_NFSD_BLOCKLAYOUT */
> > +
> > +#ifdef CONFIG_NFSD_SCSILAYOUT
> > +static int nfsd4_scsi_identify_device(struct block_device *bdev,
> > +		struct pnfs_block_volume *b)
> > +{
> > +	struct request_queue *q = bdev->bd_disk->queue;
> > +	struct request *rq;
> > +	size_t bufflen = 252, len, id_len;
> > +	u8 *buf, *d, type, assoc;
> > +	int error;
> > +
> > +	buf = kzalloc(bufflen, GFP_KERNEL);
> > +	if (!buf)
> > +		return -ENOMEM;
> > +
> > +	rq = blk_get_request(q, READ, GFP_KERNEL);
> > +	if (IS_ERR(rq)) {
> > +		error = -ENOMEM;
> > +		goto out_free_buf;
> > +	}
> > +	blk_rq_set_block_pc(rq);
> > +
> > +	error = blk_rq_map_kern(q, rq, buf, bufflen, GFP_KERNEL);
> > +	if (error)
> > +		goto out_put_request;
> > +
> > +	rq->cmd[0] = INQUIRY;
> > +	rq->cmd[1] = 1;
> > +	rq->cmd[2] = 0x83;
> > +	rq->cmd[3] = bufflen >> 8;
> > +	rq->cmd[4] = bufflen & 0xff;
> > +	rq->cmd_len = COMMAND_SIZE(INQUIRY);
> > +
> > +	error = blk_execute_rq(rq->q, NULL, rq, 1);
> > +	if (error) {
> > +		pr_err("pNFS: INQUIRY 0x83 failed with: %x\n",
> > +			rq->errors);
> > +		
> 
> Did you mean to have a "goto out_put_request;" there?
> 
> Fixed up locally under that assumption....

Yes, thanks!
