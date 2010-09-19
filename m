Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33898 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751645Ab0ISTHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Sep 2010 15:07:21 -0400
Message-ID: <4C965F66.7000200@panasas.com>
Date: Sun, 19 Sep 2010 21:07:18 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/12] RFC: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
References: <1284779874-10499-1-git-send-email-iisaman@netapp.com> <1284779874-10499-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1284779874-10499-12-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/18/2010 05:17 AM, Fred Isaman wrote:
> From: The pNFS Team <linux-nfs@vger.kernel.org>
> 
> Add the ability to actually send LAYOUTGET and GETDEVICEINFO.  This also adds
> in the machinery to handle layout state and the deviceid cache.  Note that
> GETDEVICEINFO is not called directly by the generic layer.  Instead it
> is called by the drivers while parsing the LAYOUTGET opaque data in response
> to an unknown device id embedded therein.  Annoyingly, RFC 5661 only encodes
> device ids within the driver-specific opaque data.
> 

Fred, In regard to device cache at least, this is a complete new code then what
I knew before. I wish you could send a SQUASHME diff first of what has changed.

> Signed-off-by: TBD - melding/reorganization of several patches

<snip>

> +/*
> + * Device ID cache. Currently supports one layout type per struct nfs_client.
> + * Add layout type to the lookup key to expand to support multiple types.
> + */
> +int
> +nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
> +			 void (*free_callback)(struct nfs4_deviceid *))
> +{
> +	struct nfs4_deviceid_cache *c;
> +
> +	c = kzalloc(sizeof(struct nfs4_deviceid_cache), GFP_KERNEL);
> +	if (!c)
> +		return -ENOMEM;
> +	spin_lock(&clp->cl_lock);
> +	if (clp->cl_devid_cache != NULL) {
> +		atomic_inc(&clp->cl_devid_cache->dc_ref);
> +		dprintk("%s [kref [%d]]\n", __func__,
> +			atomic_read(&clp->cl_devid_cache->dc_ref));
> +		kfree(c);
> +	} else {
> +		/* kzalloc initializes hlists */
> +		spin_lock_init(&c->dc_lock);
> +		atomic_set(&c->dc_ref, 1);
> +		c->dc_free_callback = free_callback;
> +		clp->cl_devid_cache = c;
> +		dprintk("%s [new]\n", __func__);
> +	}
> +	spin_unlock(&clp->cl_lock);
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_alloc_init_deviceid_cache);
> +
> +void
> +nfs4_init_deviceid_node(struct nfs4_deviceid *d)
> +{
> +	INIT_HLIST_NODE(&d->de_node);
> +	atomic_set(&d->de_ref, 1);
> +}
> +EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
> +
> +/*
> + * Called from pnfs_layoutdriver_type->free_lseg
> + * last layout segment reference frees deviceid
> + */
> +void
> +nfs4_put_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_deviceid *devid)
> +{
> +	struct pnfs_deviceid *id = &devid->de_id;
> +	struct nfs4_deviceid *d;
> +	struct hlist_node *n;
> +	long h = nfs4_deviceid_hash(id);
> +
> +	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
> +	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
> +		return;
> +
> +	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
> +		if (!memcmp(&d->de_id, id, sizeof(*id))) {
> +			hlist_del_rcu(&d->de_node);
> +			spin_unlock(&c->dc_lock);
> +			synchronize_rcu();
> +			c->dc_free_callback(devid);

What?!? free the devid on every put? surly something went hey-wire

This used to be kref(ed)

> +			return;
> +		}
> +	spin_unlock(&c->dc_lock);
> +}
> +EXPORT_SYMBOL_GPL(nfs4_put_deviceid);
> +
> +/* Find and reference a deviceid */
> +struct nfs4_deviceid *
> +nfs4_find_get_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_deviceid *id)
> +{
> +	struct nfs4_deviceid *d;
> +	struct hlist_node *n;
> +	long hash = nfs4_deviceid_hash(id);
> +
> +	dprintk("--> %s hash %ld\n", __func__, hash);
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
> +		if (!memcmp(&d->de_id, id, sizeof(*id))) {
> +			if (!atomic_inc_not_zero(&d->de_ref)) {
> +				goto fail;
> +			} else {
> +				rcu_read_unlock();
> +				return d;
> +			}
> +		}
> +	}
> +fail:
> +	rcu_read_unlock();
> +	return NULL;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
> +
> +/*
> + * Add a deviceid to the cache.
> + * GETDEVICEINFOs for same deviceid can race. If deviceid is found, discard new
> + */
> +struct nfs4_deviceid *
> +nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_deviceid *new)
> +{
> +	struct nfs4_deviceid *d;
> +	struct hlist_node *n;
> +	long hash = nfs4_deviceid_hash(&new->de_id);
> +
> +	dprintk("--> %s hash %ld\n", __func__, hash);
> +	spin_lock(&c->dc_lock);
> +	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
> +		if (!memcmp(&d->de_id, &new->de_id, sizeof(new->de_id))) {
> +			spin_unlock(&c->dc_lock);
> +			dprintk("%s [discard]\n", __func__);
> +			c->dc_free_callback(new);
> +			return d;

I am totally confused and should be smacked on the head strong. As said above
one alloc_lseg adds the first, second comes in, but same deviceid, finds the first
and returns it (no refcounting). Then a first free_lseg nfs4_put_deviceid is called,
so the second lseg holds free memory?

> +		}
> +	}
> +	hlist_add_head_rcu(&new->de_node, &c->dc_deviceids[hash]);
> +	spin_unlock(&c->dc_lock);
> +	dprintk("%s [new]\n", __func__);
> +	return new;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_add_deviceid);
> +
> +void
> +nfs4_put_deviceid_cache(struct nfs_client *clp)
> +{
> +	struct nfs4_deviceid_cache *local = clp->cl_devid_cache;
> +
> +	dprintk("--> %s cl_devid_cache %p\n", __func__, clp->cl_devid_cache);
> +	if (atomic_dec_and_lock(&local->dc_ref, &clp->cl_lock)) {

Don't you want to make sure there are no hanging devices on this
cache. Please note that an add or find does not take the cache
reference only server_init does, right?

> +		clp->cl_devid_cache = NULL;
> +		spin_unlock(&clp->cl_lock);
> +		kfree(local);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(nfs4_put_deviceid_cache);

Note to self. Test code alot.

Fred:
 I don't understand. A cache property I'm looking for and which I do not
 See in this code, perhaps because I'm clueless.
 (And to be honest I have not understood it before as well, since I never
  actually ran with that code I posted.)
 Is:
 - An _add_ to queue should magically hold two references to the item, so
 - A matching _put_ does not deallocate the item but keeps it referenced
   once.
 - A find/put pair does not remove the item from cache as well (+=1/-=1)
 - [optional] At some future out-of-memory condition or when cache is to
   big, according to some specified max cache. The most unused items are
   dereferenced and if are not used (ref==0) are then removed.
 - At driver shut-down all cached devices are dereferenced (and if not used
   which they should) are dealocated.

So in effect if [optional] code above is not yet implemented then a
getdeviceinfo is never preformed twice for the same deviceid
(Assuming no device recall). This is what I had in osd, and is cardinal
for it's performance. Is that what we are aiming at?

> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 1c3eb02..b7de762 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -32,11 +32,13 @@
>  
>  struct pnfs_layout_segment {
>  	struct list_head fi_list;
> -	u32 iomode;
> +	struct pnfs_layout_range range;
>  	struct kref kref;
>  	struct pnfs_layout_hdr *layout;
>  };
>  
> +#define NFS4_PNFS_DEVICEID4_SIZE 16
> +
>  #ifdef CONFIG_NFS_V4_1
>  
>  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
> @@ -44,6 +46,7 @@ struct pnfs_layout_segment {
>  enum {
>  	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
>  	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
> +	NFS_LAYOUT_STATEID_SET,		/* have a valid layout stateid */
>  };
>  
>  /* Per-layout driver specific registration structure */
> @@ -54,26 +57,102 @@ struct pnfs_layoutdriver_type {
>  	struct module *owner;
>  	int (*initialize_mountpoint) (struct nfs_server *);
>  	int (*uninitialize_mountpoint) (struct nfs_server *);
> +	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
> +	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>  };
>  
>  struct pnfs_layout_hdr {
>  	unsigned long		refcount;
>  	struct list_head	layouts;   /* other client layouts */
>  	struct list_head	segs;      /* layout segments list */
> +	seqlock_t		seqlock;   /* Protects the stateid */
> +	nfs4_stateid		stateid;
>  	unsigned long		state;
>  	struct inode		*inode;
>  };
>  
> +struct pnfs_deviceid {

Please for my own sanity, could we change those names.
I'll post a patch once we settle on final code. I want this
to be nfs4_deviceid (And perhaps in that other header)

> +	char data[NFS4_PNFS_DEVICEID4_SIZE];
> +};
> +
> +struct pnfs_device {
> +	struct pnfs_deviceid dev_id;
> +	unsigned int  layout_type;
> +	unsigned int  mincount;
> +	struct page **pages;
> +	void          *area;
> +	unsigned int  pgbase;
> +	unsigned int  pglen;
> +};
> +
> +/*
> + * Device ID RCU cache. A device ID is unique per client ID and layout type.
> + */
> +#define NFS4_DEVICE_ID_HASH_BITS	5
> +#define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
> +#define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
> +
> +static inline u32
> +nfs4_deviceid_hash(struct pnfs_deviceid *id)
> +{
> +	unsigned char *cptr = (unsigned char *)id->data;
> +	unsigned int nbytes = NFS4_PNFS_DEVICEID4_SIZE;
> +	u32 x = 0;
> +
> +	while (nbytes--) {
> +		x *= 37;
> +		x += *cptr++;
> +	}
> +	return x & NFS4_DEVICE_ID_HASH_MASK;
> +}
> +
> +/* Device ID cache node */
> +struct nfs4_deviceid {

And this one rename to pnfs_deviceid_node

> +	struct hlist_node	de_node;
> +	struct pnfs_deviceid	de_id;
> +	atomic_t		de_ref;
> +};
> +
> +struct nfs4_deviceid_cache {
> +	spinlock_t		dc_lock;
> +	atomic_t		dc_ref;
> +	void			(*dc_free_callback)(struct nfs4_deviceid *);
> +	struct hlist_head	dc_deviceids[NFS4_DEVICE_ID_HASH_SIZE];
> +	struct hlist_head	dc_to_free;
> +};
> +

All these cache APIs below, the naming convention in this header is
to call them pnfs_xxx. They don't have any use in general nfs4.
(and are implemented in pnfs.c)

> +extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
> +				void (*free_callback)(struct nfs4_deviceid *));
> +extern void nfs4_put_deviceid_cache(struct nfs_client *);
> +extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);

Why is above exported? Can't we just call it from _add_

Boaz

> +extern struct nfs4_deviceid *nfs4_find_get_deviceid(
> +				struct nfs4_deviceid_cache *,
> +				struct pnfs_deviceid *);
> +extern struct nfs4_deviceid *nfs4_add_deviceid(struct nfs4_deviceid_cache *,
> +				struct nfs4_deviceid *);
> +extern void nfs4_put_deviceid(struct nfs4_deviceid_cache *c,
> +			      struct nfs4_deviceid *devid);
> +
>  extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
>  extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
>  
> +/* nfs4proc.c */
> +extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
> +				   struct pnfs_device *dev);
> +extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
> +
> +/* pnfs.c */
>  struct pnfs_layout_segment *
>  pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>  		   enum pnfs_iomode access_type);
>  void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>  void unset_pnfs_layoutdriver(struct nfs_server *);
> +int pnfs_layout_process(struct nfs4_layoutget *lgp);
>  void pnfs_destroy_layout(struct nfs_inode *);
>  void pnfs_destroy_all_layouts(struct nfs_client *);
> +void put_layout_hdr(struct inode *inode);
> +void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
> +			     struct nfs4_state *open_state);
>  
>  
>  static inline int lo_fail_bit(u32 iomode)
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 2dde7c8..dcdd11c 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -545,6 +545,8 @@ enum {
>  	NFSPROC4_CLNT_SEQUENCE,
>  	NFSPROC4_CLNT_GET_LEASE_TIME,
>  	NFSPROC4_CLNT_RECLAIM_COMPLETE,
> +	NFSPROC4_CLNT_LAYOUTGET,
> +	NFSPROC4_CLNT_GETDEVICEINFO,
>  };
>  
>  /* nfs41 types */
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index e670a9c..7512886 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -83,6 +83,7 @@ struct nfs_client {
>  	u32			cl_exchange_flags;
>  	struct nfs4_session	*cl_session; 	/* sharred session */
>  	struct list_head	cl_layouts;
> +	struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  #ifdef CONFIG_NFS_FSCACHE
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 7d68a5c..4953b58 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -186,6 +186,55 @@ struct nfs4_get_lease_time_res {
>  	struct nfs4_sequence_res	lr_seq_res;
>  };
>  
> +#define PNFS_LAYOUT_MAXSIZE 4096
> +
> +struct nfs4_layoutdriver_data {
> +	__u32 len;
> +	void *buf;
> +};
> +
> +struct pnfs_layout_range {
> +	u32 iomode;
> +	u64 offset;
> +	u64 length;
> +};
> +
> +struct nfs4_layoutget_args {
> +	__u32 type;
> +	struct pnfs_layout_range range;
> +	__u64 minlength;
> +	__u32 maxcount;
> +	struct inode *inode;
> +	struct nfs_open_context *ctx;
> +	struct nfs4_sequence_args seq_args;
> +};
> +
> +struct nfs4_layoutget_res {
> +	__u32 return_on_close;
> +	struct pnfs_layout_range range;
> +	__u32 type;
> +	nfs4_stateid stateid;
> +	struct nfs4_layoutdriver_data layout;
> +	struct nfs4_sequence_res seq_res;
> +};
> +
> +struct nfs4_layoutget {
> +	struct nfs4_layoutget_args args;
> +	struct nfs4_layoutget_res res;
> +	struct pnfs_layout_segment **lsegpp;
> +	int status;
> +};
> +
> +struct nfs4_getdeviceinfo_args {
> +	struct pnfs_device *pdev;
> +	struct nfs4_sequence_args seq_args;
> +};
> +
> +struct nfs4_getdeviceinfo_res {
> +	struct pnfs_device *pdev;
> +	struct nfs4_sequence_res seq_res;
> +};
> +
>  /*
>   * Arguments to the open call.
>   */

