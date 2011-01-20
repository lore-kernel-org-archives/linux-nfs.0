Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50566 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab1ATMU3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 07:20:29 -0500
Received: by bwz15 with SMTP id 15so470069bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jan 2011 04:20:28 -0800 (PST)
In-Reply-To: <1266699969-21920-1-git-send-email-bhalevy@panasas.com>
References: <4B804E57.4010507@panasas.com>
	<1266699969-21920-1-git-send-email-bhalevy@panasas.com>
Date: Thu, 20 Jan 2011 07:20:28 -0500
Message-ID: <AANLkTi=AGegTKbsA7oA6yNO-Y4f=6g8ynCA2BdV9wzBY@mail.gmail.com>
Subject: Re: [pnfs] [PATCH 1/2] pnfs: trim write count to wsize when retrying
 via MDS
From: Fred Isaman <iisaman@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm going over the write code carefully preparing for wave4, and came
across some code I traced to this patch.

Why is this needed?  Why doesn't the pg_bsize check in
nfs_pageio_do_add_request() prevent this from ever being invoked?

Fred

On Sat, Feb 20, 2010 at 4:06 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> We coalesce pages based on the strip size that may be bigger
> than the server can handle in one write (and even exceed the
> maximum RPC message size on the server)
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c       |    7 +++++++
>  fs/nfs/write.c          |    8 ++++++++
>  include/linux/nfs_xdr.h |    1 +
>  3 files changed, 16 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8132a96..93b1963 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3180,6 +3180,13 @@ static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>        struct nfs_client *client = mds_svr->nfs_client;
>        int status = task->tk_status >= 0 ? 0 : task->tk_status;
>
> +       /* restore original count after retry? */
> +       if (data->pdata.orig_count) {
> +               dprintk("%s: restoring original count %u\n", __func__,
> +                       data->pdata.orig_count);
> +               data->args.count = data->pdata.orig_count;
> +       }
> +
>        if (data->pdata.pnfsflags & PNFS_NO_RPC)
>                return 0;
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 90ce78e..fee6f00 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1108,6 +1108,14 @@ void nfs_write_prepare(struct rpc_task *task, void *calldata)
>  #ifdef CONFIG_PNFS
>        if (data->fldata.ds_nfs_client)
>                clp = data->fldata.ds_nfs_client;
> +       else if (data->args.count > NFS_SERVER(data->inode)->wsize) {
> +               /* retrying via MDS? */
> +               data->pdata.orig_count = data->args.count;
> +               data->args.count = NFS_SERVER(data->inode)->wsize;
> +               dprintk("%s: trimmed count %u to wsize %u\n", __func__,
> +                       data->pdata.orig_count, data->args.count);
> +       } else
> +               data->pdata.orig_count = 0;
>  #endif /* CONFIG_PNFS */
>
>        if (nfs4_setup_sequence(clp, &data->args.seq_args,
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index efc4ca0..13ccd48 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -970,6 +970,7 @@ struct nfs_page;
>  struct pnfs_call_data {
>        struct pnfs_layout_segment *lseg;
>        const struct rpc_call_ops *call_ops;
> +       u32                     orig_count;     /* for retry via MDS */
>        int                     pnfs_error;
>        u8                      pnfsflags;
>        u8                      how;            /* for FLUSH_STABLE */
> --
> 1.6.4.4
>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
