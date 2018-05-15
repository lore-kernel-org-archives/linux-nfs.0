Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754333AbeEOPvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 11:51:31 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7577840704A1
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 15:51:30 +0000 (UTC)
Message-ID: <1526399488.7441.5.camel@redhat.com>
Subject: [PATCH v3 1/8] nfs-utils: Fix minor memory leaks
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 15 May 2018 16:51:28 +0100
In-Reply-To: <1526399410.7441.4.camel@redhat.com>
References: <1526399410.7441.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix some minor memory leaks, typos, and trailing whitespace

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 42 +++++++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 19 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 29f132d..28e29b7 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -57,9 +57,9 @@
 
 static void conf_load_defaults(void);
 static char * conf_readfile(const char *path);
-static int conf_set(int , const char *, const char *, const char *, 
+static int conf_set(int , const char *, const char *, const char *,
 	const char *, int , int );
-static void conf_parse(int trans, char *buf, 
+static void conf_parse(int trans, char *buf,
 	char **section, char **subsection);
 
 struct conf_trans {
@@ -177,7 +177,7 @@ conf_remove_section_now(const char *section)
  * into SECTION of our configuration database.
  */
 static int
-conf_set_now(const char *section, const char *arg, const char *tag, 
+conf_set_now(const char *section, const char *arg, const char *tag,
 	const char *value, int override, int is_default)
 {
 	struct conf_binding *node = 0;
@@ -186,7 +186,7 @@ conf_set_now(const char *section, const char *arg, const char *tag,
 		conf_remove_now(section, tag);
 	else if (conf_get_section(section, arg, tag)) {
 		if (!is_default) {
-			xlog(LOG_INFO, "conf_set: duplicate tag [%s]:%s, ignoring...\n", 
+			xlog(LOG_INFO, "conf_set: duplicate tag [%s]:%s, ignoring...",
 				section, tag);
 		}
 		return 1;
@@ -220,7 +220,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 		return;
 
 	/* Strip off any leading blanks */
-	while (isblank(*line)) 
+	while (isblank(*line))
 		line++;
 
 	/* Lines starting with '#' or ';' are comments.  */
@@ -241,7 +241,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 		}
 
 		/* Strip off any blanks after '[' */
-		while (isblank(*line)) 
+		while (isblank(*line))
 			line++;
 
 		/* find the closing ] */
@@ -256,7 +256,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 		*(ptr--) = '\0';
 
 		/* Strip off any blanks before ']' */
-		while (ptr >= line && isblank(*ptr)) 
+		while (ptr >= line && isblank(*ptr))
 			*(ptr--)='\0';
 
 		/* look for an arg to split from the section name */
@@ -289,7 +289,7 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
 		}
 		*ptr = '\0';
 		*subsection = strdup(val);
-		if (!*subsection) 
+		if (!*subsection)
 			xlog_warn("conf_parse_line: %d: malloc arg failed", lineno);
 		return;
 	}
@@ -535,8 +535,8 @@ conf_init_file(const char *conf_file)
 	conf_load_file(conf_file);
 }
 
-/* 
- * Empty the config and free up any used memory 
+/*
+ * Empty the config and free up any used memory
  */
 void
 conf_cleanup(void)
@@ -618,7 +618,7 @@ conf_match_num(const char *section, const char *tag, int x)
 		xlog(LOG_INFO, "conf_match_num: %s:%s %d==%d?", section, tag, val, x);
 		return x == val;
 	case 3:
-		xlog(LOG_INFO, "conf_match_num: %s:%s %d<=%d<=%d?", section, 
+		xlog(LOG_INFO, "conf_match_num: %s:%s %d<=%d<=%d?", section,
 			tag, min, x, max);
 		return min <= x && max >= x;
 	default:
@@ -642,7 +642,7 @@ char *
 conf_get_str_with_def(const char *section, const char *tag, char *def)
 {
 	char * result = conf_get_section(section, NULL, tag);
-	if (!result) 
+	if (!result)
 		return def;
 	return result;
 }
@@ -659,7 +659,7 @@ retry:
 	for (; cb; cb = LIST_NEXT (cb, link)) {
 		if (strcasecmp(section, cb->section) != 0)
 			continue;
-		if (arg && strcasecmp(arg, cb->arg) != 0)
+		if (arg && (cb->arg == NULL || strcasecmp(arg, cb->arg) != 0))
 			continue;
 		if (strcasecmp(tag, cb->tag) != 0)
 			continue;
@@ -917,6 +917,8 @@ conf_set(int transaction, const char *section, const char *arg,
 fail:
 	if (node->tag)
 		free(node->tag);
+	if (node->arg)
+		free(node->arg);
 	if (node->section)
 		free(node->section);
 	if (node)
@@ -987,8 +989,8 @@ conf_end(int transaction, int commit)
 			if (commit) {
 				switch (node->op) {
 				case CONF_SET:
-					conf_set_now(node->section, node->arg, 
-						node->tag, node->value, node->override, 
+					conf_set_now(node->section, node->arg,
+						node->tag, node->value, node->override,
 						node->is_default);
 					break;
 				case CONF_REMOVE:
@@ -1004,6 +1006,8 @@ conf_end(int transaction, int commit)
 			TAILQ_REMOVE (&conf_trans_queue, node, link);
 			if (node->section)
 				free(node->section);
+			if (node->arg)
+				free(node->arg);
 			if (node->tag)
 				free(node->tag);
 			if (node->value)
@@ -1066,7 +1070,7 @@ conf_report (void)
 					diff_arg = 1;
 				}
 				/* Dump this entry.  */
-				if (!current_section || strcmp(cb->section, current_section) 
+				if (!current_section || strcmp(cb->section, current_section)
 							|| diff_arg) {
 					if (current_section || diff_arg) {
 						len = strlen (current_section) + 3;
@@ -1077,19 +1081,19 @@ conf_report (void)
 							goto mem_fail;
 
 						if (current_arg)
-							snprintf(dnode->s, len, "[%s \"%s\"]", 
+							snprintf(dnode->s, len, "[%s \"%s\"]",
 								current_section, current_arg);
 						else
 							snprintf(dnode->s, len, "[%s]", current_section);
 
-						dnode->next = 
+						dnode->next =
 							(struct dumper *)calloc(1, sizeof (struct dumper));
 						dnode = dnode->next;
 						if (!dnode)
 							goto mem_fail;
 
 						dnode->s = "";
-						dnode->next = 
+						dnode->next =
 							(struct dumper *)calloc(1, sizeof (struct dumper));
 						dnode = dnode->next;
 						if (!dnode)
-- 
1.8.3.1




