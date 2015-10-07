Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42521 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbbJGJgs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 05:36:48 -0400
Date: Wed, 7 Oct 2015 02:36:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Christoph Hellwig <hch@infradead.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v1 00/24] New fast registration API
Message-ID: <20151007093645.GA6940@infradead.org>
References: <560C30F4.50900@sandisk.com>
 <560C42CE.6090000@sandisk.com>
 <560CDDBC.8000400@dev.mellanox.co.il>
 <560D730C.9000302@sandisk.com>
 <560D9E69.70604@sandisk.com>
 <35618B90-4D6E-4036-A69B-4405F020D440@dev.mellanox.co.il>
 <560EA4A1.3080709@sandisk.com>
 <56138854.4040209@dev.mellanox.co.il>
 <20151007092024.GA18020@infradead.org>
 <5614E505.7090808@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5614E505.7090808@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 07, 2015 at 12:25:25PM +0300, Sagi Grimberg wrote:
> Bart suggested that having to sync once for the entire page list might
> perform better than coherent memory. I'll settle either way since using
> non-coherent memory might cause higher-order allocations due to
> alignment, so it's not free-of-charge.

I don't really care either way, it just seemed like an odd change hiding
in here that I missed when reviewing earlier.
