From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
	support is built in
Date: Fri, 30 Jan 2009 16:57:01 -0500
Message-ID: <20090130215701.GJ31166@fieldses.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53114 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbZA3V5A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 16:57:00 -0500
In-Reply-To: <20090130201041.22301.60941.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 30, 2009 at 03:10:42PM -0500, Chuck Lever wrote:
> Apparently a lot of people need to completely disable IPv6 on their
> distribution-built systems, and they do this by blacklisting the
> ipv6 module.  This causes lockd_up(), and thus NFS mounts, to fail
> in all cases (even for IPv4 mounts) if CONFIG_IPV6_MODULE and
> CONFIG_SUNRPC_REGISTER_V4 is set.
> 
> As a workaround, change lockd to use an AF_INET6 listener only if IPv6
> is built into the kernel.
> 
> This allows IPv6 NFS testing to continue, while supporting legacy IPv4
> NFS as before.  In the meantime, we will pursue a long-term fix so that
> lockd (and eventually NFSD) will be able to handle this case correctly.

I'm curious to see what the long-term fix will be here.  (The idea of
trying to load the module seems reasonable as a start.)  Other than
that, I looked throught all the patches and they seem fine.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: Steve Dickson <steved@redhat.com>
> ---
> 
>  fs/lockd/svc.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 64f1c31..39ec7f2 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -54,14 +54,15 @@ unsigned long			nlmsvc_timeout;
>  
>  /*
>   * If the kernel has IPv6 support available, always listen for
> - * both AF_INET and AF_INET6 requests.
> + * both AF_INET and AF_INET6 requests.  To avoid breaking lockd
> + * if the ipv6 module was built but has been blacklisted, enable
> + * this only if IPv6 support is built into the kernel.
>   */
> -#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
> -	defined(CONFIG_SUNRPC_REGISTER_V4)
> +#if defined(CONFIG_IPV6) && defined(CONFIG_SUNRPC_REGISTER_V4)
>  static const sa_family_t	nlmsvc_family = AF_INET6;
> -#else	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
> +#else	/* CONFIG_IPV6 && CONFIG_SUNRPC_REGISTER_V4 */
>  static const sa_family_t	nlmsvc_family = AF_INET;
> -#endif	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
> +#endif	/* CONFIG_IPV6 && CONFIG_SUNRPC_REGISTER_V4 */
>  
>  /*
>   * These can be set at insmod time (useful for NFS as root filesystem),
> 
