From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 10/85] nfs41: struct nfs_server minorversion
Date: Mon, 17 Nov 2008 15:34:47 +0200
Message-ID: <492172F7.4070303@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348374-7339-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:13670 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751894AbYKQNeu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:34:50 -0500
In-Reply-To: <1226348374-7339-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:19 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Mike Sager <sager@netapp.com>
> 
> Set nfs_server minorversion from mount option (or default).
> During client initialization, use this minorversion.
> 
> Signed-off-by: Mike Sager <sager@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-14: see if wse can only keep one copy of the minorversion
in the nfs_client.

> ---
>  fs/nfs/client.c           |    2 ++
>  include/linux/nfs_fs_sb.h |    1 +
>  2 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 7547600..fe0bac9 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1112,6 +1112,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
>  	if (!server)
>  		return ERR_PTR(-ENOMEM);
>  
> +	server->minorversion = data->minorversion;
> +
>  	/* set up the general RPC client */
>  	error = nfs4_init_server(server, data);
>  	if (error < 0)
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 4e477ae..bfc83cc 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -115,6 +115,7 @@ struct nfs_server {
>  	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
>  						   that are supported on this
>  						   filesystem */
> +	u32			minorversion;
>  #endif
>  	void (*destroy)(struct nfs_server *);
>  


-- 
Benny Halevy
Software Architect
Tel/Fax: +972-3-647-8340
Mobile: +972-54-802-8340
bhalevy@panasas.com
 
Panasas, Inc.
The Leader in Parallel Storage
www.panasas.com
