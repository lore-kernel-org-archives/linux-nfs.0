Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458AbZCKSoJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:09 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi45E012186
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:08 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/30] NFS client patches queued for 2.6.30
To: linux-nfs@vger.kernel.org
Date: Wed, 11 Mar 2009 14:41:06 -0400
Message-ID: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following series of patches are being queued for inclusion in kernel
2.6.30

---

Chuck Lever (1):
      SUNRPC: Avoid spurious wake-up during UDP connect processing

NeilBrown (1):
      NFS: flush cached directory information slightly more readily.

Suresh Jayaraman (1):
      NFS: Minor __nfs_revalidate_inode cleanup

Tom Talpey (4):
      NFS: load the rpc/rdma transport module automatically
      SUNRPC: dynamically load RPC transport modules on-demand
      XPRTRDMA: correct an rpc/rdma inline send marshaling error
      SVCRDMA: remove faulty assertions in rpc/rdma chunk validation.

Trond Myklebust (23):
      SUNRPC: xs_tcp_connect_worker{4,6}: merge common code
      SUNRPC: Add a sysctl to control the duration of the socket linger timeout
      SUNRPC: Add the equivalent of the linger and linger2 timeouts to RPC sockets
      SUNRPC: Always report 'unrecognised error' cases...
      SUNRPC: Ensure that xs_nospace return values are propagated
      SUNRPC: Delay, then retry on connection errors.
      SUNRPC: Return EAGAIN instead of ENOTCONN when waking up xprt->pending
      SUNRPC: Handle socket errors correctly
      SUNRPC: Handle ECONNREFUSED correctly in xprt_transmit()
      SUNRPC: Don't disconnect if a connection is still in progress.
      SUNRPC: Ensure we set XPRT_CLOSING only after we've sent a tcp FIN...
      SUNRPC: Avoid an unnecessary task reschedule on ENOTCONN
      NFS: Kill the "defined but not used" compile error on nommu machines
      NFS: Throttle page dirtying while we're flushing to disk
      NFS: cleanup - remove struct nfs_inode->ncommit
      NFSv4: Simplify some cache consistency post-op GETATTRs
      NFSv4: A referral is assumed to always point to a directory.
      NFSv4: Make decode_getfattr() set fattr->valid to reflect what was decoded
      NFSv4: Clean up decode_getfattr()
      NFS: Fix the type of struct nfs_fattr->mode
      NFS: Shrink the struct nfs_fattr
      NFSv4: Support NFSv4 optional attributes in the struct nfs_fattr
      NFSv4: Ignore errors on the post-op attributes in SETATTR calls


 fs/nfs/file.c                         |   21 +-
 fs/nfs/getroot.c                      |    4 
 fs/nfs/inode.c                        |  268 ++++++++++++++++--------
 fs/nfs/internal.h                     |    1 
 fs/nfs/nfs2xdr.c                      |    9 -
 fs/nfs/nfs3xdr.c                      |   37 ++-
 fs/nfs/nfs4proc.c                     |   37 ++-
 fs/nfs/nfs4xdr.c                      |  213 ++++++++++++++-----
 fs/nfs/pagelist.c                     |   11 -
 fs/nfs/super.c                        |    4 
 fs/nfs/write.c                        |   53 +++--
 include/linux/nfs_fs.h                |    4 
 include/linux/nfs_fs_sb.h             |    5 
 include/linux/nfs_xdr.h               |   58 ++++-
 include/linux/sunrpc/xprt.h           |    2 
 net/sunrpc/clnt.c                     |   57 +++--
 net/sunrpc/xprt.c                     |   89 +++++---
 net/sunrpc/xprtrdma/rpc_rdma.c        |   26 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    8 -
 net/sunrpc/xprtsock.c                 |  361 +++++++++++++++++++++------------
 20 files changed, 810 insertions(+), 458 deletions(-)

-- 
Signature
