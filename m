Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64044 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab0ICQS2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 12:18:28 -0400
Subject: Re: [nfs] nfs:  Fix nfs_sockaddr_match_ipaddr6
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1283530511-20658-1-git-send-email-greearb@candelatech.com>
Date: Fri, 3 Sep 2010 12:17:34 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <1D980EDC-301A-4B4D-97D3-037B96DBAF86@oracle.com>
References: <1283530511-20658-1-git-send-email-greearb@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 3, 2010, at 12:15 PM, Ben Greear wrote:

> A typo caused this method not not actually compare the
> two addresses passed in.  It returned true in almost all
> cases instead.

>From the perspective of the local logic, that looks correct.  Have you tried this with IPv6 mounts?  Notice any overall changes in behavior?

> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 4e7df2a... e734072... M	fs/nfs/client.c
> fs/nfs/client.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 4e7df2a..e734072 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -275,7 +275,7 @@ static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
> 	    sin1->sin6_scope_id != sin2->sin6_scope_id)
> 		return 0;
> 
> -	return ipv6_addr_equal(&sin1->sin6_addr, &sin1->sin6_addr);
> +	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
> }
> #else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
> static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
> -- 
> 1.6.2.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




