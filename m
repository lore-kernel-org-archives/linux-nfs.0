Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906AbaHRPDF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 11:03:05 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s7IF33a5001845
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 18 Aug 2014 11:03:04 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-60-49.rdu2.redhat.com [10.10.60.49])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s7IF328H027793
	for <linux-nfs@vger.kernel.org>; Mon, 18 Aug 2014 11:03:03 -0400
Message-ID: <53F215A6.2080400@RedHat.com>
Date: Mon, 18 Aug 2014 11:03:02 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: Remove a strict-aliasing warning
References: <1405439595-5544-1-git-send-email-steved@redhat.com>
In-Reply-To: <1405439595-5544-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/15/2014 11:53 AM, Steve Dickson wrote:
> src/util.c: In function ‘in6_fillscopeid’:
> src/util.c:106:3: warning: dereferencing type-punned pointer will break
> strict-aliasing rules [-Wstrict-aliasing]
>    ifindex = ntohs(*(u_int16_t *)&sin6->sin6_addr.s6_addr[2]);
>    ^
> 
> src/util.c:109:4: warning: dereferencing type-punned pointer will break
> strict-aliasing rules [-Wstrict-aliasing]
>     *(u_int16_t *)&sin6->sin6_addr.s6_addr[2] = 0;
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed! 

steved.

> ---
>  src/util.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/src/util.c b/src/util.c
> index 9a5fb69..7d56479 100644
> --- a/src/util.c
> +++ b/src/util.c
> @@ -101,12 +101,14 @@ static void
>  in6_fillscopeid(struct sockaddr_in6 *sin6)
>  {
>  	u_int16_t ifindex;
> +	u_int16_t *addr;
>  
>          if (IN6_IS_ADDR_LINKLOCAL(&sin6->sin6_addr)) {
> -		ifindex = ntohs(*(u_int16_t *)&sin6->sin6_addr.s6_addr[2]);
> +		addr = (u_int16_t *)&sin6->sin6_addr.s6_addr[2];
> +		ifindex = ntohs(*addr);
>  		if (sin6->sin6_scope_id == 0 && ifindex != 0) {
>  			sin6->sin6_scope_id = ifindex;
> -			*(u_int16_t *)&sin6->sin6_addr.s6_addr[2] = 0;
> +			*addr = 0;
>  		}
>  	}
>  }
> 
