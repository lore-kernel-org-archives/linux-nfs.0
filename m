Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64939 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab2JKPLC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:11:02 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3136165iea.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:11:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] mountd: Use static buffer when constructing junction
 export options
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:10:59 -0400
Message-ID: <20121011151059.4665.71119.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Simplify locations_to_export() by constructing a junction's
export options in a static buffer.

We can do this because all of this code is called serially, in one
thread, and the result is thrown away immediately after the caller
is finished.  The returned exportent itself is static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |   36 +++++-------------------------------
 1 files changed, 5 insertions(+), 31 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 942fdbd..8de2eac 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -917,14 +917,15 @@ out_false:
  *
  * Returned exportent points to static memory.
  */
-static struct exportent *do_locations_to_export(struct jp_ops *ops,
-		nfs_fsloc_set_t locations, const char *junction,
-		char *options, size_t options_len)
+static struct exportent *locations_to_export(struct jp_ops *ops,
+		nfs_fsloc_set_t locations, const char *junction)
 {
+	static char options[BUFSIZ];
 	struct exportent *exp;
 	int ttl;
 
-	if (!locations_to_options(ops, locations, options, options_len, &ttl))
+	options[0] = '\0';
+	if (!locations_to_options(ops, locations, options, sizeof(options), &ttl))
 		return NULL;
 
 	exp = mkexportent("*", (char *)junction, options);
@@ -939,33 +940,6 @@ static struct exportent *do_locations_to_export(struct jp_ops *ops,
 }
 
 /*
- * Convert set of FS locations to an exportent.  Returns pointer to
- * an exportent if "junction" refers to a junction.
- *
- * Returned exportent points to static memory.
- */
-static struct exportent *locations_to_export(struct jp_ops *ops,
-		nfs_fsloc_set_t locations, const char *junction)
-{
-	struct exportent *exp;
-	char *options;
-
-	options = malloc(BUFSIZ);
-	if (options == NULL) {
-		xlog(D_GENERAL, "%s: failed to allocate options buffer",
-			__func__);
-		return NULL;
-	}
-	options[0] = '\0';
-
-	exp = do_locations_to_export(ops, locations, junction,
-						options, BUFSIZ);
-
-	free(options);
-	return exp;
-}
-
-/*
  * Retrieve locations information in "junction" and dump it to the
  * kernel.  Returns pointer to an exportent if "junction" refers
  * to a junction.

