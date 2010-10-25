Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58371 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab0JYBoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 21:44:07 -0400
Date: Mon, 25 Oct 2010 12:43:57 +1100
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101025124357.63b966bb@notabene>
In-Reply-To: <1287969693-12340-1-git-send-email-bfields@redhat.com>
References: <20101025010923.GB11470@fieldses.org>
	<1287969693-12340-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 24 Oct 2010 21:21:30 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> Once an xprt has been deleted, there's no reason to allow it to be
> enqueued--at worst, that might cause the xprt to be re-added to some
> global list, resulting in later corruption.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Yep, this makes svc_close_xprt() behave the same way as svc_recv() which
calls svc_delete_xprt but does not clear XPT_BUSY.  The other branches in
svc_recv call svc_xprt_received, but the XPT_CLOSE branch doesn't

Reviewed-by: NeilBrown <neilb@suse.de>

NeilBrown

> ---
>  net/sunrpc/svc_xprt.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index bef1e88..db90e4d 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -938,7 +938,6 @@ void svc_close_xprt(struct svc_xprt *xprt)
>  
>  	svc_xprt_get(xprt);
>  	svc_delete_xprt(xprt);
> -	clear_bit(XPT_BUSY, &xprt->xpt_flags);
>  	svc_xprt_put(xprt);
>  }
>  EXPORT_SYMBOL_GPL(svc_close_xprt);

