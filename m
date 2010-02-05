From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/4] text-based mount: Retry when server can't be
 reached
Date: Fri, 5 Feb 2010 09:31:25 -0500
Message-ID: <20100205093125.01a5d20f@tlielax.poochiereds.net>
References: <20100122210221.10598.84522.stgit@localhost.localdomain>
	<20100122210621.10598.15244.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756567Ab0BEOba (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 09:31:30 -0500
In-Reply-To: <20100122210621.10598.15244.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 22 Jan 2010 16:06:21 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> We want new default behavior from mount.nfs when the server refuses a
> connection.  Since connection refusal can be spurious (for example,
> if the server is rebooting), mount.nfs should retry.
> 
> NFS shares that are automatically mounted by /etc/fstab at boot
> time may be problematic.  The new behavior can be disabled by
> specifying the "retry=0" mount option, or these mounts can be changed
> to background mounts by specifying the "bg" option.
> 
> A kernel code change is still required for the mount(2) system call to
> return ECONNREFUSED for NFSv4 mounts (see 2.6.33).  For v2/v3, the
> version and transport negotiation logic in mount.nfs should drive a
> retry if the server's rpcbind can't be reached.
> 
> Note that if a v2/v3 mount request encounters an unregistered NFS
> service, it will still fail immediately.  That wouldn't be too hard
> to change as well, but there are many more corner cases there where
> failing immediately is appropriate.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/nfs.man   |    6 +++++-
>  utils/mount/stropts.c |    4 ++++
>  2 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 93bd642..c64de5f 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -363,7 +363,11 @@ The number of minutes that the
>  command retries an NFS mount operation
>  in the foreground or background before giving up.
>  If this option is not specified, the default value for foreground mounts
> -is 2 minutes, and the default value for background mounts is 10000 minutes (80 minutes shy of one week).
> +is 2 minutes, and the default value for background mounts is 10000 minutes
> +(80 minutes shy of one week).
> +If a value of zero is specified, the
> +.BR mount (8)
> +command exits immediately after the first failure.
>  .TP 1.5i
>  .BI sec= mode
>  The RPCGSS security flavor to use for accessing files on this mount point.
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 57a4b32..74224ff 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -515,6 +515,10 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
>  	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
>  				 nfs_saddr, nfs_salen, &nfs_pmap)) {
>  		errno = ESPIPE;
> +		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
> +			errno = EOPNOTSUPP;
> +		else if (rpc_createerr.cf_error.re_errno != 0)
> +			errno = rpc_createerr.cf_error.re_errno;
>  		return 0;
>  	}
>  
> 


Apologies for the long delay in testing these. I gave the most recent
set of these in your git tree some testing this morning and they seem
to do the right thing.

I've also posted a patch this morning that's similar to the one
currently in Fedora to make the Defaultproto= option affect the address
family selection as well. I see that as complimentary to this set, and
it seems to work properly in conjunction with it.

-- 
Jeff Layton <jlayton@redhat.com>
