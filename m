Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40957 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756263AbaDIAKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 20:10:17 -0400
Date: Tue, 8 Apr 2014 20:10:16 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd changes for 3.15
Message-ID: <20140409001016.GG9457@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.15 from

  git://linux-nfs.org/~bfields/linux.git for-3.15

Highlights:

	- server-side nfs/rdma fixes from Jeff Layton and Tom Tucker
	- xdr fixes (a larger xdr rewrite has been posted but I decided
	  it would be better to queue it up for 3.16).
	- miscellaneous fixes and cleanup from all over (thanks
	  especially to Kinglong Mee)

--b.

----------------------------------------------------------------
J. Bruce Fields (17):
      nfsd4: buffer-length check for SUPPATTR_EXCLCREAT
      nfsd4: session needs room for following op to error out
      nfsd4: make set of large acl return efbig, not resource
      nfsd4: leave reply buffer space for failed setattr
      nfsd4: fix test_stateid error reply encoding
      nfsd: notify_change needs elevated write count
      nfsd: typo in nfsd_rename comment
      rpc: Allow xdr_buf_subsegment to operate in-place
      nfsd4: update comments with obsolete function name
      nfsd4: nfsd4_replay_cache_entry should be static
      nfsd4: minor nfsd4_replay_cache_entry cleanup
      nfsd4: use more generous NFS4_ACL_MAX
      nfsd4: remove redundant check from nfsd4_check_resp_size
      nfsd4: fix setclientid encode size
      nfsd4: fix nfs4err_resource in 4.1 case
      nfsd: revert v2 half of "nfsd: don't return high mode bits"
      nfsd4: don't create unnecessary mask acl

Jeff Layton (5):
      svcrdma: fix printk when memory allocation fails
      svcrpc: explicitly reject compounds that are not padded out to 4-byte multiple
      lockd: ensure we tear down any live sockets when socket creation fails during lockd_up
      xprtrdma: add separate Kconfig options for NFSoRDMA client and server support
      svcrdma: fix offset calculation for non-page aligned sge entries

Kinglong Mee (9):
      NFSD: Traverse unconfirmed client through hash-table
      NFSD: simplify saved/current fh uses in nfsd4_proc_compound
      SUNRPC: fix memory leak of peer addresses in XPRT
      NFSD: Using free_conn free connection
      NFSD: Clear wcc data between compound ops
      NFSD: Free backchannel xprt in bc_destroy
      SUNRPC: New helper for creating client with rpc_xprt
      NFSD/SUNRPC: Check rpc_xprt out of xs_setup_bc_tcp
      SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed

Rashika Kheria (1):
      net: Mark functions as static in net/sunrpc/svc_xprt.c

Stanislav Kinsbursky (1):
      nfsd: check passed socket's net matches NFSd superblock's one

Tom Tucker (1):
      Fix regression in NFSRDMA server

Trond Myklebust (1):
      nfsd: Don't return NFS4ERR_STALE_STATEID for NFSv4.1+

Yan, Zheng (1):
      nfsd4: fix memory leak in nfsd4_encode_fattr()

 fs/lockd/svc.c                           |    1 +
 fs/nfsd/acl.h                            |   10 ++++--
 fs/nfsd/nfs4acl.c                        |   13 ++++---
 fs/nfsd/nfs4callback.c                   |   19 +++++++++-
 fs/nfsd/nfs4proc.c                       |   39 ++++++++++++--------
 fs/nfsd/nfs4state.c                      |   28 +++++++--------
 fs/nfsd/nfs4xdr.c                        |   30 ++++++++++++----
 fs/nfsd/nfsctl.c                         |    5 +++
 fs/nfsd/nfsd.h                           |    2 +-
 fs/nfsd/nfsfh.h                          |   14 +++++++-
 fs/nfsd/nfsxdr.c                         |    2 +-
 fs/nfsd/vfs.c                            |   15 ++++++--
 fs/nfsd/xdr4.h                           |    2 --
 include/linux/sunrpc/clnt.h              |    2 ++
 include/linux/sunrpc/svcsock.h           |    1 +
 include/linux/sunrpc/xprt.h              |   13 ++++++-
 net/sunrpc/Kconfig                       |   39 +++++++++++++-------
 net/sunrpc/Makefile                      |    3 +-
 net/sunrpc/clnt.c                        |   58 +++++++++++++++++-------------
 net/sunrpc/svc_xprt.c                    |    6 ++--
 net/sunrpc/svcsock.c                     |   16 +++++++++
 net/sunrpc/xdr.c                         |   22 ++++++++----
 net/sunrpc/xprt.c                        |   12 -------
 net/sunrpc/xprtrdma/Makefile             |    4 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   12 +++----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    3 +-
 net/sunrpc/xprtsock.c                    |   34 +++++++++---------
 28 files changed, 267 insertions(+), 140 deletions(-)
