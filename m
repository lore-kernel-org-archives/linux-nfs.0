From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 03/12] Extend the exportfs interface to pass
	fslocations info into the kernel.
Date: Thu, 08 Feb 2007 17:27:04 -0500
Message-ID: <20070208222704.23464.86120.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk7-0006sQ-GG
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:51 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk5-0006mh-KU
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:50 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

Extend exportfs interface to pass fslocations info into the kernel,
using syntax modelled after AIX.  Adds "--refer" and "--replicas"
options to exportfs to enable use of the kernel fslocation code.
---

 support/include/exportfs.h |    7 ++
 support/include/nfslib.h   |    2 
 support/nfs/exports.c      |   37 +++++++++
 utils/exportfs/exportfs.c  |   14 +++
 utils/exportfs/exports.man |   14 +++
 utils/mountd/Makefile.am   |    2 
 utils/mountd/cache.c       |   30 +++++++
 utils/mountd/fsloc.c       |  184 ++++++++++++++++++++++++++++++++++++++++++++
 utils/mountd/fsloc.h       |   50 ++++++++++++
 9 files changed, 336 insertions(+), 4 deletions(-)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 10f38c7..458611b 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -23,6 +23,13 @@ enum {
 	MCL_MAXTYPES
 };
 
+enum {
+	FSLOC_NONE = 0,
+	FSLOC_REFER,
+	FSLOC_REPLICA,
+	FSLOC_STUB
+};
+
 typedef struct mclient {
 	struct mclient *	m_next;
 	char			m_hostname[NFSCLNT_IDMAX+1];
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index aba37c2..722d47a 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -80,6 +80,8 @@ struct exportent {
 	int		e_nsqgids;
 	int		e_fsid;
 	char *		e_mountpoint;
+	int             e_fslocmethod;
+	char *          e_fslocdata;
 };
 
 struct rmtabent {
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 9b010dc..3a07ebc 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -100,6 +100,8 @@ getexportent(int fromkernel, int fromexp
 		def_ee.e_squids = NULL;
 		def_ee.e_sqgids = NULL;
 		def_ee.e_mountpoint = NULL;
+		def_ee.e_fslocmethod = FSLOC_NONE;
+		def_ee.e_fslocdata = NULL;
 		def_ee.e_nsquids = 0;
 		def_ee.e_nsqgids = 0;
 
@@ -223,7 +225,22 @@ putexportent(struct exportent *ep)
 	if (ep->e_mountpoint)
 		fprintf(fp, "mountpoint%s%s,",
 			ep->e_mountpoint[0]?"=":"", ep->e_mountpoint);
-
+	switch (ep->e_fslocmethod) {
+	case FSLOC_NONE:
+		break;
+	case FSLOC_REFER:
+		fprintf(fp, "refer=%s,", ep->e_fslocdata);
+		break;
+	case FSLOC_REPLICA:
+		fprintf(fp, "replicas=%s,", ep->e_fslocdata);
+		break;
+	case FSLOC_STUB:
+		fprintf(fp, "fsloc=stub,");
+		break;
+	default:
+		xlog(L_ERROR, "unknown fsloc method for %s:%s",
+		     ep->e_hostname, ep->e_path);
+	}
 	fprintf(fp, "mapping=");
 	switch (ep->e_maptype) {
 	case CLE_MAP_IDENT:
@@ -286,6 +303,8 @@ dupexportent(struct exportent *dst, stru
 	}
 	if (src->e_mountpoint)
 		dst->e_mountpoint = strdup(src->e_mountpoint);
+	if (src->e_fslocdata)
+		dst->e_fslocdata = strdup(src->e_fslocdata);
 }
 
 struct exportent *
@@ -300,6 +319,8 @@ mkexportent(char *hname, char *path, cha
 	ee.e_squids = NULL;
 	ee.e_sqgids = NULL;
 	ee.e_mountpoint = NULL;
+	ee.e_fslocmethod = FSLOC_NONE;
+	ee.e_fslocdata = NULL;
 	ee.e_nsquids = 0;
 	ee.e_nsqgids = 0;
 
@@ -461,6 +482,20 @@ bad_option:
 				ep->e_mountpoint = strdup(mp+1);
 			else
 				ep->e_mountpoint = strdup("");
+		} else if (strncmp(opt, "fsloc=", 6) == 0) {
+			if (strcmp(opt+6, "stub") == 0)
+				ep->e_fslocmethod = FSLOC_STUB;
+			else {
+				xlog(L_ERROR, "%s:%d: bad option %s\n",
+				     flname, flline, opt);
+				goto bad_option;
+			}
+		} else if (strncmp(opt, "refer=", 6) == 0) {
+			ep->e_fslocmethod = FSLOC_REFER;
+			ep->e_fslocdata = strdup(opt+6);
+		} else if (strncmp(opt, "replicas=", 9) == 0) {
+			ep->e_fslocmethod = FSLOC_REPLICA;
+			ep->e_fslocdata = strdup(opt+9);
 		} else {
 			xlog(L_ERROR, "%s:%d: unknown keyword \"%s\"\n",
 					flname, flline, opt);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index cd49a3b..1a8817d 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -416,7 +416,19 @@ dump(int verbose)
 				c = dumpopt(c, "anonuid=%d", ep->e_anonuid);
 			if (ep->e_anongid != 65534)
 				c = dumpopt(c, "anongid=%d", ep->e_anongid);
-
+			switch(ep->e_fslocmethod) {
+			case FSLOC_NONE:
+				break;
+			case FSLOC_REFER:
+				c = dumpopt(c, "refer=%s", ep->e_fslocdata);
+				break;
+			case FSLOC_REPLICA:
+				c = dumpopt(c, "replicas=%s", ep->e_fslocdata);
+				break;
+			case FSLOC_STUB:
+				c = dumpopt(c, "fsloc=stub");
+				break;
+			}
 			printf("%c\n", (c != '(')? ')' : ' ');
 		}
 	}
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 892533b..eb645fc 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -327,6 +327,20 @@ The value  0 has a special meaning when 
 concept of a root of the overall exported filesystem. The export point
 exported with fsid=0 will be used as this root.
 
+.TP
+.IR refer= path@host[+host][:path@host[+host]]
+A client referencing the export point will be directed to choose from
+the given list an alternative location for the filesystem.
+(Note that the server must have a mountpoint here, though a different
+filesystem is not required; so, for example,
+.IR "mount --bind" " /path /path"
+is sufficient.)
+.TP
+.IR replicas= path@host[+host][:path@host[+host]]
+If the client asks for alternative locations for the export point, it
+will be given this list of alternatives. (Note that actual replication
+of the filesystem must be handled elsewhere.)
+
 .SS User ID Mapping
 .PP
 .I nfsd
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index dd400fd..1465114 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -8,7 +8,7 @@ KPREFIX		= @kprefix@
 sbin_PROGRAMS	= mountd
 
 mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
-		 svc_run.c mountd.h
+		 svc_run.c fsloc.c mountd.h
 mountd_LDADD = ../../support/export/libexport.a \
 	       ../../support/nfs/libnfs.a \
 	       ../../support/misc/libmisc.a \
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index e8d42ae..89dc642 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -26,6 +26,7 @@ #include "nfslib.h"
 #include "exportfs.h"
 #include "mountd.h"
 #include "xmalloc.h"
+#include "fsloc.h"
 
 /*
  * Support routines for text-based upcalls.
@@ -236,6 +237,29 @@ void nfsd_fh(FILE *f)
 	return;		
 }
 
+static void write_fsloc(FILE *f, struct exportent *ep, char *path)
+{
+	struct servers *servers;
+
+	if (ep->e_fslocmethod == FSLOC_NONE)
+		return;
+
+	servers = replicas_lookup(ep->e_fslocmethod, ep->e_fslocdata, path);
+	if (!servers)
+		return;
+	qword_print(f, "fsloc");
+	qword_printint(f, servers->h_num);
+	if (servers->h_num >= 0) {
+		int i;
+		for (i=0; i<servers->h_num; i++) {
+			qword_print(f, servers->h_mp[i]->h_host);
+			qword_print(f, servers->h_mp[i]->h_path);
+		}
+	}
+	qword_printint(f, servers->h_referral);
+	release_replicas(servers);
+}
+
 void nfsd_export(FILE *f)
 {
 	/* requests are:
@@ -292,6 +316,8 @@ void nfsd_export(FILE *f)
 		qword_printint(f, found->m_export.e_anonuid);
 		qword_printint(f, found->m_export.e_anongid);
 		qword_printint(f, found->m_export.e_fsid);
+		write_fsloc(f, &found->m_export, path);
+		mountlist_add(dom, path);
 	}
 	qword_eol(f);
  out:
@@ -366,7 +392,9 @@ int cache_export_ent(char *domain, struc
 	qword_printint(f, exp->e_anonuid);
 	qword_printint(f, exp->e_anongid);
 	qword_printint(f, exp->e_fsid);
-	err = qword_eol(f);
+	write_fsloc(f, exp, exp->e_path);
+	mountlist_add(domain, exp->e_path);
+	qword_eol(f);
 
 	fclose(f);
 	return err;
diff --git a/utils/mountd/fsloc.c b/utils/mountd/fsloc.c
new file mode 100644
index 0000000..44b5b97
--- /dev/null
+++ b/utils/mountd/fsloc.c
@@ -0,0 +1,184 @@
+/*
+ * COPYRIGHT (c) 2006
+ * THE REGENTS OF THE UNIVERSITY OF MICHIGAN
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+#include <stdlib.h>
+#include <string.h>
+#include <syslog.h>
+
+#include "fsloc.h"
+#include "exportfs.h"
+
+/* Debugging tool: prints out @servers info to syslog */
+static void replicas_print(struct servers *sp)
+{
+	int i;
+	if (!sp) {
+		syslog(LOG_INFO, "NULL replicas pointer");
+		return;
+	}
+	syslog(LOG_INFO, "replicas listsize=%i", sp->h_num);
+	for (i=0; i<sp->h_num; i++) {
+		syslog(LOG_INFO, "%s:%s",
+		       sp->h_mp[i]->h_host, sp->h_mp[i]->h_path);
+	}
+}
+
+/* Called by setting 'Method = stub' in config file.  Just returns
+ * some syntactically correct gibberish for testing purposes.
+ */
+static struct servers *method_stub(char *key)
+{
+	struct servers *sp;
+	struct mount_point *mp;
+
+	syslog(LOG_INFO, "called method_stub");
+	sp = malloc(sizeof(struct servers));
+	if (!sp)
+		return NULL;
+	mp = calloc(1, sizeof(struct mount_point));
+	if (!mp) {
+		free(sp);
+		return NULL;
+	}
+	sp->h_num = 1;
+	sp->h_mp[0] = mp;
+	mp->h_host = strdup("stub_server");
+	mp->h_path = strdup("/my/test/path");
+	sp->h_referral = 1;
+	return sp;
+}
+
+/* Scan @list, which is a NULL-terminated array of strings of the
+ * form path@host[+host], and return corresponding servers structure.
+ */
+static struct servers *parse_list(char **list)
+{
+	int i;
+	struct servers *res;
+	struct mount_point *mp;
+	char *cp;
+
+	res = malloc(sizeof(struct servers));
+	if (!res)
+		return NULL;
+	res->h_num = 0;
+
+	/* parse each of the answers in sucession. */
+	for (i=0; list[i] && i<FSLOC_MAX_LIST; i++) {
+		mp = calloc(1, sizeof(struct mount_point));
+		if (!mp) {
+			release_replicas(res);
+			return NULL;
+		}
+		cp = strchr(list[i], '@');
+		if ((!cp) || list[i][0] != '/') {
+			syslog(LOG_WARNING, "invalid entry '%s'", list[i]);
+			continue; /* XXX Need better error handling */
+		}
+		res->h_mp[i] = mp;
+		res->h_num++;
+		mp->h_path = strndup(list[i], cp - list[i]);
+		cp++;
+		mp->h_host = strdup(cp);
+		/* hosts are '+' separated, kernel expects ':' separated */
+		while ( (cp = strchr(mp->h_host, '+')) )
+		       *cp = ':';
+	}
+	return res;
+}
+
+/* @data is a string of form path@host[+host][:path@host[+host]]
+ */
+static struct servers *method_list(char *data)
+{
+	char *copy, *ptr=data;
+	char **list;
+	int i, listsize;
+	struct servers *rv=NULL;
+
+	syslog(LOG_INFO, "method_list(%s)\n", data);
+	for (ptr--, listsize=1; ptr; ptr=index(ptr, ':'), listsize++)
+		ptr++;
+	list = malloc(listsize * sizeof(char *));
+	copy = strdup(data);
+	if (copy)
+		syslog(LOG_INFO, "converted to %s\n", copy);
+	if (list && copy) {
+		ptr = copy;
+		for (i=0; i<listsize; i++) {
+			list[i] = strsep(&ptr, ":");
+		}
+		rv = parse_list(list);
+	}
+	free(copy);
+	free(list);
+	replicas_print(rv);
+	return rv;
+}
+
+/* Returns appropriately filled struct servers, or NULL if had a problem */
+struct servers *replicas_lookup(int method, char *data, char *key)
+{
+	struct servers *sp=NULL;
+	switch(method) {
+	case FSLOC_NONE:
+		break;
+	case FSLOC_REFER:
+		sp = method_list(data);
+		if (sp)
+			sp->h_referral = 1;
+		break;
+	case FSLOC_REPLICA:
+		sp = method_list(data);
+		if (sp)
+			sp->h_referral = 0;
+		break;
+	case FSLOC_STUB:
+		sp = method_stub(data);
+		break;
+	default:
+		syslog(LOG_WARNING, "Unknown method = %i", method);
+	}
+	replicas_print(sp);
+	return sp;
+}
+
+void release_replicas(struct servers *server)
+{
+	int i;
+
+	if (!server) return;
+	for (i = 0; i < server->h_num; i++) {
+		free(server->h_mp[i]->h_host);
+		free(server->h_mp[i]->h_path);
+		free(server->h_mp[i]);
+	}
+	free(server);
+}
diff --git a/utils/mountd/fsloc.h b/utils/mountd/fsloc.h
new file mode 100644
index 0000000..8296d1c
--- /dev/null
+++ b/utils/mountd/fsloc.h
@@ -0,0 +1,50 @@
+/*
+ * COPYRIGHT (c) 2006
+ * THE REGENTS OF THE UNIVERSITY OF MICHIGAN
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+#ifndef FSLOC_H
+#define FSLOC_H
+
+#define FSLOC_MAX_LIST 40
+
+struct mount_point {
+	char *h_host;
+	char *h_path;
+};
+
+struct servers {
+	int h_num;
+	struct mount_point *h_mp[FSLOC_MAX_LIST];
+	int h_referral;		/* 0=replica, 1=referral */
+};
+
+struct servers *replicas_lookup(int method, char *data, char *key);
+void release_replicas(struct servers *server);
+
+#endif /* FSLOC_H */

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
