Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36128 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269AbbGNTc2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 15:32:28 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
References: <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714192941.GA26292@obsidianresearch.com>
In-Reply-To: <20150714192941.GA26292@obsidianresearch.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 14 Jul 2015 14:32:31 -0500
Message-ID: <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> On Tue, Jul 14, 2015 at 02:25:50PM -0500, Steve Wise wrote:
> 
> > The benefit is that we don't have to check for iWARP protocol in the
> > ULP.
> 
> IB should have to pay the cost of FRMR for lkey on RDMA READ, I'm
> pretty sure you have to check for iWarp at somepoint..
> 

You mean "should not", yea?  

Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)



