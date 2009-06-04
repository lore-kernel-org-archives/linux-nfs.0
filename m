From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/10] nfs-utils: add IPv6 support to nfssvc_setfds
Date: Thu, 4 Jun 2009 17:00:47 -0400
Message-ID: <DC1F246A-56CD-4236-A44D-4352DA7A75F4@oracle.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com> <1244058763-10352-9-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:45817 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbZFDVBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2009 17:01:16 -0400
In-Reply-To: <1244058763-10352-9-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2009, at 3:52 PM, Jeff Layton wrote:

> Allow nfssvc_setfds to properly deal with AF_INET6.
>
> IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set  
> the
> correct option to prevent that from occurring on IPv6 sockets.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/nfs/nfssvc.c |   14 ++++++++++++++
> 1 files changed, 14 insertions(+), 0 deletions(-)
>
> diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
> index 89fb5be..19f1a4c 100644
> --- a/support/nfs/nfssvc.c
> +++ b/support/nfs/nfssvc.c
> @@ -76,6 +76,11 @@ nfssvc_setfds(const struct addrinfo *hints, const  
> char *node, const char *port)
> 	case AF_INET:
> 		family = "inet";
> 		break;
> +#ifdef IPV6_SUPPORTED
> +	case AF_INET6:
> +		family = "inet6";
> +		break;
> +#endif /* IPV6_SUPPORTED */
> 	default:
> 		xlog(L_ERROR, "Unknown address family specified: %d\n",
> 				hints->ai_family);
> @@ -123,6 +128,15 @@ nfssvc_setfds(const struct addrinfo *hints,  
> const char *node, const char *port)
> 			rc = errno;
> 			goto error;
> 		}
> +#ifdef IPV6_SUPPORTED
> +		if (addr->ai_family == AF_INET6 &&
> +		    setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &on,  
> sizeof(on))) {
> +			xlog(L_ERROR, "unable to set IPV6_V6ONLY: "
> +				"errno %d (%s)\n", errno, strerror(errno));
> +			rc = -errno;

Maybe "rc = errno;" ?

> +			goto error;
> +		}
> +#endif /* IPV6_SUPPORTED */
> 		if (addr->ai_protocol == IPPROTO_TCP &&
> 		    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))) {
> 			xlog(L_ERROR, "unable to set SO_REUSEADDR on %s "
> -- 
> 1.6.2.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



