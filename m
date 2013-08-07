Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757407Ab3HGM1m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 08:27:42 -0400
Message-ID: <1375878446.11370.36.camel@cr0>
Subject: Re: [Patch net-next v2 5/8] sunrpc: use generic union inet_addr
From: Cong Wang <amwang@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Wed, 07 Aug 2013 20:27:26 +0800
In-Reply-To: <20130806062801.67714276@tlielax.poochiereds.net>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-6-git-send-email-amwang@redhat.com>
	 <20130802093625.2c70a330@tlielax.poochiereds.net>
	 <1375672445.32485.8.camel@cr0>
	 <20130806062801.67714276@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-08-06 at 06:28 -0400, Jeff Layton wrote:
> 
> My question is a bit more fundamental: Why are you using this new union
> in your patches instead of simply passing around "struct sockaddr"
> pointers? If you did that, then you could simply replace all of the
> rpc_* wrappers with your generic ones, since you wouldn't need to do
> the cast to this (seemingly unnecessary) union.

Because there are some places have to interpret the structure, without
this union, they need to cast to either sockaddr_in or sockaddr_in6
first, which is not as pretty as using a union.

For example, the code in netpoll:

ipv6_addr_equal(daddr, &np->local_ip.sin6.sin6_addr)

without the union, it would be:

struct sockaddr_in6 *addr = (struct sockaddr_in6 *) &np->local_ip;
ipv6_addr_equal(daddr, addr->sin6_addr);

> 
> FWIW, I too am happy to see these routines moved to common code. I just
> wonder whether it might make more sense to use the existing convention
> instead of this new union.
> 

Thanks.

