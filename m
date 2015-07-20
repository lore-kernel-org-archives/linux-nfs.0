Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:38371 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbbGTWmt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jul 2015 18:42:49 -0400
Date: Mon, 20 Jul 2015 16:42:44 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Tom Talpey'" <tom@talpey.com>, "'Chuck Lever'" <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Message-ID: <20150720224244.GB12278@obsidianresearch.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
 <55AD5B48.3010906@talpey.com>
 <20150720210544.GA9655@obsidianresearch.com>
 <015101d0c331$69e31d10$3da95730$@opengridcomputing.com>
 <55AD7065.8040809@talpey.com>
 <015701d0c33d$36b53110$a41f9330$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <015701d0c33d$36b53110$a41f9330$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 20, 2015 at 05:41:27PM -0500, Steve Wise wrote:
> > B) why bother to check? Are machines with <4GB interesting, and worth
> > supporting a special optimization?
> 
> No, but cxgb3 is still interesting to user applications, and perhaps NFSRDMA using FRMRs.

Doesn't look like the NFS client will work. It requires an all
physical memory lkey for SEND and RECV buffers..

Jason
