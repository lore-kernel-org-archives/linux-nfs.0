Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36466 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcLBD7b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:31 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:29 +1100
Subject: [PATCH 07/15] conffile: free image of config file after parsing
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110911.28046.15239417720166462424.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

conffile allocates memory and reads in the config file.
It then parses the file, using strdup() to take a copy of
any string that it uses, so after conf_parse() there are no
references in to the allocated file image.

conffile does not free this image.  It keeps a pointer, but never uses
it in an interesing way, and never frees it.  This is a little clumsy
and interfers with a future patch which will support the inclusion of
subordinate config files.

So free 'new_conf_addr' when finished with it, and discard the
'conf_addr' variable that stored it.
This has an insignificant performance consequence in that we node
always free everything in the hash table, even when we know it must
be empty.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 609d78294f35..e4597507b922 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -107,8 +107,6 @@ struct conf_binding {
 char *conf_path;
 LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
 
-static char *conf_addr;
-
 static __inline__ uint8_t
 conf_hash(char *s)
 {
@@ -396,7 +394,7 @@ conf_reinit(void)
 		/* XXX I assume short reads won't happen here.  */
 		if (read (fd, new_conf_addr, sz) != (int)sz) {
 			xlog_warn("conf_reinit: read (%d, %p, %lu) failed",
-   				fd, new_conf_addr, (unsigned long)sz);
+				fd, new_conf_addr, (unsigned long)sz);
 			goto fail;
 		}
 		close(fd);
@@ -404,6 +402,7 @@ conf_reinit(void)
 		trans = conf_begin();
 		/* XXX Should we not care about errors and rollback?  */
 		conf_parse(trans, new_conf_addr, sz);
+		free(new_conf_addr);
 	}
 	else
 		trans = conf_begin();
@@ -412,17 +411,13 @@ conf_reinit(void)
 	conf_load_defaults();
 
 	/* Free potential existing configuration.  */
-	if (conf_addr) {
-		for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++) {
-			cb = LIST_FIRST (&conf_bindings[i]);
-			for (; cb; cb = LIST_FIRST (&conf_bindings[i]))
-				conf_remove_now(cb->section, cb->tag);
-		}
-		free (conf_addr);
+	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++) {
+		cb = LIST_FIRST (&conf_bindings[i]);
+		for (; cb; cb = LIST_FIRST (&conf_bindings[i]))
+			conf_remove_now(cb->section, cb->tag);
 	}
 
 	conf_end(trans, 1);
-	conf_addr = new_conf_addr;
 	return;
 
 fail:


