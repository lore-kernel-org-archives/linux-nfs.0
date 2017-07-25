Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33642 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdGYPzX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jul 2017 11:55:23 -0400
Received: by mail-qt0-f178.google.com with SMTP id a18so12584455qta.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jul 2017 08:55:23 -0700 (PDT)
Message-ID: <1500998120.27030.0.camel@redhat.com>
Subject: Re: [PATCH 00/20] Reducing inode->i_lock contention in writebacks
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Tue, 25 Jul 2017 11:55:20 -0400
In-Reply-To: <20170719220955.58210-1-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-07-19 at 18:09 -0400, Trond Myklebust wrote:
> Chuck Lever has presented measurements, that would appear to indicate that
> the inode->i_lock can be a source of contention when doing writeback using
> high performance networks. This patch series is therefore an attempt to
> address the sources of contention that his measurements pointed to.
> 
> According to Chuck's table, the main sources of contention appear to
> be in nfs_flush_incompatible(), nfs_lock_and_join_requests() and
> nfs_updatepage(). Most of this patch series focuses on fixing
> nfs_lock_and_join_requests(), since it holds the inode lock, while
> taking locks on the page group and the sub-requests themselves,
> rolling them all back if ever there is contention.
> By noting a few simple rules that are mostly already in place, we
> can simplify that locking to ensure that we only have to keep the
> spin lock while we're dereferencing and locking the head page pointer
> that is stored in page_private(page).
> 
> Along the way, the patches also simplify the code a little, and fix
> a number of subtle races which mainly occur when you set wsize to
> some value smaller than the page size. The most notable such race
> occurs between nfs_lock_and_join_requests() and nfs_page_group_destroy(),
> and could lead to a double free() of some of the sub-requests.
> 
> Finally, there are 2 patches tacked onto the end of the series that
> attempt to improve the throttling of writes when the RPC layer is
> congested. They do so by forcing each caller of nfs_initiate_pgio()
> to wait until the request is being transmitted. The expectation is
> that this might help improve latencies when there are several processes
> competing for access to the RPC transport.
> 
> Trond Myklebust (20):
>   NFS: Simplify page writeback
>   NFS: Reduce lock contention in nfs_page_find_head_request()
>   NFS: Reduce lock contention in nfs_try_to_update_request()
>   NFS: Ensure we always dereference the page head last
>   NFS: Fix a reference and lock leak in nfs_lock_and_join_requests()
>   NFS: Fix an ABBA issue in nfs_lock_and_join_requests()
>   NFS: Don't check request offset and size without holding a lock
>   NFS: Don't unlock writebacks before declaring PG_WB_END
>   NFS: Fix the inode request accounting when pages have subrequests
>   NFS: Teach nfs_try_to_update_request() to deal with request
>     page_groups
>   NFS: Remove page group limit in nfs_flush_incompatible()
>   NFS: Reduce inode->i_lock contention in nfs_lock_and_join_requests()
>   NFS: Further optimise nfs_lock_and_join_requests()
>   NFS: Fix nfs_page_group_destroy() and nfs_lock_and_join_requests()
>     race cases
>   NFS: Remove nfs_page_group_clear_bits()
>   NFS: Remove unuse function nfs_page_group_lock_wait()
>   NFS: Remove unused parameter from nfs_page_group_lock()
>   NFS: Fix up nfs_page_group_covers_page()
>   SUNRPC: Add a function to allow waiting for RPC transmission
>   NFS: Throttle I/O to the NFS server
> 
>  fs/nfs/pagelist.c            |  64 +++------
>  fs/nfs/write.c               | 313 ++++++++++++++++++-------------------------
>  include/linux/nfs_page.h     |   3 +-
>  include/linux/sunrpc/sched.h |   3 +
>  net/sunrpc/sched.c           |  22 +++
>  net/sunrpc/xprt.c            |   6 +
>  6 files changed, 177 insertions(+), 234 deletions(-)
> 

Looks good:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
