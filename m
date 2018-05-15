Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:38808 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754022AbeEOPwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 11:52:14 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E12B24021BA2
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 15:52:13 +0000 (UTC)
Message-ID: <1526399532.7441.6.camel@redhat.com>
Subject: [PATCH v3 2/8] nfs-utils: Make config includes relative to current
 config
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 15 May 2018 16:52:12 +0100
In-Reply-To: <1526399410.7441.4.camel@redhat.com>
References: <1526399410.7441.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When including additional config files with the include directive
make relative paths be relative to the current config file instead
of to the process's cwd.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 76 +++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 63 insertions(+), 13 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 28e29b7..95dda99 100644
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
@@ -206,12 +207,49 @@ conf_set_now(const char *section, const char *arg, const char *tag,
 	return 0;
 }
 
+/* Attempt to construct a relative path to the new file */
+static char *
+relative_path(const char *oldfile, const char *newfile)
+{
+	char *tmpcopy = NULL;
+	char *dir = NULL;
+	char *relpath = NULL;
+	size_t pathlen;
+
+	if (!newfile)
+		return strdup(oldfile);
+
+	if (newfile[0] == '/')
+		return strdup(newfile);
+
+	tmpcopy = strdup(oldfile);
+	if (!tmpcopy)
+		goto mem_err;
+
+	dir = dirname(tmpcopy);
+
+	pathlen = strlen(dir) + strlen(newfile) + 2;
+	relpath = calloc(1, pathlen);
+	if (!relpath)
+		goto mem_err;
+
+	snprintf(relpath, pathlen, "%s/%s", dir, newfile);
+
+	free(tmpcopy);
+	return relpath;
+mem_err:
+	if (tmpcopy)
+		free(tmpcopy);
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
 
@@ -366,27 +404,34 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 
 	if (strcasecmp(line, "include")==0) {
 		/* load and parse subordinate config files */
-		char * subconf = conf_readfile(val);
+		char *inc_section = NULL;
+		char *inc_subsection = NULL;
+		char *relpath = relative_path(filename, val);
+		char *subconf = conf_readfile(relpath);
 		if (subconf == NULL) {
-			xlog_warn("config file error: line %d: "
-			"error loading included config", lineno);
+			xlog_warn("%s:%d: error loading included config",
+				  filename, lineno);
+			if (relpath)
+				free(relpath);
 			return;
 		}
 
 		/* copy the section data so the included file can inherit it
 		 * without accidentally changing it for us */
-		char * inc_section = NULL;
-		char * inc_subsection = NULL;
 		if (*section != NULL) {
 			inc_section = strdup(*section);
 			if (*subsection != NULL)
 				inc_subsection = strdup(*subsection);
 		}
 
-		conf_parse(trans, subconf, &inc_section, &inc_subsection);
+		conf_parse(trans, subconf, &inc_section, &inc_subsection, relpath);
 
-		if (inc_section) free(inc_section);
-		if (inc_subsection) free(inc_subsection);
+		if (inc_section)
+			free(inc_section);
+		if (inc_subsection)
+			free(inc_subsection);
+		if (relpath)
+			free(relpath);
 		free(subconf);
 	} else {
 		/* XXX Perhaps should we not ignore errors?  */
@@ -396,7 +441,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 
 /* Parse the mapped configuration file.  */
 static void
-conf_parse(int trans, char *buf, char **section, char **subsection)
+conf_parse(int trans, char *buf, char **section, char **subsection, const char *filename)
 {
 	char *cp = buf;
 	char *bufend = NULL;
@@ -413,7 +458,7 @@ conf_parse(int trans, char *buf, char **section, char **subsection)
 			else {
 				*cp = '\0';
 				lineno++;
-				conf_parse_line(trans, line, lineno, section, subsection);
+				conf_parse_line(trans, line, filename, lineno, section, subsection);
 				line = cp + 1;
 			}
 		}
@@ -434,6 +479,11 @@ static char *
 conf_readfile(const char *path)
 {
 	struct stat sb;
+	if (!path) {
+		xlog_err("conf_readfile: no path given");
+		return NULL;
+	}
+
 	if ((stat (path, &sb) == 0) || (errno != ENOENT)) {
 		char *new_conf_addr = NULL;
 		size_t sz = sb.st_size;
@@ -508,7 +558,7 @@ conf_load_file(const char *conf_file)
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



