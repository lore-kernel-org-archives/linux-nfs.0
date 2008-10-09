From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] NFS: Cleanup nfs_set_port
Date: Thu, 09 Oct 2008 15:00:32 -0400
Message-ID: <20081009190032.18388.45498.stgit@localhost.localdomain>
References: <20081009190031.18388.95039.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760718AbYJITEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:04:31 -0400
In-Reply-To: <20081009190031.18388.95039.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index be091cb..98dcc9c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -283,16 +283,15 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
  */
 static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
 {
+	struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+	struct sockaddr_in6 *ap6 = (struct sockaddr_in6 *)sap;
+
 	switch (sap->sa_family) {
-	case AF_INET: {
-	      struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-	      ap->sin_port = htons(port);
-	      break;
-	}
-	case AF_INET6: {
-	       struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
-	       ap->sin6_port = htons(port);
-	       break;
-	}
+	case AF_INET:
+		ap->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		ap6->sin6_port = htons(port);
+		break;
 	}
 }

