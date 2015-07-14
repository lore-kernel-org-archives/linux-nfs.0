Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34874 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbbGNJF6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 05:05:58 -0400
Received: by wgjx7 with SMTP id x7so3335967wgj.2
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2015 02:05:57 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: "'Christoph Hellwig'" <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20150709000337.GE16812@obsidianresearch.com>
 <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com>
 <55A00754.4010009@redhat.com> <55A01225.9000000@talpey.com>
 <20150710195420.GA31500@obsidianresearch.com>
 <20150711101736.GA14741@infradead.org>
 <20150713165748.GE23832@obsidianresearch.com>
 <20150714072536.GA7630@infradead.org>
Cc: Tom Talpey <tom@talpey.com>, Doug Ledford <dledford@redhat.com>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A4D0F1.7000909@dev.mellanox.co.il>
Date: Tue, 14 Jul 2015 12:05:53 +0300
MIME-Version: 1.0
In-Reply-To: <20150714072536.GA7630@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 10:25 AM, 'Christoph Hellwig' wrote:
> On Mon, Jul 13, 2015 at 10:57:48AM -0600, Jason Gunthorpe wrote:
>>> Currently various drivers are using ib_get_dma_mr with remote flags
>>> unfortunately, e.g. the SRP initiator driver uses it to optimize away
>>> memory registrtions for single SGL entry requests.
>>
>> Unconditionally? Ugh. Maybe we do need the warn_on :(
>
> There is a "register_always" flag to always use real MRs, but it's
> off by default:
>
> 	if (count == 1 && !register_always) {
> 		/*
> 		 * The midlayer only generated a single gather/scatter
> 		 * entry, or DMA mapping coalesced everything to a
> 		 * single entry. So a direct descriptor along with
> 		 * the DMA MR suffices.
> 		 */
> 		struct srp_direct_buf *buf = (void *) cmd->add_data;
>
> 		buf->va  = cpu_to_be64(ib_sg_dma_address(ibdev, scat));
>                  buf->key = cpu_to_be32(target->rkey);
> 		buf->len = cpu_to_be32(ib_sg_dma_len(ibdev, scat));
>
> 		req->nmdesc = 0;
> 		goto map_complete;
> 	}
>

iser has it too. I have a similar patch with a flag for iser (its
behind a bulk of patches that are still pending though).
