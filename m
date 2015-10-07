Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0085.outbound.protection.outlook.com ([65.55.169.85]:56767
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754644AbbJGQpk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2015 12:45:40 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Christoph Hellwig <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>
References: <560AE099.2080004@sandisk.com>
 <560AFB71.3010003@dev.mellanox.co.il> <560C30F4.50900@sandisk.com>
 <560C42CE.6090000@sandisk.com> <560CDDBC.8000400@dev.mellanox.co.il>
 <560D730C.9000302@sandisk.com> <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com> <56138854.4040209@dev.mellanox.co.il>
 <20151007092024.GA18020@infradead.org>
CC: Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5615489E.2050307@sandisk.com>
Date: Wed, 7 Oct 2015 09:30:22 -0700
MIME-Version: 1.0
In-Reply-To: <20151007092024.GA18020@infradead.org>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/07/2015 02:20 AM, Christoph Hellwig wrote:
> On Tue, Oct 06, 2015 at 11:37:40AM +0300, Sagi Grimberg wrote:
>> The issue is that the device requires the MR page array to have
>> an alignment (0x40 for mlx4 and 0x400 for mlx5). When I modified the
>> page array allocation to be non-coherent I didn't take care of
>> alignment.
>
> Just curious:  why did you switch away from the coheret dma allocations
> anyway?  Seems like the page lists are mapped as long as they are
> allocated so the coherent allocator would seem like a nice fit.

Hello Christoph,

My concern is that caching and/or write combining might be disabled for 
DMA coherent memory regions. This is why I assume that calling 
dma_map_single() and dma_unmap_single() will be faster for registering 
multiple pages as a single memory region instead of using DMA coherent 
memory.

Bart.
