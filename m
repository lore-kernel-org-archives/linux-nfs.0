From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 21/24] Removed warnings from network.c
Date: Tue, 20 Jul 2010 19:37:34 -0400
Message-ID: <1279669057-17509-22-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60379 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761898Ab0GUAnL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:11 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNZ-0004K5-Ak
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:41 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

network.c: In function 'nfs_verify_family':
network.c:1366: warning: unused parameter 'family'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ffb18ab..8d48ce0 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1362,11 +1362,6 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 #ifdef IPV6_SUPPORTED
 sa_family_t	config_default_family = AF_UNSPEC;
 
-static int
-nfs_verify_family(sa_family_t family)
-{
-	return 1;
-}
 #else /* IPV6_SUPPORTED */
 sa_family_t	config_default_family = AF_INET;
 
@@ -1410,13 +1405,15 @@ int nfs_nfs_proto_family(struct mount_options *options,
 		}
 	}
 
-	if (!nfs_verify_family(tmp_family))
-		goto out_err;
+#ifndef IPV6_SUPPORTED
+	if (!nfs_verify_family(tmp_family)) {
+		errno = EAFNOSUPPORT;
+		return 0;
+	}
+#endif
+
 	*family = tmp_family;
 	return 1;
-out_err:
-	errno = EAFNOSUPPORT;
-	return 0;
 }
 
 /*
@@ -1566,8 +1563,10 @@ int nfs_mount_proto_family(struct mount_options *options,
 			errno = EPROTONOSUPPORT;
 			goto out_err;
 		}
+#ifndef IPV6_SUPPORTED
 		if (!nfs_verify_family(tmp_family))
 			goto out_err;
+#endif
 		*family = tmp_family;
 		return 1;
 	}
-- 
1.7.0.1

