Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50026 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755634AbaLHQ7D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 11:59:03 -0500
Date: Mon, 8 Dec 2014 11:59:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: only call test_bit once in svc_xprt_received
Message-ID: <20141208165901.GA16612@fieldses.org>
References: <1417459524-9086-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1417459524-9086-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 01, 2014 at 01:45:24PM -0500, Jeff Layton wrote:
> ...move the WARN_ON_ONCE inside the following if block since they use
> the same condition.

Thanks, applying for 3.19

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  net/sunrpc/svc_xprt.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 0ae1d78d934d..40ecda40c2ec 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -220,9 +220,11 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
>   */
>  static void svc_xprt_received(struct svc_xprt *xprt)
>  {
> -	WARN_ON_ONCE(!test_bit(XPT_BUSY, &xprt->xpt_flags));
> -	if (!test_bit(XPT_BUSY, &xprt->xpt_flags))
> +	if (!test_bit(XPT_BUSY, &xprt->xpt_flags)) {
> +		WARN_ONCE(1, "xprt=0x%p already busy!", xprt);
>  		return;
> +	}
> +
>  	/* As soon as we clear busy, the xprt could be closed and
>  	 * 'put', so we need a reference to call svc_xprt_do_enqueue with:
>  	 */
> -- 
> 2.1.0
> 
