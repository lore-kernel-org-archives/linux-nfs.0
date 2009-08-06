From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 4/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:43:37 -0400
Message-ID: <4A7B2459.3040204@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7B2324.9090406@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit fede9b293a8faf6c4214f6dabdb1d8664929901d
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 16:02:33 2009 -0400

    Added an conditional argument to the Section names
    with the format being:
       [ Section <"argument"> ]
    This will help group similar functioning Section
    together. The argument is conditional but must be
    surrounded by the '"' characters.
    
    The new conf_get_section() interface can used
    to locate a Section by its Section name and/or
    argument.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 3309788..b263581 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -56,12 +56,12 @@ extern struct conf_list *conf_get_list(char *, char *);
 extern struct conf_list *conf_get_tag_list(char *);
 extern int      conf_get_num(char *, char *, int);
 extern char    *conf_get_str(char *, char *);
+extern char    *conf_get_section(char *, char *, char *);
 extern void     conf_init(void);
 extern int      conf_match_num(char *, char *, int);
 extern void     conf_reinit(void);
 extern int      conf_remove(int, char *, char *);
 extern int      conf_remove_section(int, char *);
-extern int      conf_set(int, char *, char *, char *, int, int);
 extern void     conf_report(void);
 
 #endif				/* _CONFFILE_H_ */
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index a8b8037..97dc88a 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -50,12 +50,15 @@
 #include "xlog.h"
 
 static void conf_load_defaults (int);
