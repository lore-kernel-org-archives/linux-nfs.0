Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44562 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753417Ab1DTTla convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 15:41:30 -0400
Subject: Re: [RFC 01/27] pnfs: CB_NOTIFY_DEVICEID
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303320368-20990-1-git-send-email-bhalevy@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
	 <1303320368-20990-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 15:41:25 -0400
Message-ID: <1303328485.23206.13.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 20:26 +0300, Benny Halevy wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Note: This functionlaity is incomplete as all layout segments referring to
> the 'to be removed device id' need to be reaped, and all in flight I/O drained.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/callback.h          |   20 +++++++++
>  fs/nfs/callback_proc.c     |   50 +++++++++++++++++++++++
>  fs/nfs/callback_xdr.c      |   96 +++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfs/nfs4filelayout.c    |    1 +
>  fs/nfs/nfs4filelayout.h    |    1 +
>  fs/nfs/nfs4filelayoutdev.c |   38 +++++++++++++++++-
>  fs/nfs/pnfs.h              |    3 +
>  7 files changed, 207 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 46d93ce..892128f 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -167,6 +167,26 @@ extern unsigned nfs4_callback_layoutrecall(
>  
>  extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
>  extern void nfs4_cb_take_slot(struct nfs_client *clp);
> +
> +struct cb_devicenotifyitem {
> +	uint32_t		cbd_notify_type;
> +	uint32_t		cbd_layout_type;
> +	struct nfs4_deviceid	cbd_dev_id;
> +	uint32_t		cbd_immediate;
> +};
> +
> +/* XXX: Should be dynamic up to max compound size */
> +#define NFS4_DEV_NOTIFY_MAXENTRIES 10
> +struct cb_devicenotifyargs {
> +	struct sockaddr			*addr;

No sockaddr_size parameter?

> +	int				 ndevs;
> +	struct cb_devicenotifyitem	 devs[NFS4_DEV_NOTIFY_MAXENTRIES];
> +};

Why can't we make this dynamic at this time?

> +
> +extern __be32 nfs4_callback_devicenotify(
> +	struct cb_devicenotifyargs *args,
> +	void *dummy, struct cb_process_state *cps);
> +
>  #endif /* CONFIG_NFS_V4_1 */
>  extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
>  extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 2f41dcce..99494f6 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -241,6 +241,56 @@ static void pnfs_recall_all_layouts(struct nfs_client *clp)
>  	do_callback_layoutrecall(clp, &args);
>  }
>  
> +__be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
> +				  void *dummy, struct cb_process_state *cps)
> +{
> +	int i;
> +	u32 res = 0;
> +	struct nfs_client *clp = cps->clp;
> +	struct nfs_server *server = NULL;
> +
> +	dprintk("%s: -->\n", __func__);
> +
> +	if (!clp) {
> +		res = NFS4ERR_OP_NOT_IN_SESSION;
> +		goto out;
> +	}
> +
> +	for (i = 0; i < args->ndevs; i++) {
> +		struct cb_devicenotifyitem *dev = &args->devs[i];
> +
> +		if (!server ||
> +		    server->pnfs_curr_ld->id != dev->cbd_layout_type) {
> +			rcu_read_lock();
> +			list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
> +				if (server->pnfs_curr_ld &&
> +				    server->pnfs_curr_ld->id == dev->cbd_layout_type) {
> +					rcu_read_unlock();
> +					goto found;
> +				}
> +			rcu_read_unlock();
> +			dprintk("%s: layout type %u not found\n",
> +				__func__, dev->cbd_layout_type);
> +			continue;
> +		}
> +
> +	found:
> +		if (!server->pnfs_curr_ld->delete_deviceid) {
> +			res = NFS4ERR_NOTSUPP;
> +			break;
> +		}
> +		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
> +			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
> +				"deleting instead\n", __func__);
> +		server->pnfs_curr_ld->delete_deviceid(&dev->cbd_dev_id);
> +	}
> +
> +out:
> +	dprintk("%s: exit with status = %u\n",
> +		__func__, res);
> +	return cpu_to_be32(res);
> +}
> +
>  int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
>  {
>  	if (delegation == NULL)
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 00ecf62..5ec2c12 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -25,6 +25,7 @@
>  
>  #if defined(CONFIG_NFS_V4_1)
>  #define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
> +#define CB_OP_DEVICENOTIFY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
>  #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
>  					4 + 1 + 3)
>  #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
> @@ -284,6 +285,93 @@ out:
>  	return status;
>  }
>  
> +static
> +__be32 decode_devicenotify_args(struct svc_rqst *rqstp,
> +				struct xdr_stream *xdr,
> +				struct cb_devicenotifyargs *args)
> +{
> +	__be32 *p;
> +	__be32 status = 0;
> +	u32 tmp;
> +	int n, i;
> +	args->ndevs = 0;
> +
> +	args->addr = svc_addr(rqstp);
> +
> +	/* Num of device notifications */
> +	p = read_buf(xdr, sizeof(uint32_t));
> +	if (unlikely(p == NULL)) {
> +		status = htonl(NFS4ERR_RESOURCE);
> +		goto out;
> +	}
> +	n = ntohl(*p++);
> +	if (n <= 0)
> +		goto out;
> +
> +	/* XXX: need to possibly return error in this case */
> +	if (n > NFS4_DEV_NOTIFY_MAXENTRIES) {
> +		dprintk("%s: Processing (%d) notifications out of (%d)\n",
> +			__func__, NFS4_DEV_NOTIFY_MAXENTRIES, n);
> +		n = NFS4_DEV_NOTIFY_MAXENTRIES;
> +	}
> +
> +	/* Decode each dev notification */
> +	for (i = 0; i < n; i++) {
> +		struct cb_devicenotifyitem *dev = &args->devs[i];
> +
> +		p = read_buf(xdr, (4 * sizeof(uint32_t)) + NFS4_DEVICEID4_SIZE);
> +		if (unlikely(p == NULL)) {
> +			status = htonl(NFS4ERR_RESOURCE);
> +			goto out;
> +		}
> +
> +		tmp = ntohl(*p++);	/* bitmap size */
> +		if (tmp != 1) {
> +			status = htonl(NFS4ERR_INVAL);
> +			goto out;
> +		}
> +		dev->cbd_notify_type = ntohl(*p++);
> +		if (dev->cbd_notify_type != NOTIFY_DEVICEID4_CHANGE &&
> +		    dev->cbd_notify_type != NOTIFY_DEVICEID4_DELETE) {
> +			status = htonl(NFS4ERR_INVAL);
> +			goto out;
> +		}
> +
> +		tmp = ntohl(*p++);	/* opaque size */
> +		if (((dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) &&
> +		     (tmp != NFS4_DEVICEID4_SIZE + 8)) ||
> +		    ((dev->cbd_notify_type == NOTIFY_DEVICEID4_DELETE) &&
> +		     (tmp != NFS4_DEVICEID4_SIZE + 4))) {
> +			status = htonl(NFS4ERR_INVAL);
> +			goto out;
> +		}
> +		dev->cbd_layout_type = ntohl(*p++);
> +		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
> +		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
> +
> +		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
> +			p = read_buf(xdr, sizeof(uint32_t));
> +			if (unlikely(p == NULL)) {
> +				status = htonl(NFS4ERR_DELAY);
> +				goto out;
> +			}
> +			dev->cbd_immediate = ntohl(*p++);
> +		} else {
> +			dev->cbd_immediate = 0;
> +		}
> +
> +		args->ndevs++;
> +
> +		dprintk("%s: type %d layout 0x%x immediate %d\n",
> +			__func__, dev->cbd_notify_type, dev->cbd_layout_type,
> +			dev->cbd_immediate);
> +	}
> +out:
> +	dprintk("%s: status %d ndevs %d\n",
> +		__func__, ntohl(status), args->ndevs);
> +	return status;
> +}
> +
>  static __be32 decode_sessionid(struct xdr_stream *xdr,
>  				 struct nfs4_sessionid *sid)
>  {
> @@ -639,10 +727,10 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
>  	case OP_CB_RECALL_ANY:
>  	case OP_CB_RECALL_SLOT:
>  	case OP_CB_LAYOUTRECALL:
> +	case OP_CB_NOTIFY_DEVICEID:
>  		*op = &callback_ops[op_nr];
>  		break;
>  
> -	case OP_CB_NOTIFY_DEVICEID:
>  	case OP_CB_NOTIFY:
>  	case OP_CB_PUSH_DELEG:
>  	case OP_CB_RECALLABLE_OBJ_AVAIL:
> @@ -849,6 +937,12 @@ static struct callback_op callback_ops[] = {
>  			(callback_decode_arg_t)decode_layoutrecall_args,
>  		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
>  	},
> +	[OP_CB_NOTIFY_DEVICEID] = {
> +		.process_op = (callback_process_op_t)nfs4_callback_devicenotify,
> +		.decode_args =
> +			(callback_decode_arg_t)decode_devicenotify_args,
> +		.res_maxsize = CB_OP_DEVICENOTIFY_RES_MAXSZ,
> +	},
>  	[OP_CB_SEQUENCE] = {
>  		.process_op = (callback_process_op_t)nfs4_callback_sequence,
>  		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index e6e0c294..2feab7f 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -867,6 +867,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>  	.commit_pagelist	= filelayout_commit_pagelist,
>  	.read_pagelist		= filelayout_read_pagelist,
>  	.write_pagelist		= filelayout_write_pagelist,
> +	.delete_deviceid	= filelayout_delete_deviceid,
>  };
>  
>  static int __init nfs4filelayout_init(void)
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index 7c44579..8be70ab 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -105,5 +105,6 @@ nfs4_fl_find_get_deviceid(struct nfs4_deviceid *dev_id);
>  extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
>  struct nfs4_file_layout_dsaddr *
>  get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id);
> +void filelayout_delete_deviceid(struct nfs4_deviceid *);
>  
>  #endif /* FS_NFS_NFS4FILELAYOUT_H */
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index de5350f..601aaea 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -601,7 +601,7 @@ void
>  nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
>  {
>  	if (atomic_dec_and_lock(&dsaddr->ref, &filelayout_deviceid_lock)) {
> -		hlist_del_rcu(&dsaddr->node);
> +		hlist_del_init_rcu(&dsaddr->node);
>  		spin_unlock(&filelayout_deviceid_lock);
>  
>  		synchronize_rcu();
> @@ -631,6 +631,42 @@ fail:
>  	return NULL;
>  }
>  
> +static struct nfs4_file_layout_dsaddr *
> +nfs4_fl_unhash_deviceid(struct nfs4_deviceid *id)
> +{
> +	struct nfs4_file_layout_dsaddr *d;
> +	struct hlist_node *n;
> +	long hash = nfs4_fl_deviceid_hash(id);
> +
> +	dprintk("%s: hash %ld\n", __func__, hash);
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(d, n, &filelayout_deviceid_cache[hash], node)
> +		if (!memcmp(&d->deviceid, id, sizeof(*id)))
> +			goto found;
> +	rcu_read_unlock();
> +	return NULL;
> +
> +found:
> +	rcu_read_unlock();

Is there a reason why we should drop the rcu lock here...

> +	spin_lock(&filelayout_deviceid_lock);
> +	hlist_del_init_rcu(&d->node);
> +	spin_unlock(&filelayout_deviceid_lock);

...instead of here? IOW: do we need to enable preemption before we
redisable it in the spin_lock() call?

Also, how are you preventing races? There is no test under the spin lock
for whether or not the device is still hashed before you call
hlist_del_init_rcu(), so how do you know that it is safe to put the
reference to filelayout_delete_deviceid()?

> +	synchronize_rcu();
> +
> +	return d;
> +}
> +
> +void
> +filelayout_delete_deviceid(struct nfs4_deviceid *id)
> +{
> +	struct nfs4_file_layout_dsaddr *d;
> +
> +	d = nfs4_fl_unhash_deviceid(id);
> +	/* balance the initial ref taken in decode_and_add_device */
> +	if (d && atomic_dec_and_test(&d->ref))
> +		nfs4_fl_free_deviceid(d);
> +}
> +
>  /*
>   * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
>   * Then: ((res + fsi) % dsaddr->stripe_count)
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index bc48272..4cb0a0d 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -89,6 +89,9 @@ struct pnfs_layoutdriver_type {
>  	 */
>  	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
>  	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
> +
> +	/* device notification methods */
> +	void (*delete_deviceid)(struct nfs4_deviceid *);
>  };
>  
>  struct pnfs_layout_hdr {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

