From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Libtirpc-devel] [PATCH] Do not skip records with nonblocking
 connections (take 2)
Date: Tue, 21 Jun 2011 14:43:41 -0400
Message-ID: <4E00E65D.604@RedHat.com>
References: <1308405706-3467-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929Ab1FUSnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 14:43:49 -0400
In-Reply-To: <1308405706-3467-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Committed...

steved.

On 06/18/2011 10:01 AM, Steve Dickson wrote:
> With non-blocking connections, do not skip records when receiving
> the streams since entire value messages can be ignored which
> in cause the entire stream to become out of sync.
> 
> For example, two mounts simultaneously send two unmaps
> commands. The first one is read, then the second thrown
> away due to skipping the record. Skipping this record
> will cause XDR error later in processing of the stream.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  src/svc_vc.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/src/svc_vc.c b/src/svc_vc.c
> index aaaf2d7..87406f1 100644
> --- a/src/svc_vc.c
> +++ b/src/svc_vc.c
> @@ -610,7 +610,11 @@ svc_vc_recv(xprt, msg)
>  	}
>  
>  	xdrs->x_op = XDR_DECODE;
> -	(void)xdrrec_skiprecord(xdrs);
> +	/*
> +	 * No need skip records with nonblocking connections
> +	 */
> +	if (cd->nonblock == FALSE)
> +		(void)xdrrec_skiprecord(xdrs);
>  	if (xdr_callmsg(xdrs, msg)) {
>  		cd->x_id = msg->rm_xid;
>  		return (TRUE);
