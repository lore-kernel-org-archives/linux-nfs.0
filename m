Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30251 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755093Ab2DXPHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 11:07:50 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfs4: fix referrals on mounts that use IPv6 addrs
Date: Tue, 24 Apr 2012 11:07:47 -0400
Message-Id: <1335280067-47391-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All referrals (IPv4 addr, IPv6 addr, and DNS) are broken on mounts of
IPv6 addresses, because validation code uses a path that is parsed
from the dev_name ("<server>:<path>") by splitting on the first colon and
colons are used in IPv6 addrs.
This patch ignores colons within IPv6 addresses that are escaped by '[' and ']'.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

Updated to pass checkpatch.pl - sorry for posting twice!

This depends on commit 2f8e4bd91488f286e83e8abb14683102efaafb05
"nfs: Enclose hostname in brackets when needed in nfs_do_root_mount".

 fs/nfs/nfs4namespace.c |   35 ++++++++++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 9c8eca3..f90c7b3 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -52,6 +52,35 @@ Elong:
 }
 
 /*
+ * parse the path component of an nfs path ("<server>:<path>").
+ *  nfspath - the "<server>:<path>" string
+ *  end - pointer to end of devname component of 'nfspath'
+ * returns NULL on failure
+ */
+static inline char *nfs_parse_path_component(char *nfspath, char *end)
+{
+	bool ipv6_esc = false;
+	char *p;
+
+	/* find first colon not in IPv6 addr */
+	for (p = nfspath; p < end && *p; p++) {
+		switch (*p) {
+		case '[':
+			ipv6_esc = true;
+			break;
+		case ']':
+			ipv6_esc = false;
+			break;
+		case ':':
+			if (!ipv6_esc)
+				return p + 1;
+			break;
+		}
+	}
+	return NULL;
+}
+
+/*
  * Determine the mount path as a string
  */
 static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
@@ -59,9 +88,9 @@ static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
 	char *limit;
 	char *path = nfs_path(&limit, dentry, buffer, buflen);
 	if (!IS_ERR(path)) {
-		char *colon = strchr(path, ':');
-		if (colon && colon < limit)
-			path = colon + 1;
+		char *path_component = nfs_parse_path_component(path, limit);
+		if (path_component)
+			return path_component;
 	}
 	return path;
 }
-- 
1.7.4.4

