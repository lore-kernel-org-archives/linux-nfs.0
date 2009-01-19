From: Greg Banks <gnb@sgi.com>
Subject: [patch 4/5] Add the dprintk module to allow dprintks to be activated/deactivated singly
Date: Mon, 19 Jan 2009 17:40:22 +1100
Message-ID: <20090119064912.379043000@sgi.com>
References: <20090119064018.442220000@sgi.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>
To: Linux NFS ML <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:58552 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753359AbZASGtZ (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 01:49:25 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a module which provides a /proc/dprintk file.  Reading the file
lists all the dprintks.  You can write simple queries to the file to
describe a set of dprintks and what flags to enable or disable.  There
are three flags, which will make the dprintk() print the message,
or dump the kernel stack, or take a crash dump.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 Documentation/dprintk-howto.txt |  267 +++++++++
 init/Kconfig                    |   15 
 kernel/Makefile                 |    1 
 kernel/dprintk.c                |  848 +++++++++++++++++++++++++++++
 4 files changed, 1131 insertions(+)

Index: bfields/Documentation/dprintk-howto.txt
===================================================================
--- /dev/null
+++ bfields/Documentation/dprintk-howto.txt
@@ -0,0 +1,267 @@
+
+Introduction
+============
+
+This document describes how to use the SGI dprintk module.
+
+Dprintk is a module designed to allow you to control the behaviour of
+dprintk() debugging print statements located in the source of modules
+which have been compiled against the dprintk module.
+
+The NFS client, NFS server, NLM code, and sunrpc code all already
+contain many such dprintk()s (nearly six hundred at last count)
+in strategic locations.  Traditionally those dprintk()s have been
+controlled using the four bitmasks which can be written to thus:
+
+echo 65535 > /proc/sys/sunrpc/nfs_debug
+echo 65535 > /proc/sys/sunrpc/nfsd_debug
+echo 65535 > /proc/sys/sunrpc/nlm_debug
+echo 65535 > /proc/sys/sunrpc/rpc_debug
+
+However this technique is something of a blunt instrument.  Typically
+each bit will control several, possibly dozens, of dprintks(),
+so enabling just the debugging information you need is dificult.
+Enter the dprintk module, which allows turning on or off any individual
+dprintk() or group of dprintk()s.
+
+The dprintk module has even more useful features:
+
+ * Simple query language allows turning on and off dprintks by matching
+   any combination of:
+
+   - source filename
+   - function name
+   - line number (including ranges of line numbers)
+   - module name
+   - format string
+
+ * Provides a /proc/dprintk which can be read to display the complete
+   list of all dprintk()s known, to help guide you
+
+ * The module is optional.  The NFS dprintk()s still work with the
+   /proc/sys/sunrpc/ bitmasks.  The dprintk module can be loaded or
+   unloaded at any time.
+
+ * In addition to enabling the print, two other behaviours can be enabled:
+
+  - printing a kernel stack trace
+  - crashing the kernel, so that a dump can be taken
+
+Controlling dprintk() Behaviour
+===============================
+
+You can control the behaviour of dprintk()s by writing a command
+to /proc/dprintk, e.g. using the echo command:
+
+nullarbor:~ # echo 'file svcsock.c line 1603 +p' > /proc/dprintk
+
+If you make a mistake with the syntax, the write will fail thus:
+
+nullarbor:~ # echo 'file svcsock.c wtf 1 +p' > /proc/dprintk
+-bash: echo: write error: Invalid argument
+
+Viewing dprintk() Behaviour
+===========================
+
+You can view the currently configured behaviour of all the dprintk()s
+in loaded modules by reading /proc/dprintk.  For example:
+
+nullarbor:~ # cat /proc/dprintk
+# filename:lineno [module]function flags format
+/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:323 [svcxprt_rdma]svc_rdma_cleanup - "SVCRDMA\040Module\040Removed,\040deregister\040RPC\040RDMA\040transport\012"
+/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:341 [svcxprt_rdma]svc_rdma_init - "\011max_inline\040\040\040\040\040\040\040:\040%d\012"
+/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:340 [svcxprt_rdma]svc_rdma_init - "\011sq_depth\040\040\040\040\040\040\040\040\040:\040%d\012"
+/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:338 [svcxprt_rdma]svc_rdma_init - "\011max_requests\040\040\040\040\040:\040%d\012"
+...
+
+
+You can also apply standard Unix text manipulation filters to this
+data, e.g.
+
+nullarbor:~ # grep -i rdma /proc/dprintk  | wc -l
+62
+
+nullarbor:~ # grep -i tcp /proc/dprintk | wc -l
+42
+
+Note in particular that the third column shows the enabled behaviour
+flags for each dprintk() callsite (see below for definitions of the
+flags).  The default value, no extra behaviour enabled, is "-".  So
+you can view all the dprintk() callsites with any non-default flags:
+
+nullarbor:~ # awk '$3 != "-"' /proc/dprintk
+# filename:lineno [module]function flags format
+/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svcsock.c:1603 [sunrpc]svc_send p "svc_process:\040st_sendto\040returned\040%d\012"
+
+
+Command Language Reference
+==========================
+
+At the lexical level, a command comprises a sequence of words separated
+by whitespace characters.  Note that newlines are treated as word
+separators and do *not* end a command or allow multiple commands to
+be done together.  So these are all equivalent:
+
+nullarbor:~ # echo -c 'file svcsock.c line 1603 +p' > /proc/dprintk
+nullarbor:~ # echo -c '  file   svcsock.c     line  1603 +p  ' > /proc/dprintk
+nullarbor:~ # echo -c 'file svcsock.c\nline 1603 +p' > /proc/dprintk
+nullarbor:~ # echo -n 'file svcsock.c line 1603 +p' > /proc/dprintk
+
+Commands are bounded by a write() system call.  If you want to do
+multiple commands you need to do a separate "echo" for each, like:
+
+nullarbor:~ # echo 'file svcsock.c line 1603 +p' > /proc/dprintk ;\
+> echo 'file svcsock.c line 1563 +p' > /proc/dprintk
+
+or even like:
+
+nullarbor:~ # (
+> echo 'file svcsock.c line 1603 +p' ;\
+> echo 'file svcsock.c line 1563 +p' ;\
+> ) > /proc/dprintk
+
+At the syntactical level, a command comprises a sequence of match
+specifications, followed by a flags change specification.
+
+command ::= match-spec* flags-spec
+
+The match-spec's are used to choose a subset of the known dprintk()
+callsites to which to apply the flags-spec.  Think of them as a query
+with implicit ANDs between each pair.  Note that an empty list of
+match-specs is possible, but is not very useful because it will not
+match any dprintk() callsites.
+
+A match specification comprises a keyword, which controls the attribute
+of the callsite to be compared, and a value to compare against.  Possible
+keywords are:
+
+match-spec ::= 'func' string |
+	       'file' string |
+	       'module' string |
+	       'format' string |
+	       'line' line-range
+
+line-range ::= lineno |
+	       '-'lineno |
+	       lineno'-' |
+	       lineno'-'lineno
+// Note: line-range cannot contain space, e.g.
+// "1-30" is valid range but "1 - 30" is not.
+
+lineno ::= unsigned-int
+
+The meanings of each keyword are:
+
+func
+    The given string is compared against the function name
+    of each callsite.  Example:
+
+    func svc_tcp_accept
+
+file
+    The given string is compared against either the full
+    pathname or the basename of the source file of each
+    callsite.  Examples:
+
+    file svcsock.c
+    file /usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svcsock.c
+
+module
+    The given string is compared against the module name
+    of each callsite.  The module name is the string as
+    seen in "lsmod", i.e. without the directory or the .ko
+    suffix and with '-' changed to '_'.  Examples:
+
+    module sunrpc
+    module nfsd
+
+format
+    The given string is searched for in the dprintk() format
+    string.  Note that the string does not need to match the
+    entire format, only some part.  Whitespace and other
+    special characters can be escaped using C octal character
+    escape \ooo notation, e.g. the space character is \040.
+    Examples:
+
+    format svcrdma:	    // many of the NFS/RDMA server dprintks
+    format readahead	    // some dprintks in the readahead cache
+    format nfsd:\040SETATTR // how to match a format with whitespace
+
+line
+    The given line number or range of line numbers is compared
+    against the line number of each dprintk() callsite.  A single
+    line number matches the callsite line number exactly.  A
+    range of line numbers matches any callsite between the first
+    and last line number inclusive.  An empty first number means
+    the first line in the file, an empty line number means the
+    last number in the file.  Examples:
+
+    line 1603	    // exactly line 1603
+    line 1600-1605  // the six lines from line 1600 to line 1605
+    line -1605	    // the 1605 lines from line 1 to line 1605
+    line 1600-	    // all lines from line 1600 to the end of the file
+
+The flags specification comprises a change operation followed
+by one or more flag characters.  The change operation is one
+of the characters:
+
+-
+    remove the given flags
+
++
+    add the given flags
+
+=
+    set the flags to the given flags
+
+The flags are:
+
+p
+    Causes a printk() message to be emitted to dmesg,
+    i.e. the obvious semantic of a dprintk().
+
+s
+    Causes a kernel stack trace to be emitted to dmesg.
+    The printk() is emitted first, even if the 'p' flag
+    is not specified.
+
+c
+    Causes the kernel to panic using the kernel BUG()
+    macro.  This will cause the machine to drop into KDB
+    or take a kernel crash dump, according to how the
+    machine has been configured.  The printk() is emitted
+    first, even if the 'p' flag is not specified.
+
+Note the regexp ^[-+=][scp]+$ matches a flags specification.
+Note also that there is no convenient syntax to remove all
+the flags at once, you need to use "-psc".
+
+Examples
+========
+
+// enable the message at line 1603 of file svcsock.c
+nullarbor:~ # echo -n 'file svcsock.c line 1603 +p' > /proc/dprintk
+
+// enable all the messages in file svcsock.c
+nullarbor:~ # echo -n 'file svcsock.c +p' > /proc/dprintk
+
+// enable all the messages in file svcsock.c
+nullarbor:~ # echo -n 'file svcsock.c +p' > /proc/dprintk
+
+// enable all the messages in the NFS server module
+nullarbor:~ # echo -n 'module nfsd +p' > /proc/dprintk
+
+// enable all 12 messages in the function svc_process()
+nullarbor:~ # echo -n 'func svc_process +p' > /proc/dprintk
+
+// disable all 12 messages in the function svc_process()
+nullarbor:~ # echo -n 'func svc_process -p' > /proc/dprintk
+
+// print a stack trace on every upcall to rpc.mountd or rpc.idmapd
+nullarbor:~ # echo -n 'format Want\040update,\040refage +s' > /proc/dprintk
+
+// cause a kernel crash dump when an RPC call to an
+// unknown RPC program number is received
+nullarbor:~ # echo -n 'format unknown\040program +c' > /proc/dprintk
+
+
Index: bfields/kernel/dprintk.c
===================================================================
--- /dev/null
+++ bfields/kernel/dprintk.c
@@ -0,0 +1,848 @@
+/*
+ * dprintk - a generic /proc interface for enabling individual debug printks.
+ *
+ * By Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
+ * Copyright (c) 2008 Silicon Graphics Inc.  All Rights Reserved.
+ * $Id: dprintk.c,v 1.1 2008/09/04 04:46:06 gnb Exp $
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/kallsyms.h>
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/mutex.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/list.h>
+#include <linux/sysctl.h>
+#include <linux/ctype.h>
+#include <asm/uaccess.h>
+#include <linux/dprintk.h>
+
+struct dprintk_table
+{
+	struct list_head link;
+	struct module *module;
+	unsigned int num_dprintks;
+	struct _dprintk *dprintks;
+};
+
+struct dprintk_query
+{
+	const char *filename;
+	const char *module;
+	const char *function;
+	const char *format;
+	unsigned int first_lineno, last_lineno;
+};
+
+struct dprintk_iter
+{
+	struct dprintk_table *table;
+	unsigned int idx;
+};
+
+static DEFINE_MUTEX(dprintk_lock);
+static LIST_HEAD(dprintk_tables);
+static int verbose = 0;
+
+module_param(verbose, int, 0644);
+MODULE_PARM_DESC(verbose, "Set this parameter to non-zero to debug "
+			  "the dprintk module itself.");
+
+/* Return the last part of a pathname */
+static inline const char *basename(const char *path)
+{
+	const char *tail = strrchr(path, '/');
+	return (tail ? tail+1 : path);
+}
+
+/* format a string into buf[] which describes the _dprintk's flags */
+static char *dprintk_describe_flags(struct _dprintk *dp, char *buf,
+				    size_t maxlen)
+{
+	char *p = buf;
+
+	BUG_ON(maxlen < 4);
+	if (dp->flags & _DPRINTK_FLAGS_CRASH)
+		*p++ = 'c';
+	if (dp->flags & _DPRINTK_FLAGS_STACK)
+		*p++ = 's';
+	if (dp->flags & _DPRINTK_FLAGS_PRINT)
+		*p++ = 'p';
+	if (p == buf)
+		*p++ = '-';
+	*p = '\0';
+
+	return buf;
+}
+
+/*
+ * Search the tables for _dprintk's which match the given
+ * `query' and apply the `flags' and `mask' to them.  Tells
+ * the user which dprintk's were changed, or whether none
+ * were matched.
+ */
+static void dprintk_change(const struct dprintk_query *query,
+			   unsigned int flags, unsigned int mask)
+{
+	int i;
+	struct dprintk_table *dt;
+	unsigned int newflags;
+	unsigned int nfound = 0;
+	char flagbuf[8];
+
+	/* search for matching dprintks */
+	mutex_lock(&dprintk_lock);
+	list_for_each_entry(dt, &dprintk_tables, link) {
+
+		/* match against the module name */
+		if (query->module != NULL &&
+		    strcmp(query->module, dt->module->name))
+			continue;
+
+		for (i = 0 ; i < dt->num_dprintks ; i++) {
+			struct _dprintk *dp = &dt->dprintks[i];
+
+			/* match against the source filename */
+			if (query->filename != NULL &&
+			    strcmp(query->filename, dp->filename) &&
+			    strcmp(query->filename, basename(dp->filename)))
+				continue;
+
+			/* match against the function */
+			if (query->function != NULL &&
+			    strcmp(query->function, dp->function))
+				continue;
+
+			/* match against the format */
+			if (query->format != NULL &&
+			    strstr(dp->format, query->format) == NULL)
+				continue;
+
+			/* match against the line number range */
+			if (query->first_lineno &&
+			    dp->lineno < query->first_lineno)
+				continue;
+			if (query->last_lineno &&
+			    dp->lineno > query->last_lineno)
+				continue;
+
+			nfound++;
+
+			newflags = (dp->flags & mask) | flags;
+			if (newflags == dp->flags)
+				continue;
+			dp->flags = newflags;
+
+			printk(KERN_INFO "dprintk: changed %s:%d [%s]%s %s\n",
+				dp->filename, dp->lineno,
+				dt->module->name, dp->function,
+				dprintk_describe_flags(dp, flagbuf, sizeof(flagbuf)));
+		}
+	}
+	mutex_unlock(&dprintk_lock);
+
+	if (!nfound)
+		printk(KERN_INFO "dprintk: no matches for query\n");
+}
+
+/*
+ * Wrapper around strsep() to collapse the multiple empty tokens
+ * that it returns when fed sequences of separator characters.
+ * Now, if we had strtok_r()...
+ */
+static inline char *nearly_strtok_r(char **p, const char *sep)
+{
+	char *r;
+
+	while ((r = strsep(p, sep)) != NULL && *r == '\0')
+		;
+	return r;
+}
+
+/*
+ * Split the buffer `buf' into space-separated words.
+ * Return the number of such words or <0 on error.
+ */
+static int dprintk_tokenize(char *buf, char *words[], int maxwords)
+{
+	int nwords = 0;
+
+	while (nwords < maxwords &&
+	       (words[nwords] = nearly_strtok_r(&buf, " \t\r\n")) != NULL)
+		nwords++;
+	if (buf)
+		return -EINVAL;	/* ran out of words[] before bytes */
+
+	if (verbose) {
+		int i;
+		printk(KERN_INFO "%s: split into words:", __FUNCTION__);
+		for (i = 0 ; i < nwords ; i++)
+			printk(" \"%s\"", words[i]);
+		printk("\n");
+	}
+
+	return nwords;
+}
+
+/*
+ * Parse a single line number.  Note that the empty string ""
+ * is treated as a special case and converted to zero, which
+ * is later treated as a "don't care" value.
+ */
+static inline int parse_lineno(const char *str, unsigned int *val)
+{
+	char *end = NULL;
+	BUG_ON(str == NULL);
+	if (*str == '\0') {
+		*val = 0;
+		return 0;
+	}
+	*val = simple_strtoul(str, &end, 10);
+	return (end == NULL || end == str || *end != '\0' ? -EINVAL : 0);
+}
+
+/*
+ * Undo octal escaping in a string, inplace.  This is useful to
+ * allow the user to express a query which matches a format
+ * containing embedded spaces.
+ */
+#define isodigit(c)		((c) >= '0' && (c) <= '7')
+static char *unescape(char *str)
+{
+	char *in = str;
+	char *out = str;
+
+	while (*in) {
+		if (*in == '\\') {
+			if (in[1] == '\\') {
+				*out++ = '\\';
+				in += 2;
+				continue;
+			} else if (in[1] == 't') {
+				*out++ = '\t';
+				in += 2;
+				continue;
+			} else if (in[1] == 'n') {
+				*out++ = '\n';
+				in += 2;
+				continue;
+			} else if (isodigit(in[1]) &&
+			         isodigit(in[2]) &&
+			         isodigit(in[3])) {
+				*out++ = ((in[1] - '0')<<6) |
+				          ((in[2] - '0')<<3) |
+				          (in[3] - '0');
+				in += 4;
+				continue;
+			}
+		}
+		*out++ = *in++;
+	}
+	*out = '\0';
+
+	return str;
+}
+
+/*
+ * Parse words[] as a dprintk query specification, which is a series
+ * of (keyword, value) pairs chosen from these possibilities:
+ *
+ * func <function-name>
+ * file <full-pathname>
+ * file <base-filename>
+ * module <module-name>
+ * format <escaped-string-to-find-in-format>
+ * line <lineno>
+ * line <first-lineno>-<last-lineno> // where either may be empty
+ */
+static int dprintk_parse_query(char *words[], int nwords,
+			       struct dprintk_query *query)
+{
+	unsigned int i;
+
+	/* check we have an even number of words */
+	if (nwords % 2 != 0)
+		return -EINVAL;
+	memset(query, 0, sizeof(*query));
+
+	for (i = 0 ; i < nwords ; i += 2) {
+		if (!strcmp(words[i], "func"))
+			query->function = words[i+1];
+		else if (!strcmp(words[i], "file"))
+			query->filename = words[i+1];
+		else if (!strcmp(words[i], "module"))
+			query->module = words[i+1];
+		else if (!strcmp(words[i], "format"))
+			query->format = unescape(words[i+1]);
+		else if (!strcmp(words[i], "line")) {
+			char *first = words[i+1];
+			char *last = strchr(first, '-');
+			if (last)
+				*last++ = '\0';
+			if (parse_lineno(first, &query->first_lineno) < 0)
+				return -EINVAL;
+			if (last != NULL) {
+				/* range <first>-<last> */
+				if (parse_lineno(last, &query->last_lineno) < 0)
+					return -EINVAL;
+			} else {
+				query->last_lineno = query->first_lineno;
+			}
+		} else {
+			if (verbose)
+				printk(KERN_ERR "%s: unknown keyword \"%s\"\n",
+					__FUNCTION__, words[i]);
+			return -EINVAL;
+		}
+	}
+
+	if (verbose)
+		printk(KERN_INFO "%s: q->function=\"%s\" q->filename=\"%s\" "
+		       "q->module=\"%s\" q->format=\"%s\" q->lineno=%u-%u\n",
+			__FUNCTION__, query->function, query->filename,
+			query->module, query->format, query->first_lineno,
+			query->last_lineno);
+
+	return 0;
+}
+
+/*
+ * Parse `str' as a flags specification, format [-+=][scp]+.
+ * Sets up *maskp and *flagsp to be used when changing the
+ * flags fields of matched _dprintk's.  Returns 0 on success
+ * or <0 on error.
+ */
+static int dprintk_parse_flags(const char *str, unsigned int *flagsp,
+			       unsigned int *maskp)
+{
+	unsigned flags = 0;
+	int op = '=';
+
+	switch (*str) {
+	case '+':
+	case '-':
+	case '=':
+		op = *str++;
+		break;
+	default:
+		return -EINVAL;
+	}
+	if (verbose)
+		printk(KERN_INFO "%s: op='%c'\n", __FUNCTION__, op);
+
+	for ( ; *str ; ++str) {
+		switch (*str) {
+		case 'p':
+			flags |= _DPRINTK_FLAGS_PRINT;
+			break;
+		case 's':
+			flags |= _DPRINTK_FLAGS_STACK;
+			break;
+		case 'c':
+			flags |= _DPRINTK_FLAGS_CRASH;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	if (flags == 0)
+		return -EINVAL;
+	if (verbose)
+		printk(KERN_INFO "%s: flags=0x%x\n", __FUNCTION__, flags);
+
+	/* calculate final *flagsp, *maskp according to mask and op */
+	switch (op) {
+	case '=':
+		*maskp = 0;
+		*flagsp = flags;
+		break;
+	case '+':
+		*maskp = ~0U;
+		*flagsp = flags;
+		break;
+	case '-':
+		*maskp = ~flags;
+		*flagsp = 0;
+		break;
+	}
+	if (verbose)
+		printk(KERN_INFO "%s: *flagsp=0x%x *maskp=0x%x\n",
+			__FUNCTION__, *flagsp, *maskp);
+	return 0;
+}
+
+/*
+ * File_ops->write method for /proc/dprintk.  Gathers the
+ * command text from userspace, parses and executes it.
+ */
+static ssize_t dprintk_proc_write(struct file *file, const char __user *ubuf,
+				  size_t len, loff_t *offp)
+{
+	unsigned int flags = 0, mask = 0;
+	struct dprintk_query query;
+#define MAXWORDS 9
+	int nwords;
+	char *words[MAXWORDS];
+	char tmpbuf[256];
+
+	if (len == 0)
+		return 0;
+	/* we don't check *offp -- multiple writes() are allowed */
+	if (len > sizeof(tmpbuf)-1)
+		return -E2BIG;
+	if (copy_from_user(tmpbuf, ubuf, len))
+		return -EFAULT;
+	tmpbuf[len] = '\0';
+	if (verbose)
+		printk(KERN_INFO "%s: read %d bytes from userspace\n",
+			__FUNCTION__, (int)len);
+
+	nwords = dprintk_tokenize(tmpbuf, words, MAXWORDS);
+	if (nwords < 0)
+		return -EINVAL;
+	if (dprintk_parse_query(words, nwords-1, &query))
+		return -EINVAL;
+	if (dprintk_parse_flags(words[nwords-1], &flags, &mask))
+		return -EINVAL;
+
+	/* actually go and implement the change */
+	dprintk_change(&query, flags, mask);
+
+	*offp += len;
+	return len;
+}
+
+/*
+ * Set the iterator to point to the first _dprintk object
+ * and return a pointer to that first object.  Returns
+ * NULL if there are no _dprintks at all.
+ */
+static struct _dprintk *dprintk_iter_first(struct dprintk_iter *iter)
+{
+	if (list_empty(&dprintk_tables)) {
+		iter->table = NULL;
+		iter->idx = 0;
+		return NULL;
+	}
+	iter->table = list_entry(dprintk_tables.next,
+				 struct dprintk_table, link);
+	iter->idx = 0;
+	return &iter->table->dprintks[iter->idx];
+}
+
+/*
+ * Advance the iterator to point to the next _dprintk
+ * object from the one the iterator currently points at,
+ * and returns a pointer to the new _dprintk.  Returns
+ * NULL if the iterator has seen all the _dprintks.
+ */
+static struct _dprintk *dprintk_iter_next(struct dprintk_iter *iter)
+{
+	if (iter->table == NULL)
+		return NULL;
+	if (++iter->idx == iter->table->num_dprintks) {
+		/* iterate to next table */
+		iter->idx = 0;
+		if (list_is_last(&iter->table->link, &dprintk_tables)) {
+			iter->table = NULL;
+			return NULL;
+		}
+		iter->table = list_entry(iter->table->link.next,
+					 struct dprintk_table, link);
+	}
+	return &iter->table->dprintks[iter->idx];
+}
+
+/*
+ * Seq_ops start method.  Called at the start of every
+ * read() call from userspace.  Takes the dprintk_lock and
+ * seeks the seq_file's iterator to the given position.
+ */
+static void *dprintk_proc_start(struct seq_file *m, loff_t *pos)
+{
+	struct dprintk_iter *iter = m->private;
+	struct _dprintk *dp;
+	int n = *pos;
+
+	if (verbose)
+		printk(KERN_INFO "%s: called m=%p *pos=%lld\n",
+			__FUNCTION__, m, (unsigned long long)*pos);
+
+	mutex_lock(&dprintk_lock);
+
+	if (!n)
+		return SEQ_START_TOKEN;
+	if (n < 0)
+		return NULL;
+	dp = dprintk_iter_first(iter);
+	while (dp != NULL && --n > 0)
+		dp = dprintk_iter_next(iter);
+	return dp;
+}
+
+/*
+ * Seq_ops next method.  Called several times within a read()
+ * call from userspace, with dprintk_lock held.  Walks to the
+ * next _dprintk object with a special case for the header line.
+ */
+static void *dprintk_proc_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct dprintk_iter *iter = m->private;
+	struct _dprintk *dp;
+
+	if (verbose)
+		printk(KERN_INFO "%s: called m=%p p=%p *pos=%lld\n",
+			__FUNCTION__, m, p, (unsigned long long)*pos);
+
+	if (p == SEQ_START_TOKEN)
+		dp = dprintk_iter_first(iter);
+	else
+		dp = dprintk_iter_next(iter);
+	++*pos;
+	return dp;
+}
+
+/*
+ * Seq_ops show method.  Called several times within a read()
+ * call from userspace, with dprintk_lock held.  Formats the
+ * current _dprintk as a single human-readable line, with a
+ * special case for the header line.
+ */
+static int dprintk_proc_show(struct seq_file *m, void *p)
+{
+	struct dprintk_iter *iter = m->private;
+	struct _dprintk *dp = p;
+	char flagsbuf[8];
+
+	if (verbose)
+		printk(KERN_INFO "%s: called m=%p p=%p\n",
+			__FUNCTION__, m, p);
+
+	if (p == SEQ_START_TOKEN) {
+		seq_puts(m, "# filename:lineno [module]function flags format\n");
+		return 0;
+	}
+
+	seq_printf(m, "%s:%u [%s]%s %s \"",
+		   dp->filename, dp->lineno,
+		   iter->table->module->name, dp->function,
+		   dprintk_describe_flags(dp, flagsbuf, sizeof(flagsbuf)));
+	seq_escape(m, dp->format, " \t\r\n\"");
+	seq_puts(m, "\"\n");
+
+	return 0;
+}
+
+/*
+ * Seq_ops stop method.  Called at the end of each read()
+ * call from userspace.  Drops dprintk_lock.
+ */
+static void dprintk_proc_stop(struct seq_file *m, void *p)
+{
+	if (verbose)
+		printk(KERN_INFO "%s: called m=%p p=%p\n",
+			__FUNCTION__, m, p);
+	mutex_unlock(&dprintk_lock);
+}
+
+static struct seq_operations dprintk_proc_seqops = {
+	.start = dprintk_proc_start,
+	.next = dprintk_proc_next,
+	.show = dprintk_proc_show,
+	.stop = dprintk_proc_stop
+};
+
+/*
+ * File_ops->open method for /proc/dprintk.  Does the seq_file
+ * setup dance, and also creates an iterator to walk the _dprintks.
+ * Note that we create a seq_file always, even for O_WRONLY files
+ * where it's not needed, as doing so simplifies the ->release method.
+ */
+static int dprintk_proc_open(struct inode *inode, struct file *file)
+{
+	struct dprintk_iter *iter;
+	int err;
+
+	if (verbose)
+		printk(KERN_INFO "%s: called\n", __FUNCTION__);
+
+	iter = kzalloc(sizeof(*iter), GFP_KERNEL);
+	if (iter == NULL)
+		return -ENOMEM;
+
+	err = seq_open(file, &dprintk_proc_seqops);
+	if (err) {
+		kfree(iter);
+		return err;
+	}
+	((struct seq_file *) file->private_data)->private = iter;
+	return 0;
+}
+
+static struct file_operations dprintk_proc_fops = {
+	.owner = THIS_MODULE,
+	.open = dprintk_proc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release_private,
+ 	.write = dprintk_proc_write
+};
+
+/*
+ * Allocate a new dprintk_table for the given module
+ * and add it to the global list.
+ */
+static int dprintk_add_table(struct _dprintk *tab, unsigned int n,
+			     struct module *mod)
+{
+	struct dprintk_table *dt;
+
+	dt = kzalloc(sizeof(*dt), GFP_KERNEL);
+	if (dt == NULL)
+		return -ENOMEM;
+	dt->module = mod;
+	dt->num_dprintks = n;
+	dt->dprintks = tab;
+
+	mutex_lock(&dprintk_lock);
+	list_add_tail(&dt->link, &dprintk_tables);
+	mutex_unlock(&dprintk_lock);
+
+	if (verbose)
+		printk(KERN_INFO "%u debug prints in module %s\n",
+				 n, mod->name);
+	return n;
+}
+
+static void dprintk_table_free(struct dprintk_table *dt)
+{
+	list_del_init(&dt->link);
+	kfree(dt);
+}
+
+/*
+ * Called in response to a module being unloaded.  Removes
+ * any dprintk_table's which point at the module.
+ */
+static int dprintk_remove_module(struct module *mod)
+{
+	struct dprintk_table *dt, *nextdt;
+	int ret = -ENOENT;
+
+	if (verbose)
+		printk(KERN_INFO "%s: removing module \"%s\"\n",
+				__FUNCTION__, mod->name);
+
+	mutex_lock(&dprintk_lock);
+	list_for_each_entry_safe(dt, nextdt, &dprintk_tables, link) {
+		if (dt->module == mod) {
+			dprintk_table_free(dt);
+			ret = 0;
+		}
+	}
+	mutex_unlock(&dprintk_lock);
+	return ret;
+}
+
+/*
+ * Called in response to the dprintk module itself being
+ * unloaded.  Removes all dprintk_table's.
+ */
+static void dprintk_remove_all_tables(void)
+{
+	mutex_lock(&dprintk_lock);
+	while (!list_empty(&dprintk_tables)) {
+		struct dprintk_table *dt = list_entry(dprintk_tables.next,
+						      struct dprintk_table,
+						      link);
+		dprintk_table_free(dt);
+	}
+	mutex_unlock(&dprintk_lock);
+}
+
+static inline const char *section_name(const struct attribute *attr)
+{
+	return attr->name;
+}
+
+static inline void *section_address(const struct attribute *attr)
+{
+	return (void *)container_of(attr, struct module_sect_attr,
+				    mattr.attr)->address;
+}
+
+static int dprintk_add_module(struct module *mod)
+{
+	const char *why = "";
+#ifdef CONFIG_KALLSYMS
+	unsigned int n;
+	struct attribute **gattr;
+	void *dprintk_start = NULL;
+	void *dprintk_end = NULL;
+	struct _dprintk *dp;
+
+	if (verbose)
+		printk(KERN_INFO "%s: adding module \"%s\"\n",
+			__FUNCTION__, mod->name);
+
+	if (mod->sect_attrs == NULL) {
+		why = "no section attributes";
+		goto nosyms;
+	}
+
+	/*
+	 * First pass: find the .dprink section.
+	 */
+	for (gattr = mod->sect_attrs->grp.attrs ; *gattr != NULL ; gattr++) {
+		if (!strcmp(section_name(*gattr), ".dprintk")) {
+			dprintk_start = section_address(*gattr);
+			break;
+		}
+	}
+	if (dprintk_start == NULL) {
+		why = "no .dprintk section";
+		goto nosyms;
+	}
+
+	/*
+	 * Second pass: find the next loaded section.
+	 *
+	 * We don't assume anything about the ordering of mod->sect_attrs,
+	 * which is probably silly.
+	 *
+	 * Note that we rely subtly on the .dprintk section not being the last
+	 * loaded section in the .ko, but this seems not to be a problem as
+	 * the module link process adds new sections.
+	 */
+	for (gattr = mod->sect_attrs->grp.attrs ; *gattr != NULL ; gattr++) {
+		void *addr = section_address(*gattr);
+		if (!strcmp(section_name(*gattr), ".dprintk"))
+			continue;
+		if (addr < dprintk_start)
+			continue;
+		if (!dprintk_end || addr < dprintk_end)
+			dprintk_end = addr;
+	}
+	if (dprintk_end == NULL) {
+		why = "no section follows .dprintk section";
+		goto nosyms;
+	}
+
+	/* scan the table looking a sequence of valid magic numbers */
+	for (dp = (struct _dprintk *)dprintk_start ;
+	     dp < (struct _dprintk *)dprintk_end ;
+	     dp++) {
+		if (dp->magic != _DPRINTK_MAGIC)
+			break;
+	}
+	/* dp now points to first byte of padding beyond
+	 * the end of the actual .dprintk section */
+	if (dp == (struct _dprintk *)dprintk_start) {
+		why = "no entries in .dprintk section";
+		goto nosyms;
+	}
+
+	/* Mention any leftover padding.  Not that it matters a lot */
+	if (verbose && dp < (struct _dprintk *)dprintk_end)
+		printk(KERN_INFO "%s: ignoring %u bytes of "
+		       "padding at end of .dprintk section\n",
+		       __FUNCTION__, (unsigned)((u8 *)dprintk_end - (u8 *)dp));
+
+	n = dp - (struct _dprintk *)dprintk_start;
+	return dprintk_add_table((struct _dprintk *)dprintk_start, n, mod);
+
+nosyms:
+#else
+	why = "CONFIG_KALLSYMS not defined";
+#endif
+	if (verbose)
+		printk(KERN_ERR "%s: %s in module \"%s\" so "
+				"cannot find dprintks.  Sorry.\n",
+			__FUNCTION__, why, mod->name);
+	return -ENOENT;
+}
+
+static void dprintk_add_module_hook(struct module *mod, void *closure)
+{
+	dprintk_add_module(mod);
+}
+
+/*
+ * Called from the base kernel module code when a module
+ * is loaded (in ToT, also when it's unloaded).
+ */
+static int dprintk_module_callback(struct notifier_block *self,
+				   unsigned long event, void *ptr)
+{
+	struct module *mod = ptr;
+
+	if (verbose)
+		printk(KERN_INFO "%s: %lu %s\n",
+		       __FUNCTION__, event, (mod ? mod->name : "null"));
+
+	switch (event) {
+	case MODULE_STATE_COMING:
+		dprintk_add_module(mod);
+		break;
+	case MODULE_STATE_GOING:
+		dprintk_remove_module(mod);
+		break;
+	default:
+		printk(KERN_ERR "%s: unexpected event %lu for module %s\n",
+		       __FUNCTION__, event, (mod == NULL ? "null" : mod->name));
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block dprintk_notifier = {
+	.notifier_call = dprintk_module_callback
+};
+
+/*
+ * Initialise the dprintk module.
+ */
+static int __init dprintk_init(void)
+{
+	struct proc_dir_entry *pde;
+
+	if (verbose)
+		printk(KERN_INFO "%s called\n", __FUNCTION__);
+
+	pde = proc_create("dprintk", 0644, NULL, &dprintk_proc_fops);
+	if (pde == NULL) {
+		printk(KERN_ERR "cannot create /proc/dprintk, "
+				"no dprintks will be available\n");
+		return -EINVAL;
+	}
+
+	/* Sadly, registering a notifier doesn't result
+	 * in callbacks for existing modules. */
+	apply_modules(dprintk_add_module_hook, NULL);
+
+	register_module_notifier(&dprintk_notifier);
+	return 0;
+}
+
+/*
+ * Cleanup the dprintk module.
+ */
+static void __exit dprintk_cleanup(void)
+{
+	if (verbose)
+		printk(KERN_INFO "%s called\n", __FUNCTION__);
+	unregister_module_notifier(&dprintk_notifier);
+	remove_proc_entry("dprintk", NULL);
+	dprintk_remove_all_tables();
+}
+
+module_init(dprintk_init);
+module_exit(dprintk_cleanup);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>");
+MODULE_DESCRIPTION("Provides a /proc interface for enabling "
+		   "individual debugging prints");
+/* vim:set ai sw=8 sts=8: */
Index: bfields/kernel/Makefile
===================================================================
--- bfields.orig/kernel/Makefile
+++ bfields/kernel/Makefile
@@ -89,6 +89,7 @@ obj-$(CONFIG_FUNCTION_TRACER) += trace/
 obj-$(CONFIG_TRACING) += trace/
 obj-$(CONFIG_SMP) += sched_cpupri.o
 obj-$(CONFIG_SLOW_WORK) += slow-work.o
+obj-$(CONFIG_DPRINTK) += dprintk.o
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan-HpYC8cTCicIJY7gZg3T8ig@public.gmane.org>, the -fno-omit-frame-pointer is
Index: bfields/init/Kconfig
===================================================================
--- bfields.orig/init/Kconfig
+++ bfields/init/Kconfig
@@ -834,6 +834,21 @@ config SLOW_WORK
 	  by a series of mkdirs and a create call, all of which have to touch
 	  disk.
 
+config DPRINTK
+	default n
+	tristate "Allow runtime activation of individual debug prints"
+	help
+	    Some kernel modules contain debugging prints, which emit
+	    to the system log information which could be useful for
+	    kernel developers and support staff.  These are normally
+	    disabled.  This module provides /proc/dprintk which allows
+	    a user to enable or disable these debug prints using a
+	    simple query language.  The language allows dprintks to
+	    be activated or deactivated singly or severally by filename,
+	    function, line number, and format string.
+
+	    See Documentation/dprintk-howto.txt for more details.
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
