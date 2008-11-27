From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] NFS: fix ERR_PTR with un mapped NFSv4 error
Date: Thu, 27 Nov 2008 09:15:24 +0200
Message-ID: <492E490C.2030109@panasas.com>
References: <1227739740-5885-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:22553 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751788AbYK0HPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Nov 2008 02:15:02 -0500
In-Reply-To: <1227739740-5885-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andy, I wonder if this actually needs to be done in
lower-level functions (e.g. nfs_probe_fsinfo).
I think that in general we should not let nfs errors
out of the layer immediately invoking the xdr routines.

Benny

On Nov. 27, 2008, 0:49 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> NFSv4 errors need to be mapped prior to ERR_PTR.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 7547600..49f06ce 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1154,7 +1154,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
>  error:
>  	nfs_free_server(server);
>  	dprintk("<-- nfs4_create_server() = error %d\n", error);
> -	return ERR_PTR(error);
> +	return ERR_PTR(nfs4_map_errors(error));
>  }
>  
>  /*
> @@ -1231,7 +1231,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
>  error:
>  	nfs_free_server(server);
>  	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
> -	return ERR_PTR(error);
> +	return ERR_PTR(nfs4_map_errors(error));
>  }
>  
>  #endif /* CONFIG_NFS_V4 */
> @@ -1299,7 +1299,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
>  out_free_server:
>  	nfs_free_server(server);
>  	dprintk("<-- nfs_clone_server() = error %d\n", error);
> -	return ERR_PTR(error);
> +	return ERR_PTR(nfs4_map_errors(error));
>  }
>  
>  #ifdef CONFIG_PROC_FS
