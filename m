Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35749 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751607Ab0ILRbV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Sep 2010 13:31:21 -0400
Message-ID: <4C8D0E65.5000405@panasas.com>
Date: Sun, 12 Sep 2010 19:31:17 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@panasas.com>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: Re: [RFC 3/3] SQUASHME: pnfs-obj: Use the generic device cache
References: <4C8D0759.6090201@panasas.com> <4C8D08A4.2060104@panasas.com>
In-Reply-To: <4C8D08A4.2060104@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/12/2010 07:06 PM, Boaz Harrosh wrote:
> 
> Drop the hand crafted device id cache and use the generic
> one.
> 
> FIXME: This is done bad and will need some segment structures
> reorganization. I will do it once all pending changes are
> integrated and code is a bit more stable.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objio_osd.c  |  120 ++++++++++++++++++++++-------------------
>  fs/nfs/objlayout/objlayout.c  |    5 +-
>  fs/nfs/objlayout/objlayout.h  |    4 +-
>  fs/nfs/objlayout/panfs_shim.c |    4 +-
>  4 files changed, 72 insertions(+), 61 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 1a155c3..b60b8c5 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -63,77 +63,69 @@ struct objio_mount_type {
>  };
>  
>  struct _dev_ent {
> -	struct list_head list;
> -	struct pnfs_deviceid d_id;
> +	struct nfs4_deviceid nfs4_di;
>  	struct osd_dev *od;
>  };
>  
> -static void _dev_list_remove_all(struct objio_mount_type *omt)
> -{
> -	spin_lock(&omt->dev_list_lock);
> -
> -	while (!list_empty(&omt->dev_list)) {
> -		struct _dev_ent *de = list_entry(omt->dev_list.next,
> -				 struct _dev_ent, list);
> -
> -		list_del_init(&de->list);
> -		osduld_put_device(de->od);
> -		kfree(de);
> -	}
> -
> -	spin_unlock(&omt->dev_list_lock);
> -}
> -
> -static struct osd_dev *___dev_list_find(struct objio_mount_type *omt,
> +static struct osd_dev *_dev_list_find(struct pnfs_layout_hdr *pnfslay,
>  	struct pnfs_deviceid *d_id)
>  {
> -	struct list_head *le;
> -
> -	list_for_each(le, &omt->dev_list) {
> -		struct _dev_ent *de = list_entry(le, struct _dev_ent, list);
> +	struct nfs4_deviceid *d;
> +	struct nfs4_deviceid_cache *devid_cache =
> +		NFS_SERVER(pnfslay->inode)->nfs_client->cl_devid_cache;
> +	struct osd_dev *od;
>  
> -		if (0 == memcmp(&de->d_id, d_id, sizeof(*d_id)))
> -			return de->od;
> -	}
> +	d = nfs4_find_get_deviceid(devid_cache, d_id);
>  
> -	return NULL;
> -}
> +	if (!d)
> +		return NULL;
>  
> -static struct osd_dev *_dev_list_find(struct objio_mount_type *omt,
> -	struct pnfs_deviceid *d_id)
> -{
> -	struct osd_dev *od;
> +	od = container_of(d, struct _dev_ent, nfs4_di)->od;
>  
> -	spin_lock(&omt->dev_list_lock);
> -	od = ___dev_list_find(omt, d_id);
> -	spin_unlock(&omt->dev_list_lock);
> +	/* FIXME: A referance is taken on an added deviceid in _dev_list_add
> +	 * That ref is only dropped at unload when device cache is freed.
> +	 * Whatever prevented uninitialize_mountpoint from been called
> +	 * with active layouts still applies today. Later when we will
> +	 * Have code that caps the cache 
> +	 */

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index b60b8c5..1acc527 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -82,11 +82,12 @@ static struct osd_dev *_dev_list_find(struct pnfs_layout_hdr *pnfslay,
 
 	od = container_of(d, struct _dev_ent, nfs4_di)->od;
 
-	/* FIXME: A referance is taken on an added deviceid in _dev_list_add
+	/* FIXME: A reference is taken on an added deviceid in _dev_list_add
 	 * That ref is only dropped at unload when device cache is freed.
 	 * Whatever prevented uninitialize_mountpoint from been called
 	 * with active layouts still applies today. Later when we will
-	 * Have code that caps the cache 
+	 * Have code that caps the cache size and starts freeing devices
+	 * dynamically, this will be a bug that must be fixed.
 	 */
 	nfs4_put_deviceid(devid_cache, d);
 	return od;

> +	nfs4_put_deviceid(devid_cache, d);
>  	return od;
>  }
>  
> -static int _dev_list_add(struct objio_mount_type *omt,
> +static struct osd_dev *_dev_list_add(struct pnfs_layout_hdr *pnfslay,
>  	struct pnfs_deviceid *d_id, struct osd_dev *od)
>  {
>  	struct _dev_ent *de = kzalloc(sizeof(*de), GFP_KERNEL);
> +	struct nfs4_deviceid *d;
>  
>  	if (!de)
> -		return -ENOMEM;
> +		return ERR_PTR(-ENOMEM);
>  
> -	spin_lock(&omt->dev_list_lock);
> +	d = nfs4_add_get_deviceid(
> +		NFS_SERVER(pnfslay->inode)->nfs_client->cl_devid_cache,
> +		&de->nfs4_di);
>  
> -	if (___dev_list_find(omt, d_id)) {
> -		kfree(de);
> -		goto out;
> +	if (d != &de->nfs4_di) {
> +		/* there was a race and we lost */
> +		osduld_put_device(de->od);
> +		de = container_of(d, struct _dev_ent, nfs4_di);
>  	}
>  
> -	de->d_id = *d_id;
> -	de->od = od;
> -	list_add(&de->list, &omt->dev_list);
> +	return de->od;
> +}
>  
> -out:
> -	spin_unlock(&omt->dev_list_lock);
> -	return 0;
> +void
> +objio_free_dev(struct kref *kref)
> +{
> +	struct nfs4_deviceid *d_id =
> +		container_of(kref, struct nfs4_deviceid, de_kref);
> +	struct _dev_ent *de = container_of(d_id, struct _dev_ent, nfs4_di);
> +
> +	osduld_put_device(de->od);
> +	kfree(de);
>  }
>  
> +
>  struct objio_segment {
>  	struct pnfs_osd_object_cred *comps;
>  
> @@ -183,12 +175,11 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
>  	struct pnfs_deviceid *d_id;
>  	struct osd_dev *od;
>  	struct osd_dev_info odi;
> -	struct objio_mount_type *omt = PNFS_NFS_SERVER(pnfslay)->pnfs_ld_data;
>  	int err;
>  
>  	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
>  
> -	od = _dev_list_find(omt, d_id);
> +	od = _dev_list_find(pnfslay, d_id);
>  	if (od)
>  		return od;
>  
> @@ -222,7 +213,8 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
>  		goto out;
>  	}
>  
> -	_dev_list_add(omt, d_id, od);
> +	/* od might have changed during add */
> +	od = _dev_list_add(pnfslay, d_id, od);
>  
>  out:
>  	dprintk("%s: return=%d\n", __func__, err);
> @@ -347,6 +339,12 @@ free_seg:
>  void objio_free_lseg(void *p)
>  {
>  	struct objio_segment *objio_seg = p;
> +/*	struct nfs_server *nfss = NFS_SERVER(PNFS_INODE(pnfslay));
> +
> +	for (i = 0; i < objio_seg->num_comps; i++) {
> +		nfs4_put_deviceid(nfss->nfs_client->cl_devid_cache,
> +				  objio_seg->devids[i]);
> +	}*/
>  
>  	kfree(objio_seg);
>  }
> @@ -1044,21 +1042,33 @@ static struct pnfs_layoutdriver_type objlayout_type = {
>  	.ld_policy_ops = &objlayout_policy_operations,
>  };
>  
> -void *objio_init_mt(void)
> +void *objio_init_mt(struct nfs_server *nfss)
>  {
> +	int status;
>  	struct objio_mount_type *omt = kzalloc(sizeof(*omt), GFP_KERNEL);
>  
>  	if (!omt)
>  		return ERR_PTR(-ENOMEM);
>  
> -	INIT_LIST_HEAD(&omt->dev_list);
> -	spin_lock_init(&omt->dev_list_lock);
> +	status = nfs4_alloc_init_deviceid_cache(nfss->nfs_client,
> +						objio_free_dev);
> +	if (status) {
> +		printk(KERN_WARNING "%s: deviceid cache could not be "
> +			"initialized\n", __func__);
> +		kfree(omt);
> +		return ERR_PTR(status);
> +	}
> +	dprintk("%s: deviceid cache has been initialized successfully\n",
> +		__func__);
> +
>  	return omt;
>  }
>  
> -void objio_fini_mt(void *mountid)
> +void objio_fini_mt(struct nfs_server *nfss, void *mountid)
>  {
> -	_dev_list_remove_all(mountid);
> +	if (nfss->pnfs_curr_ld && nfss->nfs_client->cl_devid_cache)
> +		nfs4_put_deviceid_cache(nfss->nfs_client);
> +
>  	kfree(mountid);
>  }
>  
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 259c616..0b541e6 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -752,7 +752,7 @@ objlayout_initialize_mountpoint(struct nfs_server *server,
>  {
>  	void *data;
>  
> -	data = objio_init_mt();
> +	data = objio_init_mt(server);
>  	if (IS_ERR(data)) {
>  		printk(KERN_INFO "%s: objlayout lib not ready err=%ld\n",
>  		       __func__, PTR_ERR(data));
> @@ -771,7 +771,8 @@ static int
>  objlayout_uninitialize_mountpoint(struct nfs_server *server)
>  {
>  	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
> -	objio_fini_mt(server->pnfs_ld_data);
> +
> +	objio_fini_mt(server, server->pnfs_ld_data);
>  	return 0;
>  }
>  
> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
> index adec7ad..a531016 100644
> --- a/fs/nfs/objlayout/objlayout.h
> +++ b/fs/nfs/objlayout/objlayout.h
> @@ -113,8 +113,8 @@ struct objlayout_io_state {
>  /*
>   * Raid engine I/O API
>   */
> -extern void *objio_init_mt(void);
> -extern void objio_fini_mt(void *mt);
> +extern void *objio_init_mt(struct nfs_server *nfss);
> +extern void objio_fini_mt(struct nfs_server *nfss, void *mt);
>  
>  extern int objio_alloc_lseg(void **outp,
>  	struct pnfs_layout_hdr *pnfslay,
> diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
> index fd46e96..362d088 100644
> --- a/fs/nfs/objlayout/panfs_shim.c
> +++ b/fs/nfs/objlayout/panfs_shim.c
> @@ -51,12 +51,12 @@
>  struct panfs_export_operations *panfs_export_ops;
>  
>  void *
> -objio_init_mt(void)
> +objio_init_mt(struct nfs_server *nfss)
>  {
>  	return panfs_export_ops == NULL ? ERR_PTR(-EAGAIN) : NULL;
>  }
>  
> -void objio_fini_mt(void *mountid)
> +void objio_fini_mt(struct nfs_server *nfss, void *mountid)
>  {
>  }
>  

