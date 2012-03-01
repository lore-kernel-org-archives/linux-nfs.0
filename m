Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63857 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab2CAWAQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:00:16 -0500
Received: by iagz16 with SMTP id z16so1389076iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:00:15 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/15] For 3.4 (2nd take)
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:00:14 -0500
Message-ID: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Please consider these minor fixes and migration pre-requisites for
3.4.  I've ported them to nfs-for-next on top of commit abd96698.
I've tested all but the last one (see patch description).

---

Chuck Lever (13):
      NFS: Fix some minor problems with nfs4_deviceids
      NFS: Fix some minor problems with nfs4_verifiers
      NFS: Request fh_expire_type attribute in "server caps" operation
      NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
      NFS: Simplify arguments of encode_renew()
      NFS: Save root file handle in nfs_server
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


 fs/nfs/blocklayout/blocklayout.c    |    2 
 fs/nfs/blocklayout/blocklayoutdev.c |    8 -
 fs/nfs/blocklayout/extents.c        |    5 -
 fs/nfs/callback.c                   |    3 
 fs/nfs/callback_proc.c              |    9 +
 fs/nfs/callback_xdr.c               |    2 
 fs/nfs/client.c                     |   32 +++
 fs/nfs/dir.c                        |    2 
 fs/nfs/getroot.c                    |    5 +
 fs/nfs/inode.c                      |   45 +++++
 fs/nfs/nfs4filelayout.c             |    3 
 fs/nfs/nfs4namespace.c              |    2 
 fs/nfs/nfs4proc.c                   |   40 +++-
 fs/nfs/nfs4state.c                  |   25 ++-
 fs/nfs/nfs4xdr.c                    |   84 ++++++--
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    8 -
 fs/nfs/pnfs_dev.c                   |    7 -
 fs/nfs/super.c                      |   11 +
 fs/nfsd/nfs4proc.c                  |    4 
 fs/nfsd/nfs4state.c                 |    2 
 fs/nfsd/nfs4xdr.c                   |   28 +--
 include/linux/nfs4.h                |   12 +
 include/linux/nfs_fs.h              |   14 +
 include/linux/nfs_fs_sb.h           |    4 
 include/linux/nfs_xdr.h             |   12 +
 include/linux/pnfs_osd_xdr.h        |    4 
 include/linux/sunrpc/clnt.h         |    6 -
 include/linux/sunrpc/debug.h        |   13 +
 include/linux/sunrpc/xprt.h         |    2 
 net/sunrpc/auth_gss/auth_gss.c      |    4 
 net/sunrpc/clnt.c                   |  347 ++++++++++++++++++++++++++++-------
 net/sunrpc/rpc_pipe.c               |    6 +
 net/sunrpc/rpcb_clnt.c              |   19 +-
 net/sunrpc/stats.c                  |    6 +
 net/sunrpc/xprt.c                   |   15 +-
 35 files changed, 604 insertions(+), 187 deletions(-)

-- 
Signature
