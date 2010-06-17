From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 09/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into
	nfs4_write_done - part 2
Date: Thu, 17 Jun 2010 11:19:46 -0400
Message-ID: <AANLkTimHng4urMH5CTn68aZJ_NKIasCH6VJOTCI-2zRQ@mail.gmail.com>
References: <4C1A3570.5030709@panasas.com>
	<1276786187-12514-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50511 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932980Ab0FQPTs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:19:48 -0400
Received: by bwz7 with SMTP id 7so7412bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 08:19:46 -0700 (PDT)
In-Reply-To: <1276786187-12514-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 10:49 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> PNFS_NO_RPC.
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> =A0fs/nfs/nfs4proc.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5948de5..fd2b588 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3279,6 +3279,9 @@ static int nfs4_write_done(struct rpc_task *tas=
k, struct nfs_write_data *data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->pdata.orig_count=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->args.count =3D data->pdata.orig_=
count;
> =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 if (data->pdata.pnfsflags & PNFS_NO_RPC)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> =A0#endif /* CONFIG_NFS_V4_1 */

Again, this is is a post-submit patch

=46red

>
> =A0 =A0 =A0 =A0nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_r=
es,
> --
> 1.6.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
