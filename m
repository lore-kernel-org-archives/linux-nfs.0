Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43657 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253Ab1EWOi0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 10:38:26 -0400
Received: by yxs7 with SMTP id 7so2107910yxs.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 May 2011 07:38:26 -0700 (PDT)
In-Reply-To: <4DD879BC.6000503@panasas.com>
References: <4DD879BC.6000503@panasas.com>
Date: Mon, 23 May 2011 10:38:25 -0400
Message-ID: <BANLkTiniZOn5bc711Ab38=kS0JT-5ZdgrA@mail.gmail.com>
Subject: Re: [PATCH] SQUASHME: BUGs squashing in new pnfs for LD code
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, May 21, 2011 at 10:49 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>
> 1. In nfs4_write_done_cb: data->write_done_cb comes with a NULL.
>   Just as a guess I call nfs4_write_done_cb() just above it
>   it looked like the right thing to do. With that in, I'm able
>   to write things to file When converting pnfs.c:258 to a WARN_ON.
>

It is set by the file driver in the .write_pagelist() routine, and if
it is not set there, it is set to the default nfs4_write_done_cb in
.write_setup(), which ends up being nfs4_proc_write_setup().

>   Benny we might want to set data->write_done_cb somewhere in the
>   none-rpc path? where is it best to do that?
> 1.5
>   Same as above for nfs4_read_done.
>
> 2. In pnfs_ld_write_done We don't need:
>        put_lseg(data->lseg);
>        data->lseg = NULL;
>   It is called in nfs_writedata_release()
> 2.5 Same for pnfs_ld_read_done
>
> 3. In pnfs_ld_write_done:
>   data->mds_ops->rpc_call_done(NULL, data);
>   crashes with a NULL task. Just pass it with &data->task
>
>   Which calls for a cleanup. There is bunch of functions
>   with [task, write_data] API. And the task is always
>   write_data->task
>
> 3.5
>   Same for pnfs_ld_read_done
>
> 4. It is now with current code not possible to run with out a
>   *.pg_test* opt. Without, it will crash, reference leak and
>   only do pnfs-IO on a single page. I'll send a patch to check
>   for it in... where the ld->opt is checked.
>

Yes, this is a bug in the existing code.

Fred

>   So define one for objlayout. Which always returns true.
>
> With this I'm able to read/write with pnfs-IO. (lightly test)
> (With out any WARN_ONs)
>
> One problem I've seen is that I only get up to 16 pages maximum
> in a single request. I would like to see the 512 pages we had
> before for a full request. Where should I fix that?
>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/nfs4proc.c            |    5 +++--
>  fs/nfs/objlayout/objio_osd.c |   15 +++++++++++++++
>  fs/nfs/pnfs.c                |   14 +++++++-------
>  3 files changed, 25 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 759523a..4bf7c0c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3205,7 +3205,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
>        if (!nfs4_sequence_done(task, &data->res.seq_res))
>                return -EAGAIN;
>
> -       return data->read_done_cb(task, data);
> +       return data->read_done_cb ? data->read_done_cb(task, data) : nfs4_read_done_cb(task, data);
>  }
>
>  static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
> @@ -3250,7 +3250,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
>        if (!nfs4_sequence_done(task, &data->res.seq_res))
>                return -EAGAIN;
> -       return data->write_done_cb(task, data);
> +       return data->write_done_cb ? data->write_done_cb(task, data) :
> +               nfs4_write_done_cb(task, data);
>  }
>
>  /* Reset the the nfs_write_data to send the write to the MDS. */
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 7e46d2b..105d8a6 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -989,6 +989,19 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
>        return _write_exec(ios);
>  }
>
> +/*
> + * objlayout_pg_test(). Called by nfs_can_coalesce_requests()
> + *
> + * return 1 :  coalesce page
> + * return 0 :  don't coalesce page
> + */
> +int
> +objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> +                  struct nfs_page *req)
> +{
> +       return 1;
> +}
> +
>  static struct pnfs_layoutdriver_type objlayout_type = {
>        .id = LAYOUT_OSD2_OBJECTS,
>        .name = "LAYOUT_OSD2_OBJECTS",
> @@ -1008,6 +1021,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
>
>        .encode_layoutcommit     = objlayout_encode_layoutcommit,
>        .encode_layoutreturn     = objlayout_encode_layoutreturn,
> +
> +       .pg_test                = objlayout_pg_test,
>  };
>
>  void *objio_init_mt(void)
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 8d2baf8..ea30a52 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -256,7 +256,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
>  {
>        struct inode *inode = lseg->pls_layout->plh_inode;
>
> -       BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
> +       WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>        list_del_init(&lseg->pls_list);
>        if (list_empty(&lseg->pls_layout->plh_segs)) {
>                set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
> @@ -1125,15 +1125,15 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>  {
>        int status;
>
> -       put_lseg(data->lseg);
> -       data->lseg = NULL;
>        if (!data->pnfs_error) {
>                pnfs_set_layoutcommit(data);
> -               data->mds_ops->rpc_call_done(NULL, data);
> +               data->mds_ops->rpc_call_done(&data->task, data);
>                data->mds_ops->rpc_release(data);
>                return 0;
>        }
>
> +       put_lseg(data->lseg);
> +       data->lseg = NULL;
>        dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>                data->pnfs_error);
>        status = nfs_initiate_write(data, NFS_CLIENT(data->inode), data->mds_ops, NFS_FILE_SYNC);
> @@ -1173,15 +1173,15 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>  {
>        int status;
>
> -       put_lseg(data->lseg);
> -       data->lseg = NULL;
>        if (!data->pnfs_error) {
>                __nfs4_read_done_cb(data);
> -               data->mds_ops->rpc_call_done(NULL, data);
> +               data->mds_ops->rpc_call_done(&data->task, data);
>                data->mds_ops->rpc_release(data);
>                return 0;
>        }
>
> +       put_lseg(data->lseg);
> +       data->lseg = NULL;
>        dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>                data->pnfs_error);
>        status = nfs_initiate_read(data, NFS_CLIENT(data->inode), data->mds_ops);
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
