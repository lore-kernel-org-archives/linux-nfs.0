Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55093 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883Ab2DWVYW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 17:24:22 -0400
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 23 Apr 2012 17:24:20 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4B1A138C8063
	for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 17:23:47 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3NLNlAh293042
	for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 17:23:47 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3NLNk6r015592
	for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 18:23:46 -0300
Date: Mon, 23 Apr 2012 16:23:45 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 20/20] NFS: Clean up debugging messages in
 fs/nfs/client.c
Message-ID: <20120423212345.GA17089@us.ibm.com>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
 <20120423205612.11446.89496.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120423205612.11446.89496.stgit@degas.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever [chuck.lever@oracle.com] wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/client.c |   21 +++++++++++++++++----
>  1 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 7330673..beb001b 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -192,6 +192,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  		clp->cl_machine_cred = cred;
>  	nfs_fscache_get_client_cookie(clp);
> 
> +	dprintk("NFS: %s returning new nfs_client = %p ({1})\n",
> +		__func__, clp);
>  	return clp;
> 
>  error_cleanup:
> @@ -291,7 +293,7 @@ static void pnfs_init_server(struct nfs_server *server)
>   */
>  static void nfs_free_client(struct nfs_client *clp)
>  {
> -	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
> +	dprintk("--> %s destroying nfs_client = %p\n", __func__, clp);
> 
>  	nfs4_shutdown_client(clp);
> 
> @@ -308,7 +310,7 @@ static void nfs_free_client(struct nfs_client *clp)
>  	kfree(clp->cl_hostname);
>  	kfree(clp);
> 
> -	dprintk("<-- nfs_free_client()\n");
> +	dprintk("<-- %s done\n", __func__);

Many dprintk's seem to take __func__. How about pushing that to dprink
macro itself. I have one and use it most of the time.

Regards, Malahal.

