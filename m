Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:44463 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752188AbbGTWlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 18:41:25 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Tom Talpey'" <tom@talpey.com>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net> <20150720190311.10997.12636.stgit@manet.1015granger.net> <55AD5B48.3010906@talpey.com> <20150720210544.GA9655@obsidianresearch.com> <015101d0c331$69e31d10$3da95730$@opengridcomputing.com> <55AD7065.8040809@talpey.com>
In-Reply-To: <55AD7065.8040809@talpey.com>
Subject: RE: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Date: Mon, 20 Jul 2015 17:41:27 -0500
Message-ID: <015701d0c33d$36b53110$a41f9330$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Tom Talpey [mailto:tom@talpey.com]
> Sent: Monday, July 20, 2015 5:04 PM
> To: Steve Wise; 'Jason Gunthorpe'
> Cc: 'Chuck Lever'; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
> 
> On 7/20/2015 2:16 PM, Steve Wise wrote:
> >
> >
> >> -----Original Message-----
> >> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Jason Gunthorpe
> >> Sent: Monday, July 20, 2015 4:06 PM
> >> To: Tom Talpey; Steve Wise
> >> Cc: Chuck Lever; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> >> Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
> >>
> >> On Mon, Jul 20, 2015 at 01:34:16PM -0700, Tom Talpey wrote:
> >>> On 7/20/2015 12:03 PM, Chuck Lever wrote:
> >>>> All HCA providers have an ib_get_dma_mr() verb. Thus
> >>>> rpcrdma_ia_open() will either grab the device's local_dma_key if one
> >>>> is available, or it will call ib_get_dma_mr() which is a 100%
> >>>> guaranteed fallback.
> >>>
> >>> I recall that in the past, some providers did not support mapping
> >>> all of the machine's potential physical memory with a single dma_mr.
> >>> If an rnic did/does not support 44-ish bits of length per region,
> >>> for example.
> >>
> >> Looks like you are right, but the standard in kernel is to require
> >> ib_get_dma_mr, if the HCA can't do that, then it cannot be used on a
> >> big memory machine with kernel ULPs.
> >>
> >> Looking deeper, both amso1100 and cxgb3 seem limited to 32 bits of
> >> physical memory, and silently break all kernel ULPs if they are used
> >> on a modern machine with > 4G.
> >>
> >> Is that right Steve?
> >>
> >
> > Yes.
> >
> >> Based on that, should we remove the cxgb3 driver as well? Or at least
> >> can you fix it up to at least fail get_dma_mr if there is too much
> >> ram?
> >>
> >
> > I would like to keep cxgb3 around.  I can add code to fail if the memory is > 32b.  Do you know how I get the amount of
available
> > ram?
> 
> A) are you sure it's an unsigned length, i.e. is it really 31 bits?
> 

yes.

> B) why bother to check? Are machines with <4GB interesting, and worth
> supporting a special optimization?

No, but cxgb3 is still interesting to user applications, and perhaps NFSRDMA using FRMRs.


