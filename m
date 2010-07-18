Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54677 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab0GRJGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jul 2010 05:06:41 -0400
Date: Sun, 18 Jul 2010 05:06:37 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] pnfs-block: move device mapping from kernel to user
 daemon
Message-ID: <20100718090637.GA24960@infradead.org>
References: <cover.1279221394.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1279221394.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>  10 files changed, 720 insertions(+), 712 deletions(-)

While it's good that this cruft goes away from the kernel the diffstat
is a bit disappointing.

Also you can now remove the block_class export that was added for pNFS.

