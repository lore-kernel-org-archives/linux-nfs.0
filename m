Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58704 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996Ab0JYCKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 22:10:32 -0400
Date: Mon, 25 Oct 2010 13:10:24 +1100
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 4/4] svcrpc: svc_tcp_sendto XTP_DEAD check is redundant
Message-ID: <20101025131024.1addf30d@notabene>
In-Reply-To: <1287969693-12340-4-git-send-email-bfields@redhat.com>
References: <20101025010923.GB11470@fieldses.org>
	<1287969693-12340-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 24 Oct 2010 21:21:33 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> The only caller (svc_send) has already checked XPT_DEAD.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/svcsock.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 1454739..07919e1 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1135,9 +1135,6 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
>  	reclen = htonl(0x80000000|((xbufp->len ) - 4));
>  	memcpy(xbufp->head[0].iov_base, &reclen, 4);
>  
> -	if (test_bit(XPT_DEAD, &rqstp->rq_xprt->xpt_flags))
> -		return -ENOTCONN;
> -
>  	sent = svc_sendto(rqstp, &rqstp->rq_res);
>  	if (sent != xbufp->len) {
>  		printk(KERN_NOTICE


So after removing all these references to XPT_DEAD, do we need XPT_DEAD at
all???

I think it is only used in two other places.

1/ In svc_revisit we don't queue the deferred request to an XPT_DEAD
  transport.
  We could avoid that but changing the 'owner' of a deferred request from the
  service to the xprt, and call cache_clean_deferred in svc_delete_xprt

2/ in svc_send().  I wonder if we need this at all.  There doesn't seem to be
any locking to ensure that XPT_DEAD doesn't get set immediately after the
test, and the underlying sendto (whether tcp or udp or whatever) should fail
if the socket is closed, and if it doesn't it shouldn't really matter??

So can we get rid of XPT_DEAL altogether?

NeilBrown

