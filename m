Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862Ab2CLP20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 11:28:26 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Only define some function when v4.1 is enabled
Date: Mon, 12 Mar 2012 11:28:24 -0400
Message-Id: <1331566104-10149-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Now that the nfs4_cb_match_client() function is static, gcc notices that
it is only used when CONFIG_NFS_V4_1 is enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 38e16a2..ec31a0a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -380,6 +380,7 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
 		(sin1->sin_port == sin2->sin_port);
 }
 
+#if defined(CONFIG_NFS_V4_1)
 /*
  * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, excluding the port number.
@@ -398,6 +399,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	}
 	return 0;
 }
+#endif /* CONFIG_NFS_V4_1 */
 
 /*
  * Test if two socket addresses represent the same actual socket,
@@ -418,6 +420,7 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	return 0;
 }
 
+#if defined(CONFIG_NFS_V4_1)
 /* Common match routine for v4.0 and v4.1 callback services */
 static bool nfs4_cb_match_client(const struct sockaddr *addr,
 		struct nfs_client *clp, u32 minorversion)
@@ -440,6 +443,7 @@ static bool nfs4_cb_match_client(const struct sockaddr *addr,
 
 	return true;
 }
+#endif /* CONFIG_NFS_V4_1 */
 
 /*
  * Find an nfs_client on the list that matches the initialisation data
-- 
1.7.9.2

