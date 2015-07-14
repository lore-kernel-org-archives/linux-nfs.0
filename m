Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:35545 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbbGNR1C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 13:27:02 -0400
Date: Tue, 14 Jul 2015 11:26:55 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: "'Christoph Hellwig'" <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        Doug Ledford <dledford@redhat.com>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714172655.GB24403@obsidianresearch.com>
References: <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <55A00754.4010009@redhat.com>
 <55A01225.9000000@talpey.com>
 <20150710195420.GA31500@obsidianresearch.com>
 <20150711101736.GA14741@infradead.org>
 <20150713165748.GE23832@obsidianresearch.com>
 <20150714072536.GA7630@infradead.org>
 <55A4D0F1.7000909@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A4D0F1.7000909@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 12:05:53PM +0300, Sagi Grimberg wrote:

> iser has it too. I have a similar patch with a flag for iser (its
> behind a bulk of patches that are still pending though).

Do we all agree and understand that stuff like this in

drivers/infiniband/ulp/iser/iser_verbs.c

        device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE |
                                   IB_ACCESS_REMOTE_WRITE |
                                   IB_ACCESS_REMOTE_READ);

Represents a significant security risk to the machine, and must be
off be default?

Can you take care of fixing this for iser?

Thanks,
Jason
