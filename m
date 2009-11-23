From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 07/10] nfs41: check if session exists and if it is persistent
Date: Mon, 23 Nov 2009 13:54:44 -0800
Message-ID: <1259013287-3349-7-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
 <1259013287-3349-5-git-send-email-batsakis@netapp.com>
 <1259013287-3349-6-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757288AbZKWV7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:25 -0500
In-Reply-To: <1259013287-3349-6-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/internal.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4664dc5..7c44804 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -30,6 +30,15 @@ static inline int nfs4_has_session(const struct nfs_client *clp)
 	return 0;
 }
 
+static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp))
+		return (clp->cl_session->flags & SESSION4_PERSIST);
+#endif /* CONFIG_NFS_V4_1 */
+	return 0;
+}
+
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
-- 
1.6.2.5

