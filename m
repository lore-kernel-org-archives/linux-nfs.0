Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965397AbbKDVwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:52:10 -0500
Subject: Re: [PATCH] gssd: Make TCP the default protocol for GSSD connections.
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
References: <20151028200612.5365.33553.stgit@manet.1015granger.net>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7E09.8000009@RedHat.com>
Date: Wed, 4 Nov 2015 16:52:09 -0500
MIME-Version: 1.0
In-Reply-To: <20151028200612.5365.33553.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/28/2015 04:07 PM, Chuck Lever wrote:
> No failure case if gssd doesn't recognize the kernel's requested
> protocol. Caught with "protocol=rdma" upcall.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.
> ---
> Just spit-balling.
> 
>  utils/gssd/gssd_proc.c |   11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 1d8e6a7..7569295 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -890,16 +890,9 @@ create_auth_rpc_client(struct clnt_info *clp,
>  	printerr(2, "creating %s client for server %s\n", clp->protocol,
>  			clp->servername);
>  
> -	if ((strcmp(clp->protocol, "tcp")) == 0) {
> -		protocol = IPPROTO_TCP;
> -	} else if ((strcmp(clp->protocol, "udp")) == 0) {
> +	protocol = IPPROTO_TCP;
> +	if ((strcmp(clp->protocol, "udp")) == 0)
>  		protocol = IPPROTO_UDP;
> -	} else {
> -		printerr(0, "WARNING: unrecognized protocol, '%s', requested "
> -			 "for connection to server %s for user with uid %d\n",
> -			 clp->protocol, clp->servername, uid);
> -		goto out_fail;
> -	}
>  
>  	switch (addr->sa_family) {
>  	case AF_INET:
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
