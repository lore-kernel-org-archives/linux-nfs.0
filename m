From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/30] nfs: prepare to share nfs_set_port
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.49788.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095AbYJGWcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:48 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We plan to use this function elsewhere.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h |   20 ++++++++++++++++++++
 fs/nfs/super.c    |   19 -------------------
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7bcf6ec..8d91bd8 100644
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
index 1e35586..b99096b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -675,25 +675,6 @@ static void nfs_umount_begin(struct super_block *sb)
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

