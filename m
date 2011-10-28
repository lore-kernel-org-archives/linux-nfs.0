Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933393Ab1J1VYw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 17:24:52 -0400
Date: Fri, 28 Oct 2011 17:24:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
Message-ID: <20111028212450.GA7441@fieldses.org>
References: <1319455259-3136-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319455259-3136-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 24, 2011 at 07:20:57AM -0400, bjschuma@netapp.com wrote:
...
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> new file mode 100644
> index 0000000..1ac4134
> --- /dev/null
> +++ b/fs/nfsd/fault_inject.c
> @@ -0,0 +1,90 @@
...
> +int nfsd_fault_inject_init(void)
> +{
> +	unsigned int i;
> +	struct nfsd_fault_inject_op *op;
> +	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
> +
> +	debug_dir = debugfs_create_dir("nfsd", NULL);
> +	if (!debug_dir)
> +		goto fail;
> +
> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
> +		op = &inject_ops[i];
> +		debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);

I think you need to check the return value and "goto fail" on NULL.

(Do you also need to put the returned dentry on success?  Checking other
callers.... No, I guess not, OK.)

> +	}
> +	return 0;
> +
> +fail:
> +	nfsd_fault_inject_cleanup();
> +	return -ENOMEM;
> +}
...
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index db34a58..e67f30c 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
...
> @@ -1130,6 +1131,9 @@ static int __init init_nfsd(void)
>  	retval = nfs4_state_init(); /* nfs4 locking state */
>  	if (retval)
>  		return retval;
> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
> +	if (retval)
> +		goto out_cleanup_fault_injection;
>  	nfsd_stat_init();	/* Statistics */
>  	retval = nfsd_reply_cache_init();
>  	if (retval)
> @@ -1161,6 +1165,8 @@ out_free_cache:
>  out_free_stat:
>  	nfsd_stat_shutdown();
>  	nfsd4_free_slabs();
> +out_cleanup_fault_injection:
> +	nfsd_fault_inject_cleanup();

Check the cleanup here again....  The slabs are allocated in state_init,
so you need to do that on nfsd_fault_inject_init, but you *don't* need
the fault_inject_cleanup in that case, since fault_inject_init cleanup
cleans up after itself--that's needed only on later failures.

--b.

>  	return retval;
>  }
>  
> @@ -1174,6 +1180,7 @@ static void __exit exit_nfsd(void)
>  	nfsd_lockd_shutdown();
>  	nfsd_idmap_shutdown();
>  	nfsd4_free_slabs();
> +	nfsd_fault_inject_cleanup();
>  	unregister_filesystem(&nfsd_fs_type);
>  }
>  
> -- 
> 1.7.7
> 
