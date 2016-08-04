Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:27922 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753489AbcHDAE3 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 20:04:29 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: NeilBrown <neilb@suse.com>
CC: Linux List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Revert "SUNRPC: xs_sock_mark_closed() does not need to
 trigger socket autoclose"
Date: Thu, 4 Aug 2016 00:01:19 +0000
Message-ID: <A059233E-0EFD-472A-9CCB-7BE8411BFC03@primarydata.com>
References: <87a8gtpgw4.fsf@notabene.neil.brown.name>
In-Reply-To: <87a8gtpgw4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 3, 2016, at 19:33, NeilBrown <neilb@suse.com> wrote:
> 
> 
> This reverts commit 4b0ab51db32eba0f48b7618254742f143364a28d.
> 
> This change causes 'rpc.nfsd' to hang for long time if rpcbind is not
> available.
> If
>   --no-nfs-version 2 --no-nfs-version 3
> is given, the delay is about 6.5 minutes.  When trying to register
> all versions, the delay is over half an hour.
> Before this commit, and after reverting it, nfsd fails (when v3 is
> requested) or succeeds (when only v4 is requested) immediately.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> net/sunrpc/xprtsock.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 111767ab124a..2a938055e95b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -795,6 +795,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
> 	xs_sock_reset_connection_flags(xprt);
> 	/* Mark transport as closed and wake up all pending tasks */
> 	xprt_disconnect_done(xprt);
> +	xprt_force_disconnect(xprt);
> }
> 

If there is an outstanding request, then _that_ is supposed to redrive the connection. Why is the xprt_disconnect_done() not functioning as per the comment above it?

