Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214Ab2FTRsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 13:48:15 -0400
Message-ID: <4FE20C97.2060401@redhat.com>
Date: Wed, 20 Jun 2012 13:47:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
To: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 12/12] Avoid dereferencing bd_disk during swap_entry_free
 for network storage
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-13-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2012 05:38 AM, Mel Gorman wrote:
> Commit [b3a27d: swap: Add swap slot free callback to
> block_device_operations] dereferences p->bdev->bd_disk but this is a
> NULL dereference if using swap-over-NFS. This patch checks SWP_BLKDEV
> on the swap_info_struct before dereferencing.
>
> With reference to this callback, Christoph Hellwig stated "Please
> just remove the callback entirely.  It has no user outside the staging
> tree and was added clearly against the rules for that staging tree".
> This would also be my preference but there was not an obvious way of
> keeping zram in staging/ happy.
>
> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

