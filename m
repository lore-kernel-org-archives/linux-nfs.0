Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34536 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbbGZQt1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 12:49:27 -0400
Date: Sun, 26 Jul 2015 09:49:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 01/15] xprtrdma: Make xprt_setup_rdma() agnostic to
 family of server address
Message-ID: <20150726164926.GA9273@infradead.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190233.10997.29445.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150720190233.10997.29445.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 20, 2015 at 03:02:33PM -0400, Chuck Lever wrote:
> In particular, recognize when an IPv6 connection is bound.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
