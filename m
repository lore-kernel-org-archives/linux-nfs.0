Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760099AbdEVPxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:53:00 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0115680050
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 15:52:45 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.38])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 804417A406
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 15:52:44 +0000 (UTC)
Message-ID: <1495468363.4169.13.camel@redhat.com>
Subject: [PATCH 3/3] nfs.conf tidy ups
From: Justin Mitchell <jumitche@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 22 May 2017 16:52:43 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the line length parameter and associated code which
led to buffer overruns in the line parsing code.
Also drops the undocumented 'include' directive.

Signed-off-by: Justin Mitchell <jumitche@rehat.com>

---
 support/nfs/conffile.c | 201 ++++++++++++++++++++++++++++---------------------
 1 file changed, 117 insertions(+), 84 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 7c607c0..449ac1c 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -212,15 +212,10 @@ conf_set_now(char *section, char *arg, char *tag,
  * headers and feed tag-value pairs into our configuration database.
  */
 static void
-conf_parse_line(int trans, char *line, size_t sz, char **section, char **subsection)
+conf_parse_line(int trans, char *line, int lineno, char **section, char **subsection)
 {
 	char *val, *ptr;
-	size_t i;
-	size_t j;
-	static int ln = 0;
 
-	/* Lines starting with '#' or ';' are comments.  */
-	ln++;
 	/* Ignore blank lines */
 	if (*line == '\0')
 		return;
@@ -229,113 +224,149 @@ conf_parse_line(int trans, char *line, size_t sz, char **section, char **subsect
 	while (isblank(*line)) 
 		line++;
 
+	/* Lines starting with '#' or ';' are comments.  */
 	if (*line == '#' || *line == ';')
 		return;
 
 	/* '[section]' parsing...  */
 	if (*line == '[') {
 		line++;
+
+		if (*section) {
+			free(*section);
+			*section = NULL;
+		}
+		if (*subsection) {
+			free(*subsection);
+			*subsection = NULL;
+		}
+
 		/* Strip off any blanks after '[' */
 		while (isblank(*line)) 
 			line++;
-		for (i = 0; i < sz; i++) {
-			if (line[i] == ']') {
-				break;
-			}
-		}
-		if (*section)
-			free(*section);
-		if (i == sz) {
+
+		/* find the closing ] */
+		ptr = strchr(line, ']');
+		if (ptr == NULL) {
 			xlog_warn("config file error: line %d: "
- 				"non-matched ']', ignoring until next section", ln);
-			*section = NULL;
+ 				"non-matched ']', ignoring until next section", lineno);
 			return;
 		}
+
+		/* just ignore everything after the closing ] */
+		*(ptr--) = '\0';
+
 		/* Strip off any blanks before ']' */
-		val = line;
-		j=0;
-		while (*val && !isblank(*val)) 
-			val++, j++;
-		if (*val)
-			i = j;
-		*section = malloc(i+1);
+		while (ptr >= line && isblank(*ptr)) 
+			*(ptr--)='\0';
+
+		/* look for an arg to split from the section name */
+		val = strchr(line, '"');
+		if (val != NULL) {
+			ptr = val - 1;
+			*(val++) = '\0';
+
+			/* trim away any whitespace before the " */
+			while (ptr > line && isblank(*ptr))
+				*(ptr--)='\0';
+		}
+
+		/* copy the section name */
+		*section = strdup(line);
 		if (!*section) {
-			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
-						(unsigned long)i);
+			xlog_warn("conf_parse_line: %d: malloc failed", lineno);
 			return;
 		}
-		strncpy(*section, line, i);
-		(*section)[i] = '\0';
 
-		if (*subsection) {
-			free(*subsection);
-			*subsection = NULL;
-		}
+		/* there is no arg, we are done */
+		if (val == NULL) return;
 
+		/* check for the closing " */
 		ptr = strchr(val, '"');
-		if (ptr == NULL)
-			return;
-		line = ++ptr;
-		while (*ptr && *ptr != '"' && *ptr != ']')
-			ptr++;
-		if (*ptr == '\0' || *ptr == ']') {
+		if (ptr == NULL) {
 			xlog_warn("config file error: line %d: "
- 				"non-matched '\"', ignoring until next section", ln);
-		}  else {
-			*ptr = '\0';
-			*subsection = strdup(line);
-			if (!*subsection) 
-				xlog_warn("conf_parse_line: %d: malloc arg failed", ln);
+ 				"non-matched '\"', ignoring until next section", lineno);
+			return;
 		}
+		*ptr = '\0';
+		*subsection = strdup(val);
+		if (!*subsection) 
+			xlog_warn("conf_parse_line: %d: malloc arg failed", lineno);
 		return;
 	}
 
 	/* Deal with assignments.  */
-	for (i = 0; i < sz; i++) {
-		if (line[i] == '=') {
-			/* If no section, we are ignoring the lines.  */
-			if (!*section) {
+	ptr = strchr(line, '=');
+
+	/* not an assignment line */
+	if (ptr == NULL) {
+		/* Other non-empty lines are weird.  */
+		if (line[strspn(line, " \t")])
 			xlog_warn("config file error: line %d: "
-				"ignoring line due to no section", ln);
-				return;
-			}
-			line[strcspn (line, " \t=")] = '\0';
-			val = line + i + 1 + strspn (line + i + 1, " \t");
-
-			if (val[0] == '"') {
-				val ++;
-				j = strcspn(val, "\"");
-				val[j] = 0;
-			} else if (val[0] == '\'') {
-				val ++;
-				j = strcspn(val, "'");
-				val[j] = 0;
-			} else {
-				/* Skip trailing spaces and comments */
-				for (j = 0; val[j]; j++) {
-					if ((val[j] == '#' || val[j] == ';')
-					    && (j == 0 || isspace(val[j-1]))) {
-						val[j] = '\0';
-						break;
-					}
-				}
-				while (j && isspace(val[j-1]))
-					val[--j] = '\0';
-			}
-			if (strcasecmp(line, "include") == 0)
-				conf_load(trans, val);
-			else
-				/* XXX Perhaps should we not ignore errors?  */
-				conf_set(trans, *section, *subsection, line, val, 0, 0);
+				"line not empty and not an assignment", lineno);
+		return;
+	}
+
+	/* If no section, we are ignoring the line.  */
+	if (!*section) {
+		xlog_warn("config file error: line %d: "
+			"ignoring line due to no section", lineno);
+		return;
+	}
+
+	val = ptr + 1;
+	*(ptr--) = '\0';
+
+	/* strip spaces before and after the = */
+	while (ptr >= line && isblank(*ptr))
+		*(ptr--)='\0';
+	while (*val != '\0' && isblank(*val))
+		val++;
+
+	if (*val == '"') {
+		val++;
+		ptr = strchr(val, '"');
+		if (ptr == NULL) {
+			xlog_warn("config file error: line %d: "
+				"unmatched quotes", lineno);
 			return;
 		}
+		*ptr = '\0';
+	} else
+	if (*val == '\'') {
+		val++;
+		ptr = strchr(val, '\'');
+		if (ptr == NULL) {
+			xlog_warn("config file error: line %d: "
+				"unmatched quotes", lineno);
+			return;
+		}
+		*ptr = '\0';
+	} else {
+		/* Trim any trailing spaces and comments */
+		if ((ptr=strchr(val, '#'))!=NULL)
+			*ptr = '\0';
+		if ((ptr=strchr(val, ';'))!=NULL)
+			*ptr = '\0';
+
+		ptr = val + strlen(val) - 1;
+		while (ptr > val && isspace(*ptr))
+			*(ptr--) = '\0';
 	}
-	/* Other non-empty lines are weird.  */
-	i = strspn(line, " \t");
-	if (line[i])
-		xlog_warn("config file error: line %d:", ln);
 
-	return;
+	if (*line == '\0') {
+		xlog_warn("config file error: line %d: "
+			"missing tag in assignment", lineno);
+		return;
+	}
+	if (*val == '\0') {
+		xlog_warn("config file error: line %d: "
+			"missing value in assignment", lineno);
+		return;
+	}
+
+	/* XXX Perhaps should we not ignore errors?  */
+	conf_set(trans, *section, *subsection, line, val, 0, 0);
 }
 
 /* Parse the mapped configuration file.  */
@@ -347,6 +378,7 @@ conf_parse(int trans, char *buf, size_t sz)
 	char *line;
 	char *section = NULL;
 	char *subsection = NULL;
+	int lineno = 0;
 
 	line = cp;
 	while (cp < bufend) {
@@ -356,7 +388,8 @@ conf_parse(int trans, char *buf, size_t sz)
 				*(cp - 1) = *cp = ' ';
 			else {
 				*cp = '\0';
-				conf_parse_line(trans, line, cp - line, &section, &subsection);
+				lineno++;
+				conf_parse_line(trans, line, lineno, &section, &subsection);
 				line = cp + 1;
 			}
 		}
-- 
1.8.3.1



