Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:41248 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab2JKRvA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 13:51:00 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so7534567wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 10:50:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1349974296-48449-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1349974296-48449-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 11 Oct 2012 13:50:59 -0400
Message-ID: <CAHVgHyVnowveZDOp8X_YC1K9Y7WOmj6A-TU_doDgV78vGm-cYQ@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: Kill nfs4_ds_disconnect()
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 11, 2012 at 12:51 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> There is nothing to prevent another thread from dereferencing ds->ds_clp
> during or after the call to nfs4_ds_disconnect(), and Oopsing due to the
> resulting NULL pointer.

Yes.

>
> Instead, we should just rely on filelayout_mark_devid_invalid() to keep
> us out of trouble by avoiding that deviceid.

Why do we want to keep the connection and the nfs_client? For connection retry?

-->Andy

>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c    |  1 -
>  fs/nfs/nfs4filelayout.h    |  1 -
>  fs/nfs/nfs4filelayoutdev.c | 22 ----------------------
>  3 files changed, 24 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 52d8472..816c2d0 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -207,7 +207,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>                 clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
>                 _pnfs_return_layout(inode);
>                 rpc_wake_up(&tbl->slot_tbl_waitq);
> -               nfs4_ds_disconnect(clp);
>                 /* fall through */
>         default:
>  reset:
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index dca47d78..8c07241 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -149,6 +149,5 @@ extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
>  extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
>  struct nfs4_file_layout_dsaddr *
>  filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
> -void nfs4_ds_disconnect(struct nfs_client *clp);
>
>  #endif /* FS_NFS_NFS4FILELAYOUT_H */
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 3336d5e..a8eaa9b 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -149,28 +149,6 @@ _data_server_lookup_locked(const struct list_head *dsaddrs)
>  }
>
>  /*
> - * Lookup DS by nfs_client pointer. Zero data server client pointer
> - */
> -void nfs4_ds_disconnect(struct nfs_client *clp)
> -{
> -       struct nfs4_pnfs_ds *ds;
> -       struct nfs_client *found = NULL;
> -
> -       dprintk("%s clp %p\n", __func__, clp);
> -       spin_lock(&nfs4_ds_cache_lock);
> -       list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
> -               if (ds->ds_clp && ds->ds_clp == clp) {
> -                       found = ds->ds_clp;
> -                       ds->ds_clp = NULL;
> -               }
> -       spin_unlock(&nfs4_ds_cache_lock);
> -       if (found) {
> -               set_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state);
> -               nfs_put_client(clp);
> -       }
> -}
> -
> -/*
>   * Create an rpc connection to the nfs4_pnfs_ds data server
>   * Currently only supports IPv4 and IPv6 addresses
>   */
> --
> 1.7.11.7
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
