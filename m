From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 1/8] NFS Mount Configuration File (Vers 2)
Date: Mon, 03 Aug 2009 10:51:09 -0400
Message-ID: <4A76F95D.8050209@RedHat.com>
References: <4A76F8E6.2010607@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A76F8E6.2010607@RedHat.com>
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

commit 6ac5162f456950052d2ae59f8d375ceee694d432
Author: Steve Dickson <steved@redhat.com>
Date:   Sun Aug 2 12:26:52 2009 -0400

    Move idmapd's configuration file parsing routines into
    the shared libnfs.a library, making them available to\
    other daemons and programs.
    =

    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/Makefile.am b/support/include/Makefile.am
index 718abda..f5a77ec 100644
--- a/support/include/Makefile.am
+++ b/support/include/Makefile.am
@@ -14,6 +14,7 @@ noinst_HEADERS =3D \
 	xio.h \
 	xlog.h \
 	xmalloc.h \
-	xcommon.h
+	xcommon.h \
+	conffile.h
 =

 MAINTAINERCLEANFILES =3D Makefile.in
diff --git a/support/include/conffile.h b/support/include/conffile.h
new file mode 100644
index 0000000..3309788
--- /dev/null
+++ b/support/include/conffile.h
@@ -0,0 +1,67 @@
+/* $OpenBSD: conf.h,v 1.30 2004/06/25 20:25:34 hshoexer Exp $	 */
+/* $EOM: conf.h,v 1.13 2000/09/18 00:01:47 ho Exp $	 */
+
+/*
+ * Copyright (c) 1998, 1999, 2001 Niklas Hallqvist.  All rights reserved.
+ * Copyright (c) 2000, 2003 H=E5kan Olsson.  All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTI=
ES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/*
+ * This code was written under funding by Ericsson Radio Systems.
+ */
+
+#ifndef _CONFFILE_H_
+#define _CONFFILE_H_
+
+#include <sys/queue.h>
+
+struct conf_list_node {
+	TAILQ_ENTRY(conf_list_node) link;
+	char	*field;
+};
+
+struct conf_list {
+	size_t	cnt;
+	TAILQ_HEAD(conf_list_fields_head, conf_list_node) fields;
+};
+
+extern char    *conf_path;
+
+extern int      conf_begin(void);
+extern int      conf_decode_base64(u_int8_t *, u_int32_t *, u_char *);
+extern int      conf_end(int, int);
+extern void     conf_free_list(struct conf_list *);
+extern struct sockaddr *conf_get_address(char *, char *);
+extern struct conf_list *conf_get_list(char *, char *);
+extern struct conf_list *conf_get_tag_list(char *);
+extern int      conf_get_num(char *, char *, int);
+extern char    *conf_get_str(char *, char *);
+extern void     conf_init(void);
+extern int      conf_match_num(char *, char *, int);
+extern void     conf_reinit(void);
+extern int      conf_remove(int, char *, char *);
+extern int      conf_remove_section(int, char *);
+extern int      conf_set(int, char *, char *, char *, int, int);
+extern void     conf_report(void);
+
+#endif				/* _CONFFILE_H_ */
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index 86f52a1..63e1800 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -4,7 +4,7 @@ noinst_LIBRARIES =3D libnfs.a
 libnfs_a_SOURCES =3D exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c nfssvc.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c rpc_socket.c getport.c \
