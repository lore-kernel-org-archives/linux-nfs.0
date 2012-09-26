Return-Path: linux-nfs-owner@vger.kernel.org
Received: from www.0x90.at ([78.46.59.21]:17054 "EHLO mail.0x90.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376Ab2IZUBk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Sep 2012 16:01:40 -0400
Date: Wed, 26 Sep 2012 21:51:46 +0200
From: Daniel Walter <sahne@0x90.at>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfs: replace strict_strto* with kstrto*
Message-ID: <20120926195146.GA15610@0x90.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[nfs] replace strict_str* with kstr* variants
 
 * replace string conversions with newer kstr* functions

Signed-off-by: Daniel Walter <sahne@0x90.at>
---
apply against current linux-2.6 tree
---
 fs/nfs/idmap.c |    4 ++--
 fs/nfs/super.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)
---
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index a850079..814f467 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -158,7 +158,7 @@ static int nfs_map_string_to_numeric(const char *name, size_t namelen, __u32 *re
 		return 0;
 	memcpy(buf, name, namelen);
 	buf[namelen] = '\0';
-	if (strict_strtoul(buf, 0, &val) != 0)
+	if (kstrtoul(buf, 0, &val) != 0)
 		return 0;
 	*res = val;
 	return 1;
@@ -364,7 +364,7 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen, const char *typ
 	if (data_size <= 0) {
 		ret = -EINVAL;
 	} else {
-		ret = strict_strtol(id_str, 10, &id_long);
+		ret = kstrtol(id_str, 10, &id_long);
 		*id = (__u32)id_long;
 	}
 	return ret;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b8eda70..4f62ff1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1106,7 +1106,7 @@ static int nfs_get_option_ul(substring_t args[], unsigned long *option)
 	string = match_strdup(args);
 	if (string == NULL)
 		return -ENOMEM;
-	rc = strict_strtoul(string, 10, option);
+	rc = kstrtoul(string, 10, option);
 	kfree(string);
 
 	return rc;
@@ -2659,7 +2659,7 @@ static int param_set_portnr(const char *val, const struct kernel_param *kp)
 
 	if (!val)
 		return -EINVAL;
-	ret = strict_strtoul(val, 0, &num);
+	ret = kstrtoul(val, 0, &num);
 	if (ret == -EINVAL || num > NFS_CALLBACK_MAXPORTNR)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
