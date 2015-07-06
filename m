Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51947 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbbGFO3o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 10:29:44 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Haggai Eran'" <haggaie@mellanox.com>, <dledford@redhat.com>
Cc: <sagig@mellanox.com>, <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int> <20150705232158.12029.25472.stgit@build2.ogc.int> <559A2991.3040304@mellanox.com>
In-Reply-To: <559A2991.3040304@mellanox.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Mon, 6 Jul 2015 09:29:44 -0500
Message-ID: <001201d0b7f8$343056e0$9c9104a0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Haggai Eran [mailto:haggaie@mellanox.com]
> Sent: Monday, July 06, 2015 2:09 AM
> To: Steve Wise; dledford@redhat.com
> Cc: sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-
> devel@vger.kernel.org; linux-nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org
> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> On 06/07/2015 02:22, Steve Wise wrote:
> > +int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs)
> > +{
> > +	int access_flags = attrs;
> > +
> > +	if (roles & RDMA_MRR_RECV)
> > +		access_flags |= IB_ACCESS_LOCAL_WRITE;
> > +
> > +	if (roles & RDMA_MRR_WRITE_DEST)
> > +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
> > +
> > +	if (roles & RDMA_MRR_READ_DEST) {
> > +		access_flags |= IB_ACCESS_LOCAL_WRITE;
> > +		if (rdma_protocol_iwarp(pd->device,
> > +					rdma_start_port(pd->device)))
> > +			access_flags |= IB_ACCESS_REMOTE_WRITE;
> > +	}
> > +
> > +	if (roles & RDMA_MRR_READ_SOURCE)
> > +		access_flags |= IB_ACCESS_REMOTE_READ;
> > +
> > +	if (roles & RDMA_MRR_ATOMIC_DEST)
> > +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_ATOMIC;
> 
> I think you need LOCAL_WRITE for ATOMIC_SOURCE in order to receive the
> results of the atomic operation.
> 

Ok.  I'm not familiar with atomics.  I'll verify with the IB spec and update the code as needed.


> > +
> > +	if (roles & RDMA_MRR_MW_BIND)
> > +		access_flags |= IB_ACCESS_MW_BIND;
> > +
> > +	return access_flags;
> > +}
> > +EXPORT_SYMBOL(rdma_device_access_flags);

