Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12486 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbbGWAng convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 20:43:36 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Tom Talpey <tom@talpey.com>, Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Wise <swise@opengridcomputing.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "sagig@mellanox.com" <sagig@mellanox.com>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "roid@mellanox.com" <roid@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "eli@mellanox.com" <eli@mellanox.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Oren Duer <oren@mellanox.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Thu, 23 Jul 2015 00:43:34 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A9001297@ORSMSX109.amr.corp.intel.com>
References: <559CD174.4040901@dev.mellanox.co.il>
 <20150708081320.GB24203@infradead.org> <559CF5E8.6080000@dev.mellanox.co.il>
 <20150708102035.GA28421@infradead.org> <559D0498.9050809@dev.mellanox.co.il>
 <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
 <559E34F8.4080507@dev.mellanox.co.il>
 <2189DB0A-DD00-4818-AC17-020FCE42D39B@oracle.com>
 <20150710193409.GA9815@infradead.org> <55A21BF4.7090601@dev.mellanox.co.il>
 <20150713165007.GD23832@obsidianresearch.com>
 <55A4C2FA.9060707@dev.mellanox.co.il> <55A4FF93.4090406@talpey.com>
In-Reply-To: <55A4FF93.4090406@talpey.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > This just emphasizes why we need to converge to a single method.
> 
> In my opinion, we already have it.
> 
> For local registrations, ib_reg_phys_mr()/ib_get_dma_mr(). These are not
> quite equivalent, btw.

Personally, I would work to eliminate local registration as part of the API.

> For remote registrations, ib_post_send(FRMR).

I slightly agree here.  IMO, the rkey should be obtained by associating the memory buffer with the QP, but not explicitly as a 'send' operation.

If queuing is a concern, we could expose max_active_registrations/max_total_registrations QP attributes.

I would hide the protection domain concept entirely.  If needed, a provider can allocate one PD per QP, with memory registration going to the PD.

- Sean
