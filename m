Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:56497 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaCLQvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:51:10 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so10543412iec.24
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:51:10 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] NFS/RDMA fixes
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:51:08 -0400
Message-ID: <20140312164620.15349.22643.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please consider these for 3.15.

---

Chuck Lever (6):
      NFS: incorrect "port=" value in /proc/mounts
      NFS: Use port 20049 by default for NFS/RDMA mounts
      NFS: advertise only supported callback netids
      SUNRPC: remove KERN_INFO from dprintk() call sites
      SUNRPC: Fix large reads on NFS/RDMA
      NFS: Clean up: revert increase in READDIR RPC buffer max size


 fs/nfs/client.c                 |    1 +
 fs/nfs/nfs4proc.c               |   24 ++++++++++++++++++------
 fs/nfs/nfs4xdr.c                |    3 +--
 fs/nfs/super.c                  |    2 ++
 include/uapi/linux/nfs.h        |    1 +
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +---
 net/sunrpc/xprtrdma/transport.c |   10 +++++-----
 7 files changed, 29 insertions(+), 16 deletions(-)

-- 
Chuck Lever
