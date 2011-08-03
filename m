Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655Ab1HCRo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 13:44:56 -0400
Message-ID: <4E398915.6070603@RedHat.com>
Date: Wed, 03 Aug 2011 13:44:53 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.statd: Bind downcall socket to loopback address
References: <20110801201129.3503.99913.stgit@seurat.1015granger.net>
In-Reply-To: <20110801201129.3503.99913.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/01/2011 04:13 PM, Chuck Lever wrote:
> In the past, rpc.statd posted SM_NOTIFY requests using the same socket
> it used for sending downcalls to the kernel.  To receive replies from
> remote hosts, the socket was bound to INADDR_ANY.
> 
> With commit f113db52 "Remove notify functionality from statd in
> favour of sm-notify" (Mar 20, 2007), the downcall socket is no longer
> used for sending requests to remote hosts.  However, the downcall
> socket is still bound to INADDR_ANY.
> 
> Thus a remote host can inject data on this socket since it is an
> unconnected UDP socket listening for RPC replies.  Thanks to f113db52,
> the port number of this socket is no longer controlled by a command
> line option, making it difficult to firewall.
> 
> We have demonstrated that data injection on this socket can result in
> a DoS by causing rpc.statd to consume CPU and log bandwidth, but so
> far we have not found a breach.
> 
> To prevent unwanted data injection, bind this socket to the loopback
> address.
> 
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=177
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed..

steved.

> ---
> 
> Confirmed that reboot recovery still works, and that data injection
> is no longer possible.  This is an updated and final version of this
> patch.
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
