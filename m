Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:35891 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbcFXT06 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jun 2016 15:26:58 -0400
Date: Fri, 24 Jun 2016 13:26:37 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Wise <swise@opengridcomputing.com>, Raju Rangoju <rajur@chelsio.com>,
        linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: Interrupted IO causing async errors
Message-ID: <20160624192637.GE14506@obsidianresearch.com>
References: <00e101d1cd65$e19bf360$a4d3da20$@opengridcomputing.com>
 <BDD2D64C-7A05-42EB-83C2-F95825C7579D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BDD2D64C-7A05-42EB-83C2-F95825C7579D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 23, 2016 at 08:15:29PM -0400, Chuck Lever wrote:
> When an application is signaled, outstanding RPCs are terminated.
> When an RPC completes, whether because a reply was received,
> or because the local application has died, any memory that was
> registered on behalf of that RPC is invalidated before it can be
> used for something else. The data in that memory remains at rest
> until invalidation and DMA unmapping is complete.

> It appears that your server is attempting to read an argument or
> write a result for an RPC that is no longer pending. I think both
> sides should report a transport error, and the connection should
> terminate. No other problems, though: other operation should
> continue normally after the client re-establishes a fresh connection.

Yuk! A transport tare down and restart on user space CTRL-C/etc ?
Isn't that a little too common and a little too expensive to be a
permanent solution?

Jason
