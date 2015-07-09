Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37912 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbbGIIrf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 04:47:35 -0400
Received: by wibdq8 with SMTP id dq8so235237465wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 01:47:34 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: "'Christoph Hellwig'" <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
Cc: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559E3531.5080306@dev.mellanox.co.il>
Date: Thu, 9 Jul 2015 11:47:45 +0300
MIME-Version: 1.0
In-Reply-To: <20150708203205.GA21847@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/8/2015 11:32 PM, 'Christoph Hellwig' wrote:
> On Wed, Jul 08, 2015 at 01:08:42PM -0600, Jason Gunthorpe wrote:
>> Then, what is left is all remote MRs and maybe it will be clearer what
>> to do about them then...
>
>  From looking at that for a while the APIs needed seem pretty simple
> to me from a consumer perspective:
>
> struct rdma_mr *rmda_alloc_mr(struct ib_pd *pd, unsigned int nr_pages);

Why assuming that the mr spans pages?
I'd prefer if we consolidate on an existing mr allocation API
ib_create_mr() that receives a generic struct ib_mr_init_attr.

> void rdma_free_mr(struct rdma_mr *mr);
>
> /* updates *sg if the SG couldn't be fully registered due to offsets */
> int rdma_register_sg(struct rdma_mr *mr, struct scatterlist **sg,
> 		u32 *pkey, u32 *offset, u32 *len);

This is where I have a problem. Providing an API that may or may not
post a work request on my QP is confusing, and I don't understand its
semantics at all. Do I need to reserve slots on my QP? should I ask for
a completion? If we suppress the completion will I see an error
completion? What should I expect to find in the wr_id?

The stack is converging on FRWR as the primary registration method. Any
other methods will gradually be removed. I think that posting the work
request must never be implicit. We should focus on making the
registration work request better and hide the mechanics from the
consumer.

P.S. you probably didn't mean the argument pkey unless I'm completely
missing something...

> void rdma_unregister_sg(struct rdma_mr *mr, struct scatterlist *sg);

Same arguments here for local invalidate work request.

> Note that this assumes that the iSER bounce buffer hacks are replaced
> with the QUEUE_FLAG_SG_GAPS flags and a change to the SG_IO code to
> bounce buffer for vectored SG_IO calls.

Yea - that's on my todo's...
