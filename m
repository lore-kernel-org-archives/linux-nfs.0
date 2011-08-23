Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48202 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab1HWOqC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 10:46:02 -0400
Received: by vxi9 with SMTP id 9so146335vxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2011 07:46:01 -0700 (PDT)
In-Reply-To: <1313197213-1651-2-git-send-email-bergwolf@gmail.com>
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com> <1313197213-1651-2-git-send-email-bergwolf@gmail.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 23 Aug 2011 22:45:41 +0800
Message-ID: <CA+a=Yy5V-JpEy_aJ6=H5=y=GBsoDGL-TDbPZkaVmT0DxEYhLjA@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] pNFS: recoalesce when ld write pagelist fails
To: benny@tonian.com, Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny and Boaz,

On Sat, Aug 13, 2011 at 9:00 AM, Peng Tao <bergwolf@gmail.com> wrote:
> For pnfs pagelist write failure, we need to pg_recoalesce and resend
> IO to mds.
>
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/pnfs.c  |   20 +++++++-------------
>  fs/nfs/pnfs.h  |    2 +-
>  fs/nfs/write.c |   25 ++++++++++++++++++++++++-
>  3 files changed, 32 insertions(+), 15 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index e550e88..ad0579a 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1168,23 +1168,17 @@ EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
>  /*
>  * Called by non rpc-based layout drivers
>  */
> -int
> -pnfs_ld_write_done(struct nfs_write_data *data)
> +void pnfs_ld_write_done(struct nfs_write_data *data)
>  {
> -       int status;
> -
> -       if (!data->pnfs_error) {
> +       if (likely(!data->pnfs_error)) {
>                pnfs_set_layoutcommit(data);
>                data->mds_ops->rpc_call_done(&data->task, data);
> -               data->mds_ops->rpc_release(data);
> -               return 0;
> +       } else {
> +               put_lseg(data->lseg);
> +               data->lseg = NULL;
> +               dprintk("pnfs write error = %d\n", data->pnfs_error);
>        }
> -
> -       dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> -               data->pnfs_error);
> -       status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
> -                                   data->mds_ops, NFS_FILE_SYNC);
> -       return status ? : -EAGAIN;
> +       data->mds_ops->rpc_release(data);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
>
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 01cbfd5..0fb0a41 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -200,7 +200,7 @@ void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>  void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>  int _pnfs_return_layout(struct inode *);
> -int pnfs_ld_write_done(struct nfs_write_data *);
> +void pnfs_ld_write_done(struct nfs_write_data *);
>  int pnfs_ld_read_done(struct nfs_read_data *);
>  struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
>                                               struct nfs_open_context *ctx,
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b39b37f..26b8d90 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1165,7 +1165,13 @@ static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
>  static void nfs_writeback_release_full(void *calldata)
>  {
>        struct nfs_write_data   *data = calldata;
> -       int status = data->task.tk_status;
> +       int ret, status = data->task.tk_status;
> +       struct nfs_pageio_descriptor pgio;
> +
> +       if (data->pnfs_error) {
> +               nfs_pageio_init_write_mds(&pgio, data->inode, FLUSH_STABLE);
> +               pgio.pg_recoalesce = 1;
> +       }
>
>        /* Update attributes as result of writeback. */
>        while (!list_empty(&data->pages)) {
> @@ -1181,6 +1187,11 @@ static void nfs_writeback_release_full(void *calldata)
>                        req->wb_bytes,
>                        (long long)req_offset(req));
>
> +               if (data->pnfs_error) {
> +                       dprintk(", pnfs error = %d\n", data->pnfs_error);
> +                       goto next;
> +               }
> +
>                if (status < 0) {
>                        nfs_set_pageerror(page);
>                        nfs_context_set_write_error(req->wb_context, status);
> @@ -1200,7 +1211,19 @@ remove_request:
>        next:
>                nfs_clear_page_tag_locked(req);
>                nfs_end_page_writeback(page);
> +               if (data->pnfs_error) {
> +                       lock_page(page);
> +                       nfs_pageio_cond_complete(&pgio, page->index);
> +                       ret = nfs_page_async_flush(&pgio, page, 0);
> +                       if (ret) {
> +                               nfs_set_pageerror(page);
My only concern about the patch is here. If we fail at
nfs_page_async_flush(), is it enough to just call nfs_set_pageerror()
on the page? Do we need to redirty the page as well, and maybe some
other things?

Thanks,
Tao
> +                               dprintk(", error = %d\n", ret);
> +                       }
> +                       unlock_page(page);
> +               }
>        }
> +       if (data->pnfs_error)
> +               nfs_pageio_complete(&pgio);
>        nfs_writedata_release(calldata);
>  }
>
> --
> 1.7.1.262.g5ef3d
>
>



-- 
Thanks,
-Bergwolf
