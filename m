Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35322 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758763AbbIVWbr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2015 18:31:47 -0400
Received: by igbkq10 with SMTP id kq10so89912089igb.0
        for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2015 15:31:47 -0700 (PDT)
Message-ID: <1442961094.8133.11.camel@primarydata.com>
Subject: Re: [PATCH] pnfs  support servers with multiple layout types
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Date: Tue, 22 Sep 2015 18:31:34 -0400
In-Reply-To: <1442929507-7002-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1442929507-7002-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-09-22 at 15:45 +0200, Tigran Mkrtchyan wrote:
> current NFSv4.1/pNFS client assumes that MDS supports
> only one layout type. While it's true for most existing servers,
> nevertheless, this can be change in the near future.
> 
> This patch is an attempt to multi layouttype MDS support.  To make
> it possible for such servers still function with existing clients,
> the layout
> type list will be processed in reverse order. This gives old clients
> still
> pick the first entry, but newer client will pick last entry.  Proof:
> 
> 4.3.0-rc1-dirty
> [  180.868764] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver
> Registering...
> 
> 2.6.32-573.3.1.el6.x86_64
> nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  fs/nfs/client.c         |  2 +-
>  fs/nfs/nfs4xdr.c        | 22 +++++++++---------
>  fs/nfs/pnfs.c           | 62 ++++++++++++++++++++++++++++++---------
> ----------
>  fs/nfs/pnfs.h           |  2 +-
>  include/linux/nfs_xdr.h |  4 +++-
>  5 files changed, 54 insertions(+), 38 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 57c5a02..1145bc7 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -786,7 +786,7 @@ int nfs_probe_fsinfo(struct nfs_server *server,
> struct nfs_fh *mntfh, struct nfs
>  	}
>  
>  	fsinfo.fattr = fattr;
> -	fsinfo.layouttype = 0;
> +	memset(fsinfo.layouttype, 0, sizeof(fsinfo.layouttype));
>  	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
>  	if (error < 0)
>  		goto out_error;
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 788adf3..7fbd411 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4688,14 +4688,14 @@ static int decode_getfattr(struct xdr_stream
> *xdr, struct nfs_fattr *fattr,
>  }
>  
>  /*
> - * Decode potentially multiple layout types. Currently we only
> support
> - * one layout driver per file system.
> + * Decode potentially multiple layout types.
>   */
> -static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
> +static int decode_pnfs_layout_types(struct xdr_stream *xdr,
>  					 uint32_t *layouttype)
>  {
>  	__be32 *p;
>  	int num;
> +	int i;

Make these both unsigned int?

>  
>  	p = xdr_inline_decode(xdr, 4);
>  	if (unlikely(!p))
> @@ -4704,18 +4704,18 @@ static int
> decode_first_pnfs_layout_type(struct xdr_stream *xdr,
>  
>  	/* pNFS is not supported by the underlying file system */
>  	if (num == 0) {
> -		*layouttype = 0;
>  		return 0;
>  	}
> -	if (num > 1)
> -		printk(KERN_INFO "NFS: %s: Warning: Multiple pNFS
> layout "
> -			"drivers per filesystem not supported\n",
> __func__);
> +	if (num > NFS_MAX_LAYOUT_TYPES)
> +		printk(KERN_INFO "NFS: %s: Warning: Too many (%d)
> pNFS layout types\n", __func__, num);
>  
>  	/* Decode and set first layout type, move xdr->p past unused
> types */
>  	p = xdr_inline_decode(xdr, num * 4);
>  	if (unlikely(!p))
>  		goto out_overflow;
> -	*layouttype = be32_to_cpup(p);
> +	for(i = 0; i < num && i < NFS_MAX_LAYOUT_TYPES; i++) {
> +		layouttype[i] = be32_to_cpup(p++);
> +	}

You don't need the { } block enclosure here.

>  	return 0;
>  out_overflow:
>  	print_overflow_msg(__func__, xdr);
> @@ -4735,10 +4735,10 @@ static int decode_attr_pnfstype(struct
> xdr_stream *xdr, uint32_t *bitmap,
>  	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES -
> 1U)))
>  		return -EIO;
>  	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
> -		status = decode_first_pnfs_layout_type(xdr,
> layouttype);
> +		status = decode_pnfs_layout_types(xdr, layouttype);
>  		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
>  	} else
> -		*layouttype = 0;
> +		memset(layouttype, 0, sizeof(*layouttype));

Isn't this already done by the caller in fs/nfs/client.c?

