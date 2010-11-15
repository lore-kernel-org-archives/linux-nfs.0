Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56670 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757772Ab0KOPCC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 10:02:02 -0500
Received: by bwz15 with SMTP id 15so5255368bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 07:02:01 -0800 (PST)
In-Reply-To: <1289744517-27949-1-git-send-email-bhalevy@panasas.com>
References: <AANLkTinCcrzaa0wf0QZ8mB0NuTsO2FuaMKvt8+O_rwG-@mail.gmail.com>
	<1289744517-27949-1-git-send-email-bhalevy@panasas.com>
Date: Mon, 15 Nov 2010 10:02:00 -0500
Message-ID: <AANLkTimHPTfZL5DntG3LwzyMRp9UdxH89-C1QKv3dmit@mail.gmail.com>
Subject: Re: [PATCH] SQUASHME: pnfs-submit: encode layoutreturn on close
 before close
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 14, 2010 at 9:21 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> And handle errors from layoutcommit and layoutreturn on the reply path.
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |   35 ++++++++++++++++++-----------------
>  fs/nfs/pnfs.c    |    1 +
>  2 files changed, 19 insertions(+), 17 deletions(-)
>
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 1804f35..0e6e5e4 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -441,17 +441,17 @@ static int nfs4_stat_to_errno(int);
>  #define NFS4_enc_close_sz      (compound_encode_hdr_maxsz + \
>                                 encode_sequence_maxsz + \
>                                 encode_putfh_maxsz + \
> -                                encode_close_maxsz + \
> -                                encode_getattr_maxsz + \
> +                                encode_layoutcommit_maxsz + \
>                                 encode_layoutreturn_maxsz + \
> -                                encode_layoutcommit_maxsz)
> +                                encode_close_maxsz + \
> +                                encode_getattr_maxsz)
>  #define NFS4_dec_close_sz      (compound_decode_hdr_maxsz + \
>                                 decode_sequence_maxsz + \
>                                 decode_putfh_maxsz + \
> -                                decode_close_maxsz + \
> -                                decode_getattr_maxsz + \
> +                                decode_layoutcommit_maxsz + \
>                                 decode_layoutreturn_maxsz + \
> -                                decode_layoutcommit_maxsz)
> +                                decode_close_maxsz + \
> +                                decode_getattr_maxsz)
>  #define NFS4_enc_setattr_sz    (compound_encode_hdr_maxsz + \
>                                 encode_sequence_maxsz + \
>                                 encode_putfh_maxsz + \
> @@ -2160,10 +2160,10 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
>        encode_putfh(&xdr, args->fh, &hdr);
>        if (args->op_bitmask & NFS4_HAS_LAYOUTCOMMIT) /* layoutcommit set */
>                encode_layoutcommit(&xdr, &args->lc_args, &hdr);
> -       encode_close(&xdr, args, &hdr);
> -       encode_getfattr(&xdr, args->bitmask, &hdr);
>        if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
>                encode_layoutreturn(&xdr, &args->lr_args, &hdr);
> +       encode_close(&xdr, args, &hdr);
> +       encode_getfattr(&xdr, args->bitmask, &hdr);
>        encode_nops(&hdr);
>        return 0;
>  }
> @@ -5743,9 +5743,16 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
>        status = decode_putfh(&xdr);
>        if (status)
>                goto out;
> -       /* We pay no attention to the layoutcommit return */
> -       if (res->op_bitmask & NFS4_HAS_LAYOUTCOMMIT)
> -               decode_layoutcommit(&xdr);
> +       if (res->op_bitmask & NFS4_HAS_LAYOUTCOMMIT) {
> +               status = decode_layoutcommit(&xdr);
> +               if (status)
> +                       goto out;
> +       }
> +       if (res->op_bitmask & NFS4_HAS_LAYOUTRETURN) {
> +               status = decode_layoutreturn(&xdr, &res->lr_res);
> +               if (status)
> +                       goto out;

What prevents infinite loop here?  With LAYOUTCOMMIT, the inode data
is cleared so that on retry it will not be called.  I see no
comparable "pre-cleaning" done for LAYOUTRETURN.

Fred

> +       }
>        status = decode_close(&xdr, res);
>        if (status != 0)
>                goto out;
> @@ -5757,12 +5764,6 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
>         */
>        decode_getfattr(&xdr, res->fattr, res->server,
>                        !RPC_IS_ASYNC(rqstp->rq_task));
> -       /*
> -        * With the forgetful model, we pay no attention to the
> -        * layoutreturn status.
> -        */
> -       if (res->op_bitmask & NFS4_HAS_LAYOUTRETURN)
> -               decode_layoutreturn(&xdr, &res->lr_res);
>  out:
>        return status;
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 15673d0..90a868b 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -640,6 +640,7 @@ pnfs_roc(struct nfs4_closedata *data)
>        LIST_HEAD(tmp_list);
>        bool found = false;
>
> +       data->arg.op_bitmask = data->res.op_bitmask = 0;
>        spin_lock(&data->inode->i_lock);
>        lo = NFS_I(data->inode)->layout;
>        if (!lo || lo->roc_iomode == 0 ||
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
