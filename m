Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49298 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751751AbdEVPso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:48:44 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6187B17AC61
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 15:48:44 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.38])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id DE516783CB
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 15:48:43 +0000 (UTC)
Message-ID: <1495468122.4169.8.camel@redhat.com>
Subject: [PATCH 1/3] nfs.conf tidy ups
From: Justin Mitchell <jumitche@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 22 May 2017 16:48:42 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Part of a sequence of attempts to tidy up the nfs.conf code and prepare
it for use as part of a configuration API.

Remove static vars that prevented memory cleanup and potentially lead to
parsing errors if conf_init was called again.

Signed-off-by: Justin Mitchell <jumitche@rehat.com>

---
 support/nfs/conffile.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 1bc8c01..a76c7e3 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -212,13 +212,11 @@ conf_set_now(char *section, char *arg, char *tag,
  * headers and feed tag-value pairs into our configuration database.
  */
 static void
-conf_parse_line(int trans, char *line, size_t sz)
+conf_parse_line(int trans, char *line, size_t sz, char **section, char **subsection)
 {
 	char *val, *ptr;
 	size_t i;
 	size_t j;
-	static char *section = 0;
-	static char *arg = 0;
 	static int ln = 0;
 
 	/* Lines starting with '#' or ';' are comments.  */
@@ -245,12 +243,12 @@ conf_parse_line(int trans, char *line, size_t sz)
 				break;
 			}
 		}
-		if (section)
-			free(section);
+		if (*section)
+			free(*section);
 		if (i == sz) {
 			xlog_warn("config file error: line %d: "
  				"non-matched ']', ignoring until next section", ln);
-			section = 0;
+			*section = NULL;
 			return;
 		}
 		/* Strip off any blanks before ']' */
@@ -260,18 +258,19 @@ conf_parse_line(int trans, char *line, size_t sz)
 			val++, j++;
 		if (*val)
 			i = j;
-		section = malloc(i+1);
-		if (!section) {
+		*section = malloc(i+1);
+		if (!*section) {
 			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
 						(unsigned long)i);
 			return;
 		}
-		strncpy(section, line, i);
-		section[i] = '\0';
+		strncpy(*section, line, i);
+		(*section)[i] = '\0';
 
-		if (arg) 
-			free(arg);
-		arg = 0;
+		if (*subsection) {
+			free(*subsection);
+			*subsection = NULL;
+		}
 
 		ptr = strchr(val, '"');
 		if (ptr == NULL)
@@ -284,8 +283,8 @@ conf_parse_line(int trans, char *line, size_t sz)
  				"non-matched '\"', ignoring until next section", ln);
 		}  else {
 			*ptr = '\0';
-			arg = strdup(line);
-			if (!arg) 
+			*subsection = strdup(line);
+			if (!*subsection) 
 				xlog_warn("conf_parse_line: %d: malloc arg failed", ln);
 		}
 		return;
@@ -295,7 +294,7 @@ conf_parse_line(int trans, char *line, size_t sz)
 	for (i = 0; i < sz; i++) {
 		if (line[i] == '=') {
 			/* If no section, we are ignoring the lines.  */
-			if (!section) {
+			if (!*section) {
 			xlog_warn("config file error: line %d: "
 				"ignoring line due to no section", ln);
 				return;
@@ -327,7 +326,7 @@ conf_parse_line(int trans, char *line, size_t sz)
 				conf_load(trans, val);
 			else
 				/* XXX Perhaps should we not ignore errors?  */
-				conf_set(trans, section, arg, line, val, 0, 0);
+				conf_set(trans, *section, *subsection, line, val, 0, 0);
 			return;
 		}
 	}
@@ -346,6 +345,8 @@ conf_parse(int trans, char *buf, size_t sz)
 	char *cp = buf;
 	char *bufend = buf + sz;
 	char *line;
+	char *section = NULL;
+	char *subsection = NULL;
 
 	line = cp;
 	while (cp < bufend) {
@@ -355,7 +356,7 @@ conf_parse(int trans, char *buf, size_t sz)
 				*(cp - 1) = *cp = ' ';
 			else {
 				*cp = '\0';
-				conf_parse_line(trans, line, cp - line);
+				conf_parse_line(trans, line, cp - line, &section, &subsection);
 				line = cp + 1;
 			}
 		}
@@ -363,6 +364,8 @@ conf_parse(int trans, char *buf, size_t sz)
 	}
 	if (cp != line)
 		xlog_warn("conf_parse: last line non-terminated, ignored.");
+	if (section) free(section);
+	if (subsection) free(subsection);
 }
 
 static void
-- 
1.8.3.1



