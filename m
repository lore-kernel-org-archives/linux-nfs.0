Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44480 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423Ab0JLADn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 20:03:43 -0400
Date: Mon, 11 Oct 2010 20:03:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH v2] sunrpc: Don't return NULL from rpcb_create
Message-ID: <20101012000342.GE16442@fieldses.org>
References: <4CAB56F0.9000504@parallels.com>
 <85B789F1-7E43-4C31-8C63-F1EF8C920051@oracle.com>
 <4CAC4554.7020001@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CAC4554.7020001@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 06, 2010 at 01:45:56PM +0400, Pavel Emelyanov wrote:
> > The reason for this is in the future, we may want to support additional 
> > address family types.  We should, therefore, ensure that every piece of 
> > code that is sensitive to address families fail in some orderly manner
> > to let developers know where a change is needed.
> 
> Makes sense. I was under impression, that AF-s other than INET are not
> cared about at all :(

Also leaving the rest of these to Trond; poke me if you need me to merge
anything more....

--b.

> 
> Here's a fixed version of the patch.
> 
> Log:
> 
> Its callers check for ERR_PTR.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
> 
>  net/sunrpc/rpcb_clnt.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 83af38d..1ef2d41 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -249,7 +249,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
>  		((struct sockaddr_in6 *)srvaddr)->sin6_port = htons(RPCBIND_PORT);
>  		break;
>  	default:
> -		return NULL;
> +		return ERR_PTR(-EAFNOSUPPORT);
>  	}
>  
>  	return rpc_create(&args);
> -- 
> 1.5.5.6
> 