+static int conf_set(int , char *, char *, char *, 
+	char *, int , int );
 
 struct conf_trans {
 	TAILQ_ENTRY (conf_trans) link;
 	int trans;
 	enum conf_op { CONF_SET, CONF_REMOVE, CONF_REMOVE_SECTION } op;
 	char *section;
+	char *arg;
 	char *tag;
 	char *value;
 	int override;
@@ -93,6 +96,7 @@ static const u_int8_t asc2bin[] =
 struct conf_binding {
   LIST_ENTRY (conf_binding) link;
   char *section;
+  char *arg;
   char *tag;
   char *value;
   int is_default;
@@ -143,6 +147,7 @@ conf_remove_now(char *section, char *tag)
 			LIST_REMOVE(cb, link);
 			xlog(LOG_INFO,"[%s]:%s->%s removed", section, tag, cb->value);
 			free(cb->section);
+			free(cb->arg);
 			free(cb->tag);
 			free(cb->value);
 			free(cb);
@@ -166,6 +171,7 @@ conf_remove_section_now(char *section)
 			LIST_REMOVE(cb, link);
 			xlog(LOG_INFO, "[%s]:%s->%s removed", section, cb->tag, cb->value);
 			free(cb->section);
+			free(cb->arg);
 			free(cb->tag);
 			free(cb->value);
 			free(cb);
@@ -179,27 +185,28 @@ conf_remove_section_now(char *section)
  * into SECTION of our configuration database.
  */
 static int
-conf_set_now(char *section, char *tag, char *value, int override,
-	      int is_default)
+conf_set_now(char *section, char *arg, char *tag, 
+	char *value, int override, int is_default)
 {
 	struct conf_binding *node = 0;
 
 	if (override)
 		conf_remove_now(section, tag);
-	else if (conf_get_str(section, tag)) {
+	else if (conf_get_section(section, arg, tag)) {
 		if (!is_default) {
 			xlog(LOG_INFO, "conf_set: duplicate tag [%s]:%s, ignoring...\n", 
 				section, tag);
 		}
 		return 1;
 	}
-
 	node = calloc(1, sizeof *node);
 	if (!node) {
 		xlog_warn("conf_set: calloc (1, %lu) failed", (unsigned long)sizeof *node);
 		return 1;
 	}
 	node->section = strdup(section);
+	if (arg)
+		node->arg = strdup(arg);
 	node->tag = strdup(tag);
 	node->value = strdup(value);
 	node->is_default = is_default;
@@ -215,10 +222,11 @@ conf_set_now(char *section, char *tag, char *value, int override,
 static void
 conf_parse_line(int trans, char *line, size_t sz)
 {
-	char *val;
+	char *val, *ptr;
 	size_t i;
 	int j;
 	static char *section = 0;
+	static char *arg = 0;
 	static int ln = 0;
 
 	/* Lines starting with '#' or ';' are comments.  */
@@ -240,7 +248,6 @@ conf_parse_line(int trans, char *line, size_t sz)
 		/* Strip off any blanks after '[' */
 		while (isblank(*line)) 
 			line++;
-
 		for (i = 0; i < sz; i++) {
 			if (line[i] == ']') {
 				break;
@@ -260,7 +267,6 @@ conf_parse_line(int trans, char *line, size_t sz)
 			val++, j++;
 		if (*val)
 			i = j;
-
 		section = malloc(i);
 		if (!section) {
 			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
@@ -268,6 +274,26 @@ conf_parse_line(int trans, char *line, size_t sz)
 			return;
 		}
 		strncpy(section, line, i);
+
+		if (arg) 
+			free(arg);
+		arg = 0;
+
+		ptr = strchr(val, '"');
+		if (ptr == NULL)
+			return;
+		line = ++ptr;
+		while (*ptr && *ptr != '"')
+			ptr++;
+		if (*ptr == '\0') {
+			xlog_warn("conf_parse_line: line %d:"
+ 				"non-matched '\"', ignoring until next section", ln);
+		}  else {
+			*ptr = '\0';
+			arg = strdup(line);
+			if (!arg) 
+				xlog_warn("conf_parse_line: %d: malloc arg failed", ln);
+		}
 		return;
 	}
 
@@ -286,7 +312,7 @@ conf_parse_line(int trans, char *line, size_t sz)
 			for (j = sz - (val - line) - 1; j > 0 && isspace(val[j]); j--)
 				val[j] = '\0';
 			/* XXX Perhaps should we not ignore errors?  */
-			conf_set(trans, section, line, val, 0, 0);
+			conf_set(trans, section, arg, line, val, 0, 0);
 			return;
 		}
 	}
@@ -460,6 +486,26 @@ conf_get_str(char *section, char *tag)
 	}
 	return 0;
 }
+/*
+ * Find a section that may or may not have an argument
+ */
+char *
+conf_get_section(char *section, char *arg, char *tag)
+{
+	struct conf_binding *cb;
+
+	cb = LIST_FIRST (&conf_bindings[conf_hash (section)]);
+	for (; cb; cb = LIST_NEXT (cb, link)) {
+		if (strcasecmp(section, cb->section) != 0)
+			continue;
+		if (arg && strcasecmp(arg, cb->arg) != 0)
+			continue;
+		if (strcasecmp(tag, cb->tag) != 0)
+			continue;
+		return cb->value;
+	}
+	return 0;
+}
 
 /*
  * Build a list of string values out of the comma separated value denoted by
@@ -652,9 +698,9 @@ conf_trans_node(int transaction, enum conf_op op)
 }
 
 /* Queue a set operation.  */
-int
-conf_set(int transaction, char *section, char *tag, 
-	char *value, int override, int is_default)
+static int
+conf_set(int transaction, char *section, char *arg,
+	char *tag, char *value, int override, int is_default)
 {
 	struct conf_trans *node;
 
@@ -669,6 +715,15 @@ conf_set(int transaction, char *section, char *tag,
 	/* Make Section names case-insensitive */
 	upper2lower(node->section);
 
+	if (arg) {
+		node->arg = strdup(arg);
+		if (!node->arg) {
+			xlog_warn("conf_set: strdup(\"%s\") failed", arg);
+			goto fail;
+		}
+	} else
+		node->arg = NULL;
+
 	node->tag = strdup(tag);
 	if (!node->tag) {
 		xlog_warn("conf_set: strdup(\"%s\") failed", tag);
@@ -756,8 +811,9 @@ conf_end(int transaction, int commit)
 			if (commit) {
 				switch (node->op) {
 				case CONF_SET:
-					conf_set_now(node->section, node->tag, node->value,
-					node->override, node->is_default);
+					conf_set_now(node->section, node->arg, 
+						node->tag, node->value, node->override, 
+						node->is_default);
 					break;
 				case CONF_REMOVE:
 					conf_remove_now(node->section, node->tag);
@@ -813,8 +869,9 @@ void
 conf_report (void)
 {
 	struct conf_binding *cb, *last = 0;
-	unsigned int i, len;
+	unsigned int i, len, diff_arg = 0;
 	char *current_section = (char *)0;
+	char *current_arg = (char *)0;
 	struct dumper *dumper, *dnode;
 
 	dumper = dnode = (struct dumper *)calloc(1, sizeof *dumper);
@@ -826,15 +883,29 @@ conf_report (void)
 	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
 		for (cb = LIST_FIRST(&conf_bindings[i]); cb; cb = LIST_NEXT(cb, link)) {
 			if (!cb->is_default) {
+				/* Make sure the Section arugment is the same */
+				if (current_arg && current_section && cb->arg) {
+					if (strcmp(cb->section, current_section) == 0 &&
+						strcmp(cb->arg, current_arg) != 0)
+					diff_arg = 1;
+				}
 				/* Dump this entry.  */
-				if (!current_section || strcmp(cb->section, current_section)) {
-					if (current_section) {
+				if (!current_section || strcmp(cb->section, current_section) 
+							|| diff_arg) {
+					if (current_section || diff_arg) {
 						len = strlen (current_section) + 3;
+						if (current_arg)
+							len += strlen(current_arg) + 3;
 						dnode->s = malloc(len);
 						if (!dnode->s)
 							goto mem_fail;
 
-						snprintf(dnode->s, len, "[%s]", current_section);
+						if (current_arg)
+							snprintf(dnode->s, len, "[%s \"%s\"]", 
+								current_section, current_arg);
+						else
+							snprintf(dnode->s, len, "[%s]", current_section);
+
 						dnode->next = 
 							(struct dumper *)calloc(1, sizeof (struct dumper));
 						dnode = dnode->next;
@@ -849,6 +920,8 @@ conf_report (void)
 						goto mem_fail;
 					}
 					current_section = cb->section;
+					current_arg = cb->arg;
+					diff_arg = 0;
 				}
 				dnode->s = cb->tag;
 				dnode->v = cb->value;
@@ -862,10 +935,15 @@ conf_report (void)
 
 	if (last) {
 		len = strlen(last->section) + 3;
+		if (last->arg)
+			len += strlen(last->arg) + 3;
 		dnode->s = malloc(len);
 		if (!dnode->s)
 			goto mem_fail;
-		snprintf(dnode->s, len, "[%s]", last->section);
+		if (last->arg)
+			snprintf(dnode->s, len, "[%s \"%s\"]", last->section, last->arg);
+		else
+			snprintf(dnode->s, len, "[%s]", last->section);
 	}
 	conf_report_dump(dumper);
 	return;
