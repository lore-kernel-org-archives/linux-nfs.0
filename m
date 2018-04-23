Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:46970 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755820AbeDWP0M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 11:26:12 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 661BA8DC3E
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:26:12 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.46])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id AD44083B96
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:26:11 +0000 (UTC)
Message-ID: <1524497170.7418.6.camel@redhat.com>
Subject: [PATCH 3/7] nfs-utils: Use config file name in error messages
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 23 Apr 2018 16:26:10 +0100
In-Reply-To: <1524496788.7418.2.camel@redhat.com>
References: <1524496788.7418.2.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Improve readability of error configuration error messages
by including the filename currently being read.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 42c0913..fe41de5 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -276,8 +276,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		/* find the closing ] */
 		ptr = strchr(line, ']');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
- 				"non-matched ']', ignoring until next section", lineno);
+			xlog_warn("config error at %s:%d: "
+ 				"non-matched ']', ignoring until next section", filename, lineno);
 			return;
 		}
 
@@ -302,7 +302,7 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		/* copy the section name */
 		*section = strdup(line);
 		if (!*section) {
-			xlog_warn("conf_parse_line: %d: malloc failed", lineno);
+			xlog_warn("config error at %s:%d: malloc failed", filename, lineno);
 			return;
 		}
 
@@ -312,14 +312,14 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		/* check for the closing " */
 		ptr = strchr(val, '"');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
- 				"non-matched '\"', ignoring until next section", lineno);
+			xlog_warn("config error at %s:%d: "
+ 				"non-matched '\"', ignoring until next section", filename, lineno);
 			return;
 		}
 		*ptr = '\0';
 		*subsection = strdup(val);
 		if (!*subsection) 
-			xlog_warn("conf_parse_line: %d: malloc arg failed", lineno);
+			xlog_warn("config error at %s:%d: malloc failed", filename, lineno);
 		return;
 	}
 
@@ -330,15 +330,15 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 	if (ptr == NULL) {
 		/* Other non-empty lines are weird.  */
 		if (line[strspn(line, " \t")])
-			xlog_warn("config file error: line %d: "
-				"line not empty and not an assignment", lineno);
+			xlog_warn("config error at %s:%d: "
+				"line not empty and not an assignment", filename, lineno);
 		return;
 	}
 
 	/* If no section, we are ignoring the line.  */
 	if (!*section) {
-		xlog_warn("config file error: line %d: "
-			"ignoring line due to no section", lineno);
+		xlog_warn("config error at %s:%d: "
+			"ignoring line not in a section", filename, lineno);
 		return;
 	}
 
@@ -355,8 +355,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		val++;
 		ptr = strchr(val, '"');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
-				"unmatched quotes", lineno);
+			xlog_warn("config error at %s:%d: "
+				"unmatched quotes", filename, lineno);
 			return;
 		}
 		*ptr = '\0';
@@ -365,8 +365,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		val++;
 		ptr = strchr(val, '\'');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
-				"unmatched quotes", lineno);
+			xlog_warn("config error at %s:%d: "
+				"unmatched quotes", filename, lineno);
 			return;
 		}
 		*ptr = '\0';
@@ -383,13 +383,13 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 	}
 
 	if (*line == '\0') {
-		xlog_warn("config file error: line %d: "
-			"missing tag in assignment", lineno);
+		xlog_warn("config error at %s:%d: "
+			"missing tag in assignment", filename, lineno);
 		return;
 	}
 	if (*val == '\0') {
-		xlog_warn("config file error: line %d: "
-			"missing value in assignment", lineno);
+		xlog_warn("config error at %s:%d: "
+			"missing value in assignment", filename, lineno);
 		return;
 	}
 
@@ -398,7 +398,7 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		char * relpath = relative_path(filename, val);
 		char * subconf = conf_readfile(relpath);
 		if (subconf == NULL) {
-			xlog_warn("%s:%d: error loading included config %s", 
+			xlog_warn("config error at %s:%d: error loading included config %s", 
 				  filename, lineno, relpath);
 			if (relpath) free(relpath);
 			return;
-- 
1.8.3.1



