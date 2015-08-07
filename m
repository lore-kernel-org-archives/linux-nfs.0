Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33470 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbbHGPNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 11:13:21 -0400
Date: Fri, 7 Aug 2015 08:13:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Doug Ledford'" <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, target-devel@vger.kernel.org
Subject: Re: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
Message-ID: <20150807151318.GA13777@infradead.org>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
 <1438241568-3685-12-git-send-email-sagig@mellanox.com>
 <003301d0d122$a1e46ee0$e5ad4ca0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <003301d0d122$a1e46ee0$e5ad4ca0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 07, 2015 at 10:06:26AM -0500, Steve Wise wrote:
> If it is too much of a pain to alter this patch, then I'll just
> submit the NFSRDMA fix and live with the bisect issue...

Doug's tree is still to be rebased.  So please submit your NFS
fix now as ask Doug to merge it before Sagi's series in the final
tree.
