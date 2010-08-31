Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:56558 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752510Ab0HaQcN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 12:32:13 -0400
Message-ID: <4C7D2E89.5040806@panasas.com>
Date: Tue, 31 Aug 2010 19:32:09 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: andros@netapp.com
CC: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 50/50] SQUASHME pnfs_submit: remove this unused code
References: <1281735122-1496-1-git-send-email-andros@netapp.com> <1281735122-1496-35-git-send-email-andros@netapp.com> <1281735122-1496-36-git-send-email-andros@netapp.com> <1281735122-1496-37-git-send-email-andros@netapp.com> <1281735122-1496-38-git-send-email-andros@netapp.com> <1281735122-1496-39-git-send-email-andros@netapp.com> <1281735122-1496-40-git-send-email-andros@netapp.com> <1281735122-1496-41-git-send-email-andros@netapp.com> <1281735122-1496-42-git-send-email-andros@netapp.com> <1281735122-1496-43-git-send-email-andros@netapp.com> <1281735122-1496-44-git-send-email-andros@netapp.com> <1281735122-1496-45-git-send-email-andros@netapp.com> <1281735122-1496-46-git-send-email-andros@netapp.com> <1281735122-1496-47-git-send-email-andros@netapp.com> <1281735122-1496-48-git-send-email-andros@netapp.com> <1281735122-1496-49-git-send-email-andros@netapp.com> <1281735122-1496-50-git-send-email-andros@netapp.com> <1281735122-1496-51-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-51-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/14/2010 12:32 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c           |    1 +
>  fs/nfs/file.c             |    1 +
>  fs/nfs/inode.c            |   10 +++++++++-
>  fs/nfs/nfs3proc.c         |    1 +
>  fs/nfs/nfs4_fs.h          |    1 +
>  fs/nfs/nfs4filelayout.c   |    3 +++
>  fs/nfs/nfs4filelayout.h   |    6 ++++++
>  fs/nfs/nfs4proc.c         |    2 ++
>  fs/nfs/pnfs.h             |   15 +++++++++++++++
>  fs/nfs/proc.c             |    1 +
>  fs/nfs/super.c            |   25 +++++++++++++++++++++++++
>  fs/nfs/write.c            |   11 +++++++++--
>  include/linux/nfs4.h      |    9 +++++++++
>  include/linux/nfs4_pnfs.h |   18 ++++++++++++++++++
>  include/linux/nfs_xdr.h   |    2 ++
>  include/linux/pnfs_xdr.h  |    6 +++---
>  16 files changed, 106 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index b53f61c..38ef02f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -39,6 +39,7 @@
>  #include <net/ipv6.h>
>  #include <linux/nfs_xdr.h>
>  #include <linux/sunrpc/bc_xprt.h>
> +#include <linux/nfs4_pnfs.h>
>  
>  #include <asm/system.h>
>  
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index d0ed767..bf17633 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -28,6 +28,7 @@
>  #include <linux/aio.h>
>  #include <linux/gfp.h>
>  #include <linux/swap.h>
> +#include <linux/pnfs_xdr.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 30d9ac6..6132f6b 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -279,7 +279,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>  		 */
>  		inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->file_inode_ops;
>  		if (S_ISREG(inode->i_mode)) {
> -			inode->i_fop = &nfs_file_operations;
> +			inode->i_fop = NFS_SB(sb)->nfs_client->rpc_ops->file_ops;
>  			inode->i_data.a_ops = &nfs_file_aops;
>  			inode->i_data.backing_dev_info = &NFS_SB(sb)->backing_dev_info;
>  		} else if (S_ISDIR(inode->i_mode)) {
> @@ -1207,6 +1207,14 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  		server->fsid = fattr->fsid;
>  
>  	/*
> +	 * file needs layout commit, server attributes may be stale
> +	 */
> +	if (layoutcommit_needed(nfsi) && nfsi->change_attr >= fattr->change_attr) {
> +		dprintk("NFS: %s: layoutcommit is needed for file %s/%ld\n",
> +			__func__, inode->i_sb->s_id, inode->i_ino);
> +		return 0;
> +	}
> +	/*
>  	 * Update the read time so we don't revalidate too often.
>  	 */
>  	nfsi->read_cache_jiffies = fattr->time_start;
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index fabb4f2..304c63c 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -833,6 +833,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
>  	.dentry_ops	= &nfs_dentry_operations,
>  	.dir_inode_ops	= &nfs3_dir_inode_operations,
>  	.file_inode_ops	= &nfs3_file_inode_operations,
> +	.file_ops	= &nfs_file_operations,
>  	.getroot	= nfs3_proc_get_root,
>  	.getattr	= nfs3_proc_getattr,
>  	.setattr	= nfs3_proc_setattr,
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index d6440fc..dd584e5 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -334,6 +334,7 @@ extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
>  extern void nfs_release_seqid(struct nfs_seqid *seqid);
>  extern void nfs_free_seqid(struct nfs_seqid *seqid);
>  
> +/* write.c */

A comment was removed, but is needed back just by itself? What changed?

>  extern const nfs4_stateid zero_stateid;
>  
>  /* nfs4xdr.c */
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index fea1772..b2ce478 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -65,6 +65,9 @@ MODULE_DESCRIPTION("The NFSv4 file layout driver");
>  /* Callback operations to the pNFS client */
>  struct pnfs_client_operations *pnfs_callback_ops;
>  
> +/* Forward declaration */

I'm not sure we need the comment

> +struct layoutdriver_io_operations filelayout_io_operations;
> +

Forward declaration in a .c file are we missing a "static"?

>  int
>  filelayout_initialize_mountpoint(struct nfs_client *clp)
>  {
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index f8f7c05..1de176d 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -22,6 +22,7 @@
>  
>  #define NFS4_PNFS_MAX_STRIPE_CNT 4096
>  #define NFS4_PNFS_MAX_MULTI_CNT  64 /* 256 fit into a u8 stripe_index */
> +#define NFS4_PNFS_MAX_MULTI_DS   2
>  
>  #define FILE_DSADDR(lseg) (container_of(lseg->deviceid, \
>  					struct nfs4_file_layout_dsaddr, \
> @@ -50,6 +51,11 @@ struct nfs4_file_layout_dsaddr {
>  	struct nfs4_pnfs_ds	*ds_list[1];
>  };
>  
> +struct nfs4_pnfs_dev_hlist {
> +	rwlock_t		dev_lock;
> +	struct hlist_head	dev_list[NFS4_PNFS_DEV_HASH_SIZE];
> +};
> +
>  struct nfs4_filelayout_segment {
>  	u32 stripe_type;
>  	u32 commit_through_mds;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8879fab..05f072c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4711,6 +4711,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  	dprintk("<-- %s status= %d\n", __func__, status);
>  	return status;
>  }
> +EXPORT_SYMBOL(nfs4_proc_exchange_id);
>  
>  struct nfs4_get_lease_time_data {
>  	struct nfs4_get_lease_time_args *args;
> @@ -5887,6 +5888,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
>  	.dentry_ops	= &nfs4_dentry_operations,
>  	.dir_inode_ops	= &nfs4_dir_inode_operations,
>  	.file_inode_ops	= &nfs4_file_inode_operations,
> +	.file_ops	= &nfs_file_operations,
>  	.getroot	= nfs4_proc_get_root,
>  	.getattr	= nfs4_proc_getattr,
>  	.setattr	= nfs4_proc_setattr,
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 80f67c7..78d5c30 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -30,6 +30,8 @@ extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data,
>  extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait);
>  
>  /* pnfs.c */
> +extern const nfs4_stateid zero_stateid;
> +
>  void put_lseg(struct pnfs_layout_segment *lseg);
>  void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>  	enum pnfs_iomode access_type,
> @@ -69,6 +71,9 @@ void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
>  #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
>  				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
>  				     (srv)->pnfs_curr_ld->ld_io_ops->opname)
> +#define PNFS_EXISTS_LDPOLICY_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
> +				     (srv)->pnfs_curr_ld->ld_policy_ops && \
> +				     (srv)->pnfs_curr_ld->ld_policy_ops->opname)
>  
>  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
>  
> @@ -176,6 +181,16 @@ pnfs_try_to_commit(struct nfs_write_data *data,
>  	return PNFS_NOT_ATTEMPTED;
>  }
>  
> +static inline int pnfs_get_write_status(struct nfs_write_data *data)
> +{
> +	return 0;
> +}
> +
> +static inline int pnfs_get_read_status(struct nfs_read_data *data)
> +{
> +	return 0;
> +}
> +
>  static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  {
>  	return 0;
> diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> index 737160d..1837a05 100644
> --- a/fs/nfs/proc.c
> +++ b/fs/nfs/proc.c
> @@ -694,6 +694,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
>  	.dentry_ops	= &nfs_dentry_operations,
>  	.dir_inode_ops	= &nfs_dir_inode_operations,
>  	.file_inode_ops	= &nfs_file_inode_operations,
> +	.file_ops	= &nfs_file_operations,
>  	.getroot	= nfs_proc_get_root,
>  	.getattr	= nfs_proc_getattr,
>  	.setattr	= nfs_proc_setattr,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index f9df16d..cd9f8d4 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -64,6 +64,7 @@
>  #include "iostat.h"
>  #include "internal.h"
>  #include "fscache.h"
> +#include "pnfs.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_VFS
>  
> @@ -669,6 +670,28 @@ static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
>  
>  	return 0;
>  }
> +#ifdef CONFIG_NFS_V4_1
> +void show_sessions(struct seq_file *m, struct nfs_server *server)
> +{
> +	if (nfs4_has_session(server->nfs_client))
> +		seq_printf(m, ",sessions");
> +}
> +#else
> +void show_sessions(struct seq_file *m, struct nfs_server *server) {}
> +#endif
> +
> +#ifdef CONFIG_NFS_V4_1
> +void show_pnfs(struct seq_file *m, struct nfs_server *server)
> +{
> +	seq_printf(m, ",pnfs=");
> +	if (server->pnfs_curr_ld)
> +		seq_printf(m, "%s", server->pnfs_curr_ld->name);
> +	else
> +		seq_printf(m, "not configured");
> +}
> +#else  /* CONFIG_NFS_V4_1 */
> +void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
> +#endif /* CONFIG_NFS_V4_1 */
>  
>  /*
>   * Present statistical information for this VFS mountpoint
> @@ -707,6 +730,8 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
>  		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
>  		seq_printf(m, ",bm1=0x%x", nfss->attr_bitmask[1]);
>  		seq_printf(m, ",acl=0x%x", nfss->acl_bitmask);
> +		show_sessions(m, nfss);
> +		show_pnfs(m, nfss);
>  	}
>  #endif
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 2251551..99af688 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -20,6 +20,7 @@
>  #include <linux/nfs_mount.h>
>  #include <linux/nfs_page.h>
>  #include <linux/backing-dev.h>
> +#include <linux/module.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -68,6 +69,7 @@ void nfs_commit_free(struct nfs_write_data *p)
>  		kfree(p->pagevec);
>  	mempool_free(p, nfs_commit_mempool);
>  }
> +EXPORT_SYMBOL(nfs_commit_free);
>  
>  struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
>  {
> @@ -1252,6 +1254,9 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
>  	if (task->tk_status >= 0 && resp->count < argp->count) {
>  		static unsigned long    complain;
>  
> +		dprintk("NFS:       short write:"
> +			" (resp->count %u) < (argp->count = %u)\n",
> +			resp->count, argp->count);
>  		nfs_inc_stats(data->inode, NFSIOS_SHORTWRITE);
>  
>  		/* Has the server at least made some progress? */
> @@ -1268,7 +1273,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
>  				 */
>  				argp->stable = NFS_FILE_SYNC;
>  			}
> -			nfs_restart_rpc(task, server->nfs_client);
> +			nfs_restart_rpc(task, clp);

