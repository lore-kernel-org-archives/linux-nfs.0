Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbaICQTd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 12:19:33 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/4] NFS: Move v3 declarations out of internal.h
Date: Wed, 3 Sep 2014 12:19:08 -0400
Message-ID: <1409761150-30257-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am generally against the "one big header file" approach, and
everything in the client includes this file.  Let's move all the NFS v3
declarations into a v3-only header file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  7 -------
 fs/nfs/nfs3_fs.h  | 15 +++++++++++++++
 fs/nfs/nfs3proc.c |  1 +
 3 files changed, 16 insertions(+), 7 deletions(-)
 create mode 100644 fs/nfs/nfs3_fs.h

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9056622..14ae6f2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -218,13 +218,6 @@ static inline void nfs_fs_proc_exit(void)
 int nfs_sockaddr_match_ipaddr(const struct sockaddr *, const struct sockaddr *);
 #endif
 
-/* nfs3client.c */
-#if IS_ENABLED(CONFIG_NFS_V3)
-struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
-struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
-				     struct nfs_fattr *, rpc_authflavor_t);
-#endif
-
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
new file mode 100644
index 0000000..6599e0d
--- /dev/null
+++ b/fs/nfs/nfs3_fs.h
@@ -0,0 +1,15 @@
+/*
+ * Copyright (C) 2014 Anna Schumaker.
+ *
+ * NFSv3-specific filesystem definitions and declarations
+ */
+#ifndef __LINUX_FS_NFS_NFS3_FS_H
+#define __LINUX_FS_NFS_NFS3_FS_H
+
+/* nfs3client.c */
+struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
+struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
+				     struct nfs_fattr *, rpc_authflavor_t);
+
+
+#endif /* __LINUX_FS_NFS_NFS3_FS_H */
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 809670e..524f9f8 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -22,6 +22,7 @@
 
 #include "iostat.h"
 #include "internal.h"
+#include "nfs3_fs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
-- 
2.1.0

