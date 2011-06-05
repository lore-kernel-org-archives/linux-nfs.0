Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59202 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab1FENZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jun 2011 09:25:25 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1QTD2l-0002eU-5E
	for linux-nfs@vger.kernel.org; Sun, 05 Jun 2011 15:07:03 +0200
From: Andreas Schwab <schwab@linux-m68k.org>
To: Al Viro
	<public-viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@plane.gmane.org>
Cc: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org,
        Chuck Lever
	<public-chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@plane.gmane.org>,
        public-linux-kernel-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
Subject: Re: [PATCH] fix return values of rpcb_create_local()
References: <20110605130207.GE11521@ZenIV.linux.org.uk>
Date: Sun, 05 Jun 2011 15:06:50 +0200
In-Reply-To: <20110605130207.GE11521@ZenIV.linux.org.uk> (Al Viro's message of
	"Sun, 5 Jun 2011 14:02:07 +0100")
Message-ID: <m2tyc4whp1.fsf@igel.home>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 9a80a92..5efaf5f 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -193,7 +193,7 @@ static int rpcb_create_local_unix(void)
>  	if (IS_ERR(clnt)) {
>  		dprintk("RPC:       failed to create AF_LOCAL rpcbind "
>  				"client (errno %ld).\n", PTR_ERR(clnt));
> -		result = -PTR_ERR(clnt);
> +		result = PTR_ERR(clnt);
>  		goto out;
>  	}
>  
> @@ -242,7 +242,7 @@ static int rpcb_create_local_net(void)
>  	if (IS_ERR(clnt)) {
>  		dprintk("RPC:       failed to create local rpcbind "
>  				"client (errno %ld).\n", PTR_ERR(clnt));
> -		result = -PTR_ERR(clnt);
> +		result = PTR_ERR(clnt);

Proabably the dprintk argument should be negated as well.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

