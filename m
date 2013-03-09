Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43501 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab3CIRvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Mar 2013 12:51:24 -0500
Date: Sat, 9 Mar 2013 12:51:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] sunrpc: drop "select NETVM"
Message-ID: <20130309175118.GJ31448@fieldses.org>
References: <1362844951.3137.3.camel@x61.thuisdomein>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362844951.3137.3.camel@x61.thuisdomein>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK.

On Sat, Mar 09, 2013 at 05:02:31PM +0100, Paul Bolle wrote:
> The Kconfig entry for SUNRPC_SWAP selects NETVM. That select statement
> was added in commit a564b8f0398636ba30b07c0eaebdef7ff7837249 ("nfs:
> enable swap on NFS").

Cc'ing Mel Gorman just in case there was something else going on there.

--b.

> But there's no Kconfig symbol NETVM. It apparently
> was only in used in development versions of the swap over nfs
> functionality but never entered mainline. Anyhow, it is a nop and can
> safely be dropped.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
>  net/sunrpc/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index 516fe2c..262caf0 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -24,7 +24,6 @@ config SUNRPC_XPRT_RDMA
>  config SUNRPC_SWAP
>  	bool
>  	depends on SUNRPC
> -	select NETVM
>  
>  config RPCSEC_GSS_KRB5
>  	tristate "Secure RPC: Kerberos V mechanism"
> -- 
> 1.7.11.7
> 
