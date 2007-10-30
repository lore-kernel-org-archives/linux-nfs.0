From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 03/27] SUNRPC: Check a return result
Date: Tue, 30 Oct 2007 12:56:58 -0400
Message-ID: <1193763418.7422.76.camel@heimdal.trondhjem.org>
References: <20071026173054.31475.61789.stgit@manray.1015granger.net>
	<Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImuOV-00032t-M5
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:56:48 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ImuOa-0007iF-Pw
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:56:53 -0700
In-Reply-To: <Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
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


On Tue, 2007-10-30 at 12:42 -0400, James Lentini wrote:
> On Fri, 26 Oct 2007, Chuck Lever wrote:
> 
> > Minor: Replace an empty if statement with a debugging dprintk.
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
> > ---
> > 
> >  net/sunrpc/xprtrdma/verbs.c |    8 +++++---
> >  1 files changed, 5 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> > index 44b0fb9..ffbf22a 100644
> > --- a/net/sunrpc/xprtrdma/verbs.c
> > +++ b/net/sunrpc/xprtrdma/verbs.c
> > @@ -522,7 +522,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
> >  				struct rpcrdma_create_data_internal *cdata)
> >  {
> >  	struct ib_device_attr devattr;
> > -	int rc;
> > +	int rc, err;
> >  
> >  	rc = ib_query_device(ia->ri_id->device, &devattr);
> >  	if (rc) {
> > @@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
> >  	return 0;
> >  
> >  out2:
> > -	if (ib_destroy_cq(ep->rep_cq))
> > -		;
> > +	err = ib_destroy_cq(ep->rep_cq);
> > +	if (err)
> > +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
> > +			__func__, err);
> >  out1:
> >  	return rc;
> >  }
> 
> Good eyes, Chuck. One minor suggestion: instead of adding "err", how 
> about reusing "rc"? Here's a patch against Trond's nfs-2.6 tree.
> 
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
>  verbs.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep,
>  	return 0;
>  
>  out2:
> -	if (ib_destroy_cq(ep->rep_cq))
> -		;
> +	rc = ib_destroy_cq(ep->rep_cq);
> +	if (rc)
> +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
> +			__func__, rc);
>  out1:
>  	return rc;
>  }

NAK. That would clobber the error that you are trying to return from
ib_req_notify_cq.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