> 	return status;
>  }
>  
> @@ -4792,7 +4792,7 @@ static int decode_fsinfo(struct xdr_stream
> *xdr, struct nfs_fsinfo *fsinfo)
>  	status = decode_attr_time_delta(xdr, bitmap, &fsinfo
> ->time_delta);
>  	if (status != 0)
>  		goto xdr_error;
> -	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo
> ->layouttype);
> +	status = decode_attr_pnfstype(xdr, bitmap, fsinfo
> ->layouttype);
>  	if (status != 0)
>  		goto xdr_error;
>  	status = decode_attr_layout_blksize(xdr, bitmap, &fsinfo
> ->blksize);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index ba12464..883bfa2 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -104,45 +104,59 @@ unset_pnfs_layoutdriver(struct nfs_server
> *nfss)
>   * Try to set the server's pnfs module to the pnfs layout type
> specified by id.
>   * Currently only one pNFS layout driver per filesystem is
> supported.
>   *
> - * @id layout type. Zero (illegal layout type) indicates pNFS not in
> use.
> + * @ids array of layout types supported by MDS.
>   */
>  void
>  set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh
> *mntfh,
> -		      u32 id)
> +		      u32 *ids)
>  {
>  	struct pnfs_layoutdriver_type *ld_type = NULL;
> +	u32 id;
> +	int i;
>  
> -	if (id == 0)
> -		goto out_no_driver;
>  	if (!(server->nfs_client->cl_exchange_flags &
>  		 (EXCHGID4_FLAG_USE_NON_PNFS |
> EXCHGID4_FLAG_USE_PNFS_MDS))) {
> -		printk(KERN_ERR "NFS: %s: id %u cl_exchange_flags
> 0x%x\n",
> -			__func__, id, server->nfs_client
> ->cl_exchange_flags);
> +		printk(KERN_ERR "NFS: %s: cl_exchange_flags 0x%x\n",
> +			__func__, server->nfs_client
> ->cl_exchange_flags);
>  		goto out_no_driver;
>  	}
> -	ld_type = find_pnfs_driver(id);
> -	if (!ld_type) {
> -		request_module("%s-%u",
> LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> +
> +	/*
> + 	 * walk in reverse ordet to use last in the list first.
> +   	 * By assyming, that server will send most common type
> first,
> +   	 * most preferred one last, old client will be happy with
> +   	 * a first entry, where new clients (4.4+) will pick the
> +   	 * most advance one.

This implies that old clients will always pick the least preferred
layout type from the server's perspective. Ditto if newer clients get
the value of NFS_MAX_LAYOUT_TYPES wrong.

Why not instead assume the following? 1st entry == default. Others are
sorted in order of decreasing server preference.

> + 	 */
> +	for(i = NFS_MAX_LAYOUT_TYPES; i >=0; i--) {
> +		id = ids[i];
> +		if(!id)
> +			continue;
> +
>  		ld_type = find_pnfs_driver(id);
>  		if (!ld_type) {
> -			dprintk("%s: No pNFS module found for
> %u.\n",
> -				__func__, id);
> +			request_module("%s-%u",
> LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> +			ld_type = find_pnfs_driver(id);
> +			if (!ld_type) {
> +				dprintk("%s: No pNFS module found
> for %u.\n",
> +					__func__, id);
> +				continue;
> +			}
> +		}
> +		server->pnfs_curr_ld = ld_type;
> +		if (ld_type->set_layoutdriver
> +		    && ld_type->set_layoutdriver(server, mntfh)) {
> +			printk(KERN_ERR "NFS: %s: Error initializing
> pNFS layout "
> +				"driver %u.\n", __func__, id);
> +			module_put(ld_type->owner);
>  			goto out_no_driver;
>  		}
> -	}
> -	server->pnfs_curr_ld = ld_type;
> -	if (ld_type->set_layoutdriver
> -	    && ld_type->set_layoutdriver(server, mntfh)) {
> -		printk(KERN_ERR "NFS: %s: Error initializing pNFS
> layout "
> -			"driver %u.\n", __func__, id);
> -		module_put(ld_type->owner);
> -		goto out_no_driver;
> -	}
> -	/* Bump the MDS count */
> -	atomic_inc(&server->nfs_client->cl_mds_count);
> +		/* Bump the MDS count */
> +		atomic_inc(&server->nfs_client->cl_mds_count);
>  
> -	dprintk("%s: pNFS module for %u set\n", __func__, id);
> -	return;
> +		dprintk("%s: pNFS module for %u set\n", __func__,
> id);
> +		return;
> +	}
>  
>  out_no_driver:
>  	dprintk("%s: Using NFSv4 I/O\n", __func__);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 78c9351..e7609c3 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -235,7 +235,7 @@ void pnfs_get_layout_hdr(struct pnfs_layout_hdr
> *lo);
>  void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
>  void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
>  
> -void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh
> *, u32);
> +void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh
> *, u32 *);
>  void unset_pnfs_layoutdriver(struct nfs_server *);
>  void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *,
> struct nfs_page *);
>  int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 52faf7e..6c88745 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -124,6 +124,8 @@ struct nfs_fattr {
>  		| NFS_ATTR_FATTR_SPACE_USED \
>  		| NFS_ATTR_FATTR_V4_SECURITY_LABEL)
>  
> +#define NFS_MAX_LAYOUT_TYPES 32

There are only RFCs for 4 layout types today. Where does the number
'32' come from?

> +
>  /*
>   * Info on the file system
>   */
> @@ -139,7 +141,7 @@ struct nfs_fsinfo {
>  	__u64			maxfilesize;
>  	struct timespec		time_delta; /* server time
> granularity */
>  	__u32			lease_time; /* in seconds */
> -	__u32			layouttype; /* supported pnfs
> layout driver */
> +	__u32			layouttype[NFS_MAX_LAYOUT_TYPES
> ]; /* supported pnfs layout drivers */
>  	__u32			blksize; /* preferred pnfs io
> block size */
>  };
>  
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



