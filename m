Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35860 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932672AbbGHH3r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 03:29:47 -0400
Received: by wgxm20 with SMTP id m20so4160314wgx.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 00:29:45 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
 <559A340E.9000000@dev.mellanox.co.il>
 <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
Cc: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559CD174.4040901@dev.mellanox.co.il>
Date: Wed, 8 Jul 2015 10:29:56 +0300
MIME-Version: 1.0
In-Reply-To: <20150707213628.GA5661@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/8/2015 12:36 AM, Jason Gunthorpe wrote:
> On Tue, Jul 07, 2015 at 07:27:47PM +0300, Sagi Grimberg wrote:
>
>> Doesn't it look odd to you?
>
> Sure, but the oddness is that rdma_device_access_flags exists at all,
> not the wrapper. The wrapper is what we want the API to look like,

I don't necessarily agree. The API we'd want is a single API at all
the call sites to all types of MRs. We have different QP types, and
still we don't have an allocation API for each and every one.
I honestly don't see why we have that for MRs.

If we can converge to a single API for MR allocation we can just get it
right once.

> if we could trivially change the WR format as well then
> rdma_device_access_flags wouldn't even exist at all.

I have taken some time to truly think about that following Christoph's
comments to my indirect registration patches. This is one of the things
I'm looking at.
