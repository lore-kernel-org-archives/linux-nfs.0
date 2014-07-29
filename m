Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([149.20.54.216]:49968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaG2Wuw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 18:50:52 -0400
Date: Tue, 29 Jul 2014 15:50:50 -0700 (PDT)
Message-Id: <20140729.155050.311148635959938226.davem@davemloft.net>
To: himangi774@gmail.com
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
Subject: Re: [PATCH] svcrdma: delete double assignment
From: David Miller <davem@davemloft.net>
In-Reply-To: <20140728152938.GA3040@himangi-Dell>
References: <20140728152938.GA3040@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Himangi Saraogi <himangi774@gmail.com>
Date: Mon, 28 Jul 2014 20:59:38 +0530

> Delete successive assignments to the same location.
> 
> A simplified version of Coccinelle semantic match that finds this problem is as
> follows:
> 
> // <smpl>
> @@
> expression i;
> @@
> 
> *i = ...;
>  i = ...;
> // </smpl>
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>

I am not so sure about this change either.

> @@ -956,7 +956,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>  			dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
>  			goto errout;
>  		}
> -		newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
>  		newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
>  		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
>  		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;

->sc_max_sge is used to limit the number of segments used during sends,
currently in this code.  Grep for where it is used.

Therefore, if anything, the correct thing to do would be to retain the
first line rather than the second line.

Someone who actually works on this code and understands it should
really take a close look at this before anyone even thinks about
applying this patch.
