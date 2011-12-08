Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636Ab1LHUrx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 15:47:53 -0500
Date: Thu, 8 Dec 2011 15:47:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH 1/4] SUNRPC: use passed network namespace context in
 rpc_parse_scope_id()
Message-ID: <20111208204749.GC32505@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
 <20111207112016.17273.44510.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111207112016.17273.44510.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2011 at 03:20:16PM +0300, Stanislav Kinsbursky wrote:
> Use incomming network context in rpc_parse_scope_id() instead of hard-coded

Changelogs are a little confusing; I might have said "allow
rpc_parse_cope_id() caller to pass in network context instead of using
hard-code "init_net"."

--b.

> "init_net".
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  net/sunrpc/addr.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
> index 67a655e..35eb188 100644
> --- a/net/sunrpc/addr.c
> +++ b/net/sunrpc/addr.c
> @@ -156,8 +156,9 @@ static size_t rpc_pton4(const char *buf, const size_t buflen,
>  }
>  
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> -static int rpc_parse_scope_id(const char *buf, const size_t buflen,
> -			      const char *delim, struct sockaddr_in6 *sin6)
> +static int rpc_parse_scope_id(struct net *net, const char *buf,
> +			      const size_t buflen, const char *delim,
> +			      struct sockaddr_in6 *sin6)
>  {
>  	char *p;
>  	size_t len;
> @@ -177,7 +178,7 @@ static int rpc_parse_scope_id(const char *buf, const size_t buflen,
>  		unsigned long scope_id = 0;
>  		struct net_device *dev;
>  
> -		dev = dev_get_by_name(&init_net, p);
> +		dev = dev_get_by_name(net, p);
>  		if (dev != NULL) {
>  			scope_id = dev->ifindex;
>  			dev_put(dev);
> @@ -213,7 +214,7 @@ static size_t rpc_pton6(const char *buf, const size_t buflen,
>  	if (in6_pton(buf, buflen, addr, IPV6_SCOPE_DELIMITER, &delim) == 0)
>  		return 0;
>  
> -	if (!rpc_parse_scope_id(buf, buflen, delim, sin6))
> +	if (!rpc_parse_scope_id(&init_net, buf, buflen, delim, sin6))
>  		return 0;
>  
>  	sin6->sin6_family = AF_INET6;
> 
