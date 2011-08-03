From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] rpc.statd: Bind downcall socket to loopback address
Date: Wed, 03 Aug 2011 12:58:20 -0400
Message-ID: <4E397E2C.1040001@RedHat.com>
References: <20110730224034.30227.2179.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934Ab1HCQ6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 12:58:22 -0400
In-Reply-To: <20110730224034.30227.2179.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

Are you still proposing this patch? Where you able to
get some testing done on it?

tia,

steved.

On 07/30/2011 06:43 PM, Chuck Lever wrote:
> In the past, rpc.statd posted SM_NOTIFY requests using the same socket
> it used for sending downcalls to the kernel.  To receive replies from
> remote hosts, the socket was bound to INADDR_ANY.
> 
> With commit f113db52 "Remove notify functionality from statd in
> favour of sm-notify" (Mar 20, 2007), the downcall socket is no longer
> used for sending requests to remote hosts.  However, the downcall
> socket is still bound to INADDR_ANY.  This means that any remote host
> can inject data on this socket, since it is an unconnected UDP socket
> listening for RPC replies.
> 
> To prevent unwanted data injection, bind this socket to loopback
> instead.
> 
> BugLink:
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=177
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> This proposed fix hasn't yet been thoroughly tested.  Comments?
> 
>  utils/statd/rmtcall.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
> index 0e52fe2..4ecb03c 100644
> --- a/utils/statd/rmtcall.c
> +++ b/utils/statd/rmtcall.c
> @@ -85,7 +85,7 @@ statd_get_socket(void)
>  
>  		memset(&sin, 0, sizeof(sin));
>  		sin.sin_family = AF_INET;
> -		sin.sin_addr.s_addr = INADDR_ANY;
> +		sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
>  
>  		if (bindresvport(sockfd, &sin) < 0) {
>  			xlog(D_GENERAL, "%s: can't bind to reserved port",
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
