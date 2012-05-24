Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50501 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933424Ab2EXQJI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 12:09:08 -0400
Date: Thu, 24 May 2012 12:09:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH v2 01/12] NFS: pass net to nfs_callback_down()
Message-ID: <20120524160905.GB21776@fieldses.org>
References: <20120522073320.20602.87130.stgit@localhost.localdomain>
 <20120522073555.20602.12874.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120522073555.20602.12874.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I can see that you're passing net to nfs_callback_down().  Could you
please remind me why?  What problem does this solve?

--b.

On Tue, May 22, 2012 at 11:35:55AM +0400, Stanislav Kinsbursky wrote:
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfs/callback.c |    4 ++--
>  fs/nfs/callback.h |    2 +-
>  fs/nfs/client.c   |    2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 970659d..f3d7ee2 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -322,7 +322,7 @@ out_err:
>  /*
>   * Kill the callback thread if it's no longer being used.
>   */
> -void nfs_callback_down(int minorversion)
> +void nfs_callback_down(int minorversion, struct net *net)
>  {
>  	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
>  
> @@ -330,7 +330,7 @@ void nfs_callback_down(int minorversion)
>  	cb_info->users--;
>  	if (cb_info->users == 0 && cb_info->task != NULL) {
>  		kthread_stop(cb_info->task);
> -		svc_shutdown_net(cb_info->serv, current->nsproxy->net_ns);
> +		svc_shutdown_net(cb_info->serv, net);
>  		svc_exit_thread(cb_info->rqst);
>  		cb_info->serv = NULL;
>  		cb_info->rqst = NULL;
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index a5527c9..6d900cf 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -194,7 +194,7 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
>  				   struct cb_process_state *cps);
>  #ifdef CONFIG_NFS_V4
>  extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
> -extern void nfs_callback_down(int minorversion);
> +extern void nfs_callback_down(int minorversion, struct net *net);
>  extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
>  					    const nfs4_stateid *stateid);
>  extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index da7b5e4..44cd70f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -222,7 +222,7 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
>  static void nfs4_destroy_callback(struct nfs_client *clp)
>  {
>  	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
> -		nfs_callback_down(clp->cl_mvops->minor_version);
> +		nfs_callback_down(clp->cl_mvops->minor_version, clp->net);
>  }
>  
>  static void nfs4_shutdown_client(struct nfs_client *clp)
> 
