Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37619 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757918Ab1ELQH3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2011 12:07:29 -0400
Received: by iwn34 with SMTP id 34so1534496iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 12 May 2011 09:07:28 -0700 (PDT)
In-Reply-To: <1304960987-4457-1-git-send-email-bhalevy@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
	<1304960987-4457-1-git-send-email-bhalevy@panasas.com>
Date: Thu, 12 May 2011 12:07:28 -0400
Message-ID: <BANLkTin4G6B=gFyp5tkfq__GtDH8w2RpYg@mail.gmail.com>
Subject: Re: [PATCH v2 18/29] pnfs: support for non-rpc layout drivers
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 9, 2011 at 1:09 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> Non-rpc layout driver such as for objects and blocks
> implement their own I/O path and error handling logic.
> Therefore bypass NFS-based error handling for these layout drivers.
>
> [get rid of PNFS_USE_RPC_CODE]
> [get rid of __nfs4_write_done_cb]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/internal.h       |    1 +
>  fs/nfs/nfs4proc.c       |    9 ++++++-
>  fs/nfs/pnfs.c           |   48 +++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/pnfs.h           |    2 +
>  include/linux/nfs_xdr.h |    2 +
>  5 files changed, 60 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index ce118ce..bcf0f0f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -310,6 +310,7 @@ extern int nfs_migrate_page(struct address_space *,
>  #endif
>
>  /* nfs4proc.c */
> +extern void __nfs4_read_done_cb(struct nfs_read_data *);
>  extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
>  extern int nfs4_init_client(struct nfs_client *clp,
>                            const struct rpc_timeout *timeparms,
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9bf41ea..da51abe 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3146,6 +3146,11 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
>        return err;
>  }
>
> +void __nfs4_read_done_cb(struct nfs_read_data *data)
> +{
> +       nfs_invalidate_atime(data->inode);
> +}
> +
>  static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  {
>        struct nfs_server *server = NFS_SERVER(data->inode);
> @@ -3155,7 +3160,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>                return -EAGAIN;
>        }
>
> -       nfs_invalidate_atime(data->inode);
> +       __nfs4_read_done_cb(data);
>        if (task->tk_status > 0)
>                renew_lease(server, data->timestamp);
>        return 0;
> @@ -3205,7 +3210,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
>        }
>        if (task->tk_status >= 0) {
>                renew_lease(NFS_SERVER(inode), data->timestamp);
> -               nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
> +               nfs_post_op_update_inode_force_wcc(data->inode, data->res.fattr);

Why this change?

Fred

>        }
>        return 0;
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 880a84d..dc6541d 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1055,6 +1055,30 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
>        pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
>  }
>
> +/*
> + * Called by non rpc-based layout drivers
> + */
> +int
> +pnfs_ld_write_done(struct nfs_write_data *data)
> +{
> +       int status;
> +
> +       put_lseg(data->lseg);
> +       data->lseg = NULL;
> +       if (!data->pnfs_error) {
> +               pnfs_set_layoutcommit(data);
> +               data->mds_ops->rpc_call_done(NULL, data);
> +               data->mds_ops->rpc_release(data);
> +               return 0;
> +       }
> +
> +       dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> +               data->pnfs_error);
> +       status = nfs_initiate_write(data, NFS_CLIENT(data->inode), data->mds_ops, NFS_FILE_SYNC);
> +       return status ? : -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
> +
>  enum pnfs_try_status
>  pnfs_try_to_write_data(struct nfs_write_data *wdata,
>                        const struct rpc_call_ops *call_ops, int how)
> @@ -1080,6 +1104,30 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
>  }
>
>  /*
> + * Called by non rpc-based layout drivers
> + */
> +int
> +pnfs_ld_read_done(struct nfs_read_data *data)
> +{
> +       int status;
> +
> +       put_lseg(data->lseg);
> +       data->lseg = NULL;
> +       if (!data->pnfs_error) {
> +               __nfs4_read_done_cb(data);
> +               data->mds_ops->rpc_call_done(NULL, data);
> +               data->mds_ops->rpc_release(data);
> +               return 0;
> +       }
> +
> +       dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> +               data->pnfs_error);
> +       status = nfs_initiate_read(data, NFS_CLIENT(data->inode), data->mds_ops);
> +       return status ? : -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
> +
> +/*
>  * Call the appropriate parallel I/O subsystem read function.
>  */
>  enum pnfs_try_status
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index e24c7fb..2f8776b 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -166,6 +166,8 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
> +int pnfs_ld_write_done(struct nfs_write_data *);
> +int pnfs_ld_read_done(struct nfs_read_data *);
>
>  static inline int lo_fail_bit(u32 iomode)
>  {
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 78b101e..ef2b6a9 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1084,6 +1084,7 @@ struct nfs_read_data {
>        const struct rpc_call_ops *mds_ops;
>        int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
>        __u64                   mds_offset;
> +       int                     pnfs_error;
>        struct page             *page_array[NFS_PAGEVEC_SIZE];
>  };
>
> @@ -1109,6 +1110,7 @@ struct nfs_write_data {
>        unsigned long           timestamp;      /* For lease renewal */
>  #endif
>        __u64                   mds_offset;     /* Filelayout dense stripe */
> +       int                     pnfs_error;
>        struct page             *page_array[NFS_PAGEVEC_SIZE];
>  };
>
> --
> 1.7.3.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
