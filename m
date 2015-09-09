Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38181 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbbIIOyc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2015 10:54:32 -0400
Received: by igxx6 with SMTP id x6so16087239igx.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2015 07:54:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1441790260-35583-1-git-send-email-tao.peng@primarydata.com>
References: <1441790260-35583-1-git-send-email-tao.peng@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Wed, 9 Sep 2015 22:54:12 +0800
Message-ID: <CAKVebiVH7LoQH3s9nUjPuRqBhPwQfb2Ctv=5MJ02ukXg6dR9tQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: remove roc_rpcwaitq
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please ignore this. We'll need the roc_rpcwaitq back when adding ROC
waiters on layoutreturn.

Cheers,
Tao

On Wed, Sep 9, 2015 at 5:17 PM, Peng Tao <tao.peng@primarydata.com> wrote:
>
> There are no users of it after we remove pnfs_roc_drain.
>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/client.c           | 10 ----------
>  fs/nfs/pnfs.c             |  4 ----
>  include/linux/nfs_fs_sb.h |  1 -
>  3 files changed, 15 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 57c5a02..46ce7bf 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -215,11 +215,6 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
>                 idr_remove(&nn->cb_ident_idr, clp->cl_cb_ident);
>  }
>
> -static void pnfs_init_server(struct nfs_server *server)
> -{
> -       rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
> -}
> -
>  #else
>  void nfs_cleanup_cb_ident_idr(struct net *net)
>  {
> @@ -229,10 +224,6 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
>  {
>  }
>
> -static void pnfs_init_server(struct nfs_server *server)
> -{
> -}
> -
>  #endif /* CONFIG_NFS_V4 */
>
>  /*
> @@ -900,7 +891,6 @@ struct nfs_server *nfs_alloc_server(void)
>
>         ida_init(&server->openowner_id);
>         ida_init(&server->lockowner_id);
> -       pnfs_init_server(server);
>
>         return server;
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index ba12464..dcc3571 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -334,15 +334,12 @@ static void
>  pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
>                 struct pnfs_layout_segment *lseg)
>  {
> -       struct inode *inode = lo->plh_inode;
> -
>         WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>         list_del_init(&lseg->pls_list);
>         /* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
>         atomic_dec(&lo->plh_refcount);
>         if (list_empty(&lo->plh_segs))
>                 clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
> -       rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
>  }
>
>  /* Return true if layoutreturn is needed */
> @@ -936,7 +933,6 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
>         clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
>         smp_mb__after_atomic();
>         wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
> -       rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
>  }
>
>  static int
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 570a7df..fad6b61 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -190,7 +190,6 @@ struct nfs_server {
>                                                    handle volatility type for
>                                                    this filesystem */
>         struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
> -       struct rpc_wait_queue   roc_rpcwaitq;
>         void                    *pnfs_ld_data;  /* per mount point data */
>
>         /* the following fields are protected by nfs_client->cl_lock */
> --
> 1.8.3.1
>
