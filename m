Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33149 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482AbbGGQ1f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jul 2015 12:27:35 -0400
Received: by wiwl6 with SMTP id l6so319982871wiw.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jul 2015 09:27:34 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
 <559A340E.9000000@dev.mellanox.co.il>
 <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559BFE03.4020709@dev.mellanox.co.il>
Date: Tue, 7 Jul 2015 19:27:47 +0300
MIME-Version: 1.0
In-Reply-To: <20150707161751.GA623@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/7/2015 7:17 PM, Jason Gunthorpe wrote:
> On Tue, Jul 07, 2015 at 09:05:15AM -0500, Steve Wise wrote:
>
>> I took the feedback from Christoph and Jason to mean I should remove
>> ib_get_dma_mr() entirely and pull its guts into rdma_get_dma_mr(),
>> and change all the users of ib_get_dma_mr() to use
>> rdma_get_dma_mr().  So the net result isn't a wrapper.  It would of
>> course still use rdma_device_access_flags()...
>
> Right, to the greatest extent possible.
>
> Keeping ib_get_dma_mr and the old flags around just means someone
> could go back and use the old flags.

It looks strange to me that there is a helper to get a transport
independent access_flags rdma_device_access_flags() that helps the
user to choose the correct access_flags for MR creation and fast
registration (which is more than OK), and having a wrapper that just
hides it from the user...

Doesn't it look odd to you?

>
> I expect well need to keep the driver entry point for user space, but
> we should be able to hide the API and flags from other modules.

dma_mr for user-space?? How can this be relevant for user-space?

>
> A wrapper is a reasonable way to stage through that transition..

I can't say that I completely agree here.

Sagi.
