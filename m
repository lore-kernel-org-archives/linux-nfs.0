Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:43057 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932653AbbHGQTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 12:19:54 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Doug Ledford'" <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <target-devel@vger.kernel.org>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com> <1438241568-3685-12-git-send-email-sagig@mellanox.com> <003301d0d122$a1e46ee0$e5ad4ca0$@opengridcomputing.com> <20150807151318.GA13777@infradead.org>
In-Reply-To: <20150807151318.GA13777@infradead.org>
Subject: RE: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
Date: Fri, 7 Aug 2015 11:19:59 -0500
Message-ID: <003a01d0d12c$e84b4e80$b8e1eb80$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Christoph Hellwig
> Sent: Friday, August 07, 2015 10:13 AM
> To: Steve Wise
> Cc: 'Sagi Grimberg'; 'Doug Ledford'; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org; target-devel@vger.kernel.org
> Subject: Re: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
> 
> On Fri, Aug 07, 2015 at 10:06:26AM -0500, Steve Wise wrote:
> > If it is too much of a pain to alter this patch, then I'll just
> > submit the NFSRDMA fix and live with the bisect issue...
> 
> Doug's tree is still to be rebased.  So please submit your NFS
> fix now as ask Doug to merge it before Sagi's series in the final
> tree.

My new NFS fix needs to land before these two:

af78181 cxgb3: Support ib_alloc_mr verb
b7e06cd iw_cxgb4: Support ib_alloc_mr verb

But it will cause the following patch, which is after the above two, to need rework because it hits the same lines:

e20684a xprtrdma, svcrdma: Convert to ib_alloc_mr

I guess I'll post two patches, the NFS fix that preceeds af78181/ b7e06cd, and a reworked patch to replace e20684a.

Is that the way to go in your opinion?

Steve.




