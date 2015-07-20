Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-07.prod.phx3.secureserver.net ([173.201.193.236]:34670
	"EHLO p3plsmtpa09-07.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752290AbbGTVyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 17:54:46 -0400
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
To: Chuck Lever <chuck.lever@oracle.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
 <55AD5B48.3010906@talpey.com>
 <06BCEDB0-1589-454B-BDD1-9937290AAD29@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <55AD6E43.60205@talpey.com>
Date: Mon, 20 Jul 2015 14:55:15 -0700
MIME-Version: 1.0
In-Reply-To: <06BCEDB0-1589-454B-BDD1-9937290AAD29@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/20/2015 1:55 PM, Chuck Lever wrote:
> On Jul 20, 2015, at 4:34 PM, Tom Talpey <tom@talpey.com> wrote:
>
>> On 7/20/2015 12:03 PM, Chuck Lever wrote:
>>> All HCA providers have an ib_get_dma_mr() verb. Thus
>>> rpcrdma_ia_open() will either grab the device's local_dma_key if one
>>> is available, or it will call ib_get_dma_mr() which is a 100%
>>> guaranteed fallback.
>>
>> I recall that in the past, some providers did not support mapping
>> all of the machine's potential physical memory with a single dma_mr.
>> If an rnic did/does not support 44-ish bits of length per region,
>> for example.
>
> The buffers affected by this change are small, so I’m confident that
> restriction would not be a problem here.

It's not about the buffer size, it's about the region. Because the
get_dma_mr does not specify a base address and length, the rnic must
basically attempt to map a base of zero and a length of the largest
physical offset.

This is not the case with the previous phys_reg_mr, which specified
the exact phys page range.

> What might break with such restricted hardware is ALLPHYSICAL on
> large-memory systems. ALLPHYSICAL does rely on a single DMA MR that
> covers all of the NFS client’s memory.

Yes, indeed it always did, but that mode was not intended for general
use.

