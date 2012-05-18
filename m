Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53010 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968091Ab2ERWG0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 18:06:26 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so3329530ggl.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 15:06:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/14] NFS: Add NFSDBG_STATE
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 May 2012 18:06:24 -0400
Message-ID: <20120518220624.774.7315.stgit@degas.1015granger.net>
In-Reply-To: <20120518220145.774.53741.stgit@degas.1015granger.net>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfs/nfs4state.c does not yet have any dprintk() call sites, and I'm
about to introduce some.  We will need a new flag for enabling them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4renewd.c    |    2 +-
 fs/nfs/nfs4state.c     |    2 ++
 include/linux/nfs_fs.h |    1 +
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index dc484c0..6930bec 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -49,7 +49,7 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 
-#define NFSDBG_FACILITY	NFSDBG_PROC
+#define NFSDBG_FACILITY		NFSDBG_STATE
 
 void
 nfs4_renew_state(struct work_struct *work)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7f0fcfc..f8c06de 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -57,6 +57,8 @@
 #include "internal.h"
 #include "pnfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_STATE
+
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 52a1bdb..812a945 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -654,6 +654,7 @@ nfs_fileid_to_ino_t(u64 fileid)
 #define NFSDBG_FSCACHE		0x0800
 #define NFSDBG_PNFS		0x1000
 #define NFSDBG_PNFS_LD		0x2000
+#define NFSDBG_STATE		0x4000
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__

