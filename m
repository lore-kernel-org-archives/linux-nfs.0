Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:45314
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752392Ab1IINDA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 09:03:00 -0400
Date: Fri, 9 Sep 2011 09:02:57 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 10/10] Avoid dereferencing bd_disk during swap_entry_free
 for network storage
Message-ID: <20110909130257.GA15212@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315566054-17209-11-git-send-email-mgorman@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 09, 2011 at 12:00:54PM +0100, Mel Gorman wrote:
> Commit [b3a27d: swap: Add swap slot free callback to
> block_device_operations] dereferences p->bdev->bd_disk but this is a
> NULL dereference if using swap-over-NFS. This patch checks SWP_BLKDEV
> on the swap_info_struct before dereferencing.

Please just remove the callback entirely.  It has no user outside the
staging tree and was added clearly against the rules for that staging
tree.

(and it's butt ugly)

