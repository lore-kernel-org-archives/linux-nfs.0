Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:41953 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbbGMQuR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 12:50:17 -0400
Date: Mon, 13 Jul 2015 10:50:07 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Hefty, Sean" <sean.hefty@intel.com>,
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
Message-ID: <20150713165007.GD23832@obsidianresearch.com>
References: <559CD174.4040901@dev.mellanox.co.il>
 <20150708081320.GB24203@infradead.org>
 <559CF5E8.6080000@dev.mellanox.co.il>
 <20150708102035.GA28421@infradead.org>
 <559D0498.9050809@dev.mellanox.co.il>
 <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
 <559E34F8.4080507@dev.mellanox.co.il>
 <2189DB0A-DD00-4818-AC17-020FCE42D39B@oracle.com>
 <20150710193409.GA9815@infradead.org>
 <55A21BF4.7090601@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A21BF4.7090601@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 12, 2015 at 10:49:08AM +0300, Sagi Grimberg wrote:
> On 7/10/2015 10:34 PM, Christoph Hellwig wrote:
> >On Thu, Jul 09, 2015 at 09:52:59AM -0400, Chuck Lever wrote:
> >>There is one remaining kernel user of ib_reg_phys_mr() in 4.2: Lustre.
> >
> >It's in the staging tree, which proper in-tree code doesn't have to
> >cater for.  So as soon as sunrpc is done using the interface we can and
> >should kill it off.
> >
> 
> I think we should probably ask the Lustre folks if they have a real use
> case for it before we remove it completely.

I had an interesting conversation with some Lustre devs where they
were very concerned that FMR was going to be removed and they didn't really
seem to even know that FRMR existed.

I'm sure their PHYS_MR usage is crufty old code to support old
adaptors.

And again, here is a great example of how the API is not helping the
ULPs do what they want to do. Lustre doesn't care one bit about this
stuff, they just want to send messages..

Jason
