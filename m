Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754617AbbLPPRW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 10:17:22 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 64B0F3B712
	for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2015 15:17:22 +0000 (UTC)
Subject: Re: fix mountd netgroup lookup for short hostnames
To: Frank Sorenson <sorenson@redhat.com>, linux-nfs@vger.kernel.org
References: <371875408.30231785.1450131337790.JavaMail.zimbra@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56718081.9080401@RedHat.com>
Date: Wed, 16 Dec 2015 10:17:21 -0500
MIME-Version: 1.0
In-Reply-To: <371875408.30231785.1450131337790.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/14/2015 05:15 PM, Frank Sorenson wrote:
> 
> Commit 9a92ef6f194926904b1289e0ce1daecb42bd5e8b to add netgroup
> lookup of resolvable IP addresses inadvertently broke the
> netgroup check for short hostnames by clobbering the 'hname'
> variable.
>     
> This patch fixes that breakage by changing the IP address
> lookup to use a separate variable.  The 'hname' variable
> used in the short hostname lookup is now untouched in
> the IP lookup code.
> 
> 
> 
> Author: Frank Sorenson <sorenson@redhat.com>
> Date:   Mon Dec 14 15:50:30 2015 -0600
> 
>     mountd: fix netgroup lookup for short hostnames
>     
>     Commit 9a92ef6f194926904b1289e0ce1daecb42bd5e8b to add netgroup
>     lookup of resolvable IP addresses inadvertently broke the
>     netgroup check for short hostnames.
>     
>     This patch fixes that breakage by changing the IP address
>     lookup to use a separate variable.
>     
>     Signed-off-by: Frank Sorenson <sorenson@redhat.com>
Committed... Thanks!

steved.

> 
> diff --git a/support/export/client.c b/support/export/client.c
> index af9e6bb..2346f99 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -639,7 +639,7 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
>  	const char *netgroup = clp->m_hostname + 1;
>  	struct addrinfo *tmp = NULL;
>  	struct hostent *hp;
> -	char *dot, *hname;
> +	char *dot, *hname, *ip;
>  	int i, match;
>  
>  	match = 0;
> @@ -687,19 +687,16 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
>  	}
>  
>  	/* check whether the IP itself is in the netgroup */
> -	for (tmp = (struct addrinfo *)ai ; tmp != NULL ; tmp = tmp->ai_next) {
> -		free(hname);
> -		hname = calloc(INET6_ADDRSTRLEN, 1);
> -
> -		if (inet_ntop(tmp->ai_family, &(((struct sockaddr_in *)tmp->ai_addr)->sin_addr), hname, INET6_ADDRSTRLEN) != hname) {
> -			xlog(D_GENERAL, "  %s: unable to inet_ntop addrinfo %p: %m", __func__, tmp, errno);
> -			goto out;
> -		}
> -		if (innetgr(netgroup, hname, NULL, NULL)) {
> +	ip = calloc(INET6_ADDRSTRLEN, 1);
> +	if (inet_ntop(ai->ai_family, &(((struct sockaddr_in *)ai->ai_addr)->sin_addr), ip, INET6_ADDRSTRLEN) == ip) {
> +		if (innetgr(netgroup, ip, NULL, NULL)) {
> +			free(hname);
> +			hname = ip;
>  			match = 1;
>  			goto out;
>  		}
>  	}
> +	free(ip);
>  
>  	/* Okay, strip off the domain (if we have one) */
>  	dot = strchr(hname, '.');
> 
