Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60042 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932157AbbFBMg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2015 08:36:28 -0400
Date: Tue, 2 Jun 2015 13:36:23 +0100
From: Mel Gorman <mgorman@suse.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Jerome Marchand <jmarchan@redhat.com>
Subject: Re: [PATCH 1/4] sunrpc: keep a count of swapfiles associated with
 the rpc_clnt
Message-ID: <20150602123623.GE26425@suse.de>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
 <1432987393-15604-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <1432987393-15604-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 30, 2015 at 08:03:10AM -0400, Jeff Layton wrote:
> Jerome reported seeing a warning pop when working with a swapfile on
> NFS. The nfs_swap_activate can end up calling sk_set_memalloc while
> holding the rcu_read_lock and that function can sleep.
> 
> To fix that, we need to take a reference to the xprt while holding the
> rcu_read_lock, set the socket up for swapping and then drop that
> reference. But, xprt_put is not exported and having NFS deal with the
> underlying xprt is a bit of layering violation anyway.
> 
> Fix this by adding a set of activate/deactivate functions that take a
> rpc_clnt pointer instead of an rpc_xprt, and have nfs_swap_activate and
> nfs_swap_deactivate call those.
> 
> Also, add a per-rpc_clnt atomic counter to keep track of the number of
> active swapfiles associated with it. When the counter does a 0->1
> transition, we enable swapping on the xprt, when we do a 1->0 transition
> we disable swapping on it.
> 
> This also allows us to be a bit more selective with the RPC_TASK_SWAPPER
> flag. If non-swapper and swapper clnts are sharing a xprt, then we only
> need to flag the tasks from the swapper clnt with that flag.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Reported-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs
