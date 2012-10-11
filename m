Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64939 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab2JKPLK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:11:10 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3136165iea.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:11:10 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] mountd: Set e_fslocdata field directly
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:11:08 -0400
Message-ID: <20121011151108.4665.56795.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To create an export entry for a junction, an options string is
constructed from the set of locations in the junction.  This options
string is then passed to mkexportent() where it is parsed and
converted into an exportent.

There is only one export option that is used to create a junction's
exportent: "refer=".  When that option is parsed, it's value is
simply copied to a fresh string and planted in the new export's
e_fslocdata field.

Let's avoid the option parsing and extra string copy.  Construct
a string for the new e_fslocdata field and plant it in the exportent
directly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 8de2eac..f63803b 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -831,12 +831,12 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 #include <nfs-plugin.h>
 
 /*
- * Walk through a set of FS locations and build a set of export options.
+ * Walk through a set of FS locations and build an e_fslocdata string.
  * Returns true if all went to plan; otherwise, false.
  */
-static _Bool
-locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
-		char *options, size_t remaining, int *ttl)
+static bool locations_to_fslocdata(struct jp_ops *ops,
+		nfs_fsloc_set_t locations, char *fslocdata,
+		size_t remaining, int *ttl)
 {
 	char *server, *last_path, *rootpath, *ptr;
 	_Bool seen = false;
@@ -844,7 +844,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
 	last_path = NULL;
 	rootpath = NULL;
 	server = NULL;
-	ptr = options;
+	ptr = fslocdata;
 	*ttl = 0;
 
 	for (;;) {
@@ -870,14 +870,14 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
 				goto out_false;
 			}
 			if ((size_t)len >= remaining) {
-				xlog(D_GENERAL, "%s: options buffer overflow", __func__);
+				xlog(D_GENERAL, "%s: fslocdata buffer overflow", __func__);
 				goto out_false;
 			}
 			remaining -= (size_t)len;
 			ptr += len;
 		} else {
 			if (last_path == NULL)
-				len = snprintf(ptr, remaining, "refer=%s@%s",
+				len = snprintf(ptr, remaining, "%s@%s",
 							rootpath, server);
 			else
 				len = snprintf(ptr, remaining, ":%s@%s",
@@ -887,7 +887,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
 				goto out_false;
 			}
 			if ((size_t)len >= remaining) {
-				xlog(D_GENERAL, "%s: options buffer overflow",
+				xlog(D_GENERAL, "%s: fslocdata buffer overflow",
 					__func__);
 				goto out_false;
 			}
@@ -901,8 +901,8 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
 		free(server);
 	}
 
-	xlog(D_CALL, "%s: options='%s', ttl=%d",
-		__func__, options, *ttl);
+	xlog(D_CALL, "%s: fslocdata='%s', ttl=%d",
+		__func__, fslocdata, *ttl);
 	return seen;
 
 out_false:
@@ -920,15 +920,16 @@ out_false:
 static struct exportent *locations_to_export(struct jp_ops *ops,
 		nfs_fsloc_set_t locations, const char *junction)
 {
-	static char options[BUFSIZ];
+	static char fslocdata[BUFSIZ];
 	struct exportent *exp;
 	int ttl;
 
-	options[0] = '\0';
-	if (!locations_to_options(ops, locations, options, sizeof(options), &ttl))
+	fslocdata[0] = '\0';
+	if (!locations_to_fslocdata(ops, locations,
+					fslocdata, sizeof(fslocdata), &ttl))
 		return NULL;
 
-	exp = mkexportent("*", (char *)junction, options);
+	exp = mkexportent("*", (char *)junction, "");
 	if (exp == NULL) {
 		xlog(L_ERROR, "%s: Failed to construct exportent", __func__);
 		return NULL;
@@ -936,6 +937,14 @@ static struct exportent *locations_to_export(struct jp_ops *ops,
 
 	exp->e_uuid = NULL;
 	exp->e_ttl = ttl;
+
+	free(exp->e_fslocdata);
+	exp->e_fslocmethod = FSLOC_REFER;
+	exp->e_fslocdata = strdup(fslocdata);
+	if (exp->e_fslocdata == NULL) {
+		xlog(L_ERROR, "%s: No memory", __func__);
+		return NULL;
+	}
 	return exp;
 }
 

