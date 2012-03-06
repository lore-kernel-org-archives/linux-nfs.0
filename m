Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58149 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757961Ab2CFAA4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 19:00:56 -0500
Message-ID: <4F5553AD.1050100@panasas.com>
Date: Mon, 5 Mar 2012 16:00:45 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix nfs4_deviceid alignment
References: <20120305183541.2130.18514.stgit@degas.1015granger.net>
In-Reply-To: <20120305183541.2130.18514.stgit@degas.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/05/2012 10:36 AM, Chuck Lever wrote:
> Clean up due to code review.
> 
> The struct nfs4_deviceid's data field is not guaranteed to be u64-
> aligned.  Casting an array of chars to a u32 * or u64 * is considered
> generally hazardous.
> 
> Since the pointer casts are done just to print these objects, use
> get_unaligned() to ensure the access is legal no matter what.
> 
> Make sure code always uses the .data field when comparing or copying
> these structures.
> 
> Also, sizeof(struct nfs4_deviceid) is the size of the in-core device
> ID data structure, but NFS4_DEVICEID4_SIZE is the number of octets in
> an XDR'd device ID.  The two are not interchangeable, even if they
> happen to have the same value.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Hi Boaz-
> 
> I'm thinking something like this.  Compile-tested only.
> 
>  fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
>  fs/nfs/blocklayout/extents.c        |    2 +-
>  fs/nfs/nfs4filelayout.c             |    3 +--
>  fs/nfs/nfs4filelayoutdev.c          |    6 ++++--
>  fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    5 +++--
>  fs/nfs/pnfs_dev.c                   |    8 +++++---
>  include/linux/pnfs_osd_xdr.h        |   16 +++++++++++-----
>  7 files changed, 26 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
> index b48f782..bae2e7b 100644
> --- a/fs/nfs/blocklayout/blocklayoutdev.c
> +++ b/fs/nfs/blocklayout/blocklayoutdev.c
> @@ -323,7 +323,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
>  			status = -ENOMEM;
>  			goto out_err;
>  		}
> -		memcpy(&be->be_devid, p, NFS4_DEVICEID4_SIZE);
> +		memcpy(&be->be_devid.data, p, NFS4_DEVICEID4_SIZE);
>  		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
>  		be->be_mdev = translate_devid(lo, &be->be_devid);
>  		if (!be->be_mdev)
> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> index 1f9a603..c8f54f5 100644
> --- a/fs/nfs/blocklayout/extents.c
> +++ b/fs/nfs/blocklayout/extents.c
> @@ -675,7 +675,7 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
>  	if (!xdr_start)
>  		goto out;
>  	list_for_each_entry_safe(lce, save, &bl->bl_commit, bse_node) {
> -		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
> +		p = xdr_reserve_space(xdr, 7 * 4 + NFS4_DEVICEID4_SIZE);
>  		if (!p)
>  			break;
>  		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data, NFS4_DEVICEID4_SIZE);
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 47e8f34..5d77819 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -550,8 +550,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
>  	if (unlikely(!p))
>  		goto out_err;
>  
> -	memcpy(id, p, sizeof(*id));
> -	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
> +	p = xdr_decode_opaque_fixed(p, id->data, NFS4_DEVICEID4_SIZE);
>  	nfs4_print_deviceid(id);
>  
>  	nfl_util = be32_to_cpup(p++);
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 41677f0..905c335 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -795,11 +795,13 @@ static void
>  filelayout_mark_devid_negative(struct nfs4_file_layout_dsaddr *dsaddr,
>  			       int err, const char *ds_remotestr)
>  {
> -	u32 *p = (u32 *)&dsaddr->id_node.deviceid;
> +	u32 *p = (u32 *)dsaddr->id_node.deviceid.data;
>  
>  	printk(KERN_ERR "NFS: data server %s connection error %d."
>  		" Deviceid [%x%x%x%x] marked out of use.\n",
> -		ds_remotestr, err, p[0], p[1], p[2], p[3]);
> +		ds_remotestr, err,
> +		get_unaligned(p), get_unaligned(p + 1),
> +		get_unaligned(p + 2), get_unaligned(p + 3));
>  
>  	spin_lock(&nfs4_ds_cache_lock);
>  	dsaddr->flags |= NFS4_DEVICE_ID_NEG_ENTRY;
> diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> index b3918f7..e14b938 100644
> --- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> +++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> @@ -56,12 +56,13 @@ static __be32 *
>  _osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
>  {
>  	p = xdr_decode_opaque_fixed(p, objid->oid_device_id.data,
> -				    sizeof(objid->oid_device_id.data));
> +				    NFS4_DEVICEID4_SIZE);
>  
>  	p = xdr_decode_hyper(p, &objid->oid_partition_id);
>  	p = xdr_decode_hyper(p, &objid->oid_object_id);
>  	return p;
>  }
> +
>  /*
>   * struct pnfs_osd_opaque_cred {
>   *	u32 cred_len;
> @@ -378,7 +379,7 @@ static inline __be32 *
>  pnfs_osd_xdr_encode_objid(__be32 *p, struct pnfs_osd_objid *object_id)
>  {
>  	p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.data,
> -				    sizeof(object_id->oid_device_id.data));
> +				    NFS4_DEVICEID4_SIZE);
>  	p = xdr_encode_hyper(p, object_id->oid_partition_id);
>  	p = xdr_encode_hyper(p, object_id->oid_object_id);
>  
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 4f359d2..3bf5ce1 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -46,10 +46,11 @@ static DEFINE_SPINLOCK(nfs4_deviceid_lock);
>  void
>  nfs4_print_deviceid(const struct nfs4_deviceid *id)
>  {
> -	u32 *p = (u32 *)id;
> +	u32 *p = (u32 *)id->data;
>  
>  	dprintk("%s: device id= [%x%x%x%x]\n", __func__,
> -		p[0], p[1], p[2], p[3]);
> +		get_unaligned(p), get_unaligned(p + 1),
> +		get_unaligned(p + 2), get_unaligned(p + 3));

They where not before, but these should be CPU ordered I think,
get_unaligned_be32(). Also in the other places. A be32 raw print is pretty
messy on le machines. Even with %x it can become ugly.

>  }
>  EXPORT_SYMBOL_GPL(nfs4_print_deviceid);
>  
> @@ -77,7 +78,8 @@ _lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
>  
>  	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
>  		if (d->ld == ld && d->nfs_client == clp &&
> -		    !memcmp(&d->deviceid, id, sizeof(*id))) {
> +		    !memcmp(&d->deviceid.data, id->data,
> +						NFS4_DEVICEID4_SIZE)) {
>  			if (atomic_read(&d->ref))
>  				return d;
>  			else
> diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
> index 435dd5f..e0557c1 100644
> --- a/include/linux/pnfs_osd_xdr.h
> +++ b/include/linux/pnfs_osd_xdr.h
> @@ -90,11 +90,17 @@ struct pnfs_osd_objid {
>   * kprint("dev(%llx:%llx)", _DEVID_LO(pointer), _DEVID_HI(pointer));
>   * BE style
>   */
> -#define _DEVID_LO(oid_device_id) \
> -	(unsigned long long)be64_to_cpup((__be64 *)(oid_device_id)->data)
> -
> -#define _DEVID_HI(oid_device_id) \
> -	(unsigned long long)be64_to_cpup(((__be64 *)(oid_device_id)->data) + 1)
> +static inline unsigned long long _DEVID_LO(struct nfs4_deviceid *id)
> +{
> +	__be64 *p = (__be64 *)id->data;
> +	return be64_to_cpu(get_unaligned(p));

get_unaligned_be64, which takes a void * so you don't need any cast or
temps.

I'll test with the get_unaligned_be64 bits, later today

> +}
> +
> +static inline unsigned long long _DEVID_HI(struct nfs4_deviceid *id)
> +{
> +	__be64 *p = (__be64 *)id->data;
> +	return be64_to_cpu(get_unaligned(p + 1));
> +}
>  
>  enum pnfs_osd_version {
>  	PNFS_OSD_MISSING              = 0,
> 

Let me test the obj-layout bits and come back to you

Thanks for doing this
Boaz
