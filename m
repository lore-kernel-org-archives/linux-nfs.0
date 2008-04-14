From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 04/24] SUNRPC: Address potential buffer length overflow
	in svc_sendto
Date: Mon, 14 Apr 2008 13:48:59 -0400
Message-ID: <20080414174859.GH15950@fieldses.org>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net> <20080414162708.12741.71691.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40000 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbYDNRtS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 13:49:18 -0400
In-Reply-To: <20080414162708.12741.71691.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 14, 2008 at 12:27:08PM -0400, Chuck Lever wrote:
> Paranoia: Ensure a negative error value return from kernel_sendpage never
> matches a large buffer length.

That is a little paranoid.  Absent an argument for exactly what sort of
bug could allow us to reach this point with the head iov_len in at least
the gigabytes, I'm inclined to leave this alone for simplicity's
sake....

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/svcsock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 6d4162b..a8ae279 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -200,7 +200,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
>  		flags = 0;
>  	len = kernel_sendpage(sock, rqstp->rq_respages[0], 0,
>  				  xdr->head[0].iov_len, flags);
> -	if (len != xdr->head[0].iov_len)
> +	if (len < 0 || len != xdr->head[0].iov_len)
>  		goto out;
>  	slen -= xdr->head[0].iov_len;
>  	if (slen == 0)
> 
