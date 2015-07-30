Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36613 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbbG3Nxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:53:43 -0400
Date: Thu, 30 Jul 2015 06:53:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@mellanox.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: Re: [PATCH for-4.3 00/15] Modify MR allocation API
Message-ID: <20150730135343.GA6345@infradead.org>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 10:32:33AM +0300, Sagi Grimberg wrote:
> This patch set is detached from my WIP for modifying our
> fast registration kernel API. I incorporated some comments
> from Jason and Christoph. The current set is a drop-in replacement
> of ib_alloc_fast_reg_mr to ib_alloc_mr which receives a memory
> region type (whcih can be IB_MR_TYPE_MEM_REG for normal memory
> registration, IB_MR_TYPE_SIGNATURE for a data-integrity capable
> memory region and future arbitrary SG support capable memory
> region).

While this series doesn't get us much yet it looks reasonable.
So let's start small and get this one in.
