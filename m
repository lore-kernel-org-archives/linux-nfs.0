Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:45225 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754180AbaGBTt4 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2014 15:49:56 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Devesh Sharma'" <Devesh.Sharma@Emulex.Com>,
        "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net> <20140623223942.1634.89063.stgit@manet.1015granger.net> <EE7902D3F51F404C82415C4803930ACD3FE0C540@CMEXMB1.ad.emulex.com> <53B45D7B.4020705@opengridcomputing.com> <EE7902D3F51F404C82415C4803930ACD3FE0C57A@CMEXMB1.ad.emulex.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FE0C57A@CMEXMB1.ad.emulex.com>
Subject: RE: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport disconnect
Date: Wed, 2 Jul 2014 14:50:32 -0500
Message-ID: <006001cf962e$e20df020$a629d060$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Devesh Sharma [mailto:Devesh.Sharma@Emulex.Com]
> Sent: Wednesday, July 02, 2014 2:43 PM
> To: Steve Wise; Chuck Lever; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: RE: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport disconnect
> 
> > -----Original Message-----
> > From: Steve Wise [mailto:swise@opengridcomputing.com]
> > Sent: Thursday, July 03, 2014 12:59 AM
> > To: Devesh Sharma; Chuck Lever; linux-rdma@vger.kernel.org; linux-
> > nfs@vger.kernel.org
> > Subject: Re: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport
> > disconnect
> >
> > On 7/2/2014 2:06 PM, Devesh Sharma wrote:
> > > This change is very much prone to generate poll_cq errors because of
> > > un-cleaned completions which still point to the non-existent QPs. On
> > > the new connection when these completions are polled, the poll_cq will fail
> > because old QP pointer is already NULL.
> > > Did anyone hit this situation during their testing?
> >
> > Hey Devesh,
> >
> > iw_cxgb4 will silently toss CQEs if the QP is not active.
> 
> Ya, just now checked that in mlx and cxgb4 driver code. On the other hand ocrdma is asserting
> a BUG-ON for such CQEs causing system panic.
> Out of curiosity I am asking, how this change is useful here, is it reducing the re-connection
> time...Anyhow rpcrdma_clean_cq was discarding the completions (flush/successful both)
>

Well, I don't think there is anything restricting an application from destroying the QP with pending CQEs on its CQs.   So it definitely shouldn't cause a BUG_ON() I think.   I'll have to read up in the Verbs specs if destroying a QP kills all the pending CQEs...

 
> >
> >
> > >> -----Original Message-----
> > >> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> > >> owner@vger.kernel.org] On Behalf Of Chuck Lever
> > >> Sent: Tuesday, June 24, 2014 4:10 AM
> > >> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> > >> Subject: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport
> > >> disconnect
> > >>
> > >> CQs are not destroyed until unmount. By draining CQs on transport
> > >> disconnect, successful completions that can change the r.frmr.state
> > >> field can be missed.
> 
> Still those are missed isn’t it....Since those successful completions will still be dropped after re-
> connection. Am I missing something to
> understanding the motivation...
> 
> > >>
> > >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > >> ---
> > >>   net/sunrpc/xprtrdma/verbs.c |    5 -----
> > >>   1 file changed, 5 deletions(-)
> > >>
> > >> diff --git a/net/sunrpc/xprtrdma/verbs.c
> > >> b/net/sunrpc/xprtrdma/verbs.c index 3c7f904..451e100 100644
> > >> --- a/net/sunrpc/xprtrdma/verbs.c
> > >> +++ b/net/sunrpc/xprtrdma/verbs.c
> > >> @@ -873,9 +873,6 @@ retry:
> > >>   			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
> > >>   				" status %i\n", __func__, rc);
> > >>
> > >> -		rpcrdma_clean_cq(ep->rep_attr.recv_cq);
> > >> -		rpcrdma_clean_cq(ep->rep_attr.send_cq);
> > >> -
> > >>   		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
> > >>   		id = rpcrdma_create_id(xprt, ia,
> > >>   				(struct sockaddr *)&xprt->rx_data.addr);
> > @@ -985,8 +982,6 @@
> > >> rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
> > >> {
> > >>   	int rc;
> > >>
> > >> -	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
> > >> -	rpcrdma_clean_cq(ep->rep_attr.send_cq);
> > >>   	rc = rdma_disconnect(ia->ri_id);
> > >>   	if (!rc) {
> > >>   		/* returns without wait if not connected */
> > >>
> > >> --
> > >> To unsubscribe from this list: send the line "unsubscribe linux-rdma"
> > >> in the body of a message to majordomo@vger.kernel.org More
> > majordomo
> > >> info at http://vger.kernel.org/majordomo-info.html
> > > N     r  y   b X  ǧv ^ )޺{.n +    {   "  ^n r   z   h    &   G   h 
> > > ( 階 ݢj"   m     z ޖ   f   h   ~ mml==


