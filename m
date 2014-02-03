Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45391 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbaBCVBv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 16:01:51 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Fixes for NFS/RDMA client
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 03 Feb 2014 16:01:47 -0500
Message-ID: <20140203205903.3533.39213.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---

Chuck Lever (8):
      NFS: incorrect "port=" value in /proc/mounts
      NFS: Use port 20049 by default for NFS/RDMA mounts
      NFS: advertise only supported callback netids
      NFS: Add debugging message in nfs4_callback_null()
      SUNRPC: Display tk_pid where possible
      SUNRPC: remove KERN_INFO from dprintk() call sites
      SUNRPC: Fix large reads on NFS/RDMA
      NFS: Fix READDIR oops with NFSv4 on RDMA


 fs/nfs/callback_xdr.c           |    1 
 fs/nfs/client.c                 |    1 
 fs/nfs/nfs4proc.c               |   24 +++++++++---
 fs/nfs/nfs4xdr.c                |    3 -
 fs/nfs/super.c                  |    2 +
 include/uapi/linux/nfs.h        |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c  |   80 ++++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/transport.c |   29 ++++++++------
 8 files changed, 86 insertions(+), 55 deletions(-)

-- 
Chuck Lever
