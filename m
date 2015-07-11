Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linode.aoot.com ([69.164.194.13]:40866 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbbGKQzG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jul 2015 12:55:06 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
From: Steve Wise <swise@ogc.us>
In-Reply-To: <20150710161108.GA19042@obsidianresearch.com>
Date: Sat, 11 Jul 2015 09:37:56 -0700
Cc: Tom Talpey <tom@talpey.com>, Doug Ledford <dledford@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>,
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
Message-Id: <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
References: <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 10, 2015, at 9:11 AM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
>> On Fri, Jul 10, 2015 at 09:22:24AM -0400, Tom Talpey wrote:
>> and it is enabled only when the RDMA Read is active.
> 
> ??? How is that done? ib_get_dma_mr is defined to return a remote
> usable rkey that is valid from when it it returns until the MR is
> destroyed. NFS creates one mr early on, it does not seem to make one
> per RDMA READ?
> 
> For the proposed iSER patch the problem is very acute, iser makes a
> single PD and phys MR at boot time for each device. This means there
> is a single machine wide unchanging rkey that allows remote physical
> memory access. An attacker only has to repeatedly open QPs to iSER and
> guess rkey values until they find it. Add in likely non-crypto
> randomness for rkeys, and I bet it isn't even that hard to do.
> 
> So this seems to be a catastrophic security failing.
> 
>>> From there, it is a logical wish: If Steve is going to FRMR'ize iSER
>>> to be acceptable security wise, I'd rather see that work done on in a
>>> general way. Hence the API discussion.
>> 
>> Well, it's important to realize that NFS already does the Right Thing.
>> So it isn't actually an urgent issue. There is time to discuss.
> 
> It depends on what is going on with iWarp iSER. If the iWarp community
> thinks it should go ahead insecurely then fine, put a giant warning in
> dmesg and go ahead, otherwise iWarp needs to address this difference
> with a proper generic API, which appears, must wrapper
> ib_post_send. Harder job :\
> 
> I'm sorry Steve for leading you down the wrong path with these flags,
> I did not fully realize exactly what the iWarp difference was at the
> start :(
> 
> Jason


No problem.  I'll work on iSER target FRMRs and repost the iSER series.  

Sagi, right now isert only uses FRMRs along with signature mrs.  I'll need to separate the two, I think.  Does that sound right?