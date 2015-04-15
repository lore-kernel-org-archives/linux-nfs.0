Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:55729 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947AbbDORAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2015 13:00:12 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 1/3] NFS: Remove CONFIG_NFS_V4 checks from nfs_idmap.h
Date: Wed, 15 Apr 2015 13:00:04 -0400
Message-ID: <1429117206-13671-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The idmapper is completely internal to the NFS v4 module, so this macro
will always evaluate to true.  This patch also removes unnecessary
includes of this file from the generic NFS client.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/client.c           |  1 -
 fs/nfs/super.c            |  1 -
 include/linux/nfs_idmap.h | 11 -----------
 3 files changed, 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1987415..892aeff 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -31,7 +31,6 @@
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 54a079a..e862093 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -43,7 +43,6 @@
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 333844e..daaf3ea 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -46,19 +46,8 @@ struct nfs_server;
 struct nfs_fattr;
 struct nfs4_string;
 
-#if IS_ENABLED(CONFIG_NFS_V4)
 int nfs_idmap_init(void);
 void nfs_idmap_quit(void);
-#else
-static inline int nfs_idmap_init(void)
-{
-	return 0;
-}
-
-static inline void nfs_idmap_quit(void)
-{}
-#endif
-
 int nfs_idmap_new(struct nfs_client *);
 void nfs_idmap_delete(struct nfs_client *);
 
-- 
2.3.5

