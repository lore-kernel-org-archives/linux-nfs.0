Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:43987 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932806AbcFGWBJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2016 18:01:09 -0400
Date: Tue, 7 Jun 2016 16:01:07 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
Message-ID: <20160607220107.GA9982@obsidianresearch.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
 <20160607194732.18401.71941.stgit@manet.1015granger.net>
 <20160607204941.GA7991@obsidianresearch.com>
 <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com>
 <20160607212831.GA9192@obsidianresearch.com>
 <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 07, 2016 at 05:51:04PM -0400, Chuck Lever wrote:

> There is a practical number of MRs that can be allocated
> per device, I thought. And each MR consumes some amount
> of host memory.
 
> xprtrdma is happy to allocate thousands of MRs per QP/PD
> pair, but that isn't practical as you start adding more
> transports/connections.

Yes, this is all sane and valid.

Typically you'd target a concurrency limit per QP and allocate
everything (# MRs, sq,rq,cq depth, etc) in accordance with that goal,
I'd also suggest that target concurrency is probably a user tunable..

Jason
