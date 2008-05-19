From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcrdma: Limit ORD based on client's advertised IRD
Date: Mon, 19 May 2008 13:39:34 -0400
Message-ID: <20080519173934.GN7622@fieldses.org>
References: <1211214842.31725.38.camel@trinity.ogc.int> <RTPCLUEXC1-PRD1q4gt00000114@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753688AbYESRjh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 13:39:37 -0400
In-Reply-To: <RTPCLUEXC1-PRD1q4gt00000114-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got dropped of the cc: somehow--please try not to prune cc's.  I have
enough trouble keeping up without the additional confusion to my mail
filters....

--b.

On Mon, May 19, 2008 at 01:17:54PM -0400, Talpey, Thomas wrote:
> At 12:34 PM 5/19/2008, Tom Tucker wrote:
> >When adapters have differing IRD limits, the RDMA transport will fail to
> >connect properly. The RDMA transport should use the client's advertised
> >inbound read limit when computing it's outbound read limit. For iWARP
> >transports, there is no exchange of the IRD/ORD during connect request and
> >so the only way to ensure compatability is to use the
> >/proc/sys/sunrpc/svc_rdma/max_outbound_read_requests file to control
> >server ORD.
> 
> Well, technically the iWARP connection manager *currently* does not
> exchange these values. I think the comment would be more accurate
> if it said "in the absence of"...
> 
> >-static void handle_connect_req(struct rdma_cm_id *new_cma_id)
> >+static void handle_connect_req(struct rdma_cm_id *new_cma_id, u8 client_ird)
> 
> While "u8" might be the limit of the implementations today, wouldn't "int" be
> easier to understand, and more portable?
> 
> >+	/* Save client advertised inbound read limit for use later in accept. */
> >+	newxprt->sc_ord = client_ird;
> >+
> and...
> >+	/* 
> >+	* Limit ORD based on client limit, local device limit, and
> >+	* configured svcrdma limit.
> >+	*/
> >+	newxprt->sc_ord =  min((size_t)devattr.max_qp_rd_atom, newxprt->sc_ord);
> >+	newxprt->sc_ord = min((size_t)svcrdma_ord, newxprt->sc_ord);
> 
> Looks good, but it's a little odd that the value goes into sc_ord in one
> routine, only to be changed before being used. I guess the device attrs
> aren't handy at the time the connection is notified though, so ok.
> 
> Tom.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
