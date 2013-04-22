Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885Ab3DVRTZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Apr 2013 13:19:25 -0400
Message-ID: <51757107.4030600@RedHat.com>
Date: Mon, 22 Apr 2013 13:19:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, Marc Eshel <eshel@us.ibm.com>
Subject: Re: [PATCH] sm-notify: "-v hostname" doesn't work when IPV6_SUPPORT
 is enabled
References: <20130413161628.29954.19723.stgit@seurat.1015granger.net>
In-Reply-To: <20130413161628.29954.19723.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 13/04/13 12:17, Chuck Lever wrote:
> Marc Eshel reports that using the -v command line option on the
> sm-notify command stopped working after nfs-utils 1.2.2, when IPv6
> support was added.  If nfs-utils is built without IPv6 support, it
> still works.  Marc specified a hostname with a single A record.
> 
> smn_bind_address() must construct a bind address with the same
> family as the RPC socket's protocol family.  Add an AI_V4MAPPED hint
> so an appropriate IPv6 bind address is constructed even if -v
> specifies an IPv4 presentation address, or a hostname with only IPv4
> mappings.
> 
> We still use an IPv4 bind address if IPv6 support is compiled out or
> the host does not support IPv6.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Marc Eshel <eshel@us.ibm.com>
Committed....

steved.

> ---
> 
>  utils/statd/sm-notify.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index a3290aa..9dbe5d9 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -349,7 +349,7 @@ smn_bind_address(const char *srcaddr, const char *srcport)
>  {
>  	struct addrinfo *ai = NULL;
>  	struct addrinfo hint = {
> -		.ai_flags	= AI_NUMERICSERV,
> +		.ai_flags	= AI_NUMERICSERV | AI_V4MAPPED,
>  		.ai_family	= nsm_family,
>  		.ai_protocol	= (int)IPPROTO_UDP,
>  	};
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
