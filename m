Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29344 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757817Ab1FJS3X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 14:29:23 -0400
Subject: Re: [PATCH 4/7] nfs-utils:  Implement srcaddr binding in network.c
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1307729379-7702-5-git-send-email-greearb@candelatech.com>
Date: Fri, 10 Jun 2011 14:29:12 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <7BC92EC0-31CE-4A5D-85F8-E409E812A819@oracle.com>
References: <1307729379-7702-1-git-send-email-greearb@candelatech.com> <1307729379-7702-5-git-send-email-greearb@candelatech.com>
To: greearb@candelatech.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 10, 2011, at 2:09 PM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> Implement binding logic in get_socket() if local_ip
> argument is not NULL.
> 
> Note that this method had issues with supporting IPv6 before
> this patch, and this patch does NOT resolve them.

If get_socket() doesn't support IPv6, then I doubt it's used for string-based mounts.  You may not need any changes here.

> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 36c2e94... 5419c5d... M	utils/mount/network.c
> utils/mount/network.c |   21 ++++++++++++++++++---
> 1 files changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 36c2e94..5419c5d 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -461,19 +461,34 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
> 	int so, cc, type;
> 	struct sockaddr_in laddr;
> 	socklen_t namelen = sizeof(laddr);
> +	int f = AF_INET;
> +
> +	if (local_ip && local_ip->is_set)
> +		f = local_ip->addr.sa.sa_family;
> 
> 	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
> -	if ((so = socket (AF_INET, type, p_prot)) < 0)
> +
> +	so = socket(f, type, p_prot);
> +	if (so < 0)
> 		goto err_socket;
> 
> -	laddr.sin_family = AF_INET;
> +	laddr.sin_family = f;
> 	laddr.sin_port = 0;
> 	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
> 	if (resvp) {
> +		/* TODO:  Support IPv6 */
> +		if (local_ip && local_ip->is_set
> +		    && local_ip->addr.sa.sa_family == AF_INET) {
> +			struct sockaddr_in *si = &local_ip->addr.s4;
> +			laddr.sin_addr.s_addr = si->sin_addr.s_addr;
> +		}
> 		if (bindresvport(so, &laddr) < 0)
> 			goto err_bindresvport;
> 	} else {
> -		cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
> +		if (local_ip && local_ip->is_set)
> +			cc = bind(so, &local_ip->addr.sa, local_ip->addrlen);
> +		else
> +			cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
> 		if (cc < 0)
> 			goto err_bind;
> 	}
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




