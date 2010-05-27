From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: pnfs-obj: panlayout: Fix very old BUG_ONs on
 ol_state.status
Date: Thu, 27 May 2010 21:08:18 +0300
Message-ID: <4BFEB512.7050701@panasas.com>
References: <4BFE8728.8010302@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: open-osd <osd-dev@open-osd.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58267 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756356Ab0E0SIV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:08:21 -0400
In-Reply-To: <4BFE8728.8010302@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 27, 2010, 17:52 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
> OK This is definitely my stupidity when converting panfs_shim to the
> new objlayout_read/write_done() API. But that was very, very long
> time ago. Did we not test panlayout since then.
> 
> So I fixed the stale check on ol_state.status which is never set
> until much later inside the call to generic layer.
> 
> While at it I converted the BUG_ONs to WARN_ONs because it could
> be data corruption but otherwise it will not crush the Kernel.
> Better continue to be able to debug it better. (And added missing
> information to the WARN_ON)
> 
> Congratulation, I've successfully ran all tests over
> panfs-export/panfs_shim over real Panasas HW. With latest code.
> [ This is with the new panfs-export that is also compatible with
>   the std objects layout driver. Patches to that will follow]
> 
> TODO:
>   I should also simulate/cause some IO errors and see that
>   errors are reported at layout_return
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/panfs_shim.c |   19 +++++++++++++------
>  1 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
> index 414831e..c34fb5c 100644
> --- a/fs/nfs/objlayout/panfs_shim.c
> +++ b/fs/nfs/objlayout/panfs_shim.c
> @@ -421,9 +421,12 @@ panfs_shim_read_done(
>  		rc = res_p->result;
>  	if (rc == PAN_SUCCESS) {
>  		status = res_p->length;
> -		BUG_ON(state->ol_state.status < 0);
> -		BUG_ON((pan_stor_len_t)state->ol_state.status !=
> -		       state->u.read.res.length);
> +		WARN_ON(status < 0);
> +		if (WARN_ON((pan_stor_len_t)status != state->u.read.res.length))
> +			printk(KERN_ERR
> +			      "%s: status(0x%llx) != read.res.length(0x%llx)\n",
> +			       __func__, (u64)status,
> +			       (u64)state->u.read.res.length);
>  	} else {
>  		status = -panfs_export_ops->convert_rc(rc);
>  		dprintk("%s: pan_sam_read rc %d: status %Zd\n",
> @@ -499,9 +502,13 @@ panfs_shim_write_done(
>  	if (rc == PAN_SUCCESS) {
>  		state->ol_state.committed = NFS_FILE_SYNC;
>  		status = res_p->length;
> -		BUG_ON(state->ol_state.status < 0);
> -		BUG_ON((pan_stor_len_t)state->ol_state.status !=
> -		       state->u.write.res.length);
> +		WARN_ON(status < 0);
> +		if (WARN_ON((pan_stor_len_t)status != state->u.write.res.length))
> +			printk(KERN_ERR
> +			     "%s: status(0x%llx) != write.res.length(0x%llx)\n",
> +			     __func__, (u64)status,
> +			    (u64)state->u.write.res.length);
> +
>  		objlayout_add_delta_space_used(&state->ol_state,
>  					       res_p->delta_capacity_used);
>  	} else {

Merged for (2.6.34) pnfs-all-latest and pnfs-all-2.6.33.

Thanks!

Benny
