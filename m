From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 03/20] SUNRPC: Fix some signed v. unsigned
	comparisons	in xprtsock.c
Date: Sat, 11 Aug 2007 10:43:43 -0400
Message-ID: <1186843423.17941.18.camel@heimdal.trondhjem.org>
References: <20070806155636.31233.33750.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJsBv-00049a-5f
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 07:43:47 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18XyMEfw29xR64SF2LNsWvrE8IoPtctcu0=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJsBy-00054w-Iq
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 07:43:51 -0700
In-Reply-To: <20070806155636.31233.33750.stgit@manray.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-08-06 at 11:56 -0400, Chuck Lever wrote:
> Currently these are not harmful because the range of "len" is less than the
> size of a page.

NACK. It is always safe to test an unsigned quantity against a signed
quantity for equality, _provided_ that the two quantities are the same
size. Since we're comparing an unsigned int to an int, that is clearly
the case here.

The explicit cast is not only unnecessary, but it is actually bad, since
it may obscure any future comparison errors should we ever for some
reason decide to change the size of err.

Trond

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtsock.c |   18 ++++++++++++++----
>  1 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 4ae7eed..274f235 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -338,7 +338,10 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
>  		if (remainder != 0 || more)
>  			flags |= MSG_MORE;
>  		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
> -		if (remainder == 0 || err != len)
> +		if (err < 0 || (unsigned int)err != len)
> +			break;
> +
> +		if (remainder == 0)
>  			break;
>  		sent += err;
>  		ppage++;
> @@ -377,8 +380,12 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
>  	if (base < xdr->head[0].iov_len || addr != NULL) {
>  		unsigned int len = xdr->head[0].iov_len - base;
>  		remainder -= len;
> -		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0], base, remainder != 0);
> -		if (remainder == 0 || err != len)
> +		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0],
> +				   base, remainder != 0);
> +		if (err < 0 || (unsigned int)err != len)
> +			goto out;
> +
> +		if (remainder == 0)
>  			goto out;
>  		sent += err;
>  		base = 0;
> @@ -389,7 +396,10 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
>  		unsigned int len = xdr->page_len - base;
>  		remainder -= len;
>  		err = xs_send_pagedata(sock, xdr, base, remainder != 0);
> -		if (remainder == 0 || err != len)
> +		if (err < 0 || (unsigned int)err != len)
> +			goto out;
> +
> +		if (remainder == 0)
>  			goto out;
>  		sent += err;
>  		base = 0;
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
