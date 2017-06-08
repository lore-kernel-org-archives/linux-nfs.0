Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51896 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750919AbdFHQeN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 12:34:13 -0400
Message-ID: <1496939645.4216.13.camel@redhat.com>
Subject: [PATCH] Reimplement include functionality in nfs.conf
From: Justin Mitchell <jumitche@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <SteveD@RedHat.com>, NeilBrown <neilb@suse.com>
Date: Thu, 08 Jun 2017 17:34:05 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Re-implement include file functionality as documented.

Existing implementation had various issues, one of which was it allowed
a subordinate file to inadvertently change which section the subsequent
tags back in the master config file got assigned to.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>



---
 support/nfs/conffile.c | 78 ++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 56 insertions(+), 22 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 449ac1c..05e0a6f 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -56,9 +56,11 @@
 #pragma GCC visibility push(hidden)
 
 static void conf_load_defaults(void);
-static int conf_load(int trans, const char *path);
+static char * conf_load(const char *path);
 static int conf_set(int , char *, char *, char *, 
 	char *, int , int );
+static void conf_parse(int trans, char *buf, 
+	char **section, char **subsection);
 
 struct conf_trans {
 	TAILQ_ENTRY (conf_trans) link;
@@ -202,7 +204,6 @@ conf_set_now(char *section, char *arg, char *tag,
 	node->tag = strdup(tag);
 	node->value = strdup(value);
 	node->is_default = is_default;
-
 	LIST_INSERT_HEAD(&conf_bindings[conf_hash (section)], node, link);
 	return 0;
 }
@@ -365,22 +366,47 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 		return;
 	}
 
-	/* XXX Perhaps should we not ignore errors?  */
-	conf_set(trans, *section, *subsection, line, val, 0, 0);
+	if (strcasecmp(line, "include")==0) {
+		/* load and parse subordinate config files */
+		char * subconf = conf_load(val);
+		if (subconf == NULL) {
+			xlog_warn("config file error: line %d: "
+			"error loading included config", lineno);
+			return;
+		}
+
+		/* copy the section data so the included file can inherit it
+		 * without accidentally changing it for us */
+		char * inc_section = NULL;
+		char * inc_subsection = NULL;
+		if (*section != NULL) {
+			inc_section = strdup(*section);
+			if (*subsection != NULL)
+				inc_subsection = strdup(*subsection);
+		}
+
+		conf_parse(trans, subconf, &inc_section, &inc_subsection);
+
+		if (inc_section) free(inc_section);
+		if (inc_subsection) free(inc_subsection);
+		free(subconf);
+	} else {
+		/* XXX Perhaps should we not ignore errors?  */
+		conf_set(trans, *section, *subsection, line, val, 0, 0);
+	}
 }
 
 /* Parse the mapped configuration file.  */
 static void
-conf_parse(int trans, char *buf, size_t sz)
+conf_parse(int trans, char *buf, char **section, char **subsection)
 {
 	char *cp = buf;
-	char *bufend = buf + sz;
+	char *bufend = NULL;
 	char *line;
-	char *section = NULL;
-	char *subsection = NULL;
 	int lineno = 0;
 
 	line = cp;
+	bufend = buf + strlen(buf);
 	while (cp < bufend) {
 		if (*cp == '\n') {
 			/* Check for escaped newlines.  */
@@ -389,7 +415,7 @@ conf_parse(int trans, char *buf, size_t sz)
 			else {
 				*cp = '\0';
 				lineno++;
-				conf_parse_line(trans, line, lineno, &section, &subsection);
+				conf_parse_line(trans, line, lineno, section, subsection);
 				line = cp + 1;
 			}
 		}
@@ -397,8 +423,6 @@ conf_parse(int trans, char *buf, size_t sz)
 	}
 	if (cp != line)
 		xlog_warn("conf_parse: last line non-terminated, ignored.");
-	if (section) free(section);
-	if (subsection) free(subsection);
 }
 
 static void
@@ -408,21 +432,21 @@ conf_load_defaults(void)
 	return;
 }
 
-static int
-conf_load(int trans, const char *path)
+static char *
+conf_load(const char *path)
 {
 	struct stat sb;
 	if ((stat (path, &sb) == 0) || (errno != ENOENT)) {
-		char *new_conf_addr;
+		char *new_conf_addr = NULL;
 		size_t sz = sb.st_size;
 		int fd = open (path, O_RDONLY, 0);
 
 		if (fd == -1) {
 			xlog_warn("conf_reinit: open (\"%s\", O_RDONLY) failed", path);
-			return -1;
+			return NULL;
 		}
 
-		new_conf_addr = malloc(sz);
+		new_conf_addr = malloc(sz+1);
 		if (!new_conf_addr) {
 			xlog_warn("conf_reinit: malloc (%lu) failed", (unsigned long)sz);
 			goto fail;
@@ -437,14 +461,13 @@ conf_load(int trans, const char *path)
 		close(fd);
 
 		/* XXX Should we not care about errors and rollback?  */
-		conf_parse(trans, new_conf_addr, sz);
-		free(new_conf_addr);
-		return 0;
+		new_conf_addr[sz] = '\0';
+		return new_conf_addr;
 	fail:
 		close(fd);
-		free(new_conf_addr);
+		if (new_conf_addr) free(new_conf_addr);
 	}
-	return -1;
+	return NULL;
 }
 
 /* remove and free up any existing config state */
@@ -473,14 +496,25 @@ static void
 conf_reinit(const char *conf_file)
 {
 	int trans;
+	char * conf_data;
 
 	trans = conf_begin();
-	if (conf_load(trans, conf_file) < 0)
+	conf_data = conf_load(conf_file);
+
+	if (conf_data == NULL)
 		return;
 
 	/* Load default configuration values.  */
 	conf_load_defaults();
 
+	/* Parse config contents into the transaction queue */
+	char *section = NULL;
+	char *subsection = NULL;
+	conf_parse(trans, conf_data, &section, &subsection);
+	if (section) free(section);
+	if (subsection) free(subsection);
+	free(conf_data);
+
 	/* Free potential existing configuration.  */
 	conf_free_bindings();
 
-- 
1.8.3.1



