From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 02/20] SUNRPC: Fix a signed v. unsigned comparison
	in	rpcbind's XDR routines
Date: Sat, 11 Aug 2007 10:29:48 -0400
Message-ID: <1186842588.17941.6.camel@heimdal.trondhjem.org>
References: <20070806155631.31233.23672.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJryS-0002ck-86
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 07:29:52 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19pxEnW3CDFQH3VVUrgm//ZRlljO4TpQpY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJryU-0006bg-T0
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 07:29:56 -0700
In-Reply-To: <20070806155631.31233.23672.stgit@manray.1015granger.net>
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
>  net/sunrpc/rpcb_clnt.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index d1740db..eae711f 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -490,7 +490,8 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
>  			       unsigned short *portp)
>  {
>  	char *addr;
> -	int addr_len, c, i, f, first, val;
> +	u32 addr_len;
> +	int c, i, f, first, val;
>  
>  	*portp = 0;
>  	addr_len = (unsigned int) ntohl(*p++);

I think I'll get rid of that cast too.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
