Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36481 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcLBD7g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:36 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:29 +1100
Subject: [PATCH 08/15] conffile: split loading of file into a separate
 function.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110933.28046.17029087040756427181.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will make support of include files easier.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |   47 ++++++++++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 21 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index e4597507b922..965726c74f6b 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -366,23 +366,18 @@ conf_init (void)
 	conf_reinit();
 }
 
-/* Open the config file and map it into our address space, then parse it.  */
-void
-conf_reinit(void)
+static int
+conf_load(int trans, char *path)
 {
-	struct conf_binding *cb = 0;
-	int fd, trans;
-	unsigned int i;
-	size_t sz;
-	char *new_conf_addr = 0;
 	struct stat sb;
+	if ((stat (path, &sb) == 0) || (errno != ENOENT)) {
+		char *new_conf_addr;
+		size_t sz = sb.st_size;
+		int fd = open (path, O_RDONLY, 0);
 
-	if ((stat (conf_path, &sb) == 0) || (errno != ENOENT)) {
-		sz = sb.st_size;
-		fd = open (conf_path, O_RDONLY, 0);
 		if (fd == -1) {
-			xlog_warn("conf_reinit: open (\"%s\", O_RDONLY) failed", conf_path);
-			return;
+			xlog_warn("conf_reinit: open (\"%s\", O_RDONLY) failed", path);
+			return -1;
 		}
 
 		new_conf_addr = malloc(sz);
@@ -399,13 +394,28 @@ conf_reinit(void)
 		}
 		close(fd);
 
-		trans = conf_begin();
 		/* XXX Should we not care about errors and rollback?  */
 		conf_parse(trans, new_conf_addr, sz);
 		free(new_conf_addr);
+		return 0;
+	fail:
+		close(fd);
+		free(new_conf_addr);
 	}
-	else
-		trans = conf_begin();
+	return -1;
+}
+
+/* Open the config file and map it into our address space, then parse it.  */
+void
+conf_reinit(void)
+{
+	struct conf_binding *cb = 0;
+	int trans;
+	unsigned int i;
+
+	trans = conf_begin();
+	if (conf_load(trans, conf_path) < 0)
+		return;
 
 	/* Load default configuration values.  */
 	conf_load_defaults();
@@ -419,11 +429,6 @@ conf_reinit(void)
 
 	conf_end(trans, 1);
 	return;
-
-fail:
-	if (new_conf_addr)
-		free(new_conf_addr);
-	close (fd);
 }
 
 /*


