Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54204 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525Ab2FTOVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 10:21:31 -0400
Date: Wed, 20 Jun 2012 15:21:27 +0100
From: Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
Message-ID: <20120620142127.GK4011@suse.de>
References: <1340185081-22525-1-git-send-email-mgorman@suse.de>
 <1340185081-22525-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <1340185081-22525-2-git-send-email-mgorman@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 20, 2012 at 10:37:50AM +0100, Mel Gorman wrote:
> It could happen that all !SOCK_MEMALLOC sockets have buffered so
> much data that we're over the global rmem limit. This will prevent
> SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
> from running, which is needed to reduce the buffered data.
> 
> Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
> Once this change it applied, it is important that sockets that set
> SOCK_MEMALLOC do not clear the flag until the socket is being torn down.
> If this happens, a warning is generated and the tokens reclaimed to
> avoid accounting errors until the bug is fixed.
> 
> [davem@davemloft.net: Warning about clearing SOCK_MEMALLOC]
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: David S. Miller <davem@davemloft.net>

This patch introduced a new warning that I had previously missed. I'll
fix it up when rebasing this series on top of linux-next.

-- 
Mel Gorman
SUSE Labs
