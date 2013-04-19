Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030418Ab3DSOCI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Apr 2013 10:02:08 -0400
Date: Fri, 19 Apr 2013 07:01:50 -0700
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: enable UMH client tracker in container
Message-ID: <20130419070150.6937f1e6@corrin.poochiereds.net>
In-Reply-To: <20130416111344.14621.56912.stgit@localhost.localdomain>
References: <20130416111344.14621.56912.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 16 Apr 2013 15:17:44 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> This patch adds support for UserModeHelper tracker in a container.
> The reason for this is that the only containerised tracker ("nfsdcld") is
> going to be removed in 3.10 kernel, thus at least one more tracker have to be
> containerised to replace the deprecated one.
> UMH tracker looks more preferable comparing to legacy since it's the latest
> one.
> To make UMH tracker work in a container, we have to make sure, that it
> executes right binary (i.e., this binary have to be taken from the container
> environment).
> But, UMH is a kernel thread, which works in global root environment by design
> (kernel thread's root is inherited from kthreadd, which in turn inherited it's
> root from global init). So, the root have to be swapped to the container's
> one before binary execution.
> 
> This patch passes "init" callback and private "data" to UMH interface, which
> are used to swap root for spawned kernel thread.
> 
> Note: container's root can be stored on stack, because UMH calls are
> synchronous.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfsd/nfs4recover.c |   29 ++++++++++++++++++++++-------
>  1 files changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 899ca26..15f8de6 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -38,6 +38,7 @@
>  #include <linux/crypto.h>
>  #include <linux/sched.h>
>  #include <linux/fs.h>
> +#include <linux/fs_struct.h>
>  #include <linux/module.h>
>  #include <net/net_namespace.h>
>  #include <linux/sunrpc/rpc_pipe_fs.h>
> @@ -1122,12 +1123,28 @@ nfsd4_cltrack_legacy_recdir(const struct xdr_netobj *name)
>  	return result;
>  }
>  
> +static int nfsd_swap_root(struct subprocess_info *info, struct cred *new)
> +{
> +	struct path *root = info->data;
> +	struct fs_struct *fs = current->fs;
> +	struct path current_root;
> +
> +	spin_lock(&fs->lock);
> +	current_root = fs->root;
> +	fs->root = *root;
> +	spin_unlock(&fs->lock);
> +	if (current_root.dentry)
> +		path_put(&current_root);
> +	return 0;
> +}
> +
>  static int
>  nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *legacy)
>  {
>  	char *envp[2];
>  	char *argv[4];
>  	int ret;
> +	struct path root;
>  
>  	if (unlikely(!cltrack_prog[0])) {
>  		dprintk("%s: cltrack_prog is disabled\n", __func__);
> @@ -1146,7 +1163,11 @@ nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *legacy)
>  	argv[2] = arg;
>  	argv[3] = NULL;
>  
> -	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
> +	get_fs_root(current->fs, &root);
> +
> +	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_WAIT_PROC,
> +				       nfsd_swap_root, NULL, &root);
> +
>  	/*
>  	 * Disable the upcall mechanism if we're getting an ENOENT or EACCES
>  	 * error. The admin can re-enable it on the fly by using sysfs
> @@ -1185,12 +1206,6 @@ bin_to_hex_dup(const unsigned char *src, int srclen)
>  static int
>  nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
>  {
> -	/* XXX: The usermode helper s not working in container yet. */
> -	if (net != &init_net) {
> -		WARN(1, KERN_ERR "NFSD: attempt to initialize umh client "
> -			"tracking in a container!\n");
> -		return -EINVAL;
> -	}
>  	return nfsd4_umh_cltrack_upcall("init", NULL, NULL);
>  }
>  
> 

I think this looks correct and like it'll work, but I wonder whether
we'd be best served by making this part of the UMH code itself?

IOW, add some fields to the struct subprocess_info to hold the new
root, and then do what you're doing in nfsd_swap_root before calling
the "init" function?

I imagine we'll eventually need do something similar for at least some
of the callers of call_usermodehelper so it would make sense to me to
not replicate copies of nfsd_swap_root all over the place.

-- 
Jeff Layton <jlayton@redhat.com>
