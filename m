Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab3F1UD7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 16:03:59 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] NFS: Set NFS_CS_MIGRATION for NFSv4 mounts
Date: Fri, 28 Jun 2013 20:03:58 +0000
Message-ID: <1372449832.20188.1.camel@leira.trondhjem.org>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
	 <20130625162327.36416.68503.stgit@seurat.1015granger.net>
In-Reply-To: <20130625162327.36416.68503.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 12:23 -0400, Chuck Lever wrote:
> NFS_CS_MIGRATION makes sense only for NFSv4 mounts.  Introduced by
> commit 89652617 (NFS: Introduce "migration" mount option) Fri Sep 14
> 17:24:11 2012.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/client.c     |    2 --
>  fs/nfs/nfs4client.c |    2 ++
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index c513b0c..dbb65fb 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -753,8 +753,6 @@ static int nfs_init_server(struct nfs_server *server,
>  			data->timeo, data->retrans);
>  	if (data->flags & NFS_MOUNT_NORESVPORT)
>  		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
> -	if (server->options & NFS_OPTION_MIGRATION)
> -		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
>  
>  	/* Allocate or find a client reference we can use */
>  	clp = nfs_get_client(&cl_init, &timeparms, NULL, RPC_AUTH_UNIX);
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 4cbad5d..b7a9f76 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -626,6 +626,8 @@ static int nfs4_set_client(struct nfs_server *server,
>  
>  	if (server->flags & NFS_MOUNT_NORESVPORT)
>  		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
> +	if (server->options & NFS_OPTION_MIGRATION)
> +		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
>  
>  	/* Allocate or find a client reference we can use */
>  	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour);
> 

Applied
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
