Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37536 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbGII6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 04:58:48 -0400
Received: by wiclp1 with SMTP id lp1so103221621wic.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 01:58:46 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
 <20150709000337.GE16812@obsidianresearch.com>
Cc: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559E37D2.9090103@dev.mellanox.co.il>
Date: Thu, 9 Jul 2015 11:58:58 +0300
MIME-Version: 1.0
In-Reply-To: <20150709000337.GE16812@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 3:03 AM, Jason Gunthorpe wrote:
> On Wed, Jul 08, 2015 at 01:32:05PM -0700, 'Christoph Hellwig' wrote:
>> On Wed, Jul 08, 2015 at 01:08:42PM -0600, Jason Gunthorpe wrote:
>>> Then, what is left is all remote MRs and maybe it will be clearer what
>>> to do about them then...
>>
>>  From looking at that for a while the APIs needed seem pretty simple
>> to me from a consumer perspective:
>>
>> struct rdma_mr *rmda_alloc_mr(struct ib_pd *pd, unsigned int nr_pages);
>> void rdma_free_mr(struct rdma_mr *mr);
>
> The major trouble with that is that the new MR types work by posting
> work to the send queue, that work creates the MR.
>
> I don't know all the details of how those schemes work, but it doesn't
> look like it fits into this model ?
>
> Maybe if rdma_register_sg was the only API and it accepted a QP, under
> the hood it could re-use a pooled/create a non-queued (F)MR, or issue
> FRMR, or work with indirect?

I think it's confusing to possibly do completely different registration
methods which has different implications on the consumer RDMA channel.

>
> It would be nice if it is that simple :)

It can be simple if we consolidate on a single method.

>
> Sagi, are FMRs, FRMRs and Indirect MRs documented any place? I can't
> recall off hand if FRMR was ever published by the IBTA?

I don't know if FMRs are in IBTA.
FRMRs are in under 10.6.3.7 FAST REGISTRATION (vol 1)
