Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51292 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932186AbeDWPZ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 11:25:27 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C1E5F401DEA0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:25:26 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.46])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 630C21102E26
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:25:26 +0000 (UTC)
Message-ID: <1524497125.7418.5.camel@redhat.com>
Subject: [PATCH 2/7] nfs-utils: Make config includes relative to current
 config
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 23 Apr 2018 16:25:25 +0100
In-Reply-To: <1524496788.7418.2.camel@redhat.com>
References: <1524496788.7418.2.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When including additional config files with the include directive
make relative paths be relative to the current config file instead
of to the process's cwd.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 50 +++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 41 insertions(+), 9 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index a4cc236..42c0913 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -49,6 +49,7 @@
 #include <errno.h>
 #include <err.h>
 #include <syslog.h>
+#include <libgen.h>
 
 #include "conffile.h"
 #include "xlog.h"
@@ -60,7 +61,7 @@ static char * conf_readfile(const char *path);
 static int conf_set(int , const char *, const char *, const char *, 
 	const char *, int , int );
 static void conf_parse(int trans, char *buf, 
-	char **section, char **subsection);
+	char **section, char **subsection, const char *filename);
 
 struct conf_trans {
 	TAILQ_ENTRY (conf_trans) link;
@@ -206,12 +207,40 @@ conf_set_now(const char *section, const char *arg, const char *tag,
 	return 0;
 }
 
+/* Attempt to construct a relative path to the new file */
+static char *
+relative_path(const char *oldfile, const char *newfile)
+{
+	char * tmpcopy = NULL;
+	char * dir = NULL;
+	char * relpath = NULL;
+
+	if (!newfile) return strdup(oldfile);
+	if (newfile[0] == '/') return strdup(newfile);
+
+	tmpcopy = strdup(oldfile);
+	if (!tmpcopy) goto mem_err;
+
+	dir = dirname(tmpcopy);
+	size_t pathlen =  strlen(dir)+strlen(newfile)+2;
+	relpath = calloc(1, pathlen);
+	if (!relpath) goto mem_err;
+	snprintf(relpath, pathlen, "%s/%s", dir, newfile);
+
+	free(tmpcopy);
+	return relpath;
+mem_err:
+	if (tmpcopy) free(tmpcopy);
+	return NULL;
+}
+
+
 /*
  * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
  * headers and feed tag-value pairs into our configuration database.
  */
 static void
-conf_parse_line(int trans, char *line, int lineno, char **section, char **subsection)
+conf_parse_line(int trans, char *line, const char *filename, int lineno, char **section, char **subsection)
 {
 	char *val, *ptr;
 
@@ -366,10 +395,12 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 
 	if (strcasecmp(line, "include")==0) {
 		/* load and parse subordinate config files */
-		char * subconf = conf_readfile(val);
+		char * relpath = relative_path(filename, val);
+		char * subconf = conf_readfile(relpath);
 		if (subconf == NULL) {
-			xlog_warn("config file error: line %d: "
-			"error loading included config", lineno);
+			xlog_warn("%s:%d: error loading included config %s", 
+				  filename, lineno, relpath);
+			if (relpath) free(relpath);
 			return;
 		}
 
@@ -383,10 +414,11 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 				inc_subsection = strdup(*subsection);
 		}
 
-		conf_parse(trans, subconf, &inc_section, &inc_subsection);
+		conf_parse(trans, subconf, &inc_section, &inc_subsection, relpath);
 
 		if (inc_section) free(inc_section);
 		if (inc_subsection) free(inc_subsection);
+		if (relpath) free(relpath);
 		free(subconf);
 	} else {
 		/* XXX Perhaps should we not ignore errors?  */
@@ -396,7 +428,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 
 /* Parse the mapped configuration file.  */
 static void
-conf_parse(int trans, char *buf, char **section, char **subsection)
+conf_parse(int trans, char *buf, char **section, char **subsection, const char *filename)
 {
 	char *cp = buf;
 	char *bufend = NULL;
@@ -413,7 +445,7 @@ conf_parse(int trans, char *buf, char **section, char **subsection)
 			else {
 				*cp = '\0';
 				lineno++;
-				conf_parse_line(trans, line, lineno, section, subsection);
+				conf_parse_line(trans, line, filename, lineno, section, subsection);
 				line = cp + 1;
 			}
 		}
@@ -508,7 +540,7 @@ conf_load_file(const char *conf_file)
 	/* Parse config contents into the transaction queue */
 	char *section = NULL;
 	char *subsection = NULL;
-	conf_parse(trans, conf_data, &section, &subsection);
+	conf_parse(trans, conf_data, &section, &subsection, conf_file);
 	if (section) free(section);
 	if (subsection) free(subsection);
 	free(conf_data);
-- 
1.8.3.1



