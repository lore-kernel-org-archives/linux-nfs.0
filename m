Return-Path: linux-nfs-owner@vger.kernel.org
Received: from maui.cs.washington.edu ([128.208.5.86]:57799 "EHLO
	maui.cs.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545Ab2JVSli (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 14:41:38 -0400
Date: 22 Oct 2012 11:35 PDT
From: Jan Sanislo <oystr@cs.washington.edu>
Subject: [PATCH 01/01] Allow nfsidmap to set key timeout
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com, SteveD@redhat.com
Message-Id: <1350930905/oystr@maui.cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsidmap calls keyctl_set_timeout after the key has been
instantiated, by which time our key modification privileges
have been removed.  Move the timeout setting prior to key
instantiation.

Reviewed-by: Jeff Layton jlayton@redhat.com
Signed-off-by: Jan Sanislo oystr@cs.washington.edu

--- a/nfs-utils-1.2.6/utils/nfsidmap/nfsidmap.c
+++ b/nfs-utils-1.2.6/utils/nfsidmap/nfsidmap.c
@@ -320,6 +320,16 @@
 			key, type, value, timeout);
 	}
 
+	/*
+	 * Set timeout before instantiation revokes our rights
+	 * over the key.
+	 */
+	if ( timeout > 0 ) {
+		rc = keyctl_set_timeout(key, timeout);
+		if ( rc != 0 )
+			xlog_warn("keyctl_set_timeout key 0x%x failed: %m",key);
+	}
+
 	if (strcmp(type, "uid") == 0)
 		rc = id_lookup(value, key, USER);
 	else if (strcmp(type, "gid") == 0)
@@ -329,10 +339,6 @@
 	else if (strcmp(type, "group") == 0)
 		rc = name_lookup(value, key, GROUP);
 
-	/* Set timeout to 10 (600 seconds) minutes */
-	if (rc == 0)
-		keyctl_set_timeout(key, timeout);
-
 	free(arg);
 	return rc;
 }
