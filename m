Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753906Ab2EJLTy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 07:19:54 -0400
Date: Thu, 10 May 2012 14:19:48 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 9/9] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Message-ID: <20120510111948.GA9609@redhat.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
 <1336056971-7839-9-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336056971-7839-9-git-send-email-ian.campbell@citrix.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 03, 2012 at 03:56:11PM +0100, Ian Campbell wrote:
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index f6d8c73..1145929 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -198,7 +198,8 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
>  	while (pglen > 0) {
>  		if (slen == size)
>  			flags = 0;
> -		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
> +		result = kernel_sendpage(sock, *ppage, xdr->destructor,
> +					 base, size, flags);
>  		if (result > 0)
>  			len += result;
>  		if (result != size)

So I tried triggering this by simply creating an nfs export on localhost
and copying a large file out with dd, but this never seems to trigger
this code.

Any idea how to test?

-- 
MST
