Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52633 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0KQR7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:59:47 -0500
Received: by iwn35 with SMTP id 35so2387538iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:59:47 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/12] Additional XDR clean-up
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:59:43 -0500
Message-ID: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

Here are new patches (and a couple of old ones) that continue the XDR
function clean-up effort.  In addition to a handful of minor fixes,
this series includes patches that:

 o  Remove the READ32/WRITE32 macros from the NFSv4 callback client
 o  Update the rpcbind, MNT, and NSM client XDR functions based on
    comments since the original clean up
 o  Refactor xdr_init_{en,de}code() out of every XDR function in all
    kernel clients

These have also been tested in Bruce's test environment.  I think
these are ready for linux-next and 2.6.38.

---

Chuck Lever (12):
      SUNRPC: New xdr_streams XDR decoder API
      SUNRPC: New xdr_streams XDR encoder API
      SUNRPC: Avoid return code checking in rpcbind XDR encoder functions
      NFS: Avoid return code checking in mount XDR encoder functions
      NSM: Avoid return code checking in NSM XDR encoder functions
      NFS: Squelch compiler warning in decode_getdeviceinfo()
      NFS: Simplify ->decode_dirent() calling sequence
      NFS: Fix hdrlen calculation in NFSv4's decode_read()
      lockd: Move nlmdbg_cookie2a() to svclock.c
      NFS: Repair whitespace damage in NFS PROC macro
      NFSD: Update XDR decoders in NFSv4 callback client
      NFSD: Update XDR encoders in NFSv4 callback client


 fs/lockd/clnt4xdr.c            |  114 +--
 fs/lockd/clntxdr.c             |  114 +--
 fs/lockd/mon.c                 |  110 +--
 fs/lockd/svclock.c             |   30 +
 fs/lockd/xdr.c                 |   29 -
 fs/nfs/dir.c                   |   15 
 fs/nfs/internal.h              |    9 
 fs/nfs/mount_clnt.c            |   79 +-
 fs/nfs/nfs2xdr.c               |  263 +++-----
 fs/nfs/nfs3xdr.c               |  464 ++++++-------
 fs/nfs/nfs4_fs.h               |    1 
 fs/nfs/nfs4xdr.c               | 1401 +++++++++++++++++++---------------------
 fs/nfsd/nfs4callback.c         |  690 ++++++++++++--------
 include/linux/lockd/debug.h    |   10 
 include/linux/nfs_xdr.h        |    3 
 include/linux/sunrpc/auth.h    |    8 
 include/linux/sunrpc/clnt.h    |    4 
 include/linux/sunrpc/xdr.h     |   10 
 net/sunrpc/auth.c              |   28 +
 net/sunrpc/auth_gss/auth_gss.c |   44 +
 net/sunrpc/clnt.c              |    8 
 net/sunrpc/rpcb_clnt.c         |  137 ++--
 22 files changed, 1728 insertions(+), 1843 deletions(-)

-- 
Chuck Lever
