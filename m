From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 05/20] SUNRPC: Address a signed v. unsigned
	comparison	in net/sunrpc/xprtsock.
Date: Sat, 11 Aug 2007 10:48:02 -0400
Message-ID: <1186843682.17941.20.camel@heimdal.trondhjem.org>
References: <20070806155647.31233.4510.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJsG7-0004eO-Jw
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 07:48:07 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+yhTRbH06bcKU9NovRHAfWObsL27XuUb8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJsGA-00077l-AB
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 07:48:11 -0700
In-Reply-To: <20070806155647.31233.4510.stgit@manray.1015granger.net>
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
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtsock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7448402..505a7e3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -852,7 +852,7 @@ static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_rea
>  		transport->tcp_copied += r;
>  		transport->tcp_offset += r;
>  	}
> -	if (r != len) {
> +	if (r != (ssize_t) len) {
>  		/* Error when copying to the receive buffer,
>  		 * usually because we weren't able to allocate
>  		 * additional buffer pages. All we can do now

NACK. For the same reason as the last rejection. There is no reason to
introduce an explicit cast, and it will only serve to obfuscate if we
ever change the types of r or len.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
