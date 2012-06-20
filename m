Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965Ab2FTRRd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 13:17:33 -0400
Message-ID: <4FE2056B.3070407@redhat.com>
Date: Wed, 20 Jun 2012 13:16:27 -0400
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
Subject: Re: [PATCH 09/12] nfs: disable data cache revalidation for swapfiles
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> The VM does not like PG_private set on PG_swapcache pages. As suggested
> by Trond in http://lkml.org/lkml/2006/8/25/348, this patch disables
> NFS data cache revalidation on swap files.  as it does not make
> sense to have other clients change the file while it is being used as
> swap. This avoids setting PG_private on swap pages, since there ought
> to be no further races with invalidate_inode_pages2() to deal with.
>
> Since we cannot set PG_private we cannot use page->private which
> is already used by PG_swapcache pages to store the nfs_page. Thus
> augment the new nfs_page_find_request logic.
>
> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

