Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53318 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbbGJWoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 18:44:13 -0400
Date: Fri, 10 Jul 2015 16:44:02 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Devesh Sharma <devesh.sharma@avagotech.com>, Tom Talpey <tom@talpey.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v1 09/12] xprtrdma: Prepare rpcrdma_ep_post() for
 RDMA_NOMSG calls
Message-ID: <20150710224402.GA8342@obsidianresearch.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204305.26247.39173.stgit@manet.1015granger.net>
 <CANjDDBh38PrxGgWGuKYCYcbjqY9ELrpkGqaRZ_ueKfD7FEQP8g@mail.gmail.com>
 <559FC17A.7060502@talpey.com>
 <CANjDDBipaXMO7Z5wirG127E9kQ0aHdWJ1s6ZM21th5RWLNh-4Q@mail.gmail.com>
 <F5F5CAC4-866E-4BCA-8094-908CE9ED3B4B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F5F5CAC4-866E-4BCA-8094-908CE9ED3B4B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 10:53:40AM -0400, Chuck Lever wrote:

> It is certainly possible to examine the device’s max_sge field
> in rpcrdma_ep_create() and fail transport creation if the
> device’s max_sge is less than RPC_MAX_IOVS.

I just want to draw Sagi's attention to this problem, when considering
my thoughts on an alternate API for posting.

This thread is about NFS needing 4 sges for a (rare?) message type.

The API direction I suggested addresses this kind of issue as well,
because under the covers the driver/core can spin up a temporary MR
for this case and thus support an infinite s/g list for all posts.

Jason
