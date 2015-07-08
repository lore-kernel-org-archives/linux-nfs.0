Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55731 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933113AbbGHUhS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 16:37:18 -0400
Date: Wed, 8 Jul 2015 13:37:13 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150708203713.GA21351@infradead.org>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150708203205.GA21847@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 01:32:05PM -0700, 'Christoph Hellwig' wrote:
> /* updates *sg if the SG couldn't be fully registered due to offsets */
> int rdma_register_sg(struct rdma_mr *mr, struct scatterlist **sg,
> 		u32 *pkey, u32 *offset, u32 *len);

plus an "enum dma_data_direction direction" of course.

