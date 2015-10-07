Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbbJGUIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2015 16:08:31 -0400
Date: Wed, 7 Oct 2015 16:08:31 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Use MSG_SENDPAGE_NOTLAST when calling sendpage()
Message-ID: <20151007200831.GB27924@fieldses.org>
References: <1444240482-11287-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444240482-11287-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 07, 2015 at 01:54:42PM -0400, Trond Myklebust wrote:
> If we're sending more pages via kernel_sendpage(), then set
> MSG_SENDPAGE_NOTLAST.

Given that we've survived without this a while, I assume this is a hint
that may provide better performance in some cases (have you seen that?)
and that it doesn't have to be 100% correct?

In which case, looks fine, will queue up for 4.4....

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/svcsock.c  | 2 +-
>  net/sunrpc/xprtsock.c | 4 +++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 0c8120229a03..48923730722d 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -181,7 +181,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
>  	struct page	**ppage = xdr->pages;
>  	size_t		base = xdr->page_base;
>  	unsigned int	pglen = xdr->page_len;
> -	unsigned int	flags = MSG_MORE;
> +	unsigned int	flags = MSG_MORE | MSG_SENDPAGE_NOTLAST;
>  	int		slen;
>  	int		len = 0;
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 1471ecceabf9..e71aff251ac1 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -360,8 +360,10 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
>  		int flags = XS_SENDMSG_FLAGS;
>  
>  		remainder -= len;
> -		if (remainder != 0 || more)
> +		if (more)
>  			flags |= MSG_MORE;
> +		if (remainder != 0)
> +			flags |= MSG_SENDPAGE_NOTLAST | MSG_MORE;
>  		err = do_sendpage(sock, *ppage, base, len, flags);
>  		if (remainder == 0 || err != len)
>  			break;
> -- 
> 2.4.3
