Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e38.co.us.ibm.com ([32.97.110.159]:33153 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab2A3TaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:15 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:14 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1107319D804F
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:02 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTxsb088746
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:00 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTxTD007358
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:59 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTwDL007339
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC] [PATCH 00/13] NFS4 replication support
Date: Mon, 30 Jan 2012 13:29:42 -0600
Message-Id: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch set supports NFS4 replication for read only file
systems.  The beginning set of patches are derived from Chuck Lever's
migration tree. The later set of patches support replication from the
interface built from the migration patches. Simple testing shows that it
works!

Here are some issues that I already know. Hopefully all of them
including any new issues will be resolved with the help of this list.

1. Replacing a transport (rpc_xprt) needs waiting for all the pending
   RPC tasks.  This doesn't work for now.
2. In order to use the replicated server, in addition to replacing the
   transport, we also clone a new nfs_client.  Currently the old
   nfs_client structure is not released. We can wait for all the active
   commands and then release the nfs_client (needs more work!). Or
   simply keep all old nfs_clients until nfs_free_server() is called and
   then release them.

Regards, Malahal.



Chuck Lever (3):
  SUNRPC: Add API to acquire source address
  NFS: Add an API for cloning an nfs_client
  NFS: Save root file handle in nfs_server

Malahal Naineni (6):
  NFS: Store server locations for replication
  NFS: Add replica servers to volumes proc file.
  NFS: Add replace transport infrastructure for replication
  NFS: Add replication capability to state manager thread.
  NFS: Handle replication on a timeout error
  NFS: Avoid spurious replication recoveries

Trond Myklebust (4):
  SUNRPC: Allow temporary blocking of an rpc client
  SUNRPC: Use RCU to dereference the rpc_clnt.cl_xprt field
  SUNRPC: Move clnt->cl_server into struct rpc_xprt
  SUNRPC: Add a helper to switch the transport of the rpc_client

 fs/nfs/callback.c            |    3 +-
 fs/nfs/callback_proc.c       |    9 +-
 fs/nfs/client.c              |   84 +++++++-
 fs/nfs/getroot.c             |    3 +
 fs/nfs/internal.h            |    4 +
 fs/nfs/nfs4_fs.h             |    6 +
 fs/nfs/nfs4namespace.c       |  148 +++++++++++++
 fs/nfs/nfs4proc.c            |   69 ++++++-
 fs/nfs/nfs4state.c           |   39 +++-
 fs/nfs/nfs4xdr.c             |   16 +-
 fs/nfs/super.c               |   56 +++++
 include/linux/nfs_fs_sb.h    |    8 +
 include/linux/nfs_xdr.h      |    3 +
 include/linux/sunrpc/clnt.h  |   22 ++-
 include/linux/sunrpc/debug.h |   11 +
 include/linux/sunrpc/xprt.h  |    2 +
 net/sunrpc/clnt.c            |  473 ++++++++++++++++++++++++++++++++++++-----
 net/sunrpc/rpc_pipe.c        |    5 +-
 net/sunrpc/rpcb_clnt.c       |   24 ++-
 net/sunrpc/stats.c           |    6 +-
 net/sunrpc/xprt.c            |   15 ++-
 21 files changed, 902 insertions(+), 104 deletions(-)

-- 
1.7.8.3

