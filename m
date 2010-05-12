Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42395 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab0ELOMB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 10:12:01 -0400
Received: by gyg13 with SMTP id 13so3373323gyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 May 2010 07:12:01 -0700 (PDT)
In-Reply-To: <20100512074204.GA7643@MDS-78.localdomain>
References: <20100512074204.GA7643@MDS-78.localdomain>
Date: Wed, 12 May 2010 10:11:54 -0400
Message-ID: <AANLkTilCfQl5zM9cap4vJSbFfJQ8OvoPNoydif_4DN6T@mail.gmail.com>
Subject: Re: [PATCH] pnfs: set pnfs_curr_ld before calling
	initialize_mountpoint
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Cc: linux-nfs@vger.kernel.org, bhalevy@panasas.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 12, 2010 at 3:42 AM, Zhang Jingwang
<zhangjingwang@nrchpc.ac.cn> wrote:
> initialize_mountpoint will call _nfs4_pnfs_getdevicelist and then
> pnfs_curr_ld->id is accessed.

Where is pnfs_curr_ld->ld_policy_ops accessed?

-->Andy

> This introduce a NULL pointer reference.
>
> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
> ---
>  fs/nfs/pnfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 3739c38..5ad7fc6 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -212,6 +212,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>                return;
>
>        if (id > 0 && find_pnfs(id, &mod)) {
> +               server->pnfs_curr_ld = mod->pnfs_ld_type;
>                if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
>                                                        server, mntfh)) {
>                        printk(KERN_ERR "%s: Error initializing mount point "
> @@ -222,7 +223,6 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>                 * Layout driver succeeded in initializing mountpoint
>                 * and has taken a reference on the nfs_client cl_devid_cache
>                 */
> -               server->pnfs_curr_ld = mod->pnfs_ld_type;
>                server->nfs_client->rpc_ops = &pnfs_v4_clientops;
>                dprintk("%s: pNFS module for %u set\n", __func__, id);
>                return;
> --
> 1.6.2.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
