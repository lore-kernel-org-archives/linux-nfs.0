From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] Don't check exchange flags unless using v4.1
Date: Wed, 06 Oct 2010 12:02:11 -0400
Message-ID: <4CAC9D83.2090406@panasas.com>
References: <1286380572-4558-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:12135 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751262Ab0JFQCQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Oct 2010 12:02:16 -0400
In-Reply-To: <1286380572-4558-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-10-06 11:56, Fred Isaman wrote:
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/pnfs.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 7013916..64baf20 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -141,7 +141,9 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
>  
>  	if (id == 0)
>  		goto out_no_driver;
> -	if (!(server->nfs_client->cl_exchange_flags &
> +	if ((server->nfs_client->rpc_ops->version == 4) &&
> +	    (server->nfs_client->cl_minorversion == 1) &&
> +	    !(server->nfs_client->cl_exchange_flags &
>  		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
>  		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
>  		       id, server->nfs_client->cl_exchange_flags);

Actually, it'd better to disable just the warning printout in this case,
not the entire block.

Benny
