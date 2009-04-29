From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils: Fix IPv6 support in support/nfs/rpc_socket.c
Date: Wed, 29 Apr 2009 17:35:04 -0400
Message-ID: <2DD6DD01-7395-4B93-A334-102D28E54B30@oracle.com>
References: <20090429212247.9359.84751.stgit@seurat.1015granger.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29315 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbZD2Vf2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2009 17:35:28 -0400
In-Reply-To: <20090429212247.9359.84751.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, you can ignore this one.

On Apr 29, 2009, at 5:24 PM, Chuck Lever wrote:

> Use the correct #ifdef variable to enable IPv6 support for privileged
> RPC clients.  Without this fix, unmounting IPv6 NFSv2/v3 servers  
> fails.
>
> Introduced by commit 8c94296bc84f3a204f2061c0391a1d2350e4f37e.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>
> support/nfs/rpc_socket.c |   12 +++++-------
> 1 files changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
> index 85e6064..cebf83d 100644
> --- a/support/nfs/rpc_socket.c
> +++ b/support/nfs/rpc_socket.c
> @@ -132,7 +132,7 @@ static int nfs_bind(const int sock, const  
> sa_family_t family)
> 	return -1;
> }
>
> -#ifdef IPV6_SUPPORT
> +#ifdef IPV6_SUPPORTED
>
> /*
>  * Bind a socket using an unused privileged source port.
> @@ -153,18 +153,16 @@ static int nfs_bindresvport(const int sock,  
> const sa_family_t family)
>
> 	switch (family) {
> 	case AF_INET:
> -		return bindresvport_sa(sock, (struct sockaddr *)&sin,
> -					(socklen_t)sizeof(sin));
> +		return bindresvport_sa(sock, (struct sockaddr *)&sin);
> 	case AF_INET6:
> -		return bindresvport_sa(sock, (struct sockaddr *)&sin6,
> -					(socklen_t)sizeof(sin6));
> +		return bindresvport_sa(sock, (struct sockaddr *)&sin6);
> 	}
>
> 	errno = EAFNOSUPPORT;
> 	return -1;
> }
>
> -#else	/* !IPV6_SUPPORT */
> +#else	/* !IPV6_SUPPORTED */
>
> /*
>  * Bind a socket using an unused privileged source port.
> @@ -182,7 +180,7 @@ static int nfs_bindresvport(const int sock,  
> const sa_family_t family)
> 	return bindresvport(sock, NULL);
> }
>
> -#endif	/* !IPV6_SUPPORT */
> +#endif	/* !IPV6_SUPPORTED */
>
> /*
>  * Perform a non-blocking connect on the socket fd.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
