Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41167 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291AbbGXASm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 20:18:42 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
CC: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "sagig@mellanox.com" <sagig@mellanox.com>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "roid@mellanox.com" <roid@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "eli@mellanox.com" <eli@mellanox.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Fri, 24 Jul 2015 00:18:41 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A901DBA9@ORSMSX109.amr.corp.intel.com>
References: <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714194512.GA25887@infradead.org>
 <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com>
 <1828884A29C6694DAF28B7E6B8A82373A901C9A5@ORSMSX109.amr.corp.intel.com>
 <009e01d0c57a$37d5b9e0$a7812da0$@opengridcomputing.com>
 <1828884A29C6694DAF28B7E6B8A82373A901DB80@ORSMSX109.amr.corp.intel.com>
 <20150723235310.GA20537@obsidianresearch.com>
In-Reply-To: <20150723235310.GA20537@obsidianresearch.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The lkey is possibly useful if someone wants to do single op transfers
> larger than the S/G limit of the SQE. I haven't noticed any ULPs doing
> that..

That changes how the buffer is identified, which gets back to my question of are we identifying local buffers by address or through some sort of iova/tag/descriptor/mr/whatever.  Do we have this right in the API?
