From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] nfs41 do not allocate unused back channel pages
Date: Wed, 27 Jan 2010 18:44:08 -0500
Message-ID: <1264635848.3788.179.camel@localhost>
References: <1264528528-4319-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37191 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572Ab0A0XoZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2010 18:44:25 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0RNi9jG020776
	for <linux-nfs@vger.kernel.org>; Wed, 27 Jan 2010 15:44:09 -0800 (PST)
In-Reply-To: <1264528528-4319-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-26 at 12:55 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/svc.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 538ca43..984be52 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -506,6 +506,10 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
>  {
>  	unsigned int pages, arghi;
>  
> +	/* bc_xprt uses fore channel allocated buffers */
> +	if (rqstp->rq_server->bc_xprt)
> +		return 1;
> +
>  	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
>  				       * We assume one is at most one page
>  				       */

Argh! This one too fails completely to compile ifndef CONFIG_NFS_V4_1

Trond
