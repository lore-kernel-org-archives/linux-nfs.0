Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33971 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752278AbdJTJzi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:55:38 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/11] nfs refcount conversions
Date: Fri, 20 Oct 2017 12:53:27 +0300
Message-Id: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series, for nfs components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
If there are no objections to the patches, please merge them via respective trees.

Rebased on top of linux-next.

Elena Reshetova (11):
  fs, nfsd: convert nfs4_stid.sc_count from atomic_t to refcount_t
  fs, nfsd: convert nfs4_cntl_odstate.co_odcount from atomic_t to
    refcount_t
  fs, nfsd: convert nfs4_file.fi_ref from atomic_t to refcount_t
  fs, nfs: convert nfs4_pnfs_ds.ds_count from atomic_t to refcount_t
  fs, nfs: convert pnfs_layout_segment.pls_refcount from atomic_t to
    refcount_t
  fs, nfs: convert pnfs_layout_hdr.plh_refcount from atomic_t to
    refcount_t
  fs, nfs: convert nfs4_ff_layout_mirror.ref from atomic_t to refcount_t
  fs, nfs: convert nfs_cache_defer_req.count from atomic_t to refcount_t
  fs, nfs: convert nfs4_lock_state.ls_count from atomic_t to refcount_t
  fs, nfs: convert nfs_lock_context.count from atomic_t to refcount_t
  fs, nfs: convert nfs_client.cl_count from atomic_t to refcount_t

 fs/nfs/cache_lib.c                     |  6 +++---
 fs/nfs/cache_lib.h                     |  2 +-
 fs/nfs/client.c                        | 10 +++++-----
 fs/nfs/filelayout/filelayout.c         | 12 ++++++------
 fs/nfs/flexfilelayout/flexfilelayout.c | 20 +++++++++----------
 fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++-
 fs/nfs/inode.c                         | 12 ++++++------
 fs/nfs/nfs4_fs.h                       |  2 +-
 fs/nfs/nfs4client.c                    | 10 +++++-----
 fs/nfs/nfs4proc.c                      | 18 ++++++++---------
 fs/nfs/nfs4state.c                     | 14 ++++++-------
 fs/nfs/pnfs.c                          | 24 +++++++++++------------
 fs/nfs/pnfs.h                          |  9 +++++----
 fs/nfs/pnfs_nfs.c                      | 10 +++++-----
 fs/nfsd/nfs4layouts.c                  |  4 ++--
 fs/nfsd/nfs4state.c                    | 36 +++++++++++++++++-----------------
 fs/nfsd/state.h                        |  9 +++++----
 include/linux/nfs_fs.h                 |  3 ++-
 include/linux/nfs_fs_sb.h              |  3 ++-
 19 files changed, 106 insertions(+), 101 deletions(-)

-- 
2.7.4

