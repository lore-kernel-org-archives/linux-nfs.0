Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx12.netapp.com ([216.240.18.77]:32819 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab1DLUFi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 16:05:38 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p3CJtM6V005723
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 12:55:27 -0700 (PDT)
Subject: Re: [PATCH 1/2] NFS: Attempt AUTH_UNIX style mount before guessing
 authflavors
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4DA4AA4D.2060702@netapp.com>
References: <4DA4AA4D.2060702@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Apr 2011 15:54:54 -0400
Message-ID: <1302638094.4801.76.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-04-12 at 15:38 -0400, Bryan Schumaker wrote:
> If an AUTH_UNIX mount returns -EPERM, we guess the authflavor needed
> to perform the mount.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   26 +++++++++++++++++---------
>  1 files changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8a03ee0..7e27ebf 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2208,19 +2208,15 @@ out:
>  	return ret;
>  }
>  
> -/*
> - * get the file handle for the "/" directory on the server
> - */
> -static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
> +static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>  			      struct nfs_fsinfo *info)
>  {
>  	int i, len, status = 0;
> -	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS + 2];
> +	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS];
>  
> -	flav_array[0] = RPC_AUTH_UNIX;
> -	len = gss_mech_list_pseudoflavors(&flav_array[1]);
> -	flav_array[1+len] = RPC_AUTH_NULL;
> -	len += 2;
> +	len = gss_mech_list_pseudoflavors(&flav_array[0]);
> +	flav_array[len] = RPC_AUTH_NULL;
> +	len += 1;
>  
>  	for (i = 0; i < len; i++) {
>  		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
> @@ -2228,6 +2224,18 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
>  			continue;
>  		break;
>  	}
> +	return status;
> +}
> +
> +/*
> + * get the file handle for the "/" directory on the server
> + */
> +static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
> +			      struct nfs_fsinfo *info)
> +{
> +	int status = nfs4_lookup_root(server, fhandle, info);
> +	if (status == -EPERM)
> +		status = nfs4_find_root_sec(server, fhandle, info);
>  	if (status == 0)
>  		status = nfs4_server_capabilities(server, fhandle);
>  	if (status == 0)

Wait. This is still wrong.

What if I have specified 'sec=krb5p' on my 'mount' command line?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

