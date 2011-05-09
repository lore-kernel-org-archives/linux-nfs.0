Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58964 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab1EITgN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:36:13 -0400
Received: by yxs7 with SMTP id 7so1914279yxs.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:36:12 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/16] Client-side migration support for 2.6.40 [take 3]
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:36:09 -0400
Message-ID: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

Here is the latest pass at client-side support for NFS4.0 migration.
Some 4.1 support is thrown in, but is not tested (no extant 4.1
servers in the wild support migration).  Patches are against
2.6.39-rc6.

This series adds support for both NFS4ERR_MOVED and
NFS4ERR_LEASE_MOVED.  It can also re-establish a callback channel
with the destination server, post-migration.  I've attempted to
address all comments and re-organization requests from pub night.

This series is what I am testing this week.  I'm sure there are still
some bugs, but let's get the review process rolling.

---

Chuck Lever (12):
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Remove "const" from "struct nfs_server *" fields
      NFS: Add basic migration support to state manager thread
      NFS: Add functions to swap transports during migration recovery
      NFS: Add an API for cloning an nfs_client
      NFS: Add infrastructure for updating callback data
      NFS: Introduce nfs4_proc_get_mig_status()
      NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
      NFS: Save root file handle in nfs_server
      NFS: Add a client-side function to display file handles
      SUNRPC: Add API to acquire source address

Trond Myklebust (4):
      SUNRPC: Add a helper to switch the transport of the rpc_client
      SUNRPC: Move clnt->cl_server into struct rpc_xprt
      SUNRPC: Use RCU to dereference the rpc_clnt.cl_xprt field
      SUNRPC: Allow temporary blocking of an rpc client


 fs/nfs/callback.c            |    3 
 fs/nfs/callback_proc.c       |    9 -
 fs/nfs/client.c              |   88 +++++++-
 fs/nfs/getroot.c             |    5 
 fs/nfs/inode.c               |   45 ++++
 fs/nfs/internal.h            |    6 +
 fs/nfs/nfs4_fs.h             |    8 +
 fs/nfs/nfs4namespace.c       |  202 ++++++++++++++++++
 fs/nfs/nfs4proc.c            |  218 +++++++++++++++++---
 fs/nfs/nfs4state.c           |  227 ++++++++++++++++++++-
 fs/nfs/nfs4xdr.c             |   50 +++--
 fs/nfs/super.c               |    5 
 include/linux/nfs_fs.h       |   14 +
 include/linux/nfs_fs_sb.h    |    7 +
 include/linux/nfs_xdr.h      |   42 ++--
 include/linux/sunrpc/clnt.h  |   22 ++
 include/linux/sunrpc/debug.h |   11 +
 include/linux/sunrpc/xprt.h  |    2 
 net/sunrpc/clnt.c            |  461 +++++++++++++++++++++++++++++++++++++-----
 net/sunrpc/rpc_pipe.c        |    5 
 net/sunrpc/rpcb_clnt.c       |   24 +-
 net/sunrpc/stats.c           |    6 -
 net/sunrpc/xprt.c            |   14 +
 23 files changed, 1320 insertions(+), 154 deletions(-)

-- 
Chuck Lever
