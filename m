Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35891 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751801AbdGYENE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jul 2017 00:13:04 -0400
Received: by mail-it0-f65.google.com with SMTP id r9so7997223ita.3
        for <linux-nfs@vger.kernel.org>; Mon, 24 Jul 2017 21:13:04 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 00/20] Reducing inode->i_lock contention in writebacks
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <20170719220955.58210-1-trond.myklebust@primarydata.com>
Date: Tue, 25 Jul 2017 00:13:01 -0400
Cc: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <E656DD8D-522A-4D8A-BE90-BBB7A57BF3B0@monkey.org>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 19, 2017, at 6:09 PM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:
>=20
> Chuck Lever has presented measurements, that would appear to indicate =
that
> the inode->i_lock can be a source of contention when doing writeback =
using
> high performance networks. This patch series is therefore an attempt =
to
> address the sources of contention that his measurements pointed to.
>=20
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
>=20
> Along the way, the patches also simplify the code a little, and fix
> a number of subtle races which mainly occur when you set wsize to
> some value smaller than the page size. The most notable such race
> occurs between nfs_lock_and_join_requests() and =
nfs_page_group_destroy(),
> and could lead to a double free() of some of the sub-requests.
>=20
> Finally, there are 2 patches tacked onto the end of the series that
> attempt to improve the throttling of writes when the RPC layer is
> congested. They do so by forcing each caller of nfs_initiate_pgio()
> to wait until the request is being transmitted. The expectation is
> that this might help improve latencies when there are several =
processes
> competing for access to the RPC transport.
>=20
> Trond Myklebust (20):
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
>  SUNRPC: Add a function to allow waiting for RPC transmission
>  NFS: Throttle I/O to the NFS server

This was a lot to look at, but it looks good to me.

-dros

>=20
> fs/nfs/pagelist.c            |  64 +++------
> fs/nfs/write.c               | 313 =
++++++++++++++++++-------------------------
> include/linux/nfs_page.h     |   3 +-
> include/linux/sunrpc/sched.h |   3 +
> net/sunrpc/sched.c           |  22 +++
> net/sunrpc/xprt.c            |   6 +
> 6 files changed, 177 insertions(+), 234 deletions(-)
>=20
> --=20
> 2.13.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

