From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/4] nfs: prepare to share nfs_set_port
Date: Wed, 20 Aug 2008 16:10:22 -0400
Message-ID: <1219263023-22592-3-git-send-email-bfields@citi.umich.edu>
References: <20080820200827.GC21226@fieldses.org>
 <1219263023-22592-1-git-send-email-bfields@citi.umich.edu>
 <1219263023-22592-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752967AbYHTUKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 16:10:25 -0400
In-Reply-To: <1219263023-22592-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We plan to use this function elsewhere.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/internal.h |   20 ++++++++++++++++++++
 fs/nfs/super.c    |   19 -------------------
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 24241fc..0b30f24 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,3 +276,23 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
+
+/*
+ * Set the port number in an address.  Be agnostic about the address
+ * family.
+ */
+static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
+{
+	switch (sap->sa_family) {
+	case AF_INET: {
+	      struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+	      ap->sin_port = htons(port);
+	      break;
+	}
+	case AF_INET6: {
+	       struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+	       ap->sin6_port = htons(port);
+	       break;
+	}
+	}
+}
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9abcd2b..497dd31 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -664,25 +664,6 @@ static void nfs_umount_begin(struct super_block *sb)
 }
 
 /*
- * Set the port number in an address.  Be agnostic about the address family.
- */
-static void nfs_set_port(struct sockaddr *sap, unsigned short port)
-{
-	switch (sap->sa_family) {
-	case AF_INET: {
-		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-		ap->sin_port = htons(port);
-		break;
-	}
-	case AF_INET6: {
-		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
-		ap->sin6_port = htons(port);
-		break;
-	}
-	}
-}
-
-/*
  * Sanity-check a server address provided by the mount command.
  *
  * Address family must be initialized, and address must not be
-- 
1.5.5.rc1

