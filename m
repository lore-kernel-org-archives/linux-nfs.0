Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55908 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256Ab0LNOyY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:54:24 -0500
Received: by ywl5 with SMTP id 5so373298ywl.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:54:23 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/31] NFS XDR clean up for 2.6.38
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:54:19 -0500
Message-ID: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

As requested, here is my latest revision of the XDR patchset for
2.6.38.

This converts NFSv2 and v3, all versions of NLM, and the server's
NFSv4 callback client.  It updates the XDR code for rpcbind, NSM, and
MNT as well.

All encoders and decoders now use xdr_streams.  All encoders now BUG
on any error and return void.

As a bonus, this series converts the whole kit and kaboodle to a new
calling sequence.  The RPC client's generic encode and decode routines
now invoke xdr_init_{en,de}code before calling the specific XDR
routines.  The xdr_init_{en,de}code call sites are thus removed from
all specific XDR routines in the kernel.

---

Chuck Lever (31):
      SUNRPC: New xdr_streams XDR decoder API
      SUNRPC: New xdr_streams XDR encoder API
      SUNRPC: Determine value of "nrprocs" automatically
      SUNRPC: Avoid return code checking in rpcbind XDR encoder functions
      NFS: Remove unused UMNT response data structure
      NFS: Avoid return code checking in mount XDR encoder functions
      NSM: Avoid return code checking in NSM XDR encoder functions
      NFS: Squelch compiler warning in decode_getdeviceinfo()
      NFS: Simplify ->decode_dirent() calling sequence
      NFS: Fix hdrlen calculation in NFSv4's decode_read()
      lockd: Move nlmdbg_cookie2a() to svclock.c
      NFS: Repair whitespace damage in NFS PROC macro
      NFSD: Update XDR decoders in NFSv4 callback client
      NFSD: Update XDR encoders in NFSv4 callback client
      lockd: Introduce new-style XDR functions for NLMv4
      NFS: Move and update xdr_decode_foo() functions that we're keeping
      NFS: Remove unused old NFSv3 decoder functions
      NFS: Switch in new NFSv3 decoder functions
      NFS: Introduce new-style XDR decoding functions for NFSv2
      NFS: Update xdr_encode_foo() functions that we're keeping
      NFS: Remove unused old NFSv3 encoder functions
      NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
      NFS: Introduce new-style XDR encoding functions for NFSv3
      lockd: Introduce new-style XDR functions for NLMv3
      NFS: Move and update xdr_decode_foo() functions that we're keeping
      NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
      NFS: Introduce new-style XDR decoding functions for NFSv2
      NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s argument
      NFS: Update xdr_encode_foo() functions that we're keeping
      NFS: Remove old NFSv2 encoder functions
      NFS: Introduce new-style XDR encoding functions for NFSv2


 fs/lockd/Makefile              |    6 
 fs/lockd/clnt4xdr.c            |  605 ++++++++
 fs/lockd/clntxdr.c             |  627 +++++++++
 fs/lockd/mon.c                 |  110 +-
 fs/lockd/svclock.c             |   30 
 fs/lockd/xdr.c                 |  287 ----
 fs/lockd/xdr4.c                |  255 ----
 fs/nfs/dir.c                   |   15 
 fs/nfs/internal.h              |   11 
 fs/nfs/mount_clnt.c            |   81 -
 fs/nfs/nfs2xdr.c               | 1297 ++++++++++++------
 fs/nfs/nfs3xdr.c               | 2892 +++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4_fs.h               |    1 
 fs/nfs/nfs4xdr.c               | 1401 +++++++++----------
 fs/nfs/proc.c                  |    2 
 fs/nfsd/nfs4callback.c         |  690 ++++++----
 include/linux/lockd/debug.h    |   10 
 include/linux/nfs3.h           |    3 
 include/linux/nfs_xdr.h        |    3 
 include/linux/sunrpc/auth.h    |    8 
 include/linux/sunrpc/clnt.h    |    4 
 include/linux/sunrpc/xdr.h     |   10 
 net/sunrpc/auth.c              |   28 
 net/sunrpc/auth_gss/auth_gss.c |   44 -
 net/sunrpc/clnt.c              |    9 
 net/sunrpc/rpcb_clnt.c         |  147 +-
 26 files changed, 5529 insertions(+), 3047 deletions(-)
 create mode 100644 fs/lockd/clnt4xdr.c
 create mode 100644 fs/lockd/clntxdr.c

-- 
Chuck Lever
