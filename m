Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57364 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab1FJWHE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 18:07:04 -0400
Subject: Re: [PATCH v3 3/6] nfs-utils:  Implement srcaddr binding in rpc_socket
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1307740096-19933-4-git-send-email-greearb@candelatech.com>
Date: Fri, 10 Jun 2011 18:06:51 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <A2323BA3-3082-4416-A4C4-062726F15D6F@oracle.com>
References: <1307740096-19933-1-git-send-email-greearb@candelatech.com> <1307740096-19933-4-git-send-email-greearb@candelatech.com>
To: greearb@candelatech.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 10, 2011, at 5:08 PM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> This implements the actual binding, if we are passed
> a non-null local_ip structure.

Why not _always_ pass a valid local_ip structure, and simply set .addr to an appropriate ANYADDR by default?  Then .is_set wouldn't be necessary, would it?  It would also simplify the logic in nfs_validate_options().

> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 5652f6c... 4bcbdf0... M	support/nfs/rpc_socket.c
> support/nfs/rpc_socket.c |   59 +++++++++++++++++++++++++++++++++++----------
> 1 files changed, 46 insertions(+), 13 deletions(-)
> 
> diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
> index 5652f6c..4bcbdf0 100644
> --- a/support/nfs/rpc_socket.c
> +++ b/support/nfs/rpc_socket.c
> @@ -115,6 +115,8 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
> static int nfs_bind(const int sock, const sa_family_t family,
> 		    struct local_bind_info *local_ip)
> {
> +	struct sockaddr *sa = NULL;
> +	socklen_t salen = 0;
> 	struct sockaddr_in sin = {
> 		.sin_family		= AF_INET,
> 		.sin_addr.s_addr	= htonl(INADDR_ANY),
> @@ -124,15 +126,26 @@ static int nfs_bind(const int sock, const sa_family_t family,
> 		.sin6_addr		= IN6ADDR_ANY_INIT,
> 	};
> 
> -	switch (family) {
> -	case AF_INET:
> -		return bind(sock, (struct sockaddr *)(char *)&sin,
> -					(socklen_t)sizeof(sin));
> -	case AF_INET6:
> -		return bind(sock, (struct sockaddr *)(char *)&sin6,
> -					(socklen_t)sizeof(sin6));
> +	if (local_ip && local_ip->is_set) {
> +		sa = &local_ip->addr.sa;
> +		salen = local_ip->addrlen;
> +	} else {
> +		switch (family) {
> +		case AF_INET:
> +			sa = (struct sockaddr *)&sin;
> +			salen = sizeof(sin);
> +			break;
> +		case AF_INET6:
> +			sa = (struct sockaddr *)&sin6;
> +			salen = sizeof(sin6);
> +		default:
> +			break;
> +		}
> 	}
> 
> +	if (sa)
> +		return bind(sock, sa, salen);
> +
> 	errno = EAFNOSUPPORT;
> 	return -1;
> }
> @@ -148,6 +161,7 @@ static int nfs_bind(const int sock, const sa_family_t family,
> static int nfs_bindresvport(const int sock, const sa_family_t family,
> 			    struct local_bind_info *local_ip)
> {
> +	struct sockaddr *sa = NULL;
> 	struct sockaddr_in sin = {
> 		.sin_family		= AF_INET,
> 		.sin_addr.s_addr	= htonl(INADDR_ANY),
> @@ -157,13 +171,23 @@ static int nfs_bindresvport(const int sock, const sa_family_t family,
> 		.sin6_addr		= IN6ADDR_ANY_INIT,
> 	};
> 
> -	switch (family) {
> -	case AF_INET:
> -		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin);
> -	case AF_INET6:
> -		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin6);
> +	if (local_ip && local_ip->is_set) {
> +		sa = &local_ip->addr.sa;
> +	} else {
> +		switch (family) {
> +		case AF_INET:
> +			sa = (struct sockaddr *)&sin;
> +			break;
> +		case AF_INET6:
> +			sa = (struct sockaddr *)&sin6;
> +		default:
> +			break;
> +		}
> 	}
> 
> +	if (sa)
> +		return bindresvport_sa(sock, sa);
> +
> 	errno = EAFNOSUPPORT;
> 	return -1;
> }
> @@ -179,12 +203,21 @@ static int nfs_bindresvport(const int sock, const sa_family_t family,
> static int nfs_bindresvport(const int sock, const sa_family_t family,
> 			    struct local_bind_info *local_ip)
> {
> +	struct sockaddr_in laddr;
> 	if (family != AF_INET) {
> 		errno = EAFNOSUPPORT;
> 		return -1;
> 	}
> 
> -	return bindresvport(sock, NULL);
> +	laddr.sin_family = family;
> +	laddr.sin_port = 0;
> +	if (local_ip && local_ip->is_set) {
> +		struct sockaddr_in *si = &local_ip->addr.s4;
> +		laddr.sin_addr.s_addr = si->sin_addr.s_addr;
> +	} else {
> +		laddr.sin_addr.s_addr = htonl(INADDR_ANY);
> +	}
> +	return bindresvport(sock, &laddr);
> }
> 
> #endif	/* !HAVE_LIBTIRPC */
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




