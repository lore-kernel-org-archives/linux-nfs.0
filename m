Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:61768 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757212Ab2BIQth convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2012 11:49:37 -0500
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1328805686-19559-1-git-send-email-dros@netapp.com>
Date: Thu, 9 Feb 2012 11:49:31 -0500
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <557390A3-420A-4787-99E7-5B502D11E56D@oracle.com>
References: <1328805686-19559-1-git-send-email-dros@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 9, 2012, at 11:41 AM, Weston Andros Adamson wrote:

> Include RPC statistics from all data servers in /proc/self/mountstats for pNFS
> filelayout mounts.
> 
> The additional info printed on the "per-op statistics" line does not break
> current mountstats(8) from nfs-utils.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> This is clearly a better approach than I was taking trying to keep DS rpc stats
> separate in /proc/self/mountstats.

I guess you could argue that since these are "mount" stats, it's a per mount point thing, not necessarily a per server thing.  We've simply had it that way because prior to pNFS, you couldn't have more than one server per mount point.

At some point we might consider also displaying some fs_locations data here, and perhaps a count of how many migration or replication failover events have been seen.  For another day.

> FYI, there are no other callers of rpc_print_iostats().
> 
> The new output of /proc/self/mountstats works fine with current mountstats 
> userland tool.  The additional data on the per-op statistics line doesn't make
> it into the output, but I left it in /proc/self/mountstats because it doesn't
> break anything and can be included in newer versions of mountstats.
> 
> I plan on adding the per-DS stats (rpc and others) somewhere in /proc/fs/nfsfs/
> soon.
> 
> fs/nfs/nfs4filelayout.c        |   30 ++++++++++++++++++++++++++
> fs/nfs/pnfs.h                  |   23 ++++++++++++++++++++
> fs/nfs/pnfs_dev.c              |   45 ++++++++++++++++++++++++++++++++++++++++
> fs/nfs/super.c                 |    3 +-
> include/linux/sunrpc/metrics.h |   13 +++++++++-
> net/sunrpc/stats.c             |   38 ++++++++++++++++++++++++++++++++-
> 6 files changed, 147 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 79be7ac..51c71e5 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -33,6 +33,8 @@
> #include <linux/nfs_page.h>
> #include <linux/module.h>
> 
> +#include <linux/sunrpc/metrics.h>
> +
> #include "internal.h"
> #include "nfs4filelayout.h"
> 
> @@ -918,6 +920,33 @@ filelayout_free_deveiceid_node(struct nfs4_deviceid_node *d)
> 	nfs4_fl_free_deviceid(container_of(d, struct nfs4_file_layout_dsaddr, id_node));
> }
> 
> +static unsigned int
> +filelayout_rpc_add_iostats(struct rpc_iostats *total,
> +			   unsigned int maxproc,
> +			   struct nfs4_deviceid_node *d)
> +{
> +	struct nfs4_file_layout_dsaddr *dsaddr;
> +	struct nfs4_pnfs_ds *ds;
> +	unsigned int num_ds = 0;
> +	u32 i;
> +
> +	dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
> +
> +	for (i = 0; i < dsaddr->ds_num; i++) {
> +		ds = dsaddr->ds_list[i];
> +
> +		/* only add iostats if nfs_client is different from MDS */
> +		if (ds && ds->ds_clp && d->nfs_client != ds->ds_clp) {
> +			struct rpc_clnt *clnt = ds->ds_clp->cl_rpcclient;
> +			rpc_add_iostats(total, clnt->cl_metrics,
> +					min(maxproc, clnt->cl_maxproc));
> +			num_ds++;
> +		}
> +	}
> +
> +	return num_ds;
> +}
> +
> static struct pnfs_layoutdriver_type filelayout_type = {
> 	.id			= LAYOUT_NFSV4_1_FILES,
> 	.name			= "LAYOUT_NFSV4_1_FILES",
> @@ -932,6 +961,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
> 	.read_pagelist		= filelayout_read_pagelist,
> 	.write_pagelist		= filelayout_write_pagelist,
> 	.free_deviceid_node	= filelayout_free_deveiceid_node,
> +	.ds_rpc_add_iostats	= filelayout_rpc_add_iostats,
> };
> 
> static int __init nfs4filelayout_init(void)
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 53d593a..d1b82eb 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -72,6 +72,7 @@ enum layoutdriver_policy_flags {
> };
> 
> struct nfs4_deviceid_node;
> +struct rpc_iostats;
> 
> /* Per-layout driver specific registration structure */
> struct pnfs_layoutdriver_type {
> @@ -119,6 +120,9 @@ struct pnfs_layoutdriver_type {
> 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> 				     struct xdr_stream *xdr,
> 				     const struct nfs4_layoutcommit_args *args);
> +
> +	unsigned int (*ds_rpc_add_iostats) (struct rpc_iostats *, unsigned int,
> +					    struct nfs4_deviceid_node *);
> };
> 
> struct pnfs_layout_hdr {
> @@ -239,6 +243,10 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
> struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
> bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
> void nfs4_deviceid_purge_client(const struct nfs_client *);
> +void nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
> +				     const struct nfs_client *clp,
> +				     const struct pnfs_layoutdriver_type *ld);
> +
> 
> static inline int lo_fail_bit(u32 iomode)
> {
> @@ -328,6 +336,15 @@ static inline int pnfs_return_layout(struct inode *ino)
> 	return 0;
> }
> 
> +static inline int
> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
> +{
> +	if (!pnfs_enabled_sb(nfss))
> +		return 0;
> +	nfs4_deviceid_rpc_print_iostats(m, nfss->nfs_client,
> +					nfss->pnfs_curr_ld);
> +	return 1;
> +}
> #else  /* CONFIG_NFS_V4_1 */
> 
> static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
> @@ -429,6 +446,12 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
> static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
> {
> }
> +
> +static inline void
> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
> +{
> +	return 0;
> +}
> #endif /* CONFIG_NFS_V4_1 */
> 
> #endif /* FS_NFS_PNFS_H */
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 4f359d2..aa5d102 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -29,6 +29,9 @@
>  */
> 
> #include <linux/export.h>
> +
> +#include <linux/sunrpc/metrics.h>
> +
> #include "pnfs.h"
> 
> #define NFSDBG_FACILITY		NFSDBG_PNFS
> @@ -115,6 +118,48 @@ nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
> }
> EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
> 
> +
> +void
> +nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
> +				const struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld)
> +{
> +	struct nfs4_deviceid_node *d;
> +	struct hlist_node *n;
> +	struct rpc_iostats *totals;
> +	char msgbuf[64];
> +	unsigned int num_ds = 0;
> +	unsigned int maxproc;
> +	long h;
> +
> +	if (!ld->ds_rpc_add_iostats)
> +		return;
> +	totals = rpc_alloc_iostats(clp->cl_rpcclient);
> +	if (!totals)
> +		return;
> +	maxproc = clp->cl_rpcclient->cl_maxproc;
> +	rpc_add_iostats(totals, clp->cl_rpcclient->cl_metrics, maxproc);
> +
> +	rcu_read_lock();
> +	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++) {
> +		hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[h], node) {
> +			if (d->ld == ld && d->nfs_client == clp) {
> +				if (atomic_read(&d->ref))
> +					num_ds += ld->ds_rpc_add_iostats(totals,
> +							maxproc, d);
> +			}
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	snprintf(msgbuf, sizeof(msgbuf),
> +		 " for the metadata server and %u data server%s", num_ds,
> +		 (num_ds != 1) ? "s" : "");
> +	rpc_print_iostats(seq, clp->cl_rpcclient, totals, msgbuf);
> +	rpc_free_iostats(totals);
> +}
> +EXPORT_SYMBOL_GPL(nfs4_deviceid_rpc_print_iostats);
> +
> /*
>  * Remove a deviceid from cache
>  *
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index d18a90b..76d0850 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -870,7 +870,8 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
> #endif
> 	seq_printf(m, "\n");
> 
> -	rpc_print_iostats(m, nfss->client);
> +	if (!pnfs_rpc_print_iostats(m, nfss))
> +		rpc_print_iostats(m, nfss->client, NULL, NULL);
> 
> 	return 0;
> }
> diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
> index b6edbc0..e6e04e4 100644
> --- a/include/linux/sunrpc/metrics.h
> +++ b/include/linux/sunrpc/metrics.h
> @@ -75,14 +75,23 @@ struct rpc_clnt;
> 
> struct rpc_iostats *	rpc_alloc_iostats(struct rpc_clnt *);
> void			rpc_count_iostats(struct rpc_task *);
> -void			rpc_print_iostats(struct seq_file *, struct rpc_clnt *);
> +void			rpc_print_iostats(struct seq_file *,
> +					  struct rpc_clnt *,
> +					  struct rpc_iostats *,
> +					  const char *);
> +void			rpc_add_iostats(struct rpc_iostats *,
> +					struct rpc_iostats *, unsigned int);
> void			rpc_free_iostats(struct rpc_iostats *);
> 
> #else  /*  CONFIG_PROC_FS  */
> 
> static inline struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt) { return NULL; }
> static inline void rpc_count_iostats(struct rpc_task *task) {}
> -static inline void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt) {}
> +static inline void rpc_print_iostats(struct seq_file *seq,
> +				     struct rpc_iostats *stat) {}
> +static inline void rpc_add_iostats(struct rpc_iostats *total,
> +				   struct rpc_iostats *new,
> +				   unsigned int maxproc) {}
> static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
> 
> #endif  /*  CONFIG_PROC_FS  */
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index 3c4f688..342df57 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -176,12 +176,16 @@ static void _print_name(struct seq_file *seq, unsigned int op,
> 		seq_printf(seq, "\t%12u: ", op);
> }
> 
> -void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
> +void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt,
> +		       struct rpc_iostats *altstats,
> +		       const char *altstats_msg)
> {
> 	struct rpc_iostats *stats = clnt->cl_metrics;
> 	struct rpc_xprt *xprt = clnt->cl_xprt;
> 	unsigned int op, maxproc = clnt->cl_maxproc;
> 
> +	if (altstats)
> +		stats = altstats;
> 	if (!stats)
> 		return;
> 
> @@ -192,7 +196,8 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
> 	if (xprt)
> 		xprt->ops->print_stats(xprt, seq);
> 
> -	seq_printf(seq, "\tper-op statistics\n");
> +	seq_printf(seq, "\tper-op statistics%s\n",
> +		   (altstats && altstats_msg) ? altstats_msg : "");
> 	for (op = 0; op < maxproc; op++) {
> 		struct rpc_iostats *metrics = &stats[op];
> 		_print_name(seq, op, clnt->cl_procinfo);
> @@ -209,6 +214,35 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
> }
> EXPORT_SYMBOL_GPL(rpc_print_iostats);
> 
> +void
> +rpc_add_iostats(struct rpc_iostats *totals, struct rpc_iostats *new,
> +		unsigned int maxproc)
> +{
> +	unsigned int op;
> +
> +	for (op = 0; op < maxproc; op++) {
> +		struct rpc_iostats *op_totals = &totals[op],
> +				   *op_new = &new[op];
> +
> +		op_totals->om_ops += op_new->om_ops;
> +		op_totals->om_ntrans += op_new->om_ntrans;
> +		op_totals->om_timeouts += op_new->om_timeouts;
> +
> +		op_totals->om_bytes_sent += op_new->om_bytes_sent;
> +		op_totals->om_bytes_recv += op_new->om_bytes_recv;
> +
> +		op_totals->om_queue = ktime_add(op_totals->om_queue,
> +					       op_new->om_queue);
> +
> +		op_totals->om_rtt = ktime_add(op_totals->om_rtt,
> +					      op_new->om_rtt);
> +
> +		op_totals->om_execute = ktime_add(op_totals->om_execute,
> +						 op_new->om_execute);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(rpc_add_iostats);
> +
> /*
>  * Register/unregister RPC proc files
>  */
> -- 
> 1.7.4.4
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




