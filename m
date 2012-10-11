Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64939 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab2JKPLS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:11:18 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3136165iea.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:11:18 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] mountd: Add lookup_export_parent()
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:11:17 -0400
Message-ID: <20121011151117.4665.62505.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a moment I will be adding some logic that needs to know an
junction's parent export.

Here's a function that can discover an export's parent.  It takes
the target export's pathname, chops off the rightmost component, and
tries a lookup_export().  If that succeeds, we have our answer.
If not, it chops off the next rightmost component and tries again,
until the root is reached.

At the same time, infrastructure is added to pass the parent export
down into the functions that convert locations into a new junction
export entry.  For now the parent export remains unused.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |   79 ++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 70 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index f63803b..b858e60 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -831,6 +831,60 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 #include <nfs-plugin.h>
 
 /*
+ * Find the export entry for the parent of "pathname".
+ * Caller must not free returned exportent.
+ */
+static struct exportent *lookup_parent_export(char *dom,
+		const char *pathname, struct addrinfo *ai)
+{
+	char *parent, *slash;
+	nfs_export *result;
+
+	parent = strdup(pathname);
+	if (parent == NULL) {
+		xlog(D_GENERAL, "%s: failed to allocate parent path buffer",
+			__func__);
+		goto out_default;
+	}
+	xlog(D_CALL, "%s: pathname = '%s'", __func__, pathname);
+
+again:
+	/* shorten pathname by one component */
+	slash = strrchr(parent, '/');
+	if (slash == NULL) {
+		xlog(D_GENERAL, "%s: no slash found in pathname",
+			__func__);
+		goto out_default;
+	}
+	*slash = '\0';
+
+	if (strlen(parent) == 0) {
+		result = lookup_export(dom, "/", ai);
+		if (result == NULL) {
+			xlog(L_ERROR, "%s: no root export found.", __func__);
+			goto out_default;
+		}
+		goto out;
+	}
+
+	result = lookup_export(dom, parent, ai);
+	if (result == NULL) {
+		xlog(D_GENERAL, "%s: lookup_export(%s) found nothing",
+			__func__, parent);
+		goto again;
+	}
+
+out:
+	xlog(D_CALL, "%s: found export for %s", __func__, parent);
+	free(parent);
+	return &result->m_export;
+
+out_default:
+	free(parent);
+	return mkexportent("*", "/", "insecure");
+}
+
+/*
  * Walk through a set of FS locations and build an e_fslocdata string.
  * Returns true if all went to plan; otherwise, false.
  */
@@ -918,7 +972,8 @@ out_false:
  * Returned exportent points to static memory.
  */
 static struct exportent *locations_to_export(struct jp_ops *ops,
-		nfs_fsloc_set_t locations, const char *junction)
+		nfs_fsloc_set_t locations, const char *junction,
+		struct exportent *UNUSED(parent))
 {
 	static char fslocdata[BUFSIZ];
 	struct exportent *exp;
@@ -955,10 +1010,10 @@ static struct exportent *locations_to_export(struct jp_ops *ops,
  *
  * Returned exportent points to static memory.
  */
-static struct exportent *invoke_junction_ops(void *handle,
-		const char *junction)
+static struct exportent *invoke_junction_ops(void *handle, char *dom,
+		const char *junction, struct addrinfo *ai)
 {
-	struct exportent *exp = NULL;
+	struct exportent *parent, *exp = NULL;
 	nfs_fsloc_set_t locations;
 	enum jp_status status;
 	struct jp_ops *ops;
@@ -998,7 +1053,11 @@ static struct exportent *invoke_junction_ops(void *handle,
 		goto out;
 	}
 
-	exp = locations_to_export(ops, locations, junction);
+	parent = lookup_parent_export(dom, junction, ai);
+	if (parent == NULL)
+		goto out;
+
+	exp = locations_to_export(ops, locations, junction, parent);
 
 	ops->jp_put_locations(locations);
 
@@ -1014,7 +1073,8 @@ out:
  *
  * Returned exportent points to static memory.
  */
-static struct exportent *lookup_junction(const char *pathname)
+static struct exportent *lookup_junction(char *dom, const char *pathname,
+		struct addrinfo *ai)
 {
 	struct exportent *exp;
 	void *handle;
@@ -1026,7 +1086,7 @@ static struct exportent *lookup_junction(const char *pathname)
 	}
 	(void)dlerror();	/* Clear any error */
 
-	exp = invoke_junction_ops(handle, pathname);
+	exp = invoke_junction_ops(handle, dom, pathname, ai);
 
 	/* We could leave it loaded to make junction resolution
 	 * faster next time.  However, if we want to replace the
@@ -1035,7 +1095,8 @@ static struct exportent *lookup_junction(const char *pathname)
 	return exp;
 }
 #else	/* !HAVE_NFS_PLUGIN_H */
-static inline struct exportent *lookup_junction(const char *UNUSED(pathname))
+static inline struct exportent *lookup_junction(char *UNUSED(dom),
+		const char *UNUSED(pathname), struct addrinfo *UNUSED(ai))
 {
 	return NULL;
 }
@@ -1089,7 +1150,7 @@ static void nfsd_export(FILE *f)
 			dump_to_cache(f, dom, path, NULL);
 		}
 	} else {
-		dump_to_cache(f, dom, path, lookup_junction(path));
+		dump_to_cache(f, dom, path, lookup_junction(dom, path, ai));
 	}
  out:
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);

