Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36183 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbbGJTeT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 15:34:19 -0400
Date: Fri, 10 Jul 2015 12:34:09 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        "Hefty, Sean" <sean.hefty@intel.com>,
        Christoph Hellwig <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "sagig@mellanox.com" <sagig@mellanox.com>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "roid@mellanox.com" <roid@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "eli@mellanox.com" <eli@mellanox.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150710193409.GA9815@infradead.org>
References: <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708081320.GB24203@infradead.org>
 <559CF5E8.6080000@dev.mellanox.co.il>
 <20150708102035.GA28421@infradead.org>
 <559D0498.9050809@dev.mellanox.co.il>
 <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
 <559E34F8.4080507@dev.mellanox.co.il>
 <2189DB0A-DD00-4818-AC17-020FCE42D39B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2189DB0A-DD00-4818-AC17-020FCE42D39B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2015 at 09:52:59AM -0400, Chuck Lever wrote:
> There is one remaining kernel user of ib_reg_phys_mr() in 4.2: Lustre.

It's in the staging tree, which proper in-tree code doesn't have to
cater for.  So as soon as sunrpc is done using the interface we can and
should kill it off.
