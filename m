Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31455 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758696AbbGHROG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 13:14:06 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        "'Christoph Hellwig'" <hch@infradead.org>
CC: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "sagig@mellanox.com" <sagig@mellanox.com>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "roid@mellanox.com" <roid@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "eli@mellanox.com" <eli@mellanox.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        Oren Duer <oren@mellanox.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Wed, 8 Jul 2015 17:14:04 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il> <20150708081320.GB24203@infradead.org>
 <559CF5E8.6080000@dev.mellanox.co.il> <20150708102035.GA28421@infradead.org>
 <559D0498.9050809@dev.mellanox.co.il>
In-Reply-To: <559D0498.9050809@dev.mellanox.co.il>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I am still not clear if all of us agree that we need it.
> Sean and Steve had some disclaimers...

A single entry point doesn't help a whole lot if the app must deal with different behavior based on how the API is used.  We have a single entry point for post_send, for example, and that makes things worse.  IMO, we need fewer registration *methods* not fewer calls.
