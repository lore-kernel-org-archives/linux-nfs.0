Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35815 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab1KHTiY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Nov 2011 14:38:24 -0500
Date: Tue, 8 Nov 2011 22:38:18 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Julia Lawall <julia@diku.dk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, kernel-janitors@vger.kernel.org,
        Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/5] net/sunrpc: use kstrtoul, etc
Message-ID: <20111108193817.GA3453@p183.telecom.by>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
 <1320586010-21931-3-git-send-email-julia@diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320586010-21931-3-git-send-email-julia@diku.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 06, 2011 at 02:26:47PM +0100, Julia Lawall wrote:
> @@
> expression a,b;
> {int,long} *c;
> @@
> 
> -strict_strtoul
> +kstrtoul

No, no, no!

In every case see the type or real data and use appropriate function.
kstrtou8() for ports.
This program creates lots of bogus patches in this case.

> --- a/net/sunrpc/addr.c
> +++ b/net/sunrpc/addr.c
> @@ -322,7 +322,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
>  	c = strrchr(buf, '.');
>  	if (unlikely(c == NULL))
>  		return 0;
> -	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
> +	if (unlikely(kstrtoul(c + 1, 10, &portlo) != 0))
>  		return 0;
>  	if (unlikely(portlo > 255))
>  		return 0;
> @@ -331,7 +331,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
>  	c = strrchr(buf, '.');
>  	if (unlikely(c == NULL))
>  		return 0;
> -	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
> +	if (unlikely(kstrtoul(c + 1, 10, &porthi) != 0))
>  		return 0;
>  	if (unlikely(porthi > 255))
>  		return 0;
