Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34832 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750724AbdCNHH1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:27 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/12] fs, nfs conversions from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:08 +0200
Message-Id: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series, for nfs filesystem, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The below patches have been run-time tested using NFStest on the client side only.
No issues related to refcounter conversions were detected.

If you don't see objections or issues with the patches, please take it to
your tree.

Elena Reshetova (12):
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
  fs, nfs: convert nfs_cache_array.refcount from atomic_t to refcount_t

 fs/nfs/cache_lib.c                     |  6 +++---
 fs/nfs/cache_lib.h                     |  2 +-
 fs/nfs/client.c                        | 12 ++++++------
 fs/nfs/dir.c                           |  8 ++++----
 fs/nfs/filelayout/filelayout.c         | 12 ++++++------
 fs/nfs/flexfilelayout/flexfilelayout.c | 20 +++++++++----------
 fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++-
 fs/nfs/inode.c                         | 12 ++++++------
 fs/nfs/nfs4_fs.h                       |  2 +-
 fs/nfs/nfs4client.c                    | 16 +++++++--------
 fs/nfs/nfs4proc.c                      | 18 ++++++++---------
 fs/nfs/nfs4state.c                     | 14 ++++++-------
 fs/nfs/pnfs.c                          | 28 +++++++++++++-------------
 fs/nfs/pnfs.h                          |  9 +++++----
 fs/nfs/pnfs_nfs.c                      | 10 +++++-----
 fs/nfsd/nfs4layouts.c                  |  4 ++--
 fs/nfsd/nfs4state.c                    | 36 +++++++++++++++++-----------------
 fs/nfsd/state.h                        |  9 +++++----
 include/linux/nfs_fs.h                 |  3 ++-
 include/linux/nfs_fs_sb.h              |  3 ++-
 20 files changed, 116 insertions(+), 111 deletions(-)

-- 
2.7.4

