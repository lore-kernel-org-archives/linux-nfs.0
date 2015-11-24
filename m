Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-09.prod.phx3.secureserver.net ([68.178.252.110]:34779
	"EHLO p3plsmtpa11-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752225AbbKXNn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 08:43:29 -0500
Subject: Re: [PATCH v1 3/9] xprtrdma: Introduce ro_unmap_sync method
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221414.32702.87638.stgit@manet.1015granger.net>
 <20151124064556.GA29141@infradead.org> <565442F5.7080400@dev.mellanox.co.il>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sagi Grimberg <sagig@mellanox.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <5654697E.1030809@talpey.com>
Date: Tue, 24 Nov 2015 08:43:26 -0500
MIME-Version: 1.0
In-Reply-To: <565442F5.7080400@dev.mellanox.co.il>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/24/2015 5:59 AM, Sagi Grimberg wrote:
> As I see it, if we don't wait for local-invalidate to complete before
> unmap and IO completion (and no one does)

For the record, that is false. Windows quite strictly performs these
steps, and deliver millions of real 4K IOPS over SMB Direct.

> Waiting for local invalidate to complete would be a really big
> sacrifice for our storage ULPs.

Not waiting would also be a sacrifice, by compromising data integrity.
It's a tough tradeoff, but if you choose to go that way it will be
critical to be honest about the consequences to the data.

Tom.
