Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57408 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbbI2F7P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 01:59:15 -0400
Date: Mon, 28 Sep 2015 22:59:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v1 01/24] IB/core: Introduce new fast registration API
Message-ID: <20150929055907.GA29758@infradead.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-2-git-send-email-sagig@mellanox.com>
 <5601C65F.8060403@sandisk.com>
 <5603A841.70509@dev.mellanox.co.il>
 <5609A9D0.8030607@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5609A9D0.8030607@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 28, 2015 at 01:57:52PM -0700, Bart Van Assche wrote:
> >Actually I think it doesn't since it is only relevant for the else
> >statement where we are passing the page_size boundary.
> 
> Hello Sagi,
> 
> Suppose that the following sg-list is passed to this function as { offset,
> length } pairs and that this list has not been coalesced by the DMA mapping
> code: [ { 0, page_size / 4 }, { page_size / 4, page_size / 4 }, { 2 *
> page_size / 4, page_size / 2 } ]. I think the algorithm in patch 01/24 will
> map the above sample sg-list onto two pages. Shouldn't that sg-list be
> mapped onto one page instead ?

Shouldn't higher layers take care of this?  Trying to implement the same
coalescing algorithm at various layers isn't very optimal, although we
need to decide and document which one is responsible.
