From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/8] NFS: nfs_parsed_mount_options can use unsigned int
Date: Tue, 23 Sep 2008 15:42:21 -0400
Message-ID: <1222198941.7799.46.camel@localhost>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
	 <20080813223937.13068.47032.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14928 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbYIWTmd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2008 15:42:33 -0400
In-Reply-To: <20080813223937.13068.47032.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-13 at 18:39 -0400, Chuck Lever wrote:
> Eliminate mixed sign comparisons in nfs_compare_remount_options().
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

We really don't care about the sign, since we're always going to be
comparing for equality in nfs_compare_remount_options().

Cheers
  Trond

> ---
> 
>  fs/nfs/internal.h |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 24241fc..275a692 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -32,11 +32,11 @@ struct nfs_clone_mount {
>   */
>  struct nfs_parsed_mount_data {
>  	int			flags;
> -	int			rsize, wsize;
> -	int			timeo, retrans;
> -	int			acregmin, acregmax,
> +	unsigned int		rsize, wsize;
> +	unsigned int		timeo, retrans;
> +	unsigned int		acregmin, acregmax,
>  				acdirmin, acdirmax;
> -	int			namlen;
> +	unsigned int		namlen;
>  	unsigned int		bsize;
>  	unsigned int		auth_flavor_len;
>  	rpc_authflavor_t	auth_flavors[1];
> 
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