-		   svc_socket.c cacheio.c closeall.c nfs_mntent.c
+		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c
 =

 MAINTAINERCLEANFILES =3D Makefile.in
 =

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
new file mode 100644
index 0000000..eea888e
--- /dev/null
+++ b/support/nfs/conffile.c
@@ -0,0 +1,850 @@
+/*	$OpenBSD: conf.c,v 1.55 2003/06/03 14:28:16 ho Exp $	*/
+/*	$EOM: conf.c,v 1.48 2000/12/04 02:04:29 angelos Exp $	*/
+
+/*
+ * Copyright (c) 1998, 1999, 2000, 2001 Niklas Hallqvist.  All rights rese=
rved.
+ * Copyright (c) 2000, 2001, 2002 H=E5kan Olsson.  All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTI=
ES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+/*
+ * This code was written under funding by Ericsson Radio Systems.
+ */
+
+#include <sys/param.h>
+#include <sys/mman.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <ctype.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <err.h>
+#include <syslog.h>
+
+#include "conffile.h"
+#include "xlog.h"
+
+static void conf_load_defaults (int);
+#if 0
+static int conf_find_trans_xf (int, char *);
+#endif
+
+size_t  strlcpy(char *, const char *, size_t);
+
+struct conf_trans {
+	TAILQ_ENTRY (conf_trans) link;
+	int trans;
+	enum conf_op { CONF_SET, CONF_REMOVE, CONF_REMOVE_SECTION } op;
+	char *section;
+	char *tag;
+	char *value;
+	int override;
+	int is_default;
+};
+
+TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
+
+/*
+ * Radix-64 Encoding.
+ */
+static const u_int8_t bin2asc[]
+  =3D "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
+
+static const u_int8_t asc2bin[] =3D
+{
+  255, 255, 255, 255, 255, 255, 255, 255,
+  255, 255, 255, 255, 255, 255, 255, 255,
+  255, 255, 255, 255, 255, 255, 255, 255,
+  255, 255, 255, 255, 255, 255, 255, 255,
+  255, 255, 255, 255, 255, 255, 255, 255,
+  255, 255, 255,  62, 255, 255, 255,  63,
+   52,  53,  54,  55,  56,  57,  58,  59,
+   60,  61, 255, 255, 255, 255, 255, 255,
+  255,   0,   1,   2,   3,   4,   5,   6,
+    7,   8,   9,  10,  11,  12,  13,  14,
+   15,  16,  17,  18,  19,  20,  21,  22,
+   23,  24,  25, 255, 255, 255, 255, 255,
+  255,  26,  27,  28,  29,  30,  31,  32,
+   33,  34,  35,  36,  37,  38,  39,  40,
+   41,  42,  43,  44,  45,  46,  47,  48,
+   49,  50,  51, 255, 255, 255, 255, 255
+};
+
+struct conf_binding {
+  LIST_ENTRY (conf_binding) link;
+  char *section;
+  char *tag;
+  char *value;
+  int is_default;
+};
+
+char *conf_path;
+LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
+
+static char *conf_addr;
+
+static __inline__ u_int8_t
+conf_hash(char *s)
+{
+	u_int8_t hash =3D 0;
+
+	while (*s) {
+		hash =3D ((hash << 1) | (hash >> 7)) ^ tolower (*s);
+		s++;
+	}
+	return hash;
+}
+
+/*
+ * Insert a tag-value combination from LINE (the equal sign is at POS)
+ */
+static int
+conf_remove_now(char *section, char *tag)
+{
+	struct conf_binding *cb, *next;
+
+	cb =3D LIST_FIRST(&conf_bindings[conf_hash (section)]);
+	for (; cb; cb =3D next) {
+		next =3D LIST_NEXT(cb, link);
+		if (strcasecmp(cb->section, section) =3D=3D 0
+				&& strcasecmp(cb->tag, tag) =3D=3D 0) {
+			LIST_REMOVE(cb, link);
+			xlog(LOG_INFO,"[%s]:%s->%s removed", section, tag, cb->value);
+			free(cb->section);
+			free(cb->tag);
+			free(cb->value);
+			free(cb);
+			return 0;
+		}
+	}
+	return 1;
+}
+
+static int
+conf_remove_section_now(char *section)
+{
+  struct conf_binding *cb, *next;
+  int unseen =3D 1;
+
+	cb =3D LIST_FIRST(&conf_bindings[conf_hash (section)]);
+	for (; cb; cb =3D next) {
+		next =3D LIST_NEXT(cb, link);
+		if (strcasecmp(cb->section, section) =3D=3D 0) {
+			unseen =3D 0;
+			LIST_REMOVE(cb, link);
+			xlog(LOG_INFO, "[%s]:%s->%s removed", section, cb->tag, cb->value);
+			free(cb->section);
+			free(cb->tag);
+			free(cb->value);
+			free(cb);
+			}
+		}
+	return unseen;
+}
+
+/*
+ * Insert a tag-value combination from LINE (the equal sign is at POS)
+ * into SECTION of our configuration database.
+ */
+static int
+conf_set_now(char *section, char *tag, char *value, int override,
+	      int is_default)
+{
+	struct conf_binding *node =3D 0;
+
+	if (override)
+		conf_remove_now(section, tag);
+	else if (conf_get_str(section, tag)) {
+		if (!is_default) {
+			xlog(LOG_INFO, "conf_set: duplicate tag [%s]:%s, ignoring...\n", =

+				section, tag);
+		}
+		return 1;
+	}
+
+	node =3D calloc(1, sizeof *node);
+	if (!node) {
+		xlog_warn("conf_set: calloc (1, %lu) failed", (unsigned long)sizeof *nod=
e);
+		return 1;
+	}
+	node->section =3D strdup(section);
+	node->tag =3D strdup(tag);
+	node->value =3D strdup(value);
+	node->is_default =3D is_default;
+
+	LIST_INSERT_HEAD(&conf_bindings[conf_hash (section)], node, link);
+	return 0;
+}
+
+/*
+ * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
+ * headers and feed tag-value pairs into our configuration database.
+ */
+static void
+conf_parse_line(int trans, char *line, size_t sz)
+{
+	char *val;
+	size_t i;
+	int j;
+	static char *section =3D 0;
+	static int ln =3D 0;
+
+	/* Lines starting with '#' or ';' are comments.  */
+	ln++;
+	if (*line =3D=3D '#' || *line =3D=3D ';')
+		return;
+
+	/* '[section]' parsing...  */
+	if (*line =3D=3D '[') {
+		for (i =3D 1; i < sz; i++)
+			if (line[i] =3D=3D ']')
+				break;
+		if (section)
+			free (section);
+		if (i =3D=3D sz) {
+			xlog_warn("conf_parse_line: %d:"
+ 				"non-matched ']', ignoring until next section", ln);
+			section =3D 0;
+			return;
+		}
+		section =3D malloc(i);
+		if (!section) {
+			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
+						(unsigned long)i);
+			return;
+		}
+		strlcpy(section, line + 1, i);
+		return;
+	}
+
+	/* Deal with assignments.  */
+	for (i =3D 0; i < sz; i++) {
+		if (line[i] =3D=3D '=3D') {
+			/* If no section, we are ignoring the lines.  */
+			if (!section) {
+				xlog_warn("conf_parse_line: %d: ignoring line due to no section", =

+					ln);
+				return;
+			}
+			line[strcspn (line, " \t=3D")] =3D '\0';
+			val =3D line + i + 1 + strspn (line + i + 1, " \t");
+			/* Skip trailing whitespace, if any */
+			for (j =3D sz - (val - line) - 1; j > 0 && isspace(val[j]); j--)
+				val[j] =3D '\0';
+			/* XXX Perhaps should we not ignore errors?  */
+			conf_set(trans, section, line, val, 0, 0);
+			return;
+		}
+	}
+	/* Other non-empty lines are weird.  */
+	i =3D strspn(line, " \t");
+	if (line[i])
+		xlog_warn("conf_parse_line: %d: syntax error", ln);
+
+	return;
+}
+
+/* Parse the mapped configuration file.  */
+static void
+conf_parse(int trans, char *buf, size_t sz)
+{
+	char *cp =3D buf;
+	char *bufend =3D buf + sz;
+	char *line;
+
+	line =3D cp;
+	while (cp < bufend) {
+		if (*cp =3D=3D '\n') {
+			/* Check for escaped newlines.  */
+			if (cp > buf && *(cp - 1) =3D=3D '\\')
+				*(cp - 1) =3D *cp =3D ' ';
+			else {
+				*cp =3D '\0';
+				conf_parse_line(trans, line, cp - line);
+				line =3D cp + 1;
+			}
+		}
+		cp++;
+	}
+	if (cp !=3D line)
+		xlog_warn("conf_parse: last line non-terminated, ignored.");
+}
+
+static void
+conf_load_defaults(int tr)
+{
+	/* No defaults */
+	return;
+}
+
+void
+conf_init (void)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
+		LIST_INIT (&conf_bindings[i]);
+
+	TAILQ_INIT (&conf_trans_queue);
+	conf_reinit();
+}
+
+/* Open the config file and map it into our address space, then parse it. =
 */
