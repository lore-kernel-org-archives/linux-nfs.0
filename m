Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:46452 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755532AbeDWP1x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 11:27:53 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 55EA94305C56
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:27:53 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.46])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id E8B6B83B94
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:27:52 +0000 (UTC)
Message-ID: <1524497271.7418.8.camel@redhat.com>
Subject: [PATCH 5/7] nfs-utils: tidy up output of conf_report
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 23 Apr 2018 16:27:51 +0100
In-Reply-To: <1524496788.7418.2.camel@redhat.com>
References: <1524496788.7418.2.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Previously unused conf_report() function is modified to output
an alphabetically sorted version of the current configuration
to the nominated FILE handle.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/include/conffile.h |   3 +-
 support/nfs/conffile.c     | 237 ++++++++++++++++++++++++++++-----------------
 2 files changed, 151 insertions(+), 89 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 6baaf9a..bc2d61f 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -37,6 +37,7 @@
 #include <ctype.h>
 #include <stdint.h>
 #include <stdbool.h>
+#include <stdio.h>
 
 struct conf_list_node {
 	TAILQ_ENTRY(conf_list_node) link;
@@ -65,7 +66,7 @@ extern void     conf_cleanup(void);
 extern int      conf_match_num(const char *, const char *, int);
 extern int      conf_remove(int, const char *, const char *);
 extern int      conf_remove_section(int, const char *);
-extern void     conf_report(void);
+extern void     conf_report(FILE *);
 
 /*
  * Convert letter from upper case to lower case
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 7ed5646..9148557 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -1055,117 +1055,178 @@ conf_end(int transaction, int commit)
  * Configuration is "stored in reverse order", so reverse it again.
  */
 struct dumper {
-	char *s, *v;
+	char *section;
+	char *arg;
+	char *tag;
+	char *value;
 	struct dumper *next;
 };
 
+static int dumper_section_compare(const struct dumper *nodea, const struct dumper *nodeb)
+{
+	int ret;
+
+	// missing node, shouldnt happen
+	if (!nodea || !nodeb) return -1;
+	// if only one has a section name, the blank one goes first
+	if (!nodea->section &&  nodeb->section) return -1;
+	if ( nodea->section && !nodeb->section) return  1;
+	// no section names at all
+	if (!nodea->section && !nodeb->section) return  0;
+	// two section names, do they match
+	ret = strcmp(nodea->section, nodeb->section);
+	// section names differ, that was easy
+	if (ret != 0) return ret;
+	// sections matched, but how about sub-sections, again blank goes first
+	if (!nodea->arg &&  nodeb->arg) return -1;
+	if ( nodea->arg && !nodeb->arg) return  1;
+
+	// both have sub-section args and they differ
+	if (nodea->arg && nodeb->arg && (ret=strcmp(nodea->arg, nodeb->arg))!=0)
+		return ret;
+
+	return 0;
+}
+
+static bool 
+should_escape(const char * text)
+{
+	int len;
+	if (!text) return false;
+	if (isspace(text[0])) return true;
+	len = strlen(text);
+	if (isspace(text[len-1])) return true;
+	return false;
+}
+
 static void
-conf_report_dump(struct dumper *node)
+conf_report_dump_text(struct dumper *head, FILE *ff)
 {
-	/* Recursive, cleanup when we're done.  */
-	if (node->next)
-		conf_report_dump(node->next);
-
-	if (node->v)
-		xlog(LOG_INFO, "%s=\t%s", node->s, node->v);
-	else if (node->s) {
-		xlog(LOG_INFO, "%s", node->s);
-		if (strlen(node->s) > 0)
-			free(node->s);
+	const struct dumper *node = head;
+	const struct dumper *last = NULL;
+
+	for (node=head; node!=NULL; node=node->next) {
+		if (dumper_section_compare(last, node)!=0) {
+			if (node != head) fprintf(ff, "\n");
+			if (node->arg)
+				fprintf(ff, "[%s \"%s\"]\n", node->section, node->arg);
+			else
+				fprintf(ff, "[%s]\n", node->section);
+		}
+		fprintf(ff, " %s", node->tag);
+		if (node->value) {
+			if (should_escape(node->value))
+				fprintf(ff, " = \"%s\"", node->value);
+			else
+				fprintf(ff, " = %s", node->value);
+		}
+		fprintf(ff, "\n");
+
+		last = node;
 	}
+}
 
-	free (node);
+/* compare two dumper nodes for sorting */
+static int dumper_compare(const void * a, const void * b)
+{
+	const struct dumper *nodea = *(struct dumper **)a;
+	const struct dumper *nodeb = *(struct dumper **)b;
+	int ret;
+
+	// missing node, shouldnt happen
+	if (!nodea || !nodeb) return -1;
+
+	ret = dumper_section_compare(nodea, nodeb);
+	if (ret != 0) return ret;
+
+	// sub-sections match (both blank, or both same)
+	// so we compare the tag names
+	
+	// blank tags shouldnt happen, but paranoia
+	if (!nodea->tag &&  nodeb->tag) return -1;
+	if ( nodea->tag && !nodeb->tag) return  1;
+	if (!nodea->tag && !nodeb->tag) return  0;
+
+	// last test, compare the tags directly
+	ret = strcmp(nodea->tag, nodeb->tag);
+	return ret;
 }
 
-void
-conf_report (void)
+static struct dumper *conf_report_sort(struct dumper *start)
 {
-	struct conf_binding *cb, *last = 0;
-	unsigned int i, len, diff_arg = 0;
-	char *current_section = (char *)0;
-	char *current_arg = (char *)0;
-	struct dumper *dumper, *dnode;
+	struct dumper **list;
+	struct dumper *node;
+	unsigned int count = 0;
 
-	dumper = dnode = (struct dumper *)calloc(1, sizeof *dumper);
-	if (!dumper)
-		goto mem_fail;
+	// how long is this list
+	for (node=start; node!=NULL; node=node->next) count++;
+
+	// no need to sort a list of 1 or less
+	if (count < 2) return start;
+
+	// make an array of all the nodes
+	list = calloc(count, sizeof(struct dumper *));
+	if (!list) goto mem_err;
+
+	unsigned int i=0;
+	for (node=start; node!=NULL; node=node->next) {
+		list[i++] = node;
+	}
+
+	// sort the array
+	qsort(list, count, sizeof(struct dumper *), dumper_compare);
+
+	// turn sorted array back into a linked list
+	for (i=0; i<count-1; i++) {
+		list[i]->next = list[i+1];
+	}
+	list[count-1]->next = NULL;
+
+	// remember the new head of list and cleanup
+	node = list[0];
+	free(list);
+
+	// return the new head of list
+	return node;
+
+mem_err:
+	free(list);
+	return NULL;
+}
+
+void
+conf_report (FILE *outfile)
+{
+	struct conf_binding *cb = NULL;
+	unsigned int i;
+	struct dumper *dumper = NULL, *dnode = NULL;
 
 	xlog(LOG_INFO, "conf_report: dumping running configuration");
 
-	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
+	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++) {
 		for (cb = LIST_FIRST(&conf_bindings[i]); cb; cb = LIST_NEXT(cb, link)) {
-			if (!cb->is_default) {
-				/* Make sure the Section arugment is the same */
-				if (current_arg && current_section && cb->arg) {
-					if (strcmp(cb->section, current_section) == 0 &&
-						strcmp(cb->arg, current_arg) != 0)
-					diff_arg = 1;
-				}
-				/* Dump this entry.  */
-				if (!current_section || strcmp(cb->section, current_section) 
-							|| diff_arg) {
-					if (current_section || diff_arg) {
-						len = strlen (current_section) + 3;
-						if (current_arg)
-							len += strlen(current_arg) + 3;
-						dnode->s = malloc(len);
-						if (!dnode->s)
-							goto mem_fail;
-
-						if (current_arg)
-							snprintf(dnode->s, len, "[%s \"%s\"]", 
-								current_section, current_arg);
-						else
-							snprintf(dnode->s, len, "[%s]", current_section);
-
-						dnode->next = 
-							(struct dumper *)calloc(1, sizeof (struct dumper));
-						dnode = dnode->next;
-						if (!dnode)
-							goto mem_fail;
-
-						dnode->s = "";
-						dnode->next = 
-							(struct dumper *)calloc(1, sizeof (struct dumper));
-						dnode = dnode->next;
-						if (!dnode)
-						goto mem_fail;
-					}
-					current_section = cb->section;
-					current_arg = cb->arg;
-					diff_arg = 0;
-				}
-				dnode->s = cb->tag;
-				dnode->v = cb->value;
-				dnode->next = (struct dumper *)calloc (1, sizeof (struct dumper));
-				dnode = dnode->next;
-				if (!dnode)
-					goto mem_fail;
-				last = cb;
+			struct dumper *newnode = calloc(1, sizeof (struct dumper));
+			if (!newnode) goto mem_fail;
+
+			newnode->next = dumper;
+			dumper = newnode;
+
+			newnode->section = cb->section;
+			newnode->arg = cb->arg;
+			newnode->tag = cb->tag;
+			newnode->value = cb->value;
 		}
 	}
 
-	if (last) {
-		len = strlen(last->section) + 3;
-		if (last->arg)
-			len += strlen(last->arg) + 3;
-		dnode->s = malloc(len);
-		if (!dnode->s)
-			goto mem_fail;
-		if (last->arg)
-			snprintf(dnode->s, len, "[%s \"%s\"]", last->section, last->arg);
-		else
-			snprintf(dnode->s, len, "[%s]", last->section);
-	}
-	conf_report_dump(dumper);
-	return;
+	dumper = conf_report_sort(dumper);
+	conf_report_dump_text(dumper, outfile);
+	goto cleanup;
 
 mem_fail:
 	xlog_warn("conf_report: malloc/calloc failed");
+cleanup:
 	while ((dnode = dumper) != 0) {
 		dumper = dumper->next;
-		if (dnode->s)
-			free(dnode->s);
 		free(dnode);
 	}
 	return;
-- 
1.8.3.1



