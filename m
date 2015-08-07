Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54680 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932267AbbHGQb4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 12:31:56 -0400
Date: Fri, 7 Aug 2015 09:31:54 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Doug Ledford'" <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, target-devel@vger.kernel.org
Subject: Re: [PATCH for-4.3 11/15] iw_cxgb4: Support ib_alloc_mr verb
Message-ID: <20150807163154.GA1590@infradead.org>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
 <1438241568-3685-12-git-send-email-sagig@mellanox.com>
 <003301d0d122$a1e46ee0$e5ad4ca0$@opengridcomputing.com>
 <20150807151318.GA13777@infradead.org>
 <003a01d0d12c$e84b4e80$b8e1eb80$@opengridcomputing.com>
 <20150807162615.GA16851@infradead.org>
 <003c01d0d12e$31a879d0$94f96d70$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <003c01d0d12e$31a879d0$94f96d70$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 07, 2015 at 11:29:12AM -0500, Steve Wise wrote:
> I misspoke.  I had the order reversed. The order is such that we can add my new NFS patch after:
> 
> e20684a xprtrdma, svcrdma: Convert to ib_alloc_mr
> 
> and before these:
> 
> af78181 cxgb3: Support ib_alloc_mr verb
> b7e06cd iw_cxgb4: Support ib_alloc_mr verb

In general it would be preferable to have it before the ib_alloc_mr
conversion, but if it causes more work I doubt it's really worth it.