+void
+conf_reinit(void)
+{
+	struct conf_binding *cb =3D 0;
+	int fd, trans;
+	unsigned int i;
+	size_t sz;
+	char *new_conf_addr =3D 0;
+	struct stat sb;
+
+	if ((stat (conf_path, &sb) =3D=3D 0) || (errno !=3D ENOENT)) {
+		sz =3D sb.st_size;
+		fd =3D open (conf_path, O_RDONLY, 0);
+		if (fd =3D=3D -1) {
+			xlog_warn("conf_reinit: open (\"%s\", O_RDONLY) failed", conf_path);
+			return;
+		}
+
+		new_conf_addr =3D malloc(sz);
+		if (!new_conf_addr) {
+			xlog_warn("conf_reinit: malloc (%lu) failed", (unsigned long)sz);
+			goto fail;
+		}
+
+		/* XXX I assume short reads won't happen here.  */
+		if (read (fd, new_conf_addr, sz) !=3D (int)sz) {
+			xlog_warn("conf_reinit: read (%d, %p, %lu) failed",
+   				fd, new_conf_addr, (unsigned long)sz);
+			goto fail;
+		}
+		close(fd);
+
+		trans =3D conf_begin();
+		/* XXX Should we not care about errors and rollback?  */
+		conf_parse(trans, new_conf_addr, sz);
+	}
+	else
+		trans =3D conf_begin();
+
+	/* Load default configuration values.  */
+	conf_load_defaults(trans);
+
+	/* Free potential existing configuration.  */
+	if (conf_addr) {
+		for (i =3D 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++) {
+			cb =3D LIST_FIRST (&conf_bindings[i]);
+			for (; cb; cb =3D LIST_FIRST (&conf_bindings[i]))
+				conf_remove_now(cb->section, cb->tag);
+		}
+		free (conf_addr);
+	}
+
+	conf_end(trans, 1);
+	conf_addr =3D new_conf_addr;
+	return;
+
+fail:
+	if (new_conf_addr)
+		free(new_conf_addr);
+	close (fd);
+}
+
+/*
+ * Return the numeric value denoted by TAG in section SECTION or DEF
+ * if that tag does not exist.
+ */
+int
+conf_get_num(char *section, char *tag, int def)
+{
+	char *value =3D conf_get_str(section, tag);
+
+	if (value)
+		return atoi(value);
+
+	return def;
+}
+
+/* Validate X according to the range denoted by TAG in section SECTION.  */
+int
+conf_match_num(char *section, char *tag, int x)
+{
+	char *value =3D conf_get_str (section, tag);
+	int val, min, max, n;
+
+	if (!value)
+		return 0;
+	n =3D sscanf (value, "%d,%d:%d", &val, &min, &max);
+	switch (n) {
+	case 1:
+		xlog(LOG_INFO, "conf_match_num: %s:%s %d=3D=3D%d?", section, tag, val, x=
);
+		return x =3D=3D val;
+	case 3:
+		xlog(LOG_INFO, "conf_match_num: %s:%s %d<=3D%d<=3D%d?", section, =

+			tag, min, x, max);
+		return min <=3D x && max >=3D x;
+	default:
+		xlog(LOG_INFO, "conf_match_num: section %s tag %s: invalid number spec %=
s",
+			section, tag, value);
+	}
+	return 0;
+}
+
+/* Return the string value denoted by TAG in section SECTION.  */
+char *
+conf_get_str(char *section, char *tag)
+{
+	struct conf_binding *cb;
+
+	cb =3D LIST_FIRST (&conf_bindings[conf_hash (section)]);
+	for (; cb; cb =3D LIST_NEXT (cb, link)) {
+		if (strcasecmp (section, cb->section) =3D=3D 0
+				&& strcasecmp (tag, cb->tag) =3D=3D 0)
+			return cb->value;
+	}
+	return 0;
+}
+
+/*
+ * Build a list of string values out of the comma separated value denoted =
by
+ * TAG in SECTION.
+ */
+struct conf_list *
+conf_get_list(char *section, char *tag)
+{
+	char *liststr =3D 0, *p, *field, *t;
+	struct conf_list *list =3D 0;
+	struct conf_list_node *node;
+
+	list =3D malloc (sizeof *list);
+	if (!list)
+		goto cleanup;
+	TAILQ_INIT (&list->fields);
+	list->cnt =3D 0;
+	liststr =3D conf_get_str(section, tag);
+	if (!liststr)
+		goto cleanup;
+	liststr =3D strdup (liststr);
+	if (!liststr)
+		goto cleanup;
+	p =3D liststr;
+	while ((field =3D strsep (&p, ",")) !=3D NULL) {
+		/* Skip leading whitespace */
+		while (isspace (*field))
+			field++;
+		/* Skip trailing whitespace */
+		if (p) {
+			for (t =3D p - 1; t > field && isspace (*t); t--)
+				*t =3D '\0';
+		}
+		if (*field =3D=3D '\0') {
+			xlog(LOG_INFO, "conf_get_list: empty field, ignoring...");
+			continue;
+		}
+		list->cnt++;
+		node =3D calloc (1, sizeof *node);
+		if (!node)
+			goto cleanup;
+		node->field =3D strdup (field);
+		if (!node->field) {
+			free(node);
+			goto cleanup;
+		}
+		TAILQ_INSERT_TAIL (&list->fields, node, link);
+	}
+	free (liststr);
+	return list;
+
+cleanup:
+	if (list)
+		conf_free_list(list);
+	if (liststr)
+		free(liststr);
+	return 0;
+}
+
+struct conf_list *
+conf_get_tag_list(char *section)
+{
+	struct conf_list *list =3D 0;
+	struct conf_list_node *node;
+	struct conf_binding *cb;
+
+	list =3D malloc(sizeof *list);
+	if (!list)
+		goto cleanup;
+	TAILQ_INIT(&list->fields);
+	list->cnt =3D 0;
+	cb =3D LIST_FIRST(&conf_bindings[conf_hash (section)]);
+	for (; cb; cb =3D LIST_NEXT(cb, link)) {
+		if (strcasecmp (section, cb->section) =3D=3D 0) {
+			list->cnt++;
+			node =3D calloc (1, sizeof *node);
+			if (!node)
+				goto cleanup;
+			node->field =3D strdup(cb->tag);
+			if (!node->field) {
+				free(node);
+				goto cleanup;
+			}
+			TAILQ_INSERT_TAIL(&list->fields, node, link);
+		}
+	}
+	return list;
+
+cleanup:
+	if (list)
+		conf_free_list(list);
+	return 0;
+}
+
+/* Decode a PEM encoded buffer.  */
+int
+conf_decode_base64 (u_int8_t *out, u_int32_t *len, u_char *buf)
+{
+	u_int32_t c =3D 0;
+	u_int8_t c1, c2, c3, c4;
+
+	while (*buf) {
+		if (*buf > 127 || (c1 =3D asc2bin[*buf]) =3D=3D 255)
+			return 0;
+
+		buf++;
+		if (*buf > 127 || (c2 =3D asc2bin[*buf]) =3D=3D 255)
+			return 0;
+
+		buf++;
+		if (*buf =3D=3D '=3D') {
+			c3 =3D c4 =3D 0;
+			c++;
+
+			/* Check last four bit */
+			if (c2 & 0xF)
+				return 0;
+
+			if (strcmp((char *)buf, "=3D=3D") =3D=3D 0)
+				buf++;
+			else
+				return 0;
+		} else if (*buf > 127 || (c3 =3D asc2bin[*buf]) =3D=3D 255)
+			return 0;
+		else {
+			if (*++buf =3D=3D '=3D') {
+				c4 =3D 0;
+				c +=3D 2;
+
+				/* Check last two bit */
+				if (c3 & 3)
+					return 0;
+
+			if (strcmp((char *)buf, "=3D"))
+				return 0;
+			} else if (*buf > 127 || (c4 =3D asc2bin[*buf]) =3D=3D 255)
+				return 0;
+			else
+				c +=3D 3;
+		}
+
+		buf++;
+		*out++ =3D (c1 << 2) | (c2 >> 4);
+		*out++ =3D (c2 << 4) | (c3 >> 2);
+		*out++ =3D (c3 << 6) | c4;
+	}
+
+	*len =3D c;
+	return 1;
+}
+
+void
+conf_free_list(struct conf_list *list)
+{
+	struct conf_list_node *node =3D TAILQ_FIRST(&list->fields);
+
+	while (node) {
+		TAILQ_REMOVE(&list->fields, node, link);
+		if (node->field)
+			free(node->field);
+		free (node);
+		node =3D TAILQ_FIRST(&list->fields);
+	}
+	free (list);
+}
+
+int
+conf_begin (void)
+{
+  static int seq =3D 0;
+
+  return ++seq;
+}
+
+static struct conf_trans *
+conf_trans_node (int transaction, enum conf_op op)
+{
+	struct conf_trans *node;
+
+	node =3D calloc (1, sizeof *node);
+	if (!node) {
+		xlog_warn("conf_trans_node: calloc (1, %lu) failed",
+		(unsigned long)sizeof *node);
+		return 0;
+	}
+	node->trans =3D transaction;
+	node->op =3D op;
+	TAILQ_INSERT_TAIL (&conf_trans_queue, node, link);
+	return node;
+}
+
+/* Queue a set operation.  */
+int
+conf_set (int transaction, char *section, char *tag, =

+	char *value, int override, int is_default)
+{
+	struct conf_trans *node;
+
+	node =3D conf_trans_node(transaction, CONF_SET);
+	if (!node)
+		return 1;
+	node->section =3D strdup(section);
+	if (!node->section) {
+		xlog_warn("conf_set: strdup(\"%s\") failed", section);
+		goto fail;
+	}
+	node->tag =3D strdup(tag);
+	if (!node->tag) {
+		xlog_warn("conf_set: strdup(\"%s\") failed", tag);
+		goto fail;
+	}
+	node->value =3D strdup(value);
+	if (!node->value) {
+		xlog_warn("conf_set: strdup(\"%s\") failed", value);
+		goto fail;
+	}
+	node->override =3D override;
+	node->is_default =3D is_default;
+	return 0;
+
+fail:
+	if (node->tag)
+		free(node->tag);
+	if (node->section)
+		free(node->section);
+	if (node)
+		free(node);
+	return 1;
+}
+
+/* Queue a remove operation.  */
+int
+conf_remove(int transaction, char *section, char *tag)
+{
+	struct conf_trans *node;
+
+	node =3D conf_trans_node(transaction, CONF_REMOVE);
+	if (!node)
+		goto fail;
+	node->section =3D strdup(section);
+	if (!node->section) {
+		xlog_warn("conf_remove: strdup(\"%s\") failed", section);
+		goto fail;
+	}
+	node->tag =3D strdup(tag);
+	if (!node->tag) {
+		xlog_warn("conf_remove: strdup(\"%s\") failed", tag);
+		goto fail;
+	}
+	return 0;
+
+fail:
+	if (node && node->section)
+		free (node->section);
+	if (node)
+		free (node);
+	return 1;
+}
+
+/* Queue a remove section operation.  */
+int
+conf_remove_section(int transaction, char *section)
+{
+	struct conf_trans *node;
+
+	node =3D conf_trans_node(transaction, CONF_REMOVE_SECTION);
+	if (!node)
+		goto fail;
+	node->section =3D strdup(section);
+	if (!node->section) {
+		xlog_warn("conf_remove_section: strdup(\"%s\") failed", section);
+		goto fail;
+	}
+	return 0;
+
+fail:
+	if (node)
+		free(node);
+	return 1;
+}
+
+/* Execute all queued operations for this transaction.  Cleanup.  */
+int
+conf_end(int transaction, int commit)
+{
+	struct conf_trans *node, *next;
+
+	for (node =3D TAILQ_FIRST(&conf_trans_queue); node; node =3D next) {
+		next =3D TAILQ_NEXT(node, link);
+		if (node->trans =3D=3D transaction) {
+			if (commit) {
+				switch (node->op) {
+				case CONF_SET:
+					conf_set_now(node->section, node->tag, node->value,
+					node->override, node->is_default);
+					break;
+				case CONF_REMOVE:
+					conf_remove_now(node->section, node->tag);
+					break;
+				case CONF_REMOVE_SECTION:
+					conf_remove_section_now(node->section);
+					break;
+				default:
+					xlog(LOG_INFO, "conf_end: unknown operation: %d", node->op);
+				}
+			}
+			TAILQ_REMOVE (&conf_trans_queue, node, link);
+			if (node->section)
+				free(node->section);
+			if (node->tag)
+				free(node->tag);
+			if (node->value)
+				free(node->value);
+			free (node);
+		}
+	}
+	return 0;
+}
+
+/*
+ * Dump running configuration upon SIGUSR1.
+ * Configuration is "stored in reverse order", so reverse it again.
+ */
+struct dumper {
+	char *s, *v;
+	struct dumper *next;
+};
+
+static void
+conf_report_dump(struct dumper *node)
+{
+	/* Recursive, cleanup when we're done.  */
+	if (node->next)
+		conf_report_dump(node->next);
+
+	if (node->v)
+		xlog(LOG_INFO, "%s=3D\t%s", node->s, node->v);
+	else if (node->s) {
+		xlog(LOG_INFO, "%s", node->s);
+		if (strlen(node->s) > 0)
+			free(node->s);
+	}
+
+	free (node);
+}
+
+void
+conf_report (void)
+{
+	struct conf_binding *cb, *last =3D 0;
+	unsigned int i, len;
+	char *current_section =3D (char *)0;
+	struct dumper *dumper, *dnode;
+
+	dumper =3D dnode =3D (struct dumper *)calloc(1, sizeof *dumper);
+	if (!dumper)
+		goto mem_fail;
+
+	xlog(LOG_INFO, "conf_report: dumping running configuration");
+
+	for (i =3D 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
+		for (cb =3D LIST_FIRST(&conf_bindings[i]); cb; cb =3D LIST_NEXT(cb, link=
)) {
+			if (!cb->is_default) {
+				/* Dump this entry.  */
+				if (!current_section || strcmp(cb->section, current_section)) {
+					if (current_section) {
+						len =3D strlen (current_section) + 3;
+						dnode->s =3D malloc(len);
+						if (!dnode->s)
+							goto mem_fail;
+
+						snprintf(dnode->s, len, "[%s]", current_section);
+						dnode->next =3D =

+							(struct dumper *)calloc(1, sizeof (struct dumper));
+						dnode =3D dnode->next;
+						if (!dnode)
+							goto mem_fail;
+
+						dnode->s =3D "";
+						dnode->next =3D =

+							(struct dumper *)calloc(1, sizeof (struct dumper));
+						dnode =3D dnode->next;
+						if (!dnode)
+						goto mem_fail;
+					}
+					current_section =3D cb->section;
+				}
+				dnode->s =3D cb->tag;
+				dnode->v =3D cb->value;
+				dnode->next =3D (struct dumper *)calloc (1, sizeof (struct dumper));
+				dnode =3D dnode->next;
+				if (!dnode)
+					goto mem_fail;
+				last =3D cb;
+		}
+	}
+
+	if (last) {
+		len =3D strlen(last->section) + 3;
+		dnode->s =3D malloc(len);
+		if (!dnode->s)
+			goto mem_fail;
+		snprintf(dnode->s, len, "[%s]", last->section);
+	}
+	conf_report_dump(dumper);
+	return;
+
+mem_fail:
+	xlog_warn("conf_report: malloc/calloc failed");
+	while ((dnode =3D dumper) !=3D 0) {
+		dumper =3D dumper->next;
+		if (dnode->s)
+			free(dnode->s);
+		free(dnode);
+	}
+	return;
+}
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index eb393df..4dabb3d 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -14,7 +14,6 @@ EXTRA_DIST =3D \
 =

 idmapd_SOURCES =3D \
 	atomicio.c \
-	cfg.c \
 	idmapd.c \
 	strlcat.c \
 	strlcpy.c \
diff --git a/utils/idmapd/cfg.c b/utils/idmapd/cfg.c
deleted file mode 100644
index 16d392a..0000000
--- a/utils/idmapd/cfg.c
+++ /dev/null
@@ -1,893 +0,0 @@
-/*	$OpenBSD: conf.c,v 1.55 2003/06/03 14:28:16 ho Exp $	*/
-/*	$EOM: conf.c,v 1.48 2000/12/04 02:04:29 angelos Exp $	*/
-
-/*
- * Copyright (c) 1998, 1999, 2000, 2001 Niklas Hallqvist.  All rights rese=
rved.
- * Copyright (c) 2000, 2001, 2002 H=E5kan Olsson.  All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTI=
ES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-/*
- * This code was written under funding by Ericsson Radio Systems.
- */
-
-#include <sys/param.h>
-#include <sys/mman.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
-#include <ctype.h>
-#include <fcntl.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <unistd.h>
-#include <errno.h>
-#include <err.h>
-
-#include "cfg.h"
-
-static void conf_load_defaults (int);
-#if 0
-static int conf_find_trans_xf (int, char *);
-#endif
-
-size_t  strlcpy(char *, const char *, size_t);
-
-struct conf_trans {
-  TAILQ_ENTRY (conf_trans) link;
-  int trans;
-  enum conf_op { CONF_SET, CONF_REMOVE, CONF_REMOVE_SECTION } op;
-  char *section;
-  char *tag;
-  char *value;
-  int override;
-  int is_default;
-};
-
-TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
-
-/*
- * Radix-64 Encoding.
- */
-const u_int8_t bin2asc[]
-  =3D "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
-
-const u_int8_t asc2bin[] =3D
-{
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255,  62, 255, 255, 255,  63,
-   52,  53,  54,  55,  56,  57,  58,  59,
-   60,  61, 255, 255, 255, 255, 255, 255,
-  255,   0,   1,   2,   3,   4,   5,   6,
-    7,   8,   9,  10,  11,  12,  13,  14,
-   15,  16,  17,  18,  19,  20,  21,  22,
-   23,  24,  25, 255, 255, 255, 255, 255,
-  255,  26,  27,  28,  29,  30,  31,  32,
-   33,  34,  35,  36,  37,  38,  39,  40,
-   41,  42,  43,  44,  45,  46,  47,  48,
-   49,  50,  51, 255, 255, 255, 255, 255
-};
-
-struct conf_binding {
-  LIST_ENTRY (conf_binding) link;
-  char *section;
-  char *tag;
-  char *value;
-  int is_default;
-};
-
-char *conf_path;
-LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
-
-static char *conf_addr;
-
-static __inline__ u_int8_t
-conf_hash (char *s)
-{
-  u_int8_t hash =3D 0;
-
-  while (*s)
-    {
-      hash =3D ((hash << 1) | (hash >> 7)) ^ tolower (*s);
-      s++;
-    }
-  return hash;
-}
-
-/*
- * Insert a tag-value combination from LINE (the equal sign is at POS)
- */
-static int
-conf_remove_now (char *section, char *tag)
-{
-  struct conf_binding *cb, *next;
-
-  for (cb =3D LIST_FIRST (&conf_bindings[conf_hash (section)]); cb; cb =3D=
 next)
-    {
-      next =3D LIST_NEXT (cb, link);
-      if (strcasecmp (cb->section, section) =3D=3D 0
-	  && strcasecmp (cb->tag, tag) =3D=3D 0)
-	{
-	  LIST_REMOVE (cb, link);
-	  warnx("[%s]:%s->%s removed", section, tag, cb->value);
-	  free (cb->section);
-	  free (cb->tag);
-	  free (cb->value);
-	  free (cb);
-	  return 0;
-	}
-    }
-  return 1;
-}
-
-static int
-conf_remove_section_now (char *section)
-{
-  struct conf_binding *cb, *next;
-  int unseen =3D 1;
-
-  for (cb =3D LIST_FIRST (&conf_bindings[conf_hash (section)]); cb; cb =3D=
 next)
-    {
-      next =3D LIST_NEXT (cb, link);
-      if (strcasecmp (cb->section, section) =3D=3D 0)
-	{
-	  unseen =3D 0;
-	  LIST_REMOVE (cb, link);
-	  warnx("[%s]:%s->%s removed", section, cb->tag, cb->value);
-	  free (cb->section);
-	  free (cb->tag);
-	  free (cb->value);
-	  free (cb);
-	}
-    }
-  return unseen;
-}
-
-/*
- * Insert a tag-value combination from LINE (the equal sign is at POS)
- * into SECTION of our configuration database.
- */
-static int
-conf_set_now (char *section, char *tag, char *value, int override,
-	      int is_default)
-{
-  struct conf_binding *node =3D 0;
-
-  if (override)
-    conf_remove_now (section, tag);
-  else if (conf_get_str (section, tag))
-    {
-      if (!is_default)
-	warnx("conf_set: duplicate tag [%s]:%s, ignoring...\n", section, tag);
-      return 1;
-    }
-
-  node =3D calloc (1, sizeof *node);
-  if (!node)
-    {
-      warnx("conf_set: calloc (1, %lu) failed", (unsigned long)sizeof *nod=
e);
-      return 1;
-    }
-  node->section =3D strdup (section);
-  node->tag =3D strdup (tag);
-  node->value =3D strdup (value);
-  node->is_default =3D is_default;
-
-  LIST_INSERT_HEAD (&conf_bindings[conf_hash (section)], node, link);
-  return 0;
-}
-
-/*
- * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
- * headers and feed tag-value pairs into our configuration database.
- */
-static void
-conf_parse_line (int trans, char *line, size_t sz)
-{
-  char *val;
-  size_t i;
-  int j;
-  static char *section =3D 0;
-  static int ln =3D 0;
-
-  ln++;
-
-  /* Lines starting with '#' or ';' are comments.  */
-  if (*line =3D=3D '#' || *line =3D=3D ';')
-    return;
-
-  /* '[section]' parsing...  */
-  if (*line =3D=3D '[')
-    {
-      for (i =3D 1; i < sz; i++)
-	if (line[i] =3D=3D ']')
-	  break;
-      if (section)
-	free (section);
-      if (i =3D=3D sz)
-	{
-	  warnx("conf_parse_line: %d:"
-		     "non-matched ']', ignoring until next section", ln);
-	  section =3D 0;
-	  return;
-	}
-      section =3D malloc (i);
-      if (!section)
-	{
-	  warnx("conf_parse_line: %d: malloc (%lu) failed", ln,
-		(unsigned long)i);
-	  return;
-	}
-      strlcpy (section, line + 1, i);
-      return;
-    }
-
-  /* Deal with assignments.  */
-  for (i =3D 0; i < sz; i++)
-    if (line[i] =3D=3D '=3D')
-      {
-	/* If no section, we are ignoring the lines.  */
-	if (!section)
-	  {
-	    warnx("conf_parse_line: %d: ignoring line due to no section", ln);
-	    return;
-	  }
-	line[strcspn (line, " \t=3D")] =3D '\0';
-	val =3D line + i + 1 + strspn (line + i + 1, " \t");
-	/* Skip trailing whitespace, if any */
-	for (j =3D sz - (val - line) - 1; j > 0 && isspace (val[j]); j--)
-	  val[j] =3D '\0';
-	/* XXX Perhaps should we not ignore errors?  */
-	conf_set (trans, section, line, val, 0, 0);
-	return;
-      }
-
-  /* Other non-empty lines are weird.  */
-  i =3D strspn (line, " \t");
-  if (line[i])
-    warnx("conf_parse_line: %d: syntax error", ln);
-
-  return;
-}
-
-/* Parse the mapped configuration file.  */
-static void
-conf_parse (int trans, char *buf, size_t sz)
-{
-  char *cp =3D buf;
-  char *bufend =3D buf + sz;
-  char *line;
-
-  line =3D cp;
-  while (cp < bufend)
-    {
-      if (*cp =3D=3D '\n')
-	{
-	  /* Check for escaped newlines.  */
-	  if (cp > buf && *(cp - 1) =3D=3D '\\')
-	    *(cp - 1) =3D *cp =3D ' ';
-	  else
-	    {
-	      *cp =3D '\0';
-	      conf_parse_line (trans, line, cp - line);
-	      line =3D cp + 1;
-	    }
-	}
-      cp++;
-    }
-  if (cp !=3D line)
-    warnx("conf_parse: last line non-terminated, ignored.");
-}
-
-static void
-conf_load_defaults (int tr)
-{
-	/* No defaults */
-	return;
-}
-
-void
-conf_init (void)
-{
-  unsigned int i;
-
-  for (i =3D 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
-    LIST_INIT (&conf_bindings[i]);
-  TAILQ_INIT (&conf_trans_queue);
-  conf_reinit ();
-}
-
-/* Open the config file and map it into our address space, then parse it. =
 */
-void
-conf_reinit (void)
-{
-  struct conf_binding *cb =3D 0;
-  int fd, trans;
-  unsigned int i;
-  size_t sz;
-  char *new_conf_addr =3D 0;
-  struct stat sb;
-
-  if ((stat (conf_path, &sb) =3D=3D 0) || (errno !=3D ENOENT))
-    {
-      sz =3D sb.st_size;
-      fd =3D open (conf_path, O_RDONLY, 0);
-      if (fd =3D=3D -1)
-        {
-	  warnx("conf_reinit: open (\"%s\", O_RDONLY) failed", conf_path);
-	  return;
-	}
-
-      new_conf_addr =3D malloc (sz);
-      if (!new_conf_addr)
-        {
-	  warnx("conf_reinit: malloc (%lu) failed", (unsigned long)sz);
-	  goto fail;
-	}
-
-      /* XXX I assume short reads won't happen here.  */
-      if (read (fd, new_conf_addr, sz) !=3D (int)sz)
-        {
-	    warnx("conf_reinit: read (%d, %p, %lu) failed",
-		       fd, new_conf_addr, (unsigned long)sz);
-	    goto fail;
-	}
-      close (fd);
-
-      trans =3D conf_begin ();
-
-      /* XXX Should we not care about errors and rollback?  */
-      conf_parse (trans, new_conf_addr, sz);
-    }
-  else
-    trans =3D conf_begin ();
-
-  /* Load default configuration values.  */
-  conf_load_defaults (trans);
-
-  /* Free potential existing configuration.  */
-  if (conf_addr)
-    {
-      for (i =3D 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i+=
+)
-	for (cb =3D LIST_FIRST (&conf_bindings[i]); cb;
-	     cb =3D LIST_FIRST (&conf_bindings[i]))
-	  conf_remove_now (cb->section, cb->tag);
-      free (conf_addr);
-    }
-
-  conf_end (trans, 1);
-  conf_addr =3D new_conf_addr;
-  return;
-
- fail:
-  if (new_conf_addr)
-    free (new_conf_addr);
-  close (fd);
-}
-
-/*
- * Return the numeric value denoted by TAG in section SECTION or DEF
- * if that tag does not exist.
- */
-int
-conf_get_num (char *section, char *tag, int def)
-{
-  char *value =3D conf_get_str (section, tag);
-
-  if (value)
-      return atoi (value);
-  return def;
-}
-
-/* Validate X according to the range denoted by TAG in section SECTION.  */
-int
-conf_match_num (char *section, char *tag, int x)
-{
-  char *value =3D conf_get_str (section, tag);
-  int val, min, max, n;
-
-  if (!value)
-    return 0;
-  n =3D sscanf (value, "%d,%d:%d", &val, &min, &max);
-  switch (n)
-    {
-    case 1:
-      warnx("conf_match_num: %s:%s %d=3D=3D%d?", section, tag, val, x);
-      return x =3D=3D val;
-    case 3:
-      warnx("conf_match_num: %s:%s %d<=3D%d<=3D%d?", section, tag, min, x,=
 max);
-      return min <=3D x && max >=3D x;
-    default:
-      warnx("conf_match_num: section %s tag %s: invalid number spec %s",
-		 section, tag, value);
-    }
-  return 0;
-}
-
-/* Return the string value denoted by TAG in section SECTION.  */
-char *
-conf_get_str (char *section, char *tag)
-{
-  struct conf_binding *cb;
-
-  for (cb =3D LIST_FIRST (&conf_bindings[conf_hash (section)]); cb;
-       cb =3D LIST_NEXT (cb, link))
-    if (strcasecmp (section, cb->section) =3D=3D 0
-	&& strcasecmp (tag, cb->tag) =3D=3D 0)
-      {
-	return cb->value;
-      }
-  return 0;
-}
-
-/*
- * Build a list of string values out of the comma separated value denoted =
by
- * TAG in SECTION.
- */
-struct conf_list *
-conf_get_list (char *section, char *tag)
-{
-  char *liststr =3D 0, *p, *field, *t;
-  struct conf_list *list =3D 0;
-  struct conf_list_node *node;
-
-  list =3D malloc (sizeof *list);
-  if (!list)
-    goto cleanup;
-  TAILQ_INIT (&list->fields);
-  list->cnt =3D 0;
-  liststr =3D conf_get_str (section, tag);
-  if (!liststr)
-    goto cleanup;
-  liststr =3D strdup (liststr);
-  if (!liststr)
-    goto cleanup;
-  p =3D liststr;
-  while ((field =3D strsep (&p, ",")) !=3D NULL)
-    {
-      /* Skip leading whitespace */
-      while (isspace (*field))
-	field++;
-      /* Skip trailing whitespace */
-      if (p)
-	for (t =3D p - 1; t > field && isspace (*t); t--)
-	  *t =3D '\0';
-      if (*field =3D=3D '\0')
-	{
-	  warnx("conf_get_list: empty field, ignoring...");
-	  continue;
-	}
-      list->cnt++;
-      node =3D calloc (1, sizeof *node);
-      if (!node)
-	goto cleanup;
-      node->field =3D strdup (field);
-      if (!node->field) {
-	free(node);
-	goto cleanup;
-      }
-      TAILQ_INSERT_TAIL (&list->fields, node, link);
-    }
-  free (liststr);
-  return list;
-
- cleanup:
-  if (list)
-    conf_free_list (list);
-  if (liststr)
-    free (liststr);
-  return 0;
-}
-
-struct conf_list *
-conf_get_tag_list (char *section)
-{
-  struct conf_list *list =3D 0;
-  struct conf_list_node *node;
-  struct conf_binding *cb;
-
-  list =3D malloc (sizeof *list);
-  if (!list)
-    goto cleanup;
-  TAILQ_INIT (&list->fields);
-  list->cnt =3D 0;
-  for (cb =3D LIST_FIRST (&conf_bindings[conf_hash (section)]); cb;
-       cb =3D LIST_NEXT (cb, link))
-    if (strcasecmp (section, cb->section) =3D=3D 0)
-      {
-	list->cnt++;
-	node =3D calloc (1, sizeof *node);
-	if (!node)
-	  goto cleanup;
-	node->field =3D strdup (cb->tag);
-	if (!node->field) {
-	  free(node);
-	  goto cleanup;
-	}
-	TAILQ_INSERT_TAIL (&list->fields, node, link);
-      }
-  return list;
-
- cleanup:
-  if (list)
-    conf_free_list (list);
-  return 0;
-}
-
-/* Decode a PEM encoded buffer.  */
-int
-conf_decode_base64 (u_int8_t *out, u_int32_t *len, u_char *buf)
-{
-  u_int32_t c =3D 0;
-  u_int8_t c1, c2, c3, c4;
-
-  while (*buf)
-    {
-      if (*buf > 127 || (c1 =3D asc2bin[*buf]) =3D=3D 255)
-	return 0;
-      buf++;
-
-      if (*buf > 127 || (c2 =3D asc2bin[*buf]) =3D=3D 255)
-	return 0;
-      buf++;
-
-      if (*buf =3D=3D '=3D')
-	{
-	  c3 =3D c4 =3D 0;
-	  c++;
-
-	  /* Check last four bit */
-	  if (c2 & 0xF)
-	    return 0;
-
-	  if (strcmp ((char *)buf, "=3D=3D") =3D=3D 0)
-	    buf++;
-	  else
-	    return 0;
-	}
-      else if (*buf > 127 || (c3 =3D asc2bin[*buf]) =3D=3D 255)
-	return 0;
-      else
-	{
-	  if (*++buf =3D=3D '=3D')
-	    {
-	      c4 =3D 0;
-	      c +=3D 2;
-
-	      /* Check last two bit */
-	      if (c3 & 3)
-		return 0;
-
-	      if (strcmp ((char *)buf, "=3D"))
-		return 0;
-
-	    }
-	  else if (*buf > 127 || (c4 =3D asc2bin[*buf]) =3D=3D 255)
-	      return 0;
-	  else
-	      c +=3D 3;
-	}
-
-      buf++;
-      *out++ =3D (c1 << 2) | (c2 >> 4);
-      *out++ =3D (c2 << 4) | (c3 >> 2);
-      *out++ =3D (c3 << 6) | c4;
-    }
-
-  *len =3D c;
-  return 1;
-
-}
-
-void
-conf_free_list (struct conf_list *list)
-{
-  struct conf_list_node *node =3D TAILQ_FIRST (&list->fields);
-
-  while (node)
-    {
-      TAILQ_REMOVE (&list->fields, node, link);
-      if (node->field)
-	free (node->field);
-      free (node);
-      node =3D TAILQ_FIRST (&list->fields);
-    }
-  free (list);
-}
-
-int
-conf_begin (void)
-{
-  static int seq =3D 0;
-
-  return ++seq;
-}
-
-static struct conf_trans *
-conf_trans_node (int transaction, enum conf_op op)
-{
-  struct conf_trans *node;
-
-  node =3D calloc (1, sizeof *node);
-  if (!node)
-    {
-      warnx("conf_trans_node: calloc (1, %lu) failed",
-	(unsigned long)sizeof *node);
-      return 0;
-    }
-  node->trans =3D transaction;
-  node->op =3D op;
-  TAILQ_INSERT_TAIL (&conf_trans_queue, node, link);
-  return node;
-}
-
-/* Queue a set operation.  */
-int
-conf_set (int transaction, char *section, char *tag, char *value, int over=
ride,
-	  int is_default)
-{
-  struct conf_trans *node;
-
-  node =3D conf_trans_node (transaction, CONF_SET);
-  if (!node)
-    return 1;
-  node->section =3D strdup (section);
-  if (!node->section)
-    {
-      warnx("conf_set: strdup (\"%s\") failed", section);
-      goto fail;
-    }
-  node->tag =3D strdup (tag);
-  if (!node->tag)
-    {
-      warnx("conf_set: strdup (\"%s\") failed", tag);
-      goto fail;
-    }
-  node->value =3D strdup (value);
-  if (!node->value)
-    {
-      warnx("conf_set: strdup (\"%s\") failed", value);
-      goto fail;
-    }
-  node->override =3D override;
-  node->is_default =3D is_default;
-  return 0;
-
- fail:
-  if (node->tag)
-    free (node->tag);
-  if (node->section)
-    free (node->section);
-  if (node)
-    free (node);
-  return 1;
-}
-
-/* Queue a remove operation.  */
-int
-conf_remove (int transaction, char *section, char *tag)
-{
-  struct conf_trans *node;
-
-  node =3D conf_trans_node (transaction, CONF_REMOVE);
-  if (!node)
-    goto fail;
-  node->section =3D strdup (section);
-  if (!node->section)
-    {
-      warnx("conf_remove: strdup (\"%s\") failed", section);
-      goto fail;
-    }
-  node->tag =3D strdup (tag);
-  if (!node->tag)
-    {
-      warnx("conf_remove: strdup (\"%s\") failed", tag);
-      goto fail;
-    }
-  return 0;
-
- fail:
-  if (node && node->section)
-    free (node->section);
-  if (node)
-    free (node);
-  return 1;
-}
-
-/* Queue a remove section operation.  */
-int
-conf_remove_section (int transaction, char *section)
-{
-  struct conf_trans *node;
-
-  node =3D conf_trans_node (transaction, CONF_REMOVE_SECTION);
-  if (!node)
-    goto fail;
-  node->section =3D strdup (section);
-  if (!node->section)
-    {
-      warnx("conf_remove_section: strdup (\"%s\") failed", section);
-      goto fail;
-    }
-  return 0;
-
- fail:
-  if (node)
-    free (node);
-  return 1;
-}
-
-/* Execute all queued operations for this transaction.  Cleanup.  */
-int
-conf_end (int transaction, int commit)
-{
-  struct conf_trans *node, *next;
-
-  for (node =3D TAILQ_FIRST (&conf_trans_queue); node; node =3D next)
-    {
-      next =3D TAILQ_NEXT (node, link);
-      if (node->trans =3D=3D transaction)
-	{
-	  if (commit)
-	    switch (node->op)
-	      {
-	      case CONF_SET:
-		conf_set_now (node->section, node->tag, node->value,
-			      node->override, node->is_default);
-		break;
-	      case CONF_REMOVE:
-		conf_remove_now (node->section, node->tag);
-		break;
-	      case CONF_REMOVE_SECTION:
-		conf_remove_section_now (node->section);
-		break;
-	      default:
-		warnx("conf_end: unknown operation: %d", node->op);
-	      }
-	  TAILQ_REMOVE (&conf_trans_queue, node, link);
-	  if (node->section)
-	    free (node->section);
-	  if (node->tag)
-	    free (node->tag);
-	  if (node->value)
-	    free (node->value);
-	  free (node);
-	}
-    }
-  return 0;
-}
-
-/*
- * Dump running configuration upon SIGUSR1.
- * Configuration is "stored in reverse order", so reverse it again.
- */
-struct dumper {
-  char *s, *v;
-  struct dumper *next;
-};
-
-static void
-conf_report_dump (struct dumper *node)
-{
-  /* Recursive, cleanup when we're done.  */
-
-  if (node->next)
-    conf_report_dump (node->next);
-
-  if (node->v)
-    warnx("%s=3D\t%s", node->s, node->v);
-  else if (node->s)
-    {
-      warnx("%s", node->s);
-      if (strlen (node->s) > 0)
-	free (node->s);
-    }
-
-  free (node);
-}
-
-void
-conf_report (void)
-{
-  struct conf_binding *cb, *last =3D 0;
-  unsigned int i, len;
-  char *current_section =3D (char *)0;
-  struct dumper *dumper, *dnode;
-
-  dumper =3D dnode =3D (struct dumper *)calloc (1, sizeof *dumper);
-  if (!dumper)
-    goto mem_fail;
-
-  warnx("conf_report: dumping running configuration");
-
-  for (i =3D 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
-    for (cb =3D LIST_FIRST (&conf_bindings[i]); cb;
-	 cb =3D LIST_NEXT (cb, link))
-      {
-	if (!cb->is_default)
-	  {
-	    /* Dump this entry.  */
-	    if (!current_section || strcmp (cb->section, current_section))
-	      {
-		if (current_section)
-		  {
-		    len =3D strlen (current_section) + 3;
-		    dnode->s =3D malloc (len);
-		    if (!dnode->s)
-		      goto mem_fail;
-
-		    snprintf (dnode->s, len, "[%s]", current_section);
-		    dnode->next
-		      =3D (struct dumper *)calloc (1, sizeof (struct dumper));
-		    dnode =3D dnode->next;
-		    if (!dnode)
-		      goto mem_fail;
-
-		    dnode->s =3D "";
-		    dnode->next
-		      =3D (struct dumper *)calloc (1, sizeof (struct dumper));
-		    dnode =3D dnode->next;
-		    if (!dnode)
-		      goto mem_fail;
-		  }
-		current_section =3D cb->section;
-	      }
-	    dnode->s =3D cb->tag;
-	    dnode->v =3D cb->value;
-	    dnode->next =3D (struct dumper *)calloc (1, sizeof (struct dumper));
-	    dnode =3D dnode->next;
-	    if (!dnode)
-	      goto mem_fail;
-	    last =3D cb;
-	  }
-      }
-
-  if (last)
-    {
-      len =3D strlen (last->section) + 3;
-      dnode->s =3D malloc (len);
-      if (!dnode->s)
-	goto mem_fail;
-      snprintf (dnode->s, len, "[%s]", last->section);
-    }
-
-  conf_report_dump (dumper);
-
-  return;
-
- mem_fail:
-  warnx("conf_report: malloc/calloc failed");
-  while ((dnode =3D dumper) !=3D 0)
-    {
-      dumper =3D dumper->next;
-      if (dnode->s)
-	free (dnode->s);
-      free (dnode);
-    }
-  return;
-}
diff --git a/utils/idmapd/cfg.h b/utils/idmapd/cfg.h
deleted file mode 100644
index c1ca940..0000000
--- a/utils/idmapd/cfg.h
+++ /dev/null
@@ -1,67 +0,0 @@
-/* $OpenBSD: conf.h,v 1.30 2004/06/25 20:25:34 hshoexer Exp $	 */
-/* $EOM: conf.h,v 1.13 2000/09/18 00:01:47 ho Exp $	 */
-
-/*
- * Copyright (c) 1998, 1999, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2003 H=E5kan Olsson.  All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTI=
ES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-/*
- * This code was written under funding by Ericsson Radio Systems.
- */
-
-#ifndef _CONF_H_
-#define _CONF_H_
-
-#include "queue.h"
-
-struct conf_list_node {
-	TAILQ_ENTRY(conf_list_node) link;
-	char	*field;
-};
-
-struct conf_list {
-	size_t	cnt;
-	TAILQ_HEAD(conf_list_fields_head, conf_list_node) fields;
-};
-
-extern char    *conf_path;
-
-extern int      conf_begin(void);
-extern int      conf_decode_base64(u_int8_t *, u_int32_t *, u_char *);
-extern int      conf_end(int, int);
-extern void     conf_free_list(struct conf_list *);
-extern struct sockaddr *conf_get_address(char *, char *);
-extern struct conf_list *conf_get_list(char *, char *);
-extern struct conf_list *conf_get_tag_list(char *);
-extern int      conf_get_num(char *, char *, int);
-extern char    *conf_get_str(char *, char *);
-extern void     conf_init(void);
-extern int      conf_match_num(char *, char *, int);
-extern void     conf_reinit(void);
-extern int      conf_remove(int, char *, char *);
-extern int      conf_remove_section(int, char *);
-extern int      conf_set(int, char *, char *, char *, int, int);
-extern void     conf_report(void);
-
-#endif				/* _CONF_H_ */
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 9cbe96c..65a6a2a 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -66,7 +66,7 @@
 #endif /* HAVE_CONFIG_H */
 =

 #include "xlog.h"
-#include "cfg.h"
+#include "conffile.h"
 #include "queue.h"
 #include "nfslib.h"
 =

@@ -156,7 +156,7 @@ static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
 =

-/* Used by cfg.c */
+/* Used by conffile.c in libnfs.a */
 char *conf_path;
 =

 static int
