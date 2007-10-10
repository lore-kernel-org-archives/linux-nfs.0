From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH] svc: Add xprt header len to svc_deferred_req
Date: Wed, 10 Oct 2007 12:39:56 +1000
Message-ID: <20071010023956.GC20690@sgi.com>
References: <20071009225740.26067.25488.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfRM0-0005Eh-Ht
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:31:20 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/qXj+n/e3LTfZfOB1cfuKxAx2lMwdHfPk=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfRM3-0006Oq-JS
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:31:25 -0700
In-Reply-To: <20071009225740.26067.25488.stgit@dell3.ogc.int>
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

On Tue, Oct 09, 2007 at 05:57:40PM -0500, Tom Tucker wrote:
> 
> A transport may have a header that precedes the RPC message. Save the
> size of this header in the svc_deferred_req so that when the RPC
> is revisited, the deferred recv function doesn't need to re-parse the 
> header to determine it's length.
> 
> In addition, a misleading comment related to the transport header 
> for TCP/UDP has been rewritten.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svc.h |    1 +
>  net/sunrpc/svc_xprt.c      |    1 +
>  net/sunrpc/svcsock.c       |    2 +-
>  3 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index ea07e3d..f2ada2a 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -323,6 +323,7 @@ struct svc_deferred_req {
>  	size_t			addrlen;
>  	union svc_addr_u	daddr;	/* where reply must come from */
>  	struct cache_deferred_req handle;
> +	int			xprt_hlen;
>  	int			argslen;
>  	__be32			args[0];
>  };
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 080ecf5..b580d4c 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -884,6 +884,7 @@ static struct cache_deferred_req *svc_de
>  		dr->addrlen = rqstp->rq_addrlen;
>  		dr->daddr = rqstp->rq_daddr;
>  		dr->argslen = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) >> 2;
> +		dr->xprt_hlen = rqstp->rq_xprt_hlen;
>  
>  		/* back up head to the start of the buffer and copy */
>  		skip = (rqstp->rq_arg.len + rqstp->rq_xprt_hlen) -

Are you planning on restoring rqstp->rq_xprt_hlen from
dr->xprt_hlen in svc_deferred_recv() ?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
