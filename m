Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51926 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751009AbbGFOYx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 10:24:53 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: <dledford@redhat.com>, <sagig@mellanox.com>, <ogerlitz@mellanox.com>,
        <roid@mellanox.com>, <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int> <20150706052542.GB1109@infradead.org>
In-Reply-To: <20150706052542.GB1109@infradead.org>
Subject: RE: [PATCH V3 0/5] Transport-independent MRs
Date: Mon, 6 Jul 2015 09:24:54 -0500
Message-ID: <000e01d0b7f7$86f6f100$94e4d300$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Monday, July 06, 2015 12:26 AM
> To: Steve Wise
> Cc: dledford@redhat.com; sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org;
> eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org
> Subject: Re: [PATCH V3 0/5] Transport-independent MRs
> 
> On Sun, Jul 05, 2015 at 06:21:53PM -0500, Steve Wise wrote:
> > This series introduces transport-independent RDMA core services for
> > allocating DMA MRs and computing fast register access flags.  Included are
> > changes to the iSER and NFSRDMA ULPs to make use of the new services.
> 
> Can you convert all of them and remove the old APIs?

I can.  These are the only "transport independent" ULPs at this point.  But if we want to remove ib_get_dma_mr(), then I can do
this.

