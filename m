Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59720 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753542AbeEOPwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 11:52:50 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3B57F40200A0
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 15:52:50 +0000 (UTC)
Message-ID: <1526399567.7441.7.camel@redhat.com>
Subject: [PATCH v3 3/8] nfs-utils: Use config file name in error messages
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 15 May 2018 16:52:47 +0100
In-Reply-To: <1526399410.7441.4.camel@redhat.com>
References: <1526399410.7441.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Improve readability of error configuration error messages
by including the filename currently being read.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 45 ++++++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 95dda99..5fb58ea 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -285,8 +285,9 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		/* find the closing ] */
 		ptr = strchr(line, ']');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
- 				"non-matched ']', ignoring until next section", lineno);
+			xlog_warn("config error at %s:%d: "
+				  "non-matched ']', ignoring until next section",
+				  filename, lineno);
 			return;
 		}
 
@@ -311,7 +312,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		/* copy the section name */
 		*section = strdup(line);
 		if (!*section) {
-			xlog_warn("conf_parse_line: %d: malloc failed", lineno);
+			xlog_warn("config error at %s:%d:"
+				  "malloc failed", filename, lineno);
 			return;
 		}
 
@@ -321,14 +323,16 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		/* check for the closing " */
 		ptr = strchr(val, '"');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
- 				"non-matched '\"', ignoring until next section", lineno);
+			xlog_warn("config error at %s:%d: "
+				  "non-matched '\"', ignoring until next section",
+				filename, lineno);
 			return;
 		}
 		*ptr = '\0';
 		*subsection = strdup(val);
 		if (!*subsection)
-			xlog_warn("conf_parse_line: %d: malloc arg failed", lineno);
+			xlog_warn("config error at %s:%d: "
+				  "malloc failed", filename, lineno);
 		return;
 	}
 
@@ -339,15 +343,17 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 	if (ptr == NULL) {
 		/* Other non-empty lines are weird.  */
 		if (line[strspn(line, " \t")])
-			xlog_warn("config file error: line %d: "
-				"line not empty and not an assignment", lineno);
+			xlog_warn("config error at %s:%d: "
+				"line not empty and not an assignment",
+				filename, lineno);
 		return;
 	}
 
 	/* If no section, we are ignoring the line.  */
 	if (!*section) {
-		xlog_warn("config file error: line %d: "
-			"ignoring line due to no section", lineno);
+		xlog_warn("config error at %s:%d: "
+			  "ignoring line not in a section",
+			  filename, lineno);
 		return;
 	}
 
@@ -364,8 +370,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		val++;
 		ptr = strchr(val, '"');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
-				"unmatched quotes", lineno);
+			xlog_warn("config error at %s:%d: "
+				  "unmatched quotes",filename, lineno);
 			return;
 		}
 		*ptr = '\0';
@@ -374,8 +380,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		val++;
 		ptr = strchr(val, '\'');
 		if (ptr == NULL) {
-			xlog_warn("config file error: line %d: "
-				"unmatched quotes", lineno);
+			xlog_warn("config error at %s:%d: "
+				  "unmatched quotes", filename, lineno);
 			return;
 		}
 		*ptr = '\0';
@@ -392,13 +398,13 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 	}
 
 	if (*line == '\0') {
-		xlog_warn("config file error: line %d: "
-			"missing tag in assignment", lineno);
+		xlog_warn("config error at %s:%d: "
+			  "missing tag in assignment", filename, lineno);
 		return;
 	}
 	if (*val == '\0') {
-		xlog_warn("config file error: line %d: "
-			"missing value in assignment", lineno);
+		xlog_warn("config error at %s:%d: "
+			  "missing value in assignment", filename, lineno);
 		return;
 	}
 
@@ -409,7 +415,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 		char *relpath = relative_path(filename, val);
 		char *subconf = conf_readfile(relpath);
 		if (subconf == NULL) {
-			xlog_warn("%s:%d: error loading included config",
+			xlog_warn("config error at %s:%d: "
+				  "error loading included config",
 				  filename, lineno);
 			if (relpath)
 				free(relpath);
-- 
1.8.3.1



