Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33807 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbGLHte (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 03:49:34 -0400
Received: by wibud3 with SMTP id ud3so6044659wib.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 00:49:12 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
References: <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il> <20150708081320.GB24203@infradead.org>
 <559CF5E8.6080000@dev.mellanox.co.il> <20150708102035.GA28421@infradead.org>
 <559D0498.9050809@dev.mellanox.co.il>
 <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
 <559E34F8.4080507@dev.mellanox.co.il>
 <2189DB0A-DD00-4818-AC17-020FCE42D39B@oracle.com>
 <20150710193409.GA9815@infradead.org>
Cc: "Hefty, Sean" <sean.hefty@intel.com>,
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
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A21BF4.7090601@dev.mellanox.co.il>
Date: Sun, 12 Jul 2015 10:49:08 +0300
MIME-Version: 1.0
In-Reply-To: <20150710193409.GA9815@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/10/2015 10:34 PM, Christoph Hellwig wrote:
> On Thu, Jul 09, 2015 at 09:52:59AM -0400, Chuck Lever wrote:
>> There is one remaining kernel user of ib_reg_phys_mr() in 4.2: Lustre.
>
> It's in the staging tree, which proper in-tree code doesn't have to
> cater for.  So as soon as sunrpc is done using the interface we can and
> should kill it off.
>

I think we should probably ask the Lustre folks if they have a real use
case for it before we remove it completely.

It seems that Lustre strives to FMRs and if it is not supported it uses
a PHYS_MR. Given FMRs has an expiration date and PHYS_MR is basically
alloc/free of MRs in the data path (which is obviously not desirable in
any form). Lustre will need to refresh their code to use the standard
FRWR.

Do we have Lustre folks listening on the mailing list?
