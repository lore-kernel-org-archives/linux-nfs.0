Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36096 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751627AbbGNTZr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 15:25:47 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Tom Talpey'" <tom@talpey.com>, "'Doug Ledford'" <dledford@redhat.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
References: <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il>
In-Reply-To: <55A24571.60902@dev.mellanox.co.il>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 14 Jul 2015 14:25:50 -0500
Message-ID: <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> >>
> >> I'm sorry Steve for leading you down the wrong path with these flags,
> >> I did not fully realize exactly what the iWarp difference was at the
> >> start :(
> >>
> >> Jason
> >
> >
> > No problem.  I'll work on iSER target FRMRs and repost the iSER series.
> >
> > Sagi, right now isert only uses FRMRs along with signature mrs.  I'll need to separate the two, I think.  Does that sound right?
> 
> Yea.
> 
> Given that FRWR takes extra HW (and memory) resources, it
> should probably be:
> 
> if (signature support || iwarp)
> 	use FRMR

Currently the code does:

if (device_supports_fastreg && device_supports_signature)
        use FRMR
else
        use DMAMR

Shouldn't we just recode it this way?

if (device_supports_fastreg)
        use FRMR
else
        use DMAMR

The benefit is that we don't have to check for iWARP protocol in the ULP.  The side effect is, I think, mlx4 will now use FRMR
instead of DMAMR for reads/writes since it doesn't support signature handover.



