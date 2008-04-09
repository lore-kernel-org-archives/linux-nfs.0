From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SELinux: don't BUG if fs reuses a superblock
Date: Wed, 09 Apr 2008 16:31:31 -0400
Message-ID: <1207773091.11881.27.camel@heimdal.trondhjem.org>
References: <1207764515.3070.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	steved@redhat.com, jlayton@redhat.com, sds@tycho.nsa.gov,
	jmorris@namei.org, chuck.lever@oracle.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:54930 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758598AbYDIUbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 16:31:36 -0400
In-Reply-To: <1207764515.3070.39.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-04-09 at 14:08 -0400, Eric Paris wrote:
> I (wrongly) assumed that nfs_xdev_get_sb() would not ever share a
> superblock and so cloning mount options would always be correct.  Turns
> out that isn't the case and we could fall over a BUG_ON() that wasn't a
> BUG at all.  Since there is little we can do to reconcile different
> mount options this patch just leaves the sb alone and the first set of
> options wins.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Ack...

> ---
> 
>  security/selinux/hooks.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 89bb6d3..d39b59c 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -760,13 +760,13 @@ static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
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
> +	/* if fs is reusing a sb, just let its options stand... */
> +	if (newsbsec->initialized)
> +		return;
> +
>  	mutex_lock(&newsbsec->lock);
>  
>  	newsbsec->flags = oldsbsec->flags;
> 
> 

