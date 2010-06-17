From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 06/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into
	nfs4_read_done - part 3
Date: Thu, 17 Jun 2010 11:15:00 -0400
Message-ID: <AANLkTikvo8qP_B23suRB-lKNCcCQv4W6Vw8kBmPC_6SX@mail.gmail.com>
References: <4C1A3570.5030709@panasas.com>
	<1276786155-12371-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56464 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab0FQPPC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:15:02 -0400
Received: by bwz7 with SMTP id 7so6205bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 08:15:00 -0700 (PDT)
In-Reply-To: <1276786155-12371-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 10:49 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> Do not renew the data server lease.
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> =A0fs/nfs/nfs4proc.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 77b7182..e8b0f33 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3164,7 +3164,7 @@ static int nfs4_read_done(struct rpc_task *task=
, struct nfs_read_data *data)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0nfs_invalidate_atime(data->inode);
> - =A0 =A0 =A0 if (task->tk_status > 0)
> + =A0 =A0 =A0 if (task->tk_status > 0 && client =3D=3D server->nfs_cl=
ient)

Will this test work if there is a dual role MDS/DS?

=46red

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0renew_lease(server, data->timestamp);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> --
> 1.6.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
