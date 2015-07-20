Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:55864 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbbGTWyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jul 2015 18:54:21 -0400
Date: Mon, 20 Jul 2015 16:54:14 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Tom Talpey'" <tom@talpey.com>, "'Chuck Lever'" <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Message-ID: <20150720225414.GA12442@obsidianresearch.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
 <55AD5B48.3010906@talpey.com>
 <20150720210544.GA9655@obsidianresearch.com>
 <015501d0c334$3f1c2830$bd547890$@opengridcomputing.com>
 <20150720221333.GA11356@obsidianresearch.com>
 <015e01d0c33d$82b44ce0$881ce6a0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <015e01d0c33d$82b44ce0$881ce6a0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 20, 2015 at 05:43:34PM -0500, Steve Wise wrote:
> > Yah, that seems much better.. With the patch set I am working on this
> > will mean all ULPs will fail to create a kernel PD on cxgb3 if the
> > above triggers. If our error handling works that should just make it
> > unuable from kernel space which is what we need to see..

> What about user PDs?  We need that to work for cxgb3.

Only in-kernel uses call ib_alloc_pd

The user flow calls ib_uverbs_alloc_pd which calls the driver
directly.

Jason
