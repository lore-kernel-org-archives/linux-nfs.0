Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18620 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab1FRRBG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Jun 2011 13:01:06 -0400
Subject: Re: [PATCH] Do not skip records with nonblocking connections (take 2)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1308405706-3467-1-git-send-email-steved@redhat.com>
Date: Sat, 18 Jun 2011 13:00:48 -0400
Cc: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8E8BD58F-1427-48F5-A6FA-819EEB0C6680@oracle.com>
References: <1308405706-3467-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 18, 2011, at 10:01 AM, Steve Dickson wrote:

> With non-blocking connections, do not skip records when receiving
> the streams since entire value messages can be ignored which
> in cause the entire stream to become out of sync.
> 
> For example, two mounts simultaneously send two unmaps
> commands. The first one is read, then the second thrown
> away due to skipping the record. Skipping this record
> will cause XDR error later in processing of the stream.

I notice that xdrrec_skiprecord() also does a __xdrrec_getrec() on nonblocking connections.  In the current code, then, __xdrrec_getrec() is likely invoked twice in svc_vc_recv() on non-blocking connections.  After this patch, it is only invoked once.

Invoking __xdrrec_getrec() just once in both the blocking and non-blocking cases feels more correct to me, but I don't have a deep understanding of this code.  So this patch seems like the right thing to do.

> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/svc_vc.c |    6 +++++-
> 1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/src/svc_vc.c b/src/svc_vc.c
> index aaaf2d7..87406f1 100644
> --- a/src/svc_vc.c
> +++ b/src/svc_vc.c
> @@ -610,7 +610,11 @@ svc_vc_recv(xprt, msg)
> 	}
> 
> 	xdrs->x_op = XDR_DECODE;
> -	(void)xdrrec_skiprecord(xdrs);
> +	/*
> +	 * No need skip records with nonblocking connections
> +	 */
> +	if (cd->nonblock == FALSE)
> +		(void)xdrrec_skiprecord(xdrs);

cd->nonblock is already checked just before this code block.  As a minor optimization, I'd suggest reordering slightly so cd->nonblock is checked only once:

	xdrs->x_op = XDR_DECODE;
	if (cd->nonblock) {
		if (!__xdrrec_getrec(xdrs, &cd->strm_stat, TRUE))
			return FALSE;
	} else 
		(void)xdrrec_skiprecord(xdrs);

As long as __xdrrec_getrec() doesn't care about the value of xdrs->x_op, this should be OK to do.

> 	if (xdr_callmsg(xdrs, msg)) {
> 		cd->x_id = msg->rm_xid;
> 		return (TRUE);

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




