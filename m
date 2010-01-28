From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/1] nfs41 do not allocate unused back channel pages
Date: Thu, 28 Jan 2010 09:09:56 -0500
Message-ID: <1264687796.3724.1.camel@localhost>
References: <1264556989-7409-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44839 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756232Ab0A1OKB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 09:10:01 -0500
In-Reply-To: <1264556989-7409-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-26 at 20:49 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/svc.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 538ca43..c9991e8 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -506,6 +506,12 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
>  {
>  	unsigned int pages, arghi;
>  
> +#if defined(CONFIG_NFS_V4_1)
> +	/* bc_xprt uses fore channel allocated buffers */
> +	if (rqstp->rq_server->bc_xprt)
> +		return 1;
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
>  				       * We assume one is at most one page
>  				       */

Can we replace this with a 'svc_is_backchannel(rqstp->rq_server)' type
of test? That would make it a bit easier on the eyes.



