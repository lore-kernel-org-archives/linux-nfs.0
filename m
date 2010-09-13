From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] mount.nfs: Refactor mount version and protocol
 autonegotiation
Date: Mon, 13 Sep 2010 13:51:57 -0400
Message-ID: <20100913175157.GC16253@fieldses.org>
References: <20100913171100.18926.77712.stgit@seurat.1015granger.net>
 <20100913171736.18926.97496.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33359 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474Ab0IMRxC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Sep 2010 13:53:02 -0400
In-Reply-To: <20100913171736.18926.97496.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 13, 2010 at 01:17:36PM -0400, Chuck Lever wrote:
> Clean up.
> 
> I'm beginning to agree with Bruce and Steve's assessment that the
> fallthrough switch case in nfs_try_mount() is more difficult to read
> and understand than it needs to be.  The logic that manages
> negotiating NFS version and protocol settings is getting more complex
> over time anyway.
> 
> So let's split the autonegotiation piece out of nfs_try_mount().
> 
> We can reduce indenting, and use cleaner switch-based logic.  Also,
> adding more comments can only help.

Looks OK to me, thanks.--b.

> 
> Neil also suggested replacing the pre-call "errno = 0" trick.  The
> lower-level functions may try to mount several times (given a list of
> addresses to try).  errno could be set by any of those.  The mount
> request will succeed at some point, and "success" is returned, but
> errno is still set to some non-zero value.
> 
> The kernel version check in nfs_try_mount() is more or less loop
> invariant: it's impossible for the result of that test to change
> between retries.  So we should be able to safely move it to the logic
> that sets the initial value of mi->version.
> 
> This patch is not supposed to cause a behavioral change.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/stropts.c |   67 +++++++++++++++++++++++++++++++++++++++----------
>  1 files changed, 53 insertions(+), 14 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c82ddfe..c5c4ba1 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -304,6 +304,16 @@ static int nfs_set_version(struct nfsmount_info *mi)
>  		mi->version = 4;
>  
>  	/*
> +	 * Before 2.6.32, the kernel NFS client didn't
> +	 * support "-t nfs vers=4" mounts, so NFS version
> +	 * 4 cannot be included when autonegotiating
> +	 * while running on those kernels.
> +	 */
> +	if (mi->version == 0 &&
> +	    linux_version_code() <= MAKE_VERSION(2, 6, 31))
> +		mi->version = 3;
> +
> +	/*
>  	 * If we still don't know, check for version-specific
>  	 * mount options.
>  	 */
> @@ -746,6 +756,47 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
>  }
>  
>  /*
> + * Handle NFS version and transport protocol
> + * autonegotiation.
> + *
> + * When no version or protocol is specified on the
> + * command line, mount.nfs negotiates with the server
> + * to determine appropriate settings for the new
> + * mount point.
> + *
> + * Returns TRUE if successful, otherwise FALSE.
> + * "errno" is set to reflect the individual error.
> + */
> +static int nfs_autonegotiate(struct nfsmount_info *mi)
> +{
> +	int result;
> +
> +	result = nfs_try_mount_v4(mi);
> +	if (result)
> +		return result;
> +		
> +	switch (errno) {
> +	case EPROTONOSUPPORT:
> +		/* A clear indication that the server or our
> +		 * client does not support NFS version 4. */
> +		goto fall_back;
> +	case ENOENT:
> +		/* Legacy Linux servers don't export an NFS
> +		 * version 4 pseudoroot. */
> +		goto fall_back;
> +	case EPERM:
> +		/* Linux servers prior to 2.6.25 may return
> +		 * EPERM when NFS version 4 is not supported. */
> +		goto fall_back;
> +	default:
> +		return result;
> +	}
> +
> +fall_back:
> +	return nfs_try_mount_v3v2(mi);
> +}
> +
> +/*
>   * This is a single pass through the fg/bg loop.
>   *
>   * Returns TRUE if successful, otherwise FALSE.
> @@ -757,20 +808,8 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>  
>  	switch (mi->version) {
>  	case 0:
> -		if (linux_version_code() > MAKE_VERSION(2, 6, 31)) {
> -			errno = 0;
> -			result = nfs_try_mount_v4(mi);
> -			if (errno != EPROTONOSUPPORT) {
> -				/* 
> -				 * To deal with legacy Linux servers that don't
> -				 * automatically export a pseudo root, retry
> -				 * ENOENT errors using version 3. And for
> -				 * Linux servers prior to 2.6.25, retry EPERM
> -				 */
> -				if (errno != ENOENT && errno != EPERM)
> -					break;
> -			}
> -		}
> +		result = nfs_autonegotiate(mi);
> +		break;
>  	case 2:
>  	case 3:
>  		result = nfs_try_mount_v3v2(mi);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
