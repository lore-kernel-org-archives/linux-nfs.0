Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:43094 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161003AbbHGQ3G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 12:29:06 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Doug Ledford'" <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <target-devel@vger.kernel.org>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com> <1438241568-3685-12-git-send-email-sagig@mellanox.com> <003301d0d122$a1e46ee0$e5ad4ca0$@opengridcomputing.com> <20150807151318.GA13777@infradead.org> <003a01d0d12c$e84b4e80$b8e1eb80$@opengridcomputing.com> <20150807162615.GA16851@infradead.org>
In-Reply-To: <20150807162615.GA16851@infradead.org>
Subject: RE: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
Date: Fri, 7 Aug 2015 11:29:12 -0500
Message-ID: <003c01d0d12e$31a879d0$94f96d70$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of 'Christoph Hellwig'
> Sent: Friday, August 07, 2015 11:26 AM
> To: Steve Wise
> Cc: 'Christoph Hellwig'; 'Sagi Grimberg'; 'Doug Ledford'; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org; target-
> devel@vger.kernel.org
> Subject: Re: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
> 
> On Fri, Aug 07, 2015 at 11:19:59AM -0500, Steve Wise wrote:
> > I guess I'll post two patches, the NFS fix that preceeds af78181/ b7e06cd, and a reworked patch to replace e20684a.
> >
> > Is that the way to go in your opinion?
> 
> To me this sounds good.  We have a couple patches from Jason's series
> that already need to be replaced, so the tree will need a rebase anyway,
> so I don't see a problem with replacing ones in Sagi's series either.
> If Sagi needs to do a repost for some reason he can just include your
> NFS patch in front of the series.

I misspoke.  I had the order reversed. The order is such that we can add my new NFS patch after:

e20684a xprtrdma, svcrdma: Convert to ib_alloc_mr

and before these:

af78181 cxgb3: Support ib_alloc_mr verb
b7e06cd iw_cxgb4: Support ib_alloc_mr verb

Steve


