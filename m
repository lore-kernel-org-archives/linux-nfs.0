Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41386 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757318Ab1FUWoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 18:44:32 -0400
Date: Tue, 21 Jun 2011 18:44:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com, neilb@suse.de,
        davem@davemloft.net
Subject: Re: [PATCH] svcauth_unix.c: quiet sparse noise
Message-ID: <20110621224430.GC28047@fieldses.org>
References: <201106201819.12839.hartleys@visionengravers.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201106201819.12839.hartleys@visionengravers.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 20, 2011 at 06:19:12PM -0700, H Hartley Sweeten wrote:
> Like svcauth_unix, the symbol svcauth_null is used external from this
> file. Declare it as extern to quiet the following sparse noise:
> 
> warning: symbol 'svcauth_null' was not declared. Should it be static?

Also applying for 3.1.--b.

> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> 
> ---
> 
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index c8e1021..62e49e2 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -36,6 +36,7 @@ struct unix_domain {
>  	/* other stuff later */
>  };
>  
> +extern struct auth_ops svcauth_null;
>  extern struct auth_ops svcauth_unix;
>  
>  static void svcauth_unix_domain_release(struct auth_domain *dom)
