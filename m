Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34880 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbbJGJZb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 05:25:31 -0400
Received: by lbwr8 with SMTP id r8so6249447lbw.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 02:25:30 -0700 (PDT)
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Christoph Hellwig <hch@infradead.org>
References: <560AE099.2080004@sandisk.com>
 <560AFB71.3010003@dev.mellanox.co.il> <560C30F4.50900@sandisk.com>
 <560C42CE.6090000@sandisk.com> <560CDDBC.8000400@dev.mellanox.co.il>
 <560D730C.9000302@sandisk.com> <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com> <56138854.4040209@dev.mellanox.co.il>
 <20151007092024.GA18020@infradead.org>
Cc: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5614E505.7090808@dev.mellanox.co.il>
Date: Wed, 7 Oct 2015 12:25:25 +0300
MIME-Version: 1.0
In-Reply-To: <20151007092024.GA18020@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/7/2015 12:20 PM, Christoph Hellwig wrote:
> On Tue, Oct 06, 2015 at 11:37:40AM +0300, Sagi Grimberg wrote:
>> The issue is that the device requires the MR page array to have
>> an alignment (0x40 for mlx4 and 0x400 for mlx5). When I modified the
>> page array allocation to be non-coherent I didn't take care of
>> alignment.
>
> Just curious:  why did you switch away from the coheret dma allocations
> anyway?  Seems like the page lists are mapped as long as they are
> allocated so the coherent allocator would seem like a nice fit.
>

Bart suggested that having to sync once for the entire page list might
perform better than coherent memory. I'll settle either way since using
non-coherent memory might cause higher-order allocations due to
alignment, so it's not free-of-charge.

Sagi.
