Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41375 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655AbbGZKmV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 06:42:21 -0400
Date: Sun, 26 Jul 2015 03:42:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: [PATCH V6 4/9] svcrdma: Use max_sge_rd for destination read
 depths
Message-ID: <20150726104214.GA18944@infradead.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161837.25617.48584.stgit@build2.ogc.int>
 <00d301d0c641$c2fcb6a0$48f623e0$@opengridcomputing.com>
 <55B4AF63.3040108@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B4AF63.3040108@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 26, 2015 at 12:58:59PM +0300, Sagi Grimberg wrote:
> >With the above patch change, we have no more users of the recently created rdma_cap_read_multi_sge().  Should I add a patch to remove it?
> 
> Yes please.

And in the long run this is another argument for killing the system-wide
REMOTE_WRITE phys MR and require memory registrations for iWarp..
