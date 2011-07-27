Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55536 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356Ab1G0TgV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 15:36:21 -0400
Subject: Re: [PATCH v3 02/25] pnfs: add set-clear layoutdriver interface
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 15:36:19 -0400
In-Reply-To: <1311792048-12551-3-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-3-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311795379.25645.11.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Benny Halevy <bhalevy@panasas.com>
> 
> To allow layout driver to issue getdevicelist at mount time, and clean up
> at umount time.
> 
> [fixup non NFS_V4_1 set_pnfs_layoutdriver definition]
> [pnfs: pass mntfh down the init_pnfs path]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/client.c |    8 +++++---
>  fs/nfs/pnfs.c   |   16 ++++++++++++++--
>  fs/nfs/pnfs.h   |    8 ++++++--
>  3 files changed, 25 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 19ea7d9..a9b1848 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -904,7 +904,9 @@ error:
>  /*
>   * Load up the server record from information gained in an fsinfo record
>   */
> -static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
> +static void nfs_server_set_fsinfo(struct nfs_server *server,
> +				  struct nfs_fh *mntfh,
> +				  struct nfs_fsinfo *fsinfo)
>  {
>  	unsigned long max_rpc_payload;
>  
> @@ -934,7 +936,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
>  	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
>  		server->wsize = NFS_MAX_FILE_IO_SIZE;
>  	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> -	set_pnfs_layoutdriver(server, fsinfo->layouttype);
> +	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
>  
>  	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
>  
> @@ -980,7 +982,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
>  	if (error < 0)
>  		goto out_error;
>  
> -	nfs_server_set_fsinfo(server, &fsinfo);
> +	nfs_server_set_fsinfo(server, mntfh, &fsinfo);
>  
>  	/* Get some general file system info */
>  	if (server->namelen == 0) {
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 38e5508..8e72724 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -76,8 +76,11 @@ find_pnfs_driver(u32 id)
>  void
>  unset_pnfs_layoutdriver(struct nfs_server *nfss)
>  {
> -	if (nfss->pnfs_curr_ld)
> +	if (nfss->pnfs_curr_ld) {
> +		if (nfss->pnfs_curr_ld->clear_layoutdriver)
> +			nfss->pnfs_curr_ld->clear_layoutdriver(nfss);
>  		module_put(nfss->pnfs_curr_ld->owner);
> +	}
>  	nfss->pnfs_curr_ld = NULL;
>  }
>  
> @@ -88,7 +91,8 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
>   * @id layout type. Zero (illegal layout type) indicates pNFS not in use.
>   */
>  void
> -set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
> +set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
> +		      u32 id)
>  {
>  	struct pnfs_layoutdriver_type *ld_type = NULL;
>  
> @@ -115,6 +119,14 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
>  		goto out_no_driver;
>  	}
>  	server->pnfs_curr_ld = ld_type;
> +	if (ld_type->set_layoutdriver
> +	    && ld_type->set_layoutdriver(server, mntfh)) {
> +		printk(KERN_ERR
> +		       "%s: Error initializing mount point for layout driver %u.\n",

Please fix this error message: as it stands, it doesn't make sense.



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

