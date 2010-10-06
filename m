Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:26541 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab0JFCzw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 22:55:52 -0400
Subject: Re: [PATCH] sunrpc: Don't return NULL from rpcb_create
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CAB56F0.9000504@parallels.com>
Date: Tue, 5 Oct 2010 22:55:39 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <85B789F1-7E43-4C31-8C63-F1EF8C920051@oracle.com>
References: <4CAB56F0.9000504@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 5, 2010, at 12:48 PM, Pavel Emelyanov wrote:

> Its callers check for ERR_PTR.

That's a good observation.

> However grep shows that nobody calls this with sa_familiy other than
> AF_INET/AF_INET6 so this case can be simply dropped.

The reason for this is in the future, we may want to support additional address family types.  We should, therefore, ensure that every piece of code that is sensitive to address families fail in some orderly manner to let developers know where a change is needed.

> Furthermore - the remaining code can be replaced with the existing helper.

A better choice is for rpcb_create() to return ERR_PTR(-EAFNOSUPPORT) or ERR_PTR(-EPFNOSUPPORT) in this case, rather than failing silently.

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
> net/sunrpc/rpcb_clnt.c |   12 +-----------
> 1 files changed, 1 insertions(+), 11 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 83af38d..620dee7 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -241,17 +241,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
> 					RPC_CLNT_CREATE_NONPRIVPORT),
> 	};
> 
> -	switch (srvaddr->sa_family) {
> -	case AF_INET:
> -		((struct sockaddr_in *)srvaddr)->sin_port = htons(RPCBIND_PORT);
> -		break;
> -	case AF_INET6:
> -		((struct sockaddr_in6 *)srvaddr)->sin6_port = htons(RPCBIND_PORT);
> -		break;
> -	default:
> -		return NULL;
> -	}
> -
> +	rpc_set_port(srvaddr, RPCBIND_PORT);
> 	return rpc_create(&args);
> }
> 
> -- 
> 1.5.5.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



