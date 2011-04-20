Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62972 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab1DTUgR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 16:36:17 -0400
Subject: Re: [RFC 11/27] pnfs: per mount layout driver private data
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303320461-21369-1-git-send-email-bhalevy@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
	 <1303320461-21369-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 16:36:12 -0400
Message-ID: <1303331772.23206.47.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 20:27 +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfs_fs_sb.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 216cea5..c5b3fd0 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -142,6 +142,9 @@ struct nfs_server {
>  						   filesystem */
>  	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
>  	struct rpc_wait_queue	roc_rpcwaitq;
> +	void			       *pnfs_ld_data; /* Per-mount data */
> +	unsigned int			ds_rsize;  /* Data server read size */
> +	unsigned int			ds_wsize;  /* Data server write size */

Shouldn't the rsize and wsize be part of the layout driver private data?

>  
>  	/* the following fields are protected by nfs_client->cl_lock */
>  	struct rb_root		state_owners;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

