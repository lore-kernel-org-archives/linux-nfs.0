From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/2] pnfs-submit: Dynamically load the nfslayoutdriver
Date: Tue, 25 May 2010 09:55:15 +0300
Message-ID: <4BFB7453.4080605@panasas.com>
References: <> <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com> <1274722623-11078-2-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20841 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751888Ab0EYGzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 02:55:17 -0400
In-Reply-To: <1274722623-11078-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 24, 2010, 20:37 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> Load the files layout driver if the server indicates that it supports
> LAYOUT4_NFSV4_1_FILES.  Other layouts can be loaded in a similar fashion.
> The module can be blacklisted to disable pNFS support for the corresponding
> layout type.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Committed at pnfs-all-2.6.34-2010-05-25

Thanks!

Benny

> ---
>  fs/nfs/pnfs.c |   17 +++++++++++++++--
>  fs/nfs/pnfs.h |    2 ++
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 57d3ff0..6a89279 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -205,12 +205,24 @@ unmount_pnfs_layoutdriver(struct nfs_server *nfss)
>  void
>  set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
>  {
> -	struct pnfs_module *mod;
> +	struct pnfs_module *mod = NULL;
>  
>  	if (server->pnfs_curr_ld)
>  		return;
>  
> -	if (id > 0 && find_pnfs(id, &mod)) {
> +	if (!find_pnfs(id, &mod)) {
> +		switch (id) {
> +		case LAYOUT_NFSV4_1_FILES:
> +			request_module(LAYOUT_NFSV4_1_FILES_MODULE);
> +			break;
> +		default:
> +			goto out_not_found;
> +		};
> +
> +		find_pnfs(id, &mod);
> +	}
> +
> +	if (mod) {
>  		if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
>  			server->nfs_client)) {
>  			printk(KERN_ERR "%s: Error initializing mount point "
> @@ -227,6 +239,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
>  		return;
>  	}
>  
> +out_not_found:
>  	dprintk("%s: No pNFS module found for %u. ", __func__, id);
>  out_err:
>  	dprintk("Using NFSv4 I/O\n");
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index b80157b..dac955e 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -80,6 +80,8 @@ void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
>  				     (srv)->pnfs_curr_ld->ld_policy_ops && \
>  				     (srv)->pnfs_curr_ld->ld_policy_ops->opname)
>  
> +#define LAYOUT_NFSV4_1_FILES_MODULE "nfslayoutdriver"
> +
>  static inline int lo_fail_bit(u32 iomode)
>  {
>  	return iomode == IOMODE_RW ?
