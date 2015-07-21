Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:46050 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752203AbbGUVWt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2015 17:22:49 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Tom Talpey'" <tom@talpey.com>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, "'Doug Ledford'" <dledford@redhat.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net> <20150720190311.10997.12636.stgit@manet.1015granger.net> <55AD5B48.3010906@talpey.com> <20150720210544.GA9655@obsidianresearch.com> <015101d0c331$69e31d10$3da95730$@opengridcomputing.com> <55AD7065.8040809@talpey.com> <015701d0c33d$36b53110$a41f9330$@opengridcomputing.com> <55AD8F05.6070409@talpey.com> <000301d0c3c2$3f892a50$be9b7ef0$@opengridcomputing.com> <55AEAFCE.60207@talpey.com> 
In-Reply-To: 
Subject: RE: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Date: Tue, 21 Jul 2015 16:22:52 -0500
Message-ID: <00c901d0c3fb$66e7cfa0$34b76ee0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > >>>> B) why bother to check? Are machines with <4GB interesting, and worth
> > >>>> supporting a special optimization?
> > >>>
> > >>> No, but cxgb3 is still interesting to user applications, and perhaps NFSRDMA using FRMRs.
> > >>
> > >> I'm obviously not making myself clear. I am suggesting that cxgb3 fail
> > >> the ib_get_dma_mr() verb, regardless of installed memory.
> > >>
> > >> I am not suggesting it fail to load, or fail other memreg requests. It
> > >> should work normally in all other respects.
> > >
> > > Even with its limitation, doesn't it have utility for someone using cxgb3 in an embedded 32b environment?
> >
> > Sure, do you mean making it conditional on #if sizeof(physaddr) <= 32?
> > That would make sense I guess.
> 
> No, a runtime check.  x64 platforms will work too if the mem size takes <= 32b to describe.

Jason/Doug, do you think it should allow dma mr allocaton iff totalmem_pages < 4GB?  Or do a check on the sizeof totalmem_pages and
only allow dma mrs if it is <= 4?


