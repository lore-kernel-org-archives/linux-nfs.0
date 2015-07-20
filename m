Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:44354 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754877AbbGTVeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 17:34:25 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Tom Talpey'" <tom@talpey.com>
Cc: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net> <20150720190311.10997.12636.stgit@manet.1015granger.net> <55AD5B48.3010906@talpey.com> <20150720210544.GA9655@obsidianresearch.com> 
In-Reply-To: 
Subject: RE: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Date: Mon, 20 Jul 2015 16:34:27 -0500
Message-ID: <015301d0c333$da8bae40$8fa30ac0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> 
> > Based on that, should we remove the cxgb3 driver as well? Or at least
> > can you fix it up to at least fail get_dma_mr if there is too much
> > ram?
> >
> 
> I would like to keep cxgb3 around.  I can add code to fail if the memory is > 32b.  Do you know how I get the amount of available
ram?
>

Something like this?

@@ -736,6 +736,9 @@ static struct ib_mr *iwch_get_dma_mr(struct ib_pd *pd, int acc)
        /*
         * T3 only supports 32 bits of size.
         */
+       if ((totalram_pages << PAGE_SHIFT) > 0xffffffff)
+               return -ENOTSUPP;
+
        bl.size = 0xffffffff;
        bl.addr = 0;
        kva = 0;
 


