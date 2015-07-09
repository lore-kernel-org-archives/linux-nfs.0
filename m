Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34551 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbbGIIqi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 04:46:38 -0400
Received: by wifm2 with SMTP id m2so11656644wif.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 01:46:37 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: "Hefty, Sean" <sean.hefty@intel.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il> <20150708081320.GB24203@infradead.org>
 <559CF5E8.6080000@dev.mellanox.co.il> <20150708102035.GA28421@infradead.org>
 <559D0498.9050809@dev.mellanox.co.il>
 <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
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
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559E34F8.4080507@dev.mellanox.co.il>
Date: Thu, 9 Jul 2015 11:46:48 +0300
MIME-Version: 1.0
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/8/2015 8:14 PM, Hefty, Sean wrote:
>> I am still not clear if all of us agree that we need it.
>> Sean and Steve had some disclaimers...
>
> A single entry point doesn't help a whole lot if the app must deal with different behavior based on how the API is used.

It is true that different MRs will be used differently. However, not
once we have found ourselves extending an API to add functionality. This
means changing the API signature and changing all the call sites. Just
recently we saw this in Steve's mr_roles and in Matan's timestamping
support (changed ib_create_cq). When was the last time ib_create_qp API
was modified?

> We have a single entry point for post_send, for example, and that makes things worse.

I don't necessarily agree. the fact that post_send have multiple entry
points allows the consumer to concatenate a couple of those in a single
post. That's beneficial to get maximum performance from your HW.

> IMO, we need fewer registration *methods* not fewer calls.

I do agree that we need fewer registration methods. Let's review what
we have today:

- FRWR: which is *the* standard way to register memory. It's fast,
   non-blocking and has vast support.

- FMR: which is only supported in some Mellanox devices if I'm not
   mistaken, it's fast, but has slow invalidation (unmap). It is also not
   supported over VF.
   * FMR_POOL API was designed to address the slow unmap but created a
     week invalidation semantics (unmap is done only when some number of
     remapping is met).

- REG_PHYS_MR: which is supported by some devices. It actually
   combines both MR allocation and registration in a single call (it is
   the equivalent of user-space ibv_reg_mr)

I don't consider the dma_mr a registration method. It provides physical
memory access.

As for REG_PHYS_MR, this is the only synchronous registration method in
the kernel. It is a simple interface, which is currently used by 
xprtrdma when dma mr is not supported. We can consider removing it in
the future if it turns out to be non useful.

As for FMR/FMR_POOL, I'd much rather to wait until it becomes
deprecated on it's own rather than try and incorporate it in a
modernized API.

I think the stack can converge on FRWR as its primary registration
method. Let's focus on making it better.
