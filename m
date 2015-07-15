Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36284 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbGOHKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 03:10:08 -0400
Received: by wgxm20 with SMTP id m20so25567120wgx.3
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2015 00:10:07 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com>
 <55A00754.4010009@redhat.com> <55A01225.9000000@talpey.com>
 <20150710195420.GA31500@obsidianresearch.com>
 <20150711101736.GA14741@infradead.org>
 <20150713165748.GE23832@obsidianresearch.com>
 <20150714072536.GA7630@infradead.org> <55A4D0F1.7000909@dev.mellanox.co.il>
 <20150714172655.GB24403@obsidianresearch.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        Doug Ledford <dledford@redhat.com>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A6074A.7080002@dev.mellanox.co.il>
Date: Wed, 15 Jul 2015 10:10:02 +0300
MIME-Version: 1.0
In-Reply-To: <20150714172655.GB24403@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 8:26 PM, Jason Gunthorpe wrote:
> On Tue, Jul 14, 2015 at 12:05:53PM +0300, Sagi Grimberg wrote:
>
>> iser has it too. I have a similar patch with a flag for iser (its
>> behind a bulk of patches that are still pending though).
>
> Do we all agree and understand that stuff like this in
>
> drivers/infiniband/ulp/iser/iser_verbs.c
>
>          device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE |
>                                     IB_ACCESS_REMOTE_WRITE |
>                                     IB_ACCESS_REMOTE_READ);
>
> Represents a significant security risk to the machine, and must be
> off be default?
>
> Can you take care of fixing this for iser?

I will. It is part of a patchset I have to support remote
invalidate in iser and isert.

Sagi.
