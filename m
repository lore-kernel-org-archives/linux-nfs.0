From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 04/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into
	nfs4_read_done - part 1
Date: Thu, 17 Jun 2010 11:09:52 -0400
Message-ID: <AANLkTilrUQlt_j3x2i1O3QNbQ8AB8X3t3X7MLRu8Mn2M@mail.gmail.com>
References: <4C1A3570.5030709@panasas.com>
	<1276786133-11891-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52210 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755890Ab0FQPLq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:11:46 -0400
Received: by fxm10 with SMTP id 10so14241fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 08:11:44 -0700 (PDT)
In-Reply-To: <1276786133-11891-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 10:48 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> deviding into several patches to assist review
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> =A0fs/nfs/nfs4proc.c | =A0 =A05 +++++
> =A01 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c4f707f..a6bebbf 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3144,6 +3144,11 @@ static int nfs4_read_done(struct rpc_task *tas=
k, struct nfs_read_data *data)
>
> =A0 =A0 =A0 =A0dprintk("--> %s\n", __func__);
>
> +#ifdef CONFIG_NFS_V4_1
> + =A0 =A0 =A0 if (data->pdata.pnfsflags & PNFS_NO_RPC)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +#endif /* CONFIG_NFS_V4_1 */
> +

This shouldn't be in pnfs_submit (PFNS_NO_RPC doesn't exist there anymo=
re)

=46red

> =A0 =A0 =A0 =A0nfs4_sequence_done(server, &data->res.seq_res, task->t=
k_status);
>
> =A0 =A0 =A0 =A0if (nfs4_async_handle_error(task, server, data->args.c=
ontext->state, NULL) =3D=3D -EAGAIN) {
> --
> 1.6.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
