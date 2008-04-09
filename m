From: Jeff Layton <jlayton@redhat.com>
Subject: Re: nfs_xdev_get_sb appears to sometimes reuse a sb and makes
 SELinux angry
Date: Wed, 9 Apr 2008 11:19:10 -0400
Message-ID: <20080409111910.42106baa@barsoom.rdu.redhat.com>
References: <1207753502.3070.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	steved@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616AbYDIPYj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2008 11:24:39 -0400
In-Reply-To: <1207753502.3070.25.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 09 Apr 2008 11:05:02 -0400
Eric Paris <eparis@redhat.com> wrote:

> When I wrote the new NFS/SELinux mount options code I was working under
> the assumption that nfs_xdev_get_sb() would always give a new superblock
> without the security struct initialized.  I now have a report of a user
> in which we hit BUG_ON(newsbsec->initialized) indicating to me that NFS
> is reusing a superblock.  The user says that he only has one mount to
> the server in fstab, but doesn't know much about the server setup.  Is
> it expected that nfs_xdev_get_sb might reuse a superblock?  If so maybe
> we want this patch below?  Instead of me BUGing every time selinux sees
> a reused superblock we but only if the reused superblock has different
> security options than the old one.  I can't reproduce the issue so I
> can't really test it....
> 
> comments?  should NFS be reusing a superblock here?  Can the NFS people
> let me know how I can trigger it to make sure my patch fixes it?
> 
> -Eric
> 
> ---
> 
>  security/selinux/hooks.c |   38 ++++++++++++++++++++++++++++++++++----
>  1 files changed, 34 insertions(+), 4 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 89bb6d3..71b01a4 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -760,13 +760,43 @@ static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>  	 * this early in the boot process. */
>  	BUG_ON(!ss_initialized);
>  
> -	/* this might go away sometime down the line if there is a new user
> -	 * of clone, but for now, nfs better not get here... */
> -	BUG_ON(newsbsec->initialized);
> -
>  	/* how can we clone if the old one wasn't set up?? */
>  	BUG_ON(!oldsbsec->initialized);
>  
> +	/*
> +	 * check to make sure something isn't trying to reuse a superblock that
> +	 * isn't actually the same.  if it is, that's the FS fault, not ours
> +	 */
> +	if (unlikely(newsbsec->initialized)) {
> +		struct security_mnt_opts new_opts, old_opts;
> +		int i;
> +
> +		if (newsb == oldsb)
> +			return;
> +
> +		if (selinux_get_mnt_opts(newsb, &new_opts))
> +			return;
> +		if (selinux_get_mnt_opts(oldsb, &old_opts)) {
> +			security_free_mnt_opts(&new_opts);
> +			return;
> +		}
> +
> +		BUG_ON(new_opts.num_mnt_opts != old_opts.num_mnt_opts);
> +
> +		/*
> +		 * this is safe since _get_mnt_opts puts things in the same
> +		 * order every time.
> +		 */
> +		for (i = 0; i < new_opts.num_mnt_opts; i++) {
> +			BUG_ON(new_opts.mnt_opts_flags[i] != old_opts.mnt_opts_flags[i]);
> +			BUG_ON(strcmp(new_opts.mnt_opts[i], old_opts.mnt_opts[i]));
> +		}
> +
> +		security_free_mnt_opts(&new_opts);
> +		security_free_mnt_opts(&old_opts);
> +		return;
> +	}
> +
>  	mutex_lock(&newsbsec->lock);
>  
>  	newsbsec->flags = oldsbsec->flags;
> 
> 


>From nfs_xdev_get_sb:

        int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
	...
        s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);


...if "compare_super" succeeds then an existing superblock will be
returned here.

To reproduce this, you'll probably need to have a server that
exports 2 filesystems, one mounted on the other. I've not tested this
but I suspect something like this would work:

Suppose you have 2 filesystems on the server /a and /a/b. Export them
both, and make sure to export /a/b with "nohide".

Now, on the client, mount up /a/b on a directory.

Then mount up /a in a different spot and "cd" into /a/b through that
mountpoint. When you walk into /a/b then it should search and find the
existing superblock from the first mount and use that.

If that's not clear, ping me and I'll see if I can help...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
