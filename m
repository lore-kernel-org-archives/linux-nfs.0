Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:57270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab2EKFLw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 01:11:52 -0400
Date: Fri, 11 May 2012 01:10:34 -0400 (EDT)
Message-Id: <20120511.011034.557833140906762226.davem@davemloft.net>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond.Myklebust@netapp.com, neilb@suse.de, hch@infradead.org,
        a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336658065-24851-2-git-send-email-mgorman@suse.de>
References: <1336658065-24851-1-git-send-email-mgorman@suse.de>
	<1336658065-24851-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:54:14 +0100

> It could happen that all !SOCK_MEMALLOC sockets have buffered so
> much data that we're over the global rmem limit. This will prevent
> SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
> from running, which is needed to reduce the buffered data.
> 
> Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

This introduces an invariant which I am not so sure is enforced.

With this change it is absolutely required that once a socket
becomes SOCK_MEMALLOC it must never _ever_ lose that attribute.

Otherwise we can end up liberating global rmem tokens which we never
actually took.
