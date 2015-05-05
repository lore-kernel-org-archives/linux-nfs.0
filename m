Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59713 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993449AbbEEPoM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 11:44:12 -0400
Date: Tue, 5 May 2015 08:44:11 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
Message-ID: <20150505154411.GA16729@infradead.org>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 13, 2015 at 05:21:17PM -0400, Chuck Lever wrote:
> This is a series of client-side patches for NFS/RDMA. In preparation
> for increasing the transport credit limit and maximum rsize/wsize,
> I've re-factored the memory registration logic into separate files,
> invoked via a method API.

Just curious if you ever though of moving this into the generic
rdma layer?

I've been working on a rdma based storage driver recently, and the
various different memory registration methods are a complete pain in the
ass, and impossible to test in and ULD without havin access to all kinds
of different hardware.

And from I see we litterly dont use them much different from the generic
dma mapping API helpers (at a very high level) so it seems it should
be easy to move a slightly expanded version of your API to the core
code.