OK, I admit, I don't understand what happened here?

>  			return -EAGAIN;
>  		}
>  		if (time_before(complain, jiffies)) {
> @@ -1607,6 +1612,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>   */
>  int nfs_wb_all(struct inode *inode)
>  {
> +	int ret;
>  	struct writeback_control wbc = {
>  		.sync_mode = WB_SYNC_ALL,
>  		.nr_to_write = LONG_MAX,
> @@ -1614,7 +1620,8 @@ int nfs_wb_all(struct inode *inode)
>  		.range_end = LLONG_MAX,
>  	};
>  
> -	return sync_inode(inode, &wbc);
> +	ret = sync_inode(inode, &wbc);
> +	return ret;

Why is this needed back in?

>  }
>  
>  int nfs_wb_page_cancel(struct inode *inode, struct page *page)
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index e947a32..e6748cd 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -492,6 +492,7 @@ enum lock_type4 {
>  #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
>  #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
>  #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
> +#define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
>  
>  #define NFSPROC4_NULL 0
>  #define NFSPROC4_COMPOUND 1
> @@ -606,6 +607,14 @@ enum pnfs_notify_deviceid_type4 {
>  #define NFL4_UFLG_COMMIT_THRU_MDS	0x00000002
>  #define NFL4_UFLG_STRIPE_UNIT_SIZE_MASK	0xFFFFFFC0
>  
> +/* Encoded in the loh_body field of type layouthint4 */
> +enum filelayout_hint_care4 {
> +	NFLH4_CARE_DENSE		= NFL4_UFLG_DENSE,
> +	NFLH4_CARE_COMMIT_THRU_MDS	= NFL4_UFLG_COMMIT_THRU_MDS,
> +	NFLH4_CARE_STRIPE_UNIT_SIZE	= 0x00000040,
> +	NFLH4_CARE_STRIPE_COUNT		= 0x00000080
> +};
> +
>  #endif
>  #endif
>  

Please, again don't split out the STD definitions. Even if not yet used
I don't see the point. I do see why it's bad, it forces the developer
to read the STD instead of trusting an header for been complete and
accurate.

> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
> index ef160e6..6236687 100644
> --- a/include/linux/nfs4_pnfs.h
> +++ b/include/linux/nfs4_pnfs.h
> @@ -20,6 +20,8 @@ enum pnfs_try_status {
>  	PNFS_NOT_ATTEMPTED = 1,
>  };
>  
> +#define NFS4_PNFS_GETDEVLIST_MAXNUM 16
> +
>  /* Per-layout driver specific registration structure */
>  struct pnfs_layoutdriver_type {
>  	const u32 id;
> @@ -60,6 +62,12 @@ PNFS_LD_IO_OPS(struct pnfs_layout_type *lo)
>  	return PNFS_LD(lo)->ld_io_ops;
>  }
>  
> +static inline struct layoutdriver_policy_operations *
> +PNFS_LD_POLICY_OPS(struct pnfs_layout_type *lo)
> +{
> +	return PNFS_LD(lo)->ld_policy_ops;
> +}
> +
>  static inline bool
>  has_layout(struct nfs_inode *nfsi)
>  {
> @@ -165,6 +173,12 @@ struct pnfs_device {
>  	unsigned int  dev_notify_types;
>  };
>  
> +struct pnfs_devicelist {
> +	unsigned int		eof;
> +	unsigned int		num_devs;
> +	struct pnfs_deviceid	dev_id[NFS4_PNFS_GETDEVLIST_MAXNUM];
> +};
> +
>  /*
>   * Device ID RCU cache. A device ID is unique per client ID and layout type.
>   */
> @@ -222,6 +236,7 @@ extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
>  struct pnfs_client_operations {
>  	int (*nfs_getdeviceinfo) (struct nfs_server *,
>  				  struct pnfs_device *dev);
> +	void (*nfs_return_layout) (struct inode *);
>  };
>  
>  extern struct pnfs_client_operations pnfs_ops;
> @@ -229,4 +244,7 @@ extern struct pnfs_client_operations pnfs_ops;
>  extern struct pnfs_client_operations *pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
>  extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
>  
> +#define NFS4_PNFS_MAX_LAYOUTS 4
> +#define NFS4_PNFS_PRIVATE_LAYOUT 0x80000000
> +
>  #endif /* LINUX_NFS4_PNFS_H */
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 42c5ccf..4afeaeb 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1046,6 +1046,7 @@ struct nfs_rpc_ops {
>  	const struct dentry_operations *dentry_ops;
>  	const struct inode_operations *dir_inode_ops;
>  	const struct inode_operations *file_inode_ops;
> +	const struct file_operations *file_ops;
>  
>  	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
>  			    struct nfs_fsinfo *);
> @@ -1110,6 +1111,7 @@ struct nfs_rpc_ops {
>  extern const struct nfs_rpc_ops	nfs_v2_clientops;
>  extern const struct nfs_rpc_ops	nfs_v3_clientops;
>  extern const struct nfs_rpc_ops	nfs_v4_clientops;
> +extern const struct nfs_rpc_ops	pnfs_v4_clientops;
>  extern struct rpc_version	nfs_version2;
>  extern struct rpc_version	nfs_version3;
>  extern struct rpc_version	nfs_version4;
> diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
> index ed16c65..c9a01b3 100644
> --- a/include/linux/pnfs_xdr.h
> +++ b/include/linux/pnfs_xdr.h
> @@ -89,9 +89,9 @@ struct pnfs_layoutcommit_data {
>  };
>  
>  struct nfs4_pnfs_layoutreturn_arg {
> -	__u32   reclaim;
> -	__u32   layout_type;
> -	__u32   return_type;
> +	__u32	reclaim;
> +	__u32	layout_type;
> +	__u32	return_type;

Is that a white space change of a tab to 3 spaces? could we make one
big white space SQUASHME separate from other code?

>  	struct nfs4_pnfs_layout_segment lseg;
>  	struct inode *inode;
>  	struct nfs4_sequence_args seq_args;

And all of Benny's comments as well for me.
Thanks
Boaz

