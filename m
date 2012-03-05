Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42116 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757549Ab2CET6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 14:58:32 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Undo changes to idmap.h
Date: Mon,  5 Mar 2012 14:58:15 -0500
Message-Id: <1330977495-27824-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

When compiled without NFS v4 configured these function won't be defined
and the compiler will yell.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 include/linux/nfs_idmap.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 717fa50..7eed201 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -69,8 +69,19 @@ struct nfs_server;
 struct nfs_fattr;
 struct nfs4_string;
 
+#ifdef CONFIG_NFS_V4
 int nfs_idmap_init(void);
 void nfs_idmap_quit(void);
+#else
+static inline int nfs_idmap_init(void)
+{
+	return 0;
+}
+
+static inline void nfs_idmap_quit(void)
+{}
+#endif
+
 int nfs_idmap_new(struct nfs_client *);
 void nfs_idmap_delete(struct nfs_client *);
 
-- 
1.7.9.2

