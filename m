From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH REPOST] svcrdma: Limit ORD based on client's
  advertised IRD
Date: Mon, 19 May 2008 15:35:17 -0400
Message-ID: <RTPCLUEXC1-PRDch9wP0000011a@RTPMVEXC1-PRD.hq.netapp.com>
References: <1211224653.31725.62.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Bruce Fields <bfields@fieldses.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61655 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757864AbYESTfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 15:35:14 -0400
In-Reply-To: <1211224653.31725.62.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
References: <1211224653.31725.62.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 03:17 PM 5/19/2008, Tom Tucker wrote:
>-static void handle_connect_req(struct rdma_cm_id *new_cma_id)
>+static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)

Wow! That'll do it - 4 billion RDMA reads here we come!

Looks good to me with one tiny suggestion:

> 	newxprt->sc_ord =  min((size_t)devattr.max_qp_rd_atom,
>-			       (size_t)svcrdma_ord);
>+			       (size_t)newxprt->sc_ord);
>+	newxprt->sc_ord = min((size_t)svcrdma_ord,
>+			      (size_t)newxprt->sc_ord);
> 

You can code these a tiny bit more cleanly as min_t(size_t, foo, bar)
and thereby avoid all four casts.

Tom.

