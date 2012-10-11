Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:53157 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757691Ab2JKPLp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:11:45 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1304641iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:11:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] mountd: Dynamically allocate exportent that represents
 junctions
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:11:43 -0400
Message-ID: <20121011151143.4665.12217.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're now duplicating a real exportent with arbitrary export options
to create a junction exportent.  After a dupexportent() call,
several of the structure's fields can point to dynamically allocated
memory.  We have to be careful about not orphaning that memory.

What's more, returning a pointer to a static structure is as 90's as
a bad mullet.  It's more straightforward to allocate the exportent
dynamically and release it when we are through with it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |   55 ++++++++++++++++++++++++++++----------------------
 1 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9c2b972..457fc9c 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -968,30 +968,36 @@ out_false:
 /*
  * Duplicate the junction's parent's export options and graft in
  * the fslocdata we constructed from the locations list.
- *
- * Returned exportent points to static memory.
  */
 static struct exportent *create_junction_exportent(struct exportent *parent,
 		const char *junction, const char *fslocdata, int ttl)
 {
-	static struct exportent ee;
+	static struct exportent *eep;
 
-	dupexportent(&ee, parent);
-	strcpy(ee.e_path, junction);
-	ee.e_hostname = strdup(parent->e_hostname);
-	if (ee.e_hostname == NULL)
-		goto out_nomem;
-	free(ee.e_uuid);
-	ee.e_uuid = NULL;
-	ee.e_ttl = (unsigned int)ttl;
-
-	free(ee.e_fslocdata);
-	ee.e_fslocmethod = FSLOC_REFER;
-	ee.e_fslocdata = strdup(fslocdata);
-	if (ee.e_fslocdata == NULL)
+	eep = (struct exportent *)malloc(sizeof(*eep));
+	if (eep == NULL)
 		goto out_nomem;
 
-	return &ee;
+	dupexportent(eep, parent);
+	strcpy(eep->e_path, junction);
+	eep->e_hostname = strdup(parent->e_hostname);
+	if (eep->e_hostname == NULL) {
+		free(eep);
+		goto out_nomem;
+	}
+	free(eep->e_uuid);
+	eep->e_uuid = NULL;
+	eep->e_ttl = (unsigned int)ttl;
+
+	free(eep->e_fslocdata);
+	eep->e_fslocdata = strdup(fslocdata);
+	if (eep->e_fslocdata == NULL) {
+		free(eep->e_hostname);
+		free(eep);
+		goto out_nomem;
+	}
+	eep->e_fslocmethod = FSLOC_REFER;
+	return eep;
 
 out_nomem:
 	xlog(L_ERROR, "%s: No memory", __func__);
@@ -1001,8 +1007,6 @@ out_nomem:
 /*
  * Walk through the set of FS locations and build an exportent.
  * Returns pointer to an exportent if "junction" refers to a junction.
- *
- * Returned exportent points to static memory.
  */
 static struct exportent *locations_to_export(struct jp_ops *ops,
 		nfs_fsloc_set_t locations, const char *junction,
@@ -1022,8 +1026,6 @@ static struct exportent *locations_to_export(struct jp_ops *ops,
  * Retrieve locations information in "junction" and dump it to the
  * kernel.  Returns pointer to an exportent if "junction" refers
  * to a junction.
- *
- * Returned exportent points to static memory.
  */
 static struct exportent *invoke_junction_ops(void *handle, char *dom,
 		const char *junction, struct addrinfo *ai)
@@ -1085,8 +1087,6 @@ out:
  * Load the junction plug-in, then try to resolve "pathname".
  * Returns pointer to an initialized exportent if "junction"
  * refers to a junction, or NULL if not.
- *
- * Returned exportent points to static memory.
  */
 static struct exportent *lookup_junction(char *dom, const char *pathname,
 		struct addrinfo *ai)
@@ -1165,7 +1165,14 @@ static void nfsd_export(FILE *f)
 			dump_to_cache(f, dom, path, NULL);
 		}
 	} else {
-		dump_to_cache(f, dom, path, lookup_junction(dom, path, ai));
+		struct exportent *eep;
+
+		eep = lookup_junction(dom, path, ai);
+		dump_to_cache(f, dom, path, eep);
+		if (eep != NULL) {
+			exportent_release(eep);
+			free(eep);
+		}
 	}
  out:
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);

