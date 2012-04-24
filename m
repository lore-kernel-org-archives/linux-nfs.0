Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753186Ab2DXUgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 16:36:08 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfs4: fix referrals on mounts that use IPv6 addrs
Date: Tue, 24 Apr 2012 16:35:20 -0400
Message-Id: <1335299720-50765-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All referrals (IPv4 addr, IPv6 addr, and DNS) are broken on mounts of
IPv6 addresses, because validation code uses a path that is parsed
from the dev_name ("<server>:<path>") by splitting on the first colon and
colons are used in IPv6 addrs.
This patch ignores colons within IPv6 addresses that are escaped by '[' and ']'.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Reposted to address comments from Trond and Jim

This depends on commit 2f8e4bd91488f286e83e8abb14683102efaafb05
"nfs: Enclose hostname in brackets when needed in nfs_do_root_mount".

 fs/nfs/nfs4namespace.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 9c8eca3..8c84e73 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -52,6 +52,30 @@ Elong:
 }
 
 /*
+ * return the path component of "<server>:<path>"
+ *  nfspath - the "<server>:<path>" string
+ *  end - one past the last char that could contain "<server>:"
+ * returns NULL on failure
+ */
+static char *nfs_path_component(const char *nfspath, const char *end)
+{
+	char *p;
+
+	if (*nfspath == '[') {
+		/* parse [] escaped IPv6 addrs */
+		p = strchr(nfspath, ']');
+		if (p != NULL && (p + 1) < end && *(++p) == ':')
+			return p + 1;
+	} else {
+		/* otherwise split on first colon */
+		p = strchr(nfspath, ':');
+		if (p != NULL && p < end)
+			return p + 1;
+	}
+	return NULL;
+}
+
+/*
  * Determine the mount path as a string
  */
 static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
@@ -59,9 +83,9 @@ static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
 	char *limit;
 	char *path = nfs_path(&limit, dentry, buffer, buflen);
 	if (!IS_ERR(path)) {
-		char *colon = strchr(path, ':');
-		if (colon && colon < limit)
-			path = colon + 1;
+		char *path_component = nfs_path_component(path, limit);
+		if (path_component)
+			return path_component;
 	}
 	return path;
 }
-- 
1.7.4.4

