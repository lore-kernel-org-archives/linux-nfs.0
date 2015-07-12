Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53986 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbGLH6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 03:58:19 -0400
Date: Sun, 12 Jul 2015 00:58:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 04/12] xprtrdma: Remove last ib_reg_phys_mr() call site
Message-ID: <20150712075814.GA6636@infradead.org>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204218.26247.67243.stgit@manet.1015granger.net>
 <20150711103428.GD14741@infradead.org>
 <682604AF-955A-44F8-86F9-EB7D403CABFF@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <682604AF-955A-44F8-86F9-EB7D403CABFF@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 11, 2015 at 02:50:58PM -0400, Chuck Lever wrote:
> I would prefer to run this by Doug Oucharek first, as a courtesy.
> Unless I???m mistaken, the Lustre client is supposed to be on its
> way into the kernel, not on its way out.

The only way a mess like lustre got into the kernel tree at all is
because the rules allow ignoring the staging tree for API changes,
otherwise kernel development wouldn't scale.  Lustre isn't really
on the way in, it's been in the staging tree forever and has made
zero progress towards actually being maintainable code.
