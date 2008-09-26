From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 6/7] nfs: prepare to share nfs_set_port
Date: Fri, 26 Sep 2008 19:35:16 -0400
Message-ID: <1222472117-9773-7-git-send-email-bfields@citi.umich.edu>
References: <1222472117-9773-1-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-2-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-3-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-4-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-5-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-6-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbYIZXfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:35:21 -0400
In-Reply-To: <1222472117-9773-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We plan to use this function elsewhere.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/internal.h |   18 ++++++++++++++++++
 fs/nfs/super.c    |   19 -------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 24241fc..926d8db 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,3 +276,21 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
+/*
+ * Set the port number in an address.  Be agnostic about the address
+ * family.
+ */
+static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
+{
+	struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+	struct sockaddr_in6 *ap6 = (struct sockaddr_in6 *)sap;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		ap->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		ap6->sin6_port = htons(port);
+		break;
+	}
+}
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c989e71..9608797 100644
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

