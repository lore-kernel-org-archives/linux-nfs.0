From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/7] SUNRPC: Address a few compiler warnings in
	the RPC	client
Date: Mon, 27 Aug 2007 17:59:13 -0400
Message-ID: <1188251953.6701.113.camel@heimdal.trondhjem.org>
References: <20070827173013.23426.67897.stgit@monet.1015granger.net>
	<1188238002.6701.99.camel@heimdal.trondhjem.org>
	<46D322CE.40002@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPmcF-0005wV-Ar
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 14:59:23 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPmcH-000806-GT
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 14:59:27 -0700
In-Reply-To: <46D322CE.40002@oracle.com>
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

On Mon, 2007-08-27 at 15:15 -0400, Chuck Lever wrote:
> >> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >> index c796e2f..0ad3042 100644
> >> --- a/net/sunrpc/clnt.c
> >> +++ b/net/sunrpc/clnt.c
> >> @@ -127,7 +127,7 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
> >>  	struct rpc_clnt		*clnt = NULL;
> >>  	struct rpc_auth		*auth;
> >>  	int err;
> >> -	int len;
> >> +	size_t len;
> > 
> > What if 'len' overflows when we do 'strlen() + 1'?
> 
> strlen() returns size_t, which is unsigned.  Thus the overflow would be 
> zero.  Seems like that's a better outcome than what would happen today.

Yes, but there has to be a reason for fixing these signed comparisons
beyond just silencing the compiler. If we're worried that len may
overflow the signed integer space, then we really should be setting a
hard limit on the string length. I personally don't think that a server
name of 2^31 characters or more makes any sense whatsoever.

Do we know if the callers are checking the size of the server name prior
to calling rpc_new_client?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
