Return-Path: linux-nfs-owner@vger.kernel.org
Received: from webmail.solarflare.com ([12.187.104.25]:43832 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258Ab3F0Pg6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:36:58 -0400
Message-ID: <1372347413.2436.6.camel@bwh-desktop.uk.level5networks.com>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
From: Ben Hutchings <bhutchings@solarflare.com>
To: Cong Wang <amwang@redhat.com>
CC: <netdev@vger.kernel.org>, Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Date: Thu, 27 Jun 2013 16:36:53 +0100
In-Reply-To: <1372315398-19683-5-git-send-email-amwang@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-5-git-send-email-amwang@redhat.com>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
[...]
> -/**
> - * rpc_cmp_addr - compare the address portion of two sockaddrs.
> - * @sap1: first sockaddr
> - * @sap2: second sockaddr
> - *
> - * Just compares the family and address portion. Ignores port, but
> - * compares the scope if it's a link-local address.

You're removing the scope comparison.

Ben.

> - * Returns true if the addrs are equal, false if they aren't.
> - */
>  static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
>  				const struct sockaddr *sap2)
>  {
> -	if (sap1->sa_family == sap2->sa_family) {
> -		switch (sap1->sa_family) {
> -		case AF_INET:
> -			return __rpc_cmp_addr4(sap1, sap2);
> -		case AF_INET6:
> -			return __rpc_cmp_addr6(sap1, sap2);
> -		}
> -	}
> -	return false;
> +	return inet_addr_equal((const union inet_addr *)sap1,
> +			       (const union inet_addr *)sap2);
>  }
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

