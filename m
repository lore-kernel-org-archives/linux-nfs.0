Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37656 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbbKXOkk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 09:40:40 -0500
Received: by wmww144 with SMTP id w144so29269390wmw.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2015 06:40:22 -0800 (PST)
Subject: Re: [PATCH v1 3/9] xprtrdma: Introduce ro_unmap_sync method
To: Tom Talpey <tom@talpey.com>, Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221414.32702.87638.stgit@manet.1015granger.net>
 <20151124064556.GA29141@infradead.org> <565442F5.7080400@dev.mellanox.co.il>
 <5654697E.1030809@talpey.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sagi Grimberg <sagig@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <565476D0.3020607@dev.mellanox.co.il>
Date: Tue, 24 Nov 2015 16:40:16 +0200
MIME-Version: 1.0
In-Reply-To: <5654697E.1030809@talpey.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Tom,

> On 11/24/2015 5:59 AM, Sagi Grimberg wrote:
>> As I see it, if we don't wait for local-invalidate to complete before
>> unmap and IO completion (and no one does)
>
> For the record, that is false. Windows quite strictly performs these
> steps,

I meant Linux ULPs. I'm not very familiar with Windows SMBD.

> and deliver millions of real 4K IOPS over SMB Direct.

That's very encouraging! Is this the client side scaling?
 From my experience, getting a storage client/initiator to scale
up to 1.5-3 MIOPs over a single HCA with limited number of cores
is really a struggle for each interrupt and cacheline.

Still the latency of each IO will see a noticable increase.

>> Waiting for local invalidate to complete would be a really big
>> sacrifice for our storage ULPs.
>
> Not waiting would also be a sacrifice, by compromising data integrity.
> It's a tough tradeoff, but if you choose to go that way it will be
> critical to be honest about the consequences to the data.

That's true. I assume that the best compromise would be remote
invalidation but some standards needs enhancements and it doesn't solve
the multi-rkey transactions.

As storage devices are becoming faster we really should try to do our
best to keep up.
