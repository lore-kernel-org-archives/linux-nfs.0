Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51170 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751615AbdF2UUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Jun 2017 16:20:04 -0400
Date: Thu, 29 Jun 2017 16:20:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 09/18] sunrpc: Allocate one more page per svc_rqst
Message-ID: <20170629202004.GC4178@fieldses.org>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
 <20170623211816.5162.54447.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170623211816.5162.54447.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm confused by this one:

On Fri, Jun 23, 2017 at 05:18:16PM -0400, Chuck Lever wrote:
> svcrdma needs 259 pages for 1MB NFSv4.0 READ requests:
> 
>  - 1 page for the transport header and head iovec
>  - 256 pages for the data payload
>  - 1 page for the trailing GETATTR request (since NFSD XDR decoding
>    does not look for a tail iovec, the GETATTR is stuck at the end
>    of the rqstp->rq_arg.pages list)
>  - 1 page for building the reply xdr_buf
> 
> Note that RPCSVC_MAXPAGES is defined as:
> 
> 	((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2 + 1)
> 
> I don't understand why the "+PAGE_SIZE-1" is in there, because
> division will always round the result down to
> 
> 	(RPCSVC_MAXPAYLOAD / PAGE_SIZE + 2 + 1)

I think you're assuming that RPCSVC_MAXPAYLOAD is a multiple of
PAGE_SIZE.  Maybe that's true in all cases (I haven't checked), but it
seems harmless to handle the case where it's not.

> Let's remove the "-1" to get 260 pages maximum.

Why?  (I'm not necessarily opposed, I just missed the explanation.)

--b.

> Then svc_alloc_args() needs to ask for pages according to this
> same formula, otherwise it will never allocate enough.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/svc.h |    3 +--
>  net/sunrpc/svc_xprt.c      |    8 +++++---
>  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 11cef5a..35c274f 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -176,8 +176,7 @@ static inline void svc_get(struct svc_serv *serv)
>   * We using ->sendfile to return read data, we might need one extra page
>   * if the request is not page-aligned.  So add another '1'.
>   */
> -#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE \
> -				+ 2 + 1)
> +#define RPCSVC_MAXPAGES	((RPCSVC_MAXPAYLOAD + PAGE_SIZE) / PAGE_SIZE + 2 + 1)
>  
>  static inline u32 svc_getnl(struct kvec *iov)
>  {
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 7bfe1fb..9bd484d 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -659,11 +659,13 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
>  	int i;
>  
>  	/* now allocate needed pages.  If we get a failure, sleep briefly */
> -	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
> -	WARN_ON_ONCE(pages >= RPCSVC_MAXPAGES);
> -	if (pages >= RPCSVC_MAXPAGES)
> +	pages = (serv->sv_max_mesg + (2 * PAGE_SIZE)) >> PAGE_SHIFT;
> +	if (pages >= RPCSVC_MAXPAGES) {
> +		pr_warn_once("svc: warning: pages=%u >= RPCSVC_MAXPAGES=%lu\n",
> +			     pages, RPCSVC_MAXPAGES);
>  		/* use as many pages as possible */
>  		pages = RPCSVC_MAXPAGES - 1;
> +	}
>  	for (i = 0; i < pages ; i++)
>  		while (rqstp->rq_pages[i] == NULL) {
>  			struct page *p = alloc_page(GFP_KERNEL);
