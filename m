From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs: restore state recovery in async handler
Date: Thu, 06 May 2010 22:44:58 +0300
Message-ID: <4BE31C3A.4060904@panasas.com>
References: <1273010046-9015-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45395 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab0EFTpG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:45:06 -0400
Received: by wyg36 with SMTP id 36so285287wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 12:45:04 -0700 (PDT)
In-Reply-To: <1273010046-9015-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 05, 2010, 0:54 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> For some reason, the call to nfs4_schedule_state_recovery was removed from
> the pNFS git trees, but is present in the straight 2.6.34-rcX kernels.

Committed to pnfs-submit. Thanks!

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4b3bd81..43dab3c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3694,6 +3694,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>  			dprintk("%s ERROR %d, Reset session. Exchangeid "
>  				"flags 0x%x\n", __func__, task->tk_status,
>  				clp->cl_exchange_flags);
> +			nfs4_schedule_state_recovery(clp);
>  			task->tk_status = 0;
>  			return -EAGAIN;
>  #endif /* CONFIG_NFS_V4_1 */

