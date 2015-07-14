Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36383 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752132AbbGNVBB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 17:01:01 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
References: <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714194512.GA25887@infradead.org> <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com> <20150714204145.GC26927@obsidianresearch.com> <010c01d0be76$dbb4c520$931e4f60$@opengridcomputing.com>
In-Reply-To: <010c01d0be76$dbb4c520$931e4f60$@opengridcomputing.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 14 Jul 2015 16:01:04 -0500
Message-ID: <011001d0be78$32412ef0$96c38cd0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Steve Wise
> Sent: Tuesday, July 14, 2015 3:51 PM
> To: 'Jason Gunthorpe'
> Cc: 'Christoph Hellwig'; 'Sagi Grimberg'; 'Steve Wise'; 'Tom Talpey'; 'Doug Ledford'; sagig@mellanox.com; ogerlitz@mellanox.com;
> roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org;
> trond.myklebust@primarydata.com; bfields@fieldses.org; 'Oren Duer'
> Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> 
> 
> > -----Original Message-----
> > From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Jason Gunthorpe
> > Sent: Tuesday, July 14, 2015 3:42 PM
> > To: Steve Wise
> > Cc: 'Christoph Hellwig'; 'Sagi Grimberg'; 'Steve Wise'; 'Tom Talpey'; 'Doug Ledford'; sagig@mellanox.com; ogerlitz@mellanox.com;
> > roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org;
> > trond.myklebust@primarydata.com; bfields@fieldses.org; 'Oren Duer'
> > Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> >
> > On Tue, Jul 14, 2015 at 02:58:23PM -0500, Steve Wise wrote:
> > > The local_dma_lkey can be used in any rdma sge that requires an
> > > lkey.
> >
> > No, this is where iWarp doesn't follow the generic API - a local dma
> > lkey cannot be used with iWarp's RDMA_READ WR lkey. In effect RDMA
> > READ requires an *rkey* (confusingly stuck into the lkey slot) for
> > iWarp. (Right?)
> >
> 
> Right, a local_dma_lkey is not an rkey, and iwarp requires the rkey for the read destination MR.  Further that rkey needs
> REMOTE_WRITE.
>

BTW: What use is an IB rkey with no REMOTE_ flags set?  Can it be used somehow differently than the associated lkey?


