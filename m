Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56842 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbbGMHDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:03:12 -0400
Date: Mon, 13 Jul 2015 00:03:11 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/9] NFS: Use RPC functions for matching sockaddrs
Message-ID: <20150713070311.GH26245@infradead.org>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1436561897-8051-5-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436561897-8051-5-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
>  				const struct sockaddr *sa2)
>  {
>  	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
>  	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
>  
> -	return nfs_sockaddr_match_ipaddr6(sa1, sa2) &&
> -		(sin1->sin6_port == sin2->sin6_port);
> +	return rpc_cmp_addr6(sa1, sa2) && (sin1->sin6_port == sin2->sin6_port);
>  }
>  
>  static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
> @@ -350,31 +301,8 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
>  	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
>  	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
>  
> -	return nfs_sockaddr_match_ipaddr4(sa1, sa2) &&
> -		(sin1->sin_port == sin2->sin_port);
> -}

I'd say kill nfs_sockaddr_cmp as well and use rpc_cmp_addr in
nfs_match_client.

