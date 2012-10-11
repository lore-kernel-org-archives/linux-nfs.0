Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64939 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757691Ab2JKPL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:11:27 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3136165iea.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:11:27 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] mountd: Junctions inherit parent export's options
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:11:25 -0400
Message-ID: <20121011151125.4665.50408.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attempting to access junctions on a Linux NFS server from an NFS
client connected via an ephemeral source port fails with a "client
insecure" error on the server.  This happens even when the
"insecure" export option is specified on the junction's parent
export.

As a test, via a mountd code change, I added "insecure" to the fixed
export options that mountd sets up for each junction, and the error
disappeared.

It's simple enough for old-school referrals configured directly in
/etc/exports ("refer=") to have the needed options specified there.
Cache entries for junctions, however, are created on the fly by
mountd, and don't ever appear in /etc/exports.  So there's nowhere
obvious that export options for junctions can be specified.

Bruce suggested that in order to specify unique export options for
junctions, they should inherit the export options of their parent
export.  The junction's parent's exportent is duplicated in order
to create an exportent for the junction itself.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |   55 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index b858e60..9c2b972 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -966,6 +966,39 @@ out_false:
 }
 
 /*
+ * Duplicate the junction's parent's export options and graft in
+ * the fslocdata we constructed from the locations list.
+ *
+ * Returned exportent points to static memory.
+ */
+static struct exportent *create_junction_exportent(struct exportent *parent,
+		const char *junction, const char *fslocdata, int ttl)
+{
+	static struct exportent ee;
+
+	dupexportent(&ee, parent);
+	strcpy(ee.e_path, junction);
+	ee.e_hostname = strdup(parent->e_hostname);
+	if (ee.e_hostname == NULL)
+		goto out_nomem;
+	free(ee.e_uuid);
+	ee.e_uuid = NULL;
+	ee.e_ttl = (unsigned int)ttl;
+
+	free(ee.e_fslocdata);
+	ee.e_fslocmethod = FSLOC_REFER;
+	ee.e_fslocdata = strdup(fslocdata);
+	if (ee.e_fslocdata == NULL)
+		goto out_nomem;
+
+	return &ee;
+
+out_nomem:
+	xlog(L_ERROR, "%s: No memory", __func__);
+	return NULL;
+}
+
+/*
  * Walk through the set of FS locations and build an exportent.
  * Returns pointer to an exportent if "junction" refers to a junction.
  *
@@ -973,34 +1006,16 @@ out_false:
  */
 static struct exportent *locations_to_export(struct jp_ops *ops,
 		nfs_fsloc_set_t locations, const char *junction,
-		struct exportent *UNUSED(parent))
+		struct exportent *parent)
 {
 	static char fslocdata[BUFSIZ];
-	struct exportent *exp;
 	int ttl;
 
 	fslocdata[0] = '\0';
 	if (!locations_to_fslocdata(ops, locations,
 					fslocdata, sizeof(fslocdata), &ttl))
 		return NULL;
-
-	exp = mkexportent("*", (char *)junction, "");
-	if (exp == NULL) {
-		xlog(L_ERROR, "%s: Failed to construct exportent", __func__);
-		return NULL;
-	}
-
-	exp->e_uuid = NULL;
-	exp->e_ttl = ttl;
-
-	free(exp->e_fslocdata);
-	exp->e_fslocmethod = FSLOC_REFER;
-	exp->e_fslocdata = strdup(fslocdata);
-	if (exp->e_fslocdata == NULL) {
-		xlog(L_ERROR, "%s: No memory", __func__);
-		return NULL;
-	}
-	return exp;
+	return create_junction_exportent(parent, junction, fslocdata, ttl);
 }
 
 /*

