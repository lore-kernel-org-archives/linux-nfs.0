Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45757 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757253Ab2CBV6Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 16:58:24 -0500
Received: by iagz16 with SMTP id z16so2853208iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 13:58:23 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/12] For 3.4 (3rd take)
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 16:58:22 -0500
Message-ID: <20120302215559.12758.39526.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Please consider these minor fixes and migration pre-requisites for
3.4.  I've ported them to nfs-for-next on top of commit abd96698.

This take addresses yesterday's review comments.  I'm leaving the 
nfs4_verifier and nfs4_deviceid patches for a separate submission,
since the following patches seem to have reached a low level of
controversy and should be ready to include now.

---

Chuck Lever (10):
      NFS: Request fh_expire_type attribute in "server caps" operation
      NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
      NFS: Simplify arguments of encode_renew()
      NFS: Add a client-side function to display NFS file handles
      commit 6f38b4ba433ac6494f83cb73dd07dcbde797e1e0
      SUNRPC: Add API to acquire source address
      NFS: Reduce debugging noise from encode_compound_hdr
      NFS: Add debugging messages to NFSv4's CLOSE procedure
      NFS: Clean up debugging in decode_pathname()
      NFS: Make nfs_cache_array.size a signed integer

Trond Myklebust (2):
      SUNRPC: Move clnt->cl_server into struct rpc_xprt
      SUNRPC: Use RCU to dereference the rpc_clnt.cl_xprt field


 fs/nfs/callback.c              |    3 
 fs/nfs/callback_proc.c         |    9 +
 fs/nfs/client.c                |   31 +++-
 fs/nfs/dir.c                   |    2 
 fs/nfs/inode.c                 |   45 +++++
 fs/nfs/nfs4namespace.c         |    2 
 fs/nfs/nfs4proc.c              |   34 +++-
 fs/nfs/nfs4state.c             |   25 ++-
 fs/nfs/nfs4xdr.c               |   52 ++++--
 fs/nfs/super.c                 |   11 +
 include/linux/nfs_fs.h         |   14 ++
 include/linux/nfs_fs_sb.h      |    3 
 include/linux/nfs_xdr.h        |   12 +
 include/linux/sunrpc/clnt.h    |    6 -
 include/linux/sunrpc/debug.h   |   13 +
 include/linux/sunrpc/xprt.h    |    2 
 net/sunrpc/auth_gss/auth_gss.c |    4 
 net/sunrpc/clnt.c              |  347 ++++++++++++++++++++++++++++++++--------
 net/sunrpc/rpc_pipe.c          |    6 +
 net/sunrpc/rpcb_clnt.c         |   19 +-
 net/sunrpc/stats.c             |    6 +
 net/sunrpc/xprt.c              |   15 ++
 22 files changed, 527 insertions(+), 134 deletions(-)

-- 
Chuck Lever
