Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36827 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753179AbdGMVQ2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jul 2017 17:16:28 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
To: torvalds@linux-foundation.org
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
Date: Thu, 13 Jul 2017 17:16:24 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 32c1431eea4881a6b17bd7c639315010aeefa452:

  Linux 4.12-rc5 (2017-06-11 16:48:20 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1

for you to fetch changes up to b4f937cffa66b3d56eb8f586e620d0b223a281a3:

  NFS: Don't run wake_up_bit() when nobody is waiting... (2017-07-13 16:57:18 -0400)


Stable bugfixes:
- Fix -EACCESS on commit to DS handling
- Fix initialization of nfs_page_array->npages
- Only invalidate dentries that are actually invalid

Features:
- Enable NFSoRDMA transparent state migration
- Add support for lookup-by-filehandle
- Add support for nfs re-exporting

Other bugfixes and cleanups:
- Christoph cleaned up the way we declare NFS operations
- Clean up various internal structures
- Various cleanups to commits
- Various improvements to error handling
- Set the dt_type of . and .. entries in NFS v4
- Make slot allocation more reliable
- Fix fscache stat printing
- Fix uninitialized variable warnings
- Fix potential list overrun in nfs_atomic_open()
- Fix a race in NFSoRDMA RPC reply handler
- Fix return size for nfs42_proc_copy()
- Fix against MAC forgery timing attacks


As Bruce mentioned in his pull request, we didn't do a good job coordinating
with Christoph's patches from the beginning.  I ended up rebasing my tree on
top of Christoph's nfs-ops branch to prevent duplicate commits.  Apologies if
that was the wrong choice!

Cheers,
Anna

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Set FATTR4_WORD0_TYPE for . and .. entries

Benjamin Coddington (3):
      NFS: convert flags to bool
      NFS: nfs_rename() - revalidate directories on -ERESTARTSYS
      NFS: Fix initialization of nfs_page_array->npages

Christoph Hellwig (33):
      sunrpc: properly type argument to kxdreproc_t
      sunrpc: fix encoder callback prototypes
      lockd: fix encoder callback prototypes
      nfs: fix encoder callback prototypes
      nfsd: fix encoder callback prototypes
      sunrpc/auth_gss: nfsd: fix encoder callback prototypes
      sunrpc: properly type argument to kxdrdproc_t
      sunrpc: fix decoder callback prototypes
      sunrpc/auth_gss: fix decoder callback prototypes
      nfsd: fix decoder callback prototypes
      lockd: fix decoder callback prototypes
      nfs: fix decoder callback prototypes
      nfs: don't cast callback decode/proc/encode routines
      lockd: fix some weird indentation
      sunrpc: move p_count out of struct rpc_procinfo
      nfs: use ARRAY_SIZE() in the nfsacl_version3 declaration
      sunrpc: mark all struct rpc_procinfo instances as const
      nfsd4: const-ify nfs_cb_version4
      nfsd: use named initializers in PROC()
      nfsd: remove the unused PROC() macro in nfs3proc.c
      sunrpc: properly type pc_func callbacks
      sunrpc: properly type pc_release callbacks
      sunrpc: properly type pc_decode callbacks
      sunrpc: properly type pc_encode callbacks
      sunrpc: remove kxdrproc_t
      nfsd4: properly type op_set_currentstateid callbacks
      nfsd4: properly type op_get_currentstateid callbacks
      nfsd4: remove nfsd4op_rsize
      nfsd4: properly type op_func callbacks
      sunrpc: move pc_count out of struct svc_procinfo
      sunrpc: mark all struct svc_procinfo instances as const
      sunrpc: mark all struct svc_version instances as const
      nfsd4: const-ify nfsd4_ops

Chuck Lever (13):
      xprtrdma: On invalidation failure, remove MWs from rl_registered
      xprtrdma: Pre-mark remotely invalidated MRs
      xprtrdma: Pass only the list of registered MRs to ro_unmap_sync
      xprtrdma: Rename rpcrdma_req::rl_free
      xprtrdma: Fix client lock-up after application signal fires
      xprtrdma: Fix FRWR invalidation error recovery
      xprtrdma: Don't defer MR recovery if ro_map fails
      NFSv4.1: Handle EXCHGID4_FLAG_CONFIRMED_R during NFSv4.1 migration
      NFSv4.1: Use seqid returned by EXCHANGE_ID after state migration
      xprtrdma: Demote "connect" log messages
      xprtrdma: FMR does not need list_del_init()
      xprtrdma: Replace PAGE_MASK with offset_in_page()
      xprtrdma: Fix documenting comments in frwr_ops.c

Dan Carpenter (1):
      NFS: silence a uninitialized variable warning

Jason A. Donenfeld (1):
      sunrpc: use constant time memory comparison for mac

Jeff Layton (1):
      nfs4: add NFSv4 LOOKUPP handlers

NeilBrown (3):
      NFS: only invalidate dentrys that are clearly invalid.
      NFS: guard against confused server in nfs_atomic_open()
      NFS: check for nfs_refresh_inode() errors in nfs_fhget()

Olga Kornievskaia (3):
      PNFS fix EACCESS on commit to DS handling
      PNFS for stateid errors retry against MDS first
      NFSv4.2 fix size storage for nfs42_proc_copy

Peng Tao (3):
      nfs: replace d_add with d_splice_alias in atomic_open
      nfs: add a nfs_ilookup helper
      nfs: add export operations

Trond Myklebust (5):
      SUNRPC: Make slot allocation more reliable
      NFS: Remove unused fields in the page I/O structures
      NFS: Ensure we commit after writeback is complete
      NFS: Fix commit policy for non-blocking calls to nfs_write_inode()
      NFS: Don't run wake_up_bit() when nobody is waiting...

Tuo Chen Peng (1):
      nfs: Fix fscache stat printing in nfs_show_stats()

 fs/lockd/clnt4xdr.c                    |  34 ++-
 fs/lockd/clntxdr.c                     |  58 +++--
 fs/lockd/mon.c                         |  38 +--
 fs/lockd/svc.c                         |  38 +--
 fs/lockd/svc4proc.c                    | 124 ++++++----
 fs/lockd/svcproc.c                     | 124 ++++++----
 fs/lockd/xdr.c                         |  43 ++--
 fs/lockd/xdr4.c                        |  43 ++--
 fs/nfs/Makefile                        |   2 +-
 fs/nfs/callback.c                      |   2 +-
 fs/nfs/callback.h                      |  27 +--
 fs/nfs/callback_proc.c                 |  33 ++-
 fs/nfs/callback_xdr.c                  | 113 +++++----
 fs/nfs/dir.c                           |  42 ++--
 fs/nfs/export.c                        | 177 ++++++++++++++
 fs/nfs/filelayout/filelayout.c         |  31 +--
 fs/nfs/flexfilelayout/flexfilelayout.c |  33 ---
 fs/nfs/inode.c                         |  36 ++-
 fs/nfs/internal.h                      |  18 +-
 fs/nfs/mount_clnt.c                    |  29 ++-
 fs/nfs/nfs2xdr.c                       |  72 ++++--
 fs/nfs/nfs3proc.c                      |   2 +-
 fs/nfs/nfs3xdr.c                       | 153 ++++++++----
 fs/nfs/nfs42proc.c                     |   2 +-
 fs/nfs/nfs42xdr.c                      |  52 +++--
 fs/nfs/nfs4_fs.h                       |   6 +-
 fs/nfs/nfs4client.c                    |   5 +
 fs/nfs/nfs4idmap.c                     |   3 +-
 fs/nfs/nfs4proc.c                      | 109 ++++++---
 fs/nfs/nfs4state.c                     |  16 +-
 fs/nfs/nfs4trace.h                     |  29 +++
 fs/nfs/nfs4xdr.c                       | 408 ++++++++++++++++++++++----------
 fs/nfs/pagelist.c                      |  23 +-
 fs/nfs/proc.c                          |   2 +-
 fs/nfs/super.c                         |   4 +-
 fs/nfs/unlink.c                        |  13 ++
 fs/nfs/write.c                         |  59 ++++-
 fs/nfsd/current_stateid.h              |  36 ++-
 fs/nfsd/nfs2acl.c                      | 116 +++++-----
 fs/nfsd/nfs3acl.c                      |  75 +++---
 fs/nfsd/nfs3proc.c                     | 301 ++++++++++++------------
 fs/nfsd/nfs3xdr.c                      | 164 +++++++------
 fs/nfsd/nfs4callback.c                 |  32 ++-
 fs/nfsd/nfs4proc.c                     | 412 +++++++++++++++++----------------
 fs/nfsd/nfs4state.c                    | 142 +++++++-----
 fs/nfsd/nfs4xdr.c                      |  13 +-
 fs/nfsd/nfsd.h                         |   6 +-
 fs/nfsd/nfsproc.c                      | 206 +++++++++--------
 fs/nfsd/nfssvc.c                       |  24 +-
 fs/nfsd/nfsxdr.c                       |  92 +++++---
 fs/nfsd/xdr.h                          |  50 ++--
 fs/nfsd/xdr3.h                         | 100 +++-----
 fs/nfsd/xdr4.h                         |  78 +++----
 include/linux/lockd/lockd.h            |   4 +-
 include/linux/lockd/xdr.h              |  26 +--
 include/linux/lockd/xdr4.h             |  26 +--
 include/linux/nfs4.h                   |   1 +
 include/linux/nfs_fs.h                 |   1 +
 include/linux/nfs_fs_sb.h              |   2 +
 include/linux/nfs_page.h               |   4 +-
 include/linux/nfs_xdr.h                |  31 ++-
 include/linux/sunrpc/clnt.h            |   6 +-
 include/linux/sunrpc/sched.h           |   2 +-
 include/linux/sunrpc/svc.h             |  21 +-
 include/linux/sunrpc/xdr.h             |  15 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c  |   3 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c   |   9 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c      |  14 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h      |   4 +-
 net/sunrpc/clnt.c                      |  16 +-
 net/sunrpc/rpcb_clnt.c                 |  82 ++++---
 net/sunrpc/stats.c                     |  16 +-
 net/sunrpc/svc.c                       |  33 +--
 net/sunrpc/xprt.c                      |   8 +-
 net/sunrpc/xprtrdma/fmr_ops.c          |  47 ++--
 net/sunrpc/xprtrdma/frwr_ops.c         |  69 +++---
 net/sunrpc/xprtrdma/rpc_rdma.c         | 125 ++++++----
 net/sunrpc/xprtrdma/transport.c        |   3 +-
 net/sunrpc/xprtrdma/verbs.c            |  55 ++---
 net/sunrpc/xprtrdma/xprt_rdma.h        |  40 +++-
 80 files changed, 2733 insertions(+), 1780 deletions(-)
 create mode 100644 fs/nfs/export.c
