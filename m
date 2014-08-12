Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:58322 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbaHLLg7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 07:36:59 -0400
Received: by mail-wg0-f49.google.com with SMTP id k14so9677229wgh.8
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 04:36:57 -0700 (PDT)
Message-ID: <53E9FC57.9010806@gmail.com>
Date: Tue, 12 Aug 2014 14:36:55 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] pnfs: factor GETDEVICEINFO implementations
References: <1407787617-26050-1-git-send-email-hch@lst.de> <1407787617-26050-2-git-send-email-hch@lst.de>
In-Reply-To: <1407787617-26050-2-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/11/2014 11:06 PM, Christoph Hellwig wrote:
> Add support to the common pNFS core to issue GETDEVICEINFO calls on
> a device ID cache miss.  The code is taken from the well debugged
> file layout implementation and calls out to the layoutdriver through
> a new alloc_deviceid_node method.  The calling conventions for
> nfs4_find_get_deviceid are changed so that all information needed to
> send a GETDEVICEINFO request is passed to the common code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/filelayout/filelayout.c    |  29 +++++---
>  fs/nfs/filelayout/filelayout.h    |   7 +-
>  fs/nfs/filelayout/filelayoutdev.c | 108 ++--------------------------
>  fs/nfs/objlayout/objio_osd.c      | 114 +++++++++++------------------
>  fs/nfs/objlayout/objlayout.c      |  70 ------------------
>  fs/nfs/objlayout/objlayout.h      |   5 --
>  fs/nfs/pnfs.h                     |  12 ++--
>  fs/nfs/pnfs_dev.c                 | 146 ++++++++++++++++++++++++++------------
>  8 files changed, 178 insertions(+), 313 deletions(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 1359c4a..3136fc7 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -646,18 +646,15 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
>  	}
>  
>  	/* find and reference the deviceid */
> -	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode)->pnfs_curr_ld,
> -				   NFS_SERVER(lo->plh_inode)->nfs_client, id);
> -	if (d == NULL) {
> -		dsaddr = filelayout_get_device_info(lo->plh_inode, id,
> -				lo->plh_lc_cred, gfp_flags);
> -		if (dsaddr == NULL)
> -			goto out;
> -	} else
> -		dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
> +	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), id,
> +			lo->plh_lc_cred, gfp_flags);
> +	if (d == NULL)
> +		goto out;
> +
> +	dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
>  	/* Found deviceid is unavailable */
>  	if (filelayout_test_devid_unavailable(&dsaddr->id_node))
> -			goto out_put;
> +		goto out_put;
>  
>  	fl->dsaddr = dsaddr;
>  
> @@ -1367,6 +1364,17 @@ out:
>  	cinfo->ds->ncommitting = 0;
>  	return PNFS_ATTEMPTED;
>  }
> +static struct nfs4_deviceid_node *
> +filelayout_alloc_deviceid_node(struct nfs_server *server,
> +		struct pnfs_device *pdev, gfp_t gfp_flags)
> +{
> +	struct nfs4_file_layout_dsaddr *dsaddr;
> +
> +	dsaddr = nfs4_fl_alloc_deviceid_node(server, pdev, gfp_flags);
> +	if (!dsaddr)
> +		return NULL;
> +	return &dsaddr->id_node;
> +}
>  
>  static void
>  filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
> @@ -1419,6 +1427,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>  	.commit_pagelist	= filelayout_commit_pagelist,
>  	.read_pagelist		= filelayout_read_pagelist,
>  	.write_pagelist		= filelayout_write_pagelist,
> +	.alloc_deviceid_node	= filelayout_alloc_deviceid_node,
>  	.free_deviceid_node	= filelayout_free_deveiceid_node,
>  };
>  
> diff --git a/fs/nfs/filelayout/filelayout.h b/fs/nfs/filelayout/filelayout.h
> index ffbddf2..7c9f800 100644
> --- a/fs/nfs/filelayout/filelayout.h
> +++ b/fs/nfs/filelayout/filelayout.h
> @@ -147,10 +147,11 @@ u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
>  u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
>  struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
>  					u32 ds_idx);
> +
> +extern struct nfs4_file_layout_dsaddr *
> +nfs4_fl_alloc_deviceid_node(struct nfs_server *server,
> +	struct pnfs_device *pdev, gfp_t gfp_flags);
>  extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
>  extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
> -struct nfs4_file_layout_dsaddr *
> -filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id,
> -		struct rpc_cred *cred, gfp_t gfp_flags);
>  
>  #endif /* FS_NFS_NFS4FILELAYOUT_H */
> diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
> index 48f8dcd..c1edb3a 100644
> --- a/fs/nfs/filelayout/filelayoutdev.c
> +++ b/fs/nfs/filelayout/filelayoutdev.c
> @@ -484,8 +484,9 @@ out_err:
>  }
>  
>  /* Decode opaque device data and return the result */
> -static struct nfs4_file_layout_dsaddr*
> -decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
> +struct nfs4_file_layout_dsaddr *
> +nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
> +		gfp_t gfp_flags)
>  {
>  	int i;
>  	u32 cnt, num;
> @@ -570,10 +571,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
>  	dsaddr->stripe_indices = stripe_indices;
>  	stripe_indices = NULL;
>  	dsaddr->ds_num = num;
> -	nfs4_init_deviceid_node(&dsaddr->id_node,
> -				NFS_SERVER(ino)->pnfs_curr_ld,
> -				NFS_SERVER(ino)->nfs_client,
> -				&pdev->dev_id);
> +	nfs4_init_deviceid_node(&dsaddr->id_node, server, &pdev->dev_id);
>  
>  	INIT_LIST_HEAD(&dsaddrs);
>  
> @@ -587,7 +585,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
>  
>  		mp_count = be32_to_cpup(p); /* multipath count */
>  		for (j = 0; j < mp_count; j++) {
> -			da = decode_ds_addr(NFS_SERVER(ino)->nfs_client->cl_net,
> +			da = decode_ds_addr(server->nfs_client->cl_net,
>  					    &stream, gfp_flags);
>  			if (da)
>  				list_add_tail(&da->da_node, &dsaddrs);
> @@ -637,102 +635,6 @@ out_err:
>  	return NULL;
>  }
>  
> -/*
> - * Decode the opaque device specified in 'dev' and add it to the cache of
> - * available devices.
> - */
> -static struct nfs4_file_layout_dsaddr *
> -decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_flags)
> -{
> -	struct nfs4_deviceid_node *d;
> -	struct nfs4_file_layout_dsaddr *n, *new;
> -
> -	new = decode_device(inode, dev, gfp_flags);
> -	if (!new) {
> -		printk(KERN_WARNING "NFS: %s: Could not decode or add device\n",
> -			__func__);
> -		return NULL;
> -	}
> -
> -	d = nfs4_insert_deviceid_node(&new->id_node);
> -	n = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
> -	if (n != new) {
> -		nfs4_fl_free_deviceid(new);
> -		return n;
> -	}
> -
> -	return new;
> -}
> -
> -/*
> - * Retrieve the information for dev_id, add it to the list
> - * of available devices, and return it.
> - */
> -struct nfs4_file_layout_dsaddr *
> -filelayout_get_device_info(struct inode *inode,
> -		struct nfs4_deviceid *dev_id,
> -		struct rpc_cred *cred,
> -		gfp_t gfp_flags)
> -{
> -	struct pnfs_device *pdev = NULL;
> -	u32 max_resp_sz;
> -	int max_pages;
> -	struct page **pages = NULL;
> -	struct nfs4_file_layout_dsaddr *dsaddr = NULL;
> -	int rc, i;
> -	struct nfs_server *server = NFS_SERVER(inode);
> -
> -	/*
> -	 * Use the session max response size as the basis for setting
> -	 * GETDEVICEINFO's maxcount
> -	 */
> -	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
> -	max_pages = nfs_page_array_len(0, max_resp_sz);
> -	dprintk("%s inode %p max_resp_sz %u max_pages %d\n",
> -		__func__, inode, max_resp_sz, max_pages);
> -
> -	pdev = kzalloc(sizeof(struct pnfs_device), gfp_flags);
> -	if (pdev == NULL)
> -		return NULL;
> -
> -	pages = kcalloc(max_pages, sizeof(struct page *), gfp_flags);
> -	if (pages == NULL) {
> -		kfree(pdev);
> -		return NULL;
> -	}
> -	for (i = 0; i < max_pages; i++) {
> -		pages[i] = alloc_page(gfp_flags);
> -		if (!pages[i])
> -			goto out_free;
> -	}
> -
> -	memcpy(&pdev->dev_id, dev_id, sizeof(*dev_id));
> -	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
> -	pdev->pages = pages;
> -	pdev->pgbase = 0;
> -	pdev->pglen = max_resp_sz;
> -	pdev->mincount = 0;
> -	pdev->maxcount = max_resp_sz - nfs41_maxgetdevinfo_overhead;
> -
> -	rc = nfs4_proc_getdeviceinfo(server, pdev, cred);
> -	dprintk("%s getdevice info returns %d\n", __func__, rc);
> -	if (rc)
> -		goto out_free;
> -
> -	/*
> -	 * Found new device, need to decode it and then add it to the
> -	 * list of known devices for this mountpoint.
> -	 */
> -	dsaddr = decode_and_add_device(inode, pdev, gfp_flags);
> -out_free:
> -	for (i = 0; i < max_pages; i++)
> -		__free_page(pages[i]);
> -	kfree(pages);
> -	kfree(pdev);
> -	dprintk("<-- %s dsaddr %p\n", __func__, dsaddr);
> -	return dsaddr;
> -}
> -
>  void
>  nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
>  {
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index ae05278..da2c1c4 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -60,52 +60,6 @@ objio_free_deviceid_node(struct nfs4_deviceid_node *d)
>  	kfree(de);
>  }
>  
> -static struct objio_dev_ent *_dev_list_find(const struct nfs_server *nfss,
> -	const struct nfs4_deviceid *d_id)
> -{
> -	struct nfs4_deviceid_node *d;
> -	struct objio_dev_ent *de;
> -
> -	d = nfs4_find_get_deviceid(nfss->pnfs_curr_ld, nfss->nfs_client, d_id);
> -	if (!d)
> -		return NULL;
> -
> -	de = container_of(d, struct objio_dev_ent, id_node);
> -	return de;
> -}
> -
> -static struct objio_dev_ent *
> -_dev_list_add(const struct nfs_server *nfss,
> -	const struct nfs4_deviceid *d_id, struct osd_dev *od,
> -	gfp_t gfp_flags)
> -{
> -	struct nfs4_deviceid_node *d;
> -	struct objio_dev_ent *de = kzalloc(sizeof(*de), gfp_flags);
> -	struct objio_dev_ent *n;
> -
> -	if (!de) {
> -		dprintk("%s: -ENOMEM od=%p\n", __func__, od);
> -		return NULL;
> -	}
> -
> -	dprintk("%s: Adding od=%p\n", __func__, od);
> -	nfs4_init_deviceid_node(&de->id_node,
> -				nfss->pnfs_curr_ld,
> -				nfss->nfs_client,
> -				d_id);
> -	de->od.od = od;
> -
> -	d = nfs4_insert_deviceid_node(&de->id_node);
> -	n = container_of(d, struct objio_dev_ent, id_node);
> -	if (n != de) {
> -		dprintk("%s: Race with other n->od=%p\n", __func__, n->od.od);
> -		objio_free_deviceid_node(&de->id_node);
> -		de = n;
> -	}
> -
> -	return de;
> -}
> -
>  struct objio_segment {
>  	struct pnfs_layout_segment lseg;
>  
> @@ -130,29 +84,24 @@ struct objio_state {
>  
>  /* Send and wait for a get_device_info of devices in the layout,
>     then look them up with the osd_initiator library */
> -static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
> -	struct objio_segment *objio_seg, unsigned c, struct nfs4_deviceid *d_id,
> -	gfp_t gfp_flags)
> +struct nfs4_deviceid_node *
> +objio_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
> +			gfp_t gfp_flags)
>  {
>  	struct pnfs_osd_deviceaddr *deviceaddr;
> -	struct objio_dev_ent *ode;
> +	struct objio_dev_ent *ode = NULL;
>  	struct osd_dev *od;
>  	struct osd_dev_info odi;
>  	bool retry_flag = true;
> +	u32 *p;
>  	int err;
>  
> -	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode), d_id);
> -	if (ode) {
> -		objio_seg->oc.ods[c] = &ode->od; /* must use container_of */
> -		return 0;
> -	}
> -
> -	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr, gfp_flags);
> -	if (unlikely(err)) {
> -		dprintk("%s: objlayout_get_deviceinfo dev(%llx:%llx) =>%d\n",
> -			__func__, _DEVID_LO(d_id), _DEVID_HI(d_id), err);
> -		return err;
> -	}
> +	deviceaddr = kzalloc(sizeof(*deviceaddr), gfp_flags);
> +	if (!deviceaddr)
> +		return NULL;
> +	
> +	p = page_address(pdev->pages[0]);
> +	pnfs_osd_xdr_decode_deviceaddr(deviceaddr, p);
>  
>  	odi.systemid_len = deviceaddr->oda_systemid.len;
>  	if (odi.systemid_len > sizeof(odi.systemid)) {
> @@ -188,14 +137,24 @@ retry_lookup:
>  		goto out;
>  	}
>  
> -	ode = _dev_list_add(NFS_SERVER(pnfslay->plh_inode), d_id, od,
> -			    gfp_flags);
> -	objio_seg->oc.ods[c] = &ode->od; /* must use container_of */
>  	dprintk("Adding new dev_id(%llx:%llx)\n",
> -		_DEVID_LO(d_id), _DEVID_HI(d_id));
> +		_DEVID_LO(&pdev->dev_id), _DEVID_HI(&pdev->dev_id));
> +
> +	ode = kzalloc(sizeof(*ode), gfp_flags);
> +	if (!ode) {
> +		dprintk("%s: -ENOMEM od=%p\n", __func__, od);
> +		goto out;
> +	}
> +
> +	nfs4_init_deviceid_node(&ode->id_node, server, &pdev->dev_id);
> +	kfree(deviceaddr);
> +
> +	ode->od.od = od;
> +	return &ode->id_node;
> +
>  out:
> -	objlayout_put_deviceinfo(deviceaddr);
> -	return err;
> +	kfree(deviceaddr);
> +	return NULL;
>  }
>  
>  static void copy_single_comp(struct ore_components *oc, unsigned c,
> @@ -254,6 +213,7 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>  	struct xdr_stream *xdr,
>  	gfp_t gfp_flags)
>  {
> +	struct nfs_server *server = NFS_SERVER(pnfslay->plh_inode);
>  	struct objio_segment *objio_seg;
>  	struct pnfs_osd_xdr_decode_layout_iter iter;
>  	struct pnfs_osd_layout layout;
> @@ -283,13 +243,21 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>  	objio_seg->oc.first_dev = layout.olo_comps_index;
>  	cur_comp = 0;
>  	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err)) {
> +		struct nfs4_deviceid_node *d;
> +		struct objio_dev_ent *ode;
> +
>  		copy_single_comp(&objio_seg->oc, cur_comp, &src_comp);
> -		err = objio_devices_lookup(pnfslay, objio_seg, cur_comp,
> -					   &src_comp.oc_object_id.oid_device_id,
> -					   gfp_flags);
> -		if (err)
> +	
> +		d = nfs4_find_get_deviceid(server,
> +				&src_comp.oc_object_id.oid_device_id,
> +				pnfslay->plh_lc_cred, gfp_flags);
> +		if (!d) {
> +			err = -ENXIO;
>  			goto err;
> -		++cur_comp;
> +		}
> +
> +		ode = container_of(d, struct objio_dev_ent, id_node);
> +		objio_seg->oc.ods[cur_comp++] = &ode->od;
>  	}
>  	/* pnfs_osd_xdr_decode_layout_comp returns false on error */
>  	if (unlikely(err))
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 697a16d..c89357c 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -574,76 +574,6 @@ loop_done:
>  	dprintk("%s: Return\n", __func__);
>  }
>  
> -
> -/*
> - * Get Device Info API for io engines
> - */
> -struct objlayout_deviceinfo {
> -	struct page *page;
> -	struct pnfs_osd_deviceaddr da; /* This must be last */
> -};
> -
> -/* Initialize and call nfs_getdeviceinfo, then decode and return a
> - * "struct pnfs_osd_deviceaddr *" Eventually objlayout_put_deviceinfo()
> - * should be called.
> - */
> -int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
> -	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr,
> -	gfp_t gfp_flags)
> -{
> -	struct objlayout_deviceinfo *odi;
> -	struct pnfs_device pd;
> -	struct page *page, **pages;
> -	u32 *p;
> -	int err;
> -
> -	page = alloc_page(gfp_flags);
> -	if (!page)
> -		return -ENOMEM;
> -
> -	pages = &page;
> -	pd.pages = pages;
> -
> -	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
> -	pd.layout_type = LAYOUT_OSD2_OBJECTS;
> -	pd.pages = &page;
> -	pd.pgbase = 0;
> -	pd.pglen = PAGE_SIZE;
> -	pd.mincount = 0;
> -	pd.maxcount = PAGE_SIZE;
> -
> -	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd,
> -			pnfslay->plh_lc_cred);
> -	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
> -	if (err)
> -		goto err_out;
> -
> -	p = page_address(page);
> -	odi = kzalloc(sizeof(*odi), gfp_flags);
> -	if (!odi) {
> -		err = -ENOMEM;
> -		goto err_out;
> -	}
> -	pnfs_osd_xdr_decode_deviceaddr(&odi->da, p);
> -	odi->page = page;
> -	*deviceaddr = &odi->da;
> -	return 0;
> -
> -err_out:
> -	__free_page(page);
> -	return err;
> -}
> -
> -void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
> -{
> -	struct objlayout_deviceinfo *odi = container_of(deviceaddr,
> -						struct objlayout_deviceinfo,
> -						da);
> -
> -	__free_page(odi->page);
> -	kfree(odi);
> -}
> -
>  enum {
>  	OBJLAYOUT_MAX_URI_LEN = 256, OBJLAYOUT_MAX_OSDNAME_LEN = 64,
>  	OBJLAYOUT_MAX_SYSID_HEX_LEN = OSD_SYSTEMID_LEN * 2 + 1,
> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
> index fd13f1d..3a0828d 100644
> --- a/fs/nfs/objlayout/objlayout.h
> +++ b/fs/nfs/objlayout/objlayout.h
> @@ -149,11 +149,6 @@ extern void objlayout_read_done(struct objlayout_io_res *oir,
>  extern void objlayout_write_done(struct objlayout_io_res *oir,
>  				 ssize_t status, bool sync);
>  
> -extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
> -	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr,
> -	gfp_t gfp_flags);
> -extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
> -
>  /*
>   * exported generic objects function vectors
>   */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 603f460..e145b79 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -125,6 +125,9 @@ struct pnfs_layoutdriver_type {
>  	enum pnfs_try_status (*write_pagelist)(struct nfs_pgio_header *, int);
>  
>  	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
> +	struct nfs4_deviceid_node * (*alloc_deviceid_node)
> +			(struct nfs_server *server, struct pnfs_device *pdev,
> +			gfp_t gfp_flags);
>  
>  	void (*encode_layoutreturn) (struct pnfs_layout_hdr *layoutid,
>  				     struct xdr_stream *xdr,
> @@ -259,11 +262,12 @@ struct nfs4_deviceid_node {
>  	atomic_t			ref;
>  };
>  
> -struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
> +struct nfs4_deviceid_node *
> +nfs4_find_get_deviceid(struct nfs_server *server,
> +		const struct nfs4_deviceid *id, struct rpc_cred *cred,
> +		gfp_t gfp_mask);
>  void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
> -void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
> -			     const struct pnfs_layoutdriver_type *,
> -			     const struct nfs_client *,
> +void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
>  			     const struct nfs4_deviceid *);
>  struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
>  bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 6da209b..e3d4fa9 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -29,6 +29,9 @@
>   */
>  
>  #include <linux/export.h>
> +#include <linux/nfs_fs.h>
> +#include "nfs4session.h"
> +#include "internal.h"
>  #include "pnfs.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_PNFS
> @@ -89,6 +92,71 @@ _lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
>  	return NULL;
>  }
>  
> +static struct nfs4_deviceid_node *
> +nfs4_get_device_info(struct nfs_server *server,
> +		const struct nfs4_deviceid *dev_id,
> +		struct rpc_cred *cred, gfp_t gfp_flags)
> +{
> +	struct nfs4_deviceid_node *d = NULL;
> +	struct pnfs_device *pdev = NULL;
> +	struct page **pages = NULL;
> +	u32 max_resp_sz;
> +	int max_pages;
> +	int rc, i;
> +
> +	/*
> +	 * Use the session max response size as the basis for setting
> +	 * GETDEVICEINFO's maxcount
> +	 */
> +	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
> +	max_pages = nfs_page_array_len(0, max_resp_sz);
> +	dprintk("%s: server %p max_resp_sz %u max_pages %d\n",
> +		__func__, server, max_resp_sz, max_pages);
> +

This is an extremely too big an allocation for obj-lo (which has
a couple of embedded strings here). The all RPC can fit a single
page

Should we put like a flag in struct pnfs_layoutdriver_type:

	if (server->pnfs_curr_ld->flags & PNFS_DEVINFO_SINGLE_PAGE) {
		max_pages = 1;
		max_resp_sz = PAGE_SIZE;
	}

This gives us so many extra allocation for storing one page pointer but for
the simplicity of the cleanup we can live with it.
		 
What do you say? For obj-lo a device_id is a light wait resource and it can
have hundreds/thousand of them. Not like file-lo and block-lo that have few, up to
tens, devices. Do we want this optimization?

(Did not review the all thing yet, will do later)
Thanks
Boaz

> +	pdev = kzalloc(sizeof(*pdev), gfp_flags);
> +	if (!pdev)
> +		return NULL;
> +
> +	pages = kcalloc(max_pages, sizeof(struct page *), gfp_flags);
> +	if (!pages)
> +		goto out_free_pdev;
> +
> +	for (i = 0; i < max_pages; i++) {
> +		pages[i] = alloc_page(gfp_flags);
> +		if (!pages[i])
> +			goto out_free_pages;
> +	}
> +
> +	memcpy(&pdev->dev_id, dev_id, sizeof(*dev_id));
> +	pdev->layout_type = server->pnfs_curr_ld->id;
> +	pdev->pages = pages;
> +	pdev->pgbase = 0;
> +	pdev->pglen = max_resp_sz;
> +	pdev->mincount = 0;
> +	pdev->maxcount = max_resp_sz - nfs41_maxgetdevinfo_overhead;
> +
> +	rc = nfs4_proc_getdeviceinfo(server, pdev, cred);
> +	dprintk("%s getdevice info returns %d\n", __func__, rc);
> +	if (rc)
> +		goto out_free_pages;
> +
> +	/*
> +	 * Found new device, need to decode it and then add it to the
> +	 * list of known devices for this mountpoint.
> +	 */
> +	d = server->pnfs_curr_ld->alloc_deviceid_node(server, pdev,
> +			gfp_flags);
> +
> +out_free_pages:
> +	for (i = 0; i < max_pages; i++)
> +		__free_page(pages[i]);
> +	kfree(pages);
> +out_free_pdev:
> +	kfree(pdev);
> +	dprintk("<-- %s d %p\n", __func__, d);
> +	return d;
> +}
> +
>  /*
>   * Lookup a deviceid in cache and get a reference count on it if found
>   *
> @@ -96,14 +164,14 @@ _lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
>   * @id deviceid to look up
>   */
>  static struct nfs4_deviceid_node *
> -_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
> -		   const struct nfs_client *clp, const struct nfs4_deviceid *id,
> -		   long hash)
> +__nfs4_find_get_deviceid(struct nfs_server *server,
> +		const struct nfs4_deviceid *id, long hash)
>  {
>  	struct nfs4_deviceid_node *d;
>  
>  	rcu_read_lock();
> -	d = _lookup_deviceid(ld, clp, id, hash);
> +	d = _lookup_deviceid(server->pnfs_curr_ld, server->nfs_client, id,
> +			hash);
>  	if (d != NULL)
>  		atomic_inc(&d->ref);
>  	rcu_read_unlock();
> @@ -111,10 +179,33 @@ _find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
>  }
>  
>  struct nfs4_deviceid_node *
> -nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
> -		       const struct nfs_client *clp, const struct nfs4_deviceid *id)
> +nfs4_find_get_deviceid(struct nfs_server *server,
> +		const struct nfs4_deviceid *id, struct rpc_cred *cred,
> +		gfp_t gfp_mask)
>  {
> -	return _find_get_deviceid(ld, clp, id, nfs4_deviceid_hash(id));
> +	long hash = nfs4_deviceid_hash(id);
> +	struct nfs4_deviceid_node *d, *new;
> +
> +	d = __nfs4_find_get_deviceid(server, id, hash);
> +	if (d)
> +		return d;
> +
> +	new = nfs4_get_device_info(server, id, cred, gfp_mask);
> +	if (!new)
> +		return new;
> +
> +	spin_lock(&nfs4_deviceid_lock);
> +	d = __nfs4_find_get_deviceid(server, id, hash);
> +	if (d) {
> +		spin_unlock(&nfs4_deviceid_lock);
> +		server->pnfs_curr_ld->free_deviceid_node(new);
> +		return d;
> +	}
> +	hlist_add_head_rcu(&new->node, &nfs4_deviceid_cache[hash]);
> +	atomic_inc(&new->ref);
> +	spin_unlock(&nfs4_deviceid_lock);
> +
> +	return new;
>  }
>  EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
>  
> @@ -151,15 +242,13 @@ nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *ld,
>  EXPORT_SYMBOL_GPL(nfs4_delete_deviceid);
>  
>  void
> -nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
> -			const struct pnfs_layoutdriver_type *ld,
> -			const struct nfs_client *nfs_client,
> +nfs4_init_deviceid_node(struct nfs4_deviceid_node *d, struct nfs_server *server,
>  			const struct nfs4_deviceid *id)
>  {
>  	INIT_HLIST_NODE(&d->node);
>  	INIT_HLIST_NODE(&d->tmpnode);
> -	d->ld = ld;
> -	d->nfs_client = nfs_client;
> +	d->ld = server->pnfs_curr_ld;
> +	d->nfs_client = server->nfs_client;
>  	d->flags = 0;
>  	d->deviceid = *id;
>  	atomic_set(&d->ref, 1);
> @@ -167,39 +256,6 @@ nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
>  EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
>  
>  /*
> - * Uniquely initialize and insert a deviceid node into cache
> - *
> - * @new new deviceid node
> - *      Note that the caller must set up the following members:
> - *        new->ld
> - *        new->nfs_client
> - *        new->deviceid
> - *
> - * @ret the inserted node, if none found, otherwise, the found entry.
> - */
> -struct nfs4_deviceid_node *
> -nfs4_insert_deviceid_node(struct nfs4_deviceid_node *new)
> -{
> -	struct nfs4_deviceid_node *d;
> -	long hash;
> -
> -	spin_lock(&nfs4_deviceid_lock);
> -	hash = nfs4_deviceid_hash(&new->deviceid);
> -	d = _find_get_deviceid(new->ld, new->nfs_client, &new->deviceid, hash);
> -	if (d) {
> -		spin_unlock(&nfs4_deviceid_lock);
> -		return d;
> -	}
> -
> -	hlist_add_head_rcu(&new->node, &nfs4_deviceid_cache[hash]);
> -	spin_unlock(&nfs4_deviceid_lock);
> -	atomic_inc(&new->ref);
> -
> -	return new;
> -}
> -EXPORT_SYMBOL_GPL(nfs4_insert_deviceid_node);
> -
> -/*
>   * Dereference a deviceid node and delete it when its reference count drops
>   * to zero.
>   *
> 

