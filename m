Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22313 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdHCPFE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 11:05:04 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 00/28] Reducing inode->i_lock contention in writebacks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170803134523.4922-1-trond.myklebust@primarydata.com>
Date: Thu, 3 Aug 2017 11:04:58 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <26E54933-A2AB-4F99-9317-0BF300B36A5D@oracle.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 3, 2017, at 9:44 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
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
> v2: Further patches to eliminate use of inode->i_lock to protect the
>    page->private contents.
>    Protect the (large!) list of unstable pages using a dedicated
>    NFS_I(inode)->commit_mutex instead of the inode->i_lock.
> 
> Trond Myklebust (28):
>  NFS: Simplify page writeback
>  NFS: Reduce lock contention in nfs_page_find_head_request()
>  NFS: Reduce lock contention in nfs_try_to_update_request()
>  NFS: Ensure we always dereference the page head last
>  NFS: Fix a reference and lock leak in nfs_lock_and_join_requests()
>  NFS: Fix an ABBA issue in nfs_lock_and_join_requests()
>  NFS: Don't check request offset and size without holding a lock
>  NFS: Don't unlock writebacks before declaring PG_WB_END
>  NFS: Fix the inode request accounting when pages have subrequests
>  NFS: Teach nfs_try_to_update_request() to deal with request
>    page_groups
>  NFS: Remove page group limit in nfs_flush_incompatible()
>  NFS: Reduce inode->i_lock contention in nfs_lock_and_join_requests()
>  NFS: Further optimise nfs_lock_and_join_requests()
>  NFS: Fix nfs_page_group_destroy() and nfs_lock_and_join_requests()
>    race cases
>  NFS: Remove nfs_page_group_clear_bits()
>  NFS: Remove unuse function nfs_page_group_lock_wait()
>  NFS: Remove unused parameter from nfs_page_group_lock()
>  NFS: Fix up nfs_page_group_covers_page()
>  NFSv4: Convert nfs_lock_and_join_requests() to use
>    nfs_page_find_head_request()
>  NFS: Refactor nfs_page_find_head_request()
>  NFSv4: Use a mutex to protect the per-inode commit lists
>  NFS: Use an atomic_long_t to count the number of requests
>  NFS: Use an atomic_long_t to count the number of commits
>  NFS: Switch to using mapping->private_lock for page writeback lookups.
>  NFSv4/pnfs: Replace pnfs_put_lseg_locked() with pnfs_put_lseg()
>  NFS: Wait for requests that are locked on the commit list
>  SUNRPC: Add a function to allow waiting for RPC transmission
>  NFS: Throttle I/O to the NFS server
> 
> fs/nfs/callback_proc.c       |   2 +-
> fs/nfs/delegation.c          |   2 +-
> fs/nfs/direct.c              |   4 +-
> fs/nfs/inode.c               |  10 +-
> fs/nfs/pagelist.c            |  70 +++----
> fs/nfs/pnfs.c                |  41 ----
> fs/nfs/pnfs.h                |   2 -
> fs/nfs/pnfs_nfs.c            |  37 ++--
> fs/nfs/write.c               | 440 ++++++++++++++++++++-----------------------
> include/linux/nfs_fs.h       |   5 +-
> include/linux/nfs_page.h     |   3 +-
> include/linux/nfs_xdr.h      |   2 +-
> include/linux/sunrpc/sched.h |   3 +
> net/sunrpc/sched.c           |  22 +++
> net/sunrpc/xprt.c            |   6 +
> 15 files changed, 295 insertions(+), 354 deletions(-)

Hey Trond, do you have a topic branch somewhere I can pull this?


--
Chuck Lever



