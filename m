Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51897 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab0JMSDI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 14:03:08 -0400
Received: by bwz15 with SMTP id 15so3414804bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 11:03:07 -0700 (PDT)
In-Reply-To: <1285758613-26897-1-git-send-email-bhalevy@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
	<1285758613-26897-1-git-send-email-bhalevy@panasas.com>
Date: Wed, 13 Oct 2010 14:03:07 -0400
Message-ID: <AANLkTim8BCOgLNXZt3QKLX=g1dEruNEWHsb2GPs2AVYD@mail.gmail.com>
Subject: Re: [PATCH 5/5] NFS: clear fsinfo before sendign rpc
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 29, 2010 at 7:10 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> To initialize all values to zero, in case the server or protocol version
> do no support particular attributes.

Sorry for the delayed response, but...

Zero is not an appropriate default for many of the values.  Further,
decode_fsinfo sets a default for each value, even in cases where the
server or protocol version do not support particular attributes.  So
this patch seems to server no purpose.

Fred

>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/client.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 23d740c..beb206e 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -942,6 +942,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
>                        goto out_error;
>        }
>
> +       memset(&fsinfo, 0, sizeof(fsinfo));
>        fsinfo.fattr = fattr;
>        error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
>        if (error < 0)
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
