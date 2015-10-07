Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45763 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbJGJU1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 05:20:27 -0400
Date: Wed, 7 Oct 2015 02:20:24 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v1 00/24] New fast registration API
Message-ID: <20151007092024.GA18020@infradead.org>
References: <560AE099.2080004@sandisk.com>
 <560AFB71.3010003@dev.mellanox.co.il>
 <560C30F4.50900@sandisk.com>
 <560C42CE.6090000@sandisk.com>
 <560CDDBC.8000400@dev.mellanox.co.il>
 <560D730C.9000302@sandisk.com>
 <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com>
 <56138854.4040209@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56138854.4040209@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 06, 2015 at 11:37:40AM +0300, Sagi Grimberg wrote:
> The issue is that the device requires the MR page array to have
> an alignment (0x40 for mlx4 and 0x400 for mlx5). When I modified the
> page array allocation to be non-coherent I didn't take care of
> alignment.

Just curious:  why did you switch away from the coheret dma allocations
anyway?  Seems like the page lists are mapped as long as they are
allocated so the coherent allocator would seem like a nice fit.
