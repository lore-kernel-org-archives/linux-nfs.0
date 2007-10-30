From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH 03/27] SUNRPC: Check a return result
Date: Tue, 30 Oct 2007 12:42:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
References: <20071026173054.31475.61789.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImuBA-0000qi-4J
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:43:00 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImuBA-0006oX-Gs
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:43:00 -0700
In-Reply-To: <20071026173054.31475.61789.stgit@manray.1015granger.net>
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


On Fri, 26 Oct 2007, Chuck Lever wrote:

> Minor: Replace an empty if statement with a debugging dprintk.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
> ---
> 
>  net/sunrpc/xprtrdma/verbs.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 44b0fb9..ffbf22a 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -522,7 +522,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>  				struct rpcrdma_create_data_internal *cdata)
>  {
>  	struct ib_device_attr devattr;
> -	int rc;
> +	int rc, err;
>  
>  	rc = ib_query_device(ia->ri_id->device, &devattr);
>  	if (rc) {
> @@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>  	return 0;
>  
>  out2:
> -	if (ib_destroy_cq(ep->rep_cq))
> -		;
> +	err = ib_destroy_cq(ep->rep_cq);
> +	if (err)
> +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
> +			__func__, err);
>  out1:
>  	return rc;
>  }

Good eyes, Chuck. One minor suggestion: instead of adding "err", how 
about reusing "rc"? Here's a patch against Trond's nfs-2.6 tree.

Signed-off-by: James Lentini <jlentini@netapp.com>

 verbs.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep,
 	return 0;
 
 out2:
-	if (ib_destroy_cq(ep->rep_cq))
-		;
+	rc = ib_destroy_cq(ep->rep_cq);
+	if (rc)
+		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
+			__func__, rc);
 out1:
 	return rc;
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
