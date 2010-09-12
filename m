Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804Ab0ILTmk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Sep 2010 15:42:40 -0400
Subject: Re: [RFC 1/3] SQUASHME: Generalize the device cache so it can be
 used by all layouts
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@panasas.com>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4C8D07D5.6010006@panasas.com>
References: <4C8D0759.6090201@panasas.com>  <4C8D07D5.6010006@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 12 Sep 2010 15:42:13 -0400
Message-ID: <1284320533.7880.131.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-09-12 at 19:03 +0200, Boaz Harrosh wrote:
> Current code thinks that there can be a single device_id per
> layout segment. Change that to assume no relations between segments
> and device_ids. It's now up to the layout-driver to make any relations.
> 
> Files layout driver is fixed in next patch.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pnfs.c             |   20 +++++---------------
>  include/linux/nfs4_pnfs.h |    6 +-----
>  2 files changed, 6 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index eb4e092..f26abc0 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1892,26 +1892,16 @@ nfs4_init_deviceid_node(struct nfs4_deviceid *d)
>  }
>  EXPORT_SYMBOL(nfs4_init_deviceid_node);
>  
> -/* Called from layoutdriver_io_operations->alloc_lseg */
> -void
> -nfs4_set_layout_deviceid(struct pnfs_layout_segment *l, struct nfs4_deviceid *d)
> -{
> -	dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.refcount));
> -	l->deviceid = d;
> -}
> -EXPORT_SYMBOL(nfs4_set_layout_deviceid);
> -
>  /* Called from layoutdriver_io_operations->free_lseg */
>  void
> -nfs4_put_unset_layout_deviceid(struct pnfs_layout_segment *l,
> -			   struct nfs4_deviceid *d,
> -			   void (*free_callback)(struct kref *))
> +nfs4_put_deviceid(struct nfs4_deviceid_cache *c,
> +			   struct nfs4_deviceid *d)
>  {
>  	dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.refcount));
> -	l->deviceid = NULL;
> -	kref_put(&d->de_kref, free_callback);
> +	kref_put(&d->de_kref, c->dc_free_callback);
> +	/* Do we need to return the deviceid_cache ref */
>  }
> -EXPORT_SYMBOL(nfs4_put_unset_layout_deviceid);
> +EXPORT_SYMBOL(nfs4_put_deviceid);
>  
>  /* Find and reference a deviceid */
>  struct nfs4_deviceid *
> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
> index 577cd2b..dc3410e 100644
> --- a/include/linux/nfs4_pnfs.h
> +++ b/include/linux/nfs4_pnfs.h
> @@ -111,7 +111,6 @@ struct pnfs_layout_segment {
>  	struct kref kref;
>  	bool valid;
>  	struct pnfs_layout_hdr *layout;
> -	struct nfs4_deviceid *deviceid;
>  	u8 ld_data[];			/* layout driver private data */
>  };
>  
> @@ -287,11 +286,8 @@ extern struct nfs4_deviceid *nfs4_find_get_deviceid(
>  				struct pnfs_deviceid *);
>  extern struct nfs4_deviceid *nfs4_add_get_deviceid(struct nfs4_deviceid_cache *,
>  				struct nfs4_deviceid *);
> -extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
> +extern void nfs4_put_deviceid(struct nfs4_deviceid_cache *,
>  				struct nfs4_deviceid *);
> -extern void nfs4_put_unset_layout_deviceid(struct pnfs_layout_segment *,
> -				struct nfs4_deviceid *,
> -				void (*free_callback)(struct kref *));
>  extern void nfs4_delete_device(struct nfs4_deviceid_cache *,
>  				struct pnfs_deviceid *);
>  

This doesn't look like it needs to be part of the initial single-layout
submission. Why is it being labelled as a squashme?

Trond
