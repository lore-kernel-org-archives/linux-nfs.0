Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab3EPUVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 May 2013 16:21:43 -0400
Date: Thu, 16 May 2013 16:21:42 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] SUNRPC: Convert auth_gss pipe detection to work in
 namespaces
Message-ID: <20130516202142.GB3216@fieldses.org>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
 <1368647441-24815-2-git-send-email-Trond.Myklebust@netapp.com>
 <1368647441-24815-3-git-send-email-Trond.Myklebust@netapp.com>
 <1368647441-24815-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368647441-24815-4-git-send-email-Trond.Myklebust@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 12:50:41PM -0700, Trond Myklebust wrote:
> This seems to have been overlooked when we did the namespace
> conversion. If a container is running a legacy version of rpc.gssd
> then it will be disrupted if the global 'pipe_version' is set by a
> container running the new version of rpc.gssd.

Might be worth deprecating the "legacy" version--add a warning in for
any users and then remove it if we don't see any evidence anyone's hit
it recently.

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 46 +++++++++++++++++++++++++-----------------
>  net/sunrpc/netns.h             |  2 ++
>  net/sunrpc/rpc_pipe.c          |  1 +
>  3 files changed, 30 insertions(+), 19 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 3aff72f..fc2f78d 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -87,8 +87,6 @@ struct gss_auth {
>  };
>  
>  /* pipe_version >= 0 if and only if someone has a pipe open. */
> -static int pipe_version = -1;
> -static atomic_t pipe_users = ATOMIC_INIT(0);
>  static DEFINE_SPINLOCK(pipe_version_lock);
>  static struct rpc_wait_queue pipe_version_rpc_waitqueue;
>  static DECLARE_WAIT_QUEUE_HEAD(pipe_version_waitqueue);
> @@ -268,24 +266,27 @@ struct gss_upcall_msg {
>  	char databuf[UPCALL_BUF_LEN];
>  };
>  
> -static int get_pipe_version(void)
> +static int get_pipe_version(struct net *net)
>  {
> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>  	int ret;
>  
>  	spin_lock(&pipe_version_lock);
> -	if (pipe_version >= 0) {
> -		atomic_inc(&pipe_users);
> -		ret = pipe_version;
> +	if (sn->pipe_version >= 0) {
> +		atomic_inc(&sn->pipe_users);
> +		ret = sn->pipe_version;
>  	} else
>  		ret = -EAGAIN;
>  	spin_unlock(&pipe_version_lock);
>  	return ret;
>  }
>  
> -static void put_pipe_version(void)
> +static void put_pipe_version(struct net *net)
>  {
> -	if (atomic_dec_and_lock(&pipe_users, &pipe_version_lock)) {
> -		pipe_version = -1;
> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> +
> +	if (atomic_dec_and_lock(&sn->pipe_users, &pipe_version_lock)) {
> +		sn->pipe_version = -1;
>  		spin_unlock(&pipe_version_lock);
>  	}
>  }
> @@ -293,9 +294,10 @@ static void put_pipe_version(void)
>  static void
>  gss_release_msg(struct gss_upcall_msg *gss_msg)
>  {
> +	struct net *net = rpc_net_ns(gss_msg->auth->client);
>  	if (!atomic_dec_and_test(&gss_msg->count))
>  		return;
> -	put_pipe_version();
> +	put_pipe_version(net);
>  	BUG_ON(!list_empty(&gss_msg->list));
>  	if (gss_msg->ctx != NULL)
>  		gss_put_ctx(gss_msg->ctx);
> @@ -441,7 +443,10 @@ static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
>  				struct rpc_clnt *clnt,
>  				const char *service_name)
>  {
> -	if (pipe_version == 0)
> +	struct net *net = rpc_net_ns(clnt);
> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> +
> +	if (sn->pipe_version == 0)
>  		gss_encode_v0_msg(gss_msg);
>  	else /* pipe_version == 1 */
>  		gss_encode_v1_msg(gss_msg, clnt, service_name);
> @@ -457,7 +462,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
>  	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
>  	if (gss_msg == NULL)
>  		return ERR_PTR(-ENOMEM);
> -	vers = get_pipe_version();
> +	vers = get_pipe_version(rpc_net_ns(clnt));
>  	if (vers < 0) {
>  		kfree(gss_msg);
>  		return ERR_PTR(vers);
> @@ -581,8 +586,8 @@ retry:
>  	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
>  	if (PTR_ERR(gss_msg) == -EAGAIN) {
>  		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
> -				pipe_version >= 0, timeout);
> -		if (pipe_version < 0) {
> +				sn->pipe_version >= 0, timeout);
> +		if (sn->pipe_version < 0) {
>  			if (err == 0)
>  				sn->gssd_running = 0;
>  			warn_gssd();
> @@ -719,20 +724,22 @@ out:
>  
>  static int gss_pipe_open(struct inode *inode, int new_version)
>  {
> +	struct net *net = inode->i_sb->s_fs_info;
> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>  	int ret = 0;
>  
>  	spin_lock(&pipe_version_lock);
> -	if (pipe_version < 0) {
> +	if (sn->pipe_version < 0) {
>  		/* First open of any gss pipe determines the version: */
> -		pipe_version = new_version;
> +		sn->pipe_version = new_version;
>  		rpc_wake_up(&pipe_version_rpc_waitqueue);
>  		wake_up(&pipe_version_waitqueue);
> -	} else if (pipe_version != new_version) {
> +	} else if (sn->pipe_version != new_version) {
>  		/* Trying to open a pipe of a different version */
>  		ret = -EBUSY;
>  		goto out;
>  	}
> -	atomic_inc(&pipe_users);
> +	atomic_inc(&sn->pipe_users);
>  out:
>  	spin_unlock(&pipe_version_lock);
>  	return ret;
> @@ -752,6 +759,7 @@ static int gss_pipe_open_v1(struct inode *inode)
>  static void
>  gss_pipe_release(struct inode *inode)
>  {
> +	struct net *net = inode->i_sb->s_fs_info;
>  	struct rpc_pipe *pipe = RPC_I(inode)->pipe;
>  	struct gss_upcall_msg *gss_msg;
>  
> @@ -770,7 +778,7 @@ restart:
>  	}
>  	spin_unlock(&pipe->lock);
>  
> -	put_pipe_version();
> +	put_pipe_version(net);
>  }
>  
>  static void
> diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
> index 0827f64..f88b018 100644
> --- a/net/sunrpc/netns.h
> +++ b/net/sunrpc/netns.h
> @@ -28,6 +28,8 @@ struct sunrpc_net {
>  	wait_queue_head_t gssp_wq;
>  	struct rpc_clnt *gssp_clnt;
>  	int use_gss_proxy;
> +	unsigned int pipe_version;
> +	atomic_t pipe_users;
>  	struct proc_dir_entry *use_gssp_proc;
>  
>  	unsigned int gssd_running;
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 415b705..4f59a3c 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -1073,6 +1073,7 @@ void rpc_pipefs_init_net(struct net *net)
>  
>  	mutex_init(&sn->pipefs_sb_lock);
>  	sn->gssd_running = -1;
> +	sn->pipe_version = -1;
>  }
>  
>  /*
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
