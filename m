From: Steve Dickson <SteveD@redhat.com>
Subject: Re: ANNOUNCE: nfs-utils 1.0.11
Date: Mon, 26 Feb 2007 07:08:21 -0500
Message-ID: <45E2CDB5.7090900@RedHat.com>
References: <17885.10111.791755.714451@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080805070608000508090802"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLec3-0006Dv-CC
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 04:05:51 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLec4-0005UU-ML
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 04:05:53 -0800
In-Reply-To: <17885.10111.791755.714451@notabene.brown>
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

This is a multi-part message in MIME format.
--------------080805070608000508090802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hey Neil,

Neil Brown wrote:
> 
> I have just made a release of  nfs-utils 1.0.11

Unfortunately there are some problems with the
FS-Location patches you used... namely they don't
compile... So attached is the patch that takes
care of the compile problems...

The correction patch came from CITI, with a few tweaks
of my own... namely turning the syslog calls in
the mountd code to xlog calls..

The commit blob is relative to:
git://git.infradead.org/~steved/nfs-utils.git

steved.

--------------080805070608000508090802
Content-Type: text/x-patch;
 name="fsloc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fsloc.patch"

commit b89bca96533c95a4e32c5f47048612acbdb707b0
Author: Fred Isaman <iisaman@citi.umich.edu>
Date:   Fri Feb 23 13:02:16 2007 -0500

        Extend the exportfs/mountd interface to pass fslocations info into the
    kernel
    
        Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
        Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    
        Extend the exportfs/mountd interface to pass fslocations info into
        the kernel using syntax modelled after AIX.
    
        Adds "refer=" and "replicas=" to the options in /etc/exports
        to enable use of the kernel fslocation code.

diff --git a/support/export/export.c b/support/export/export.c
index cfb6681..a4b0788 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -240,6 +240,8 @@ export_freeall(void)
 				xfree(exp->m_export.e_sqgids);
 			if (exp->m_export.e_mountpoint)
 				free(exp->m_export.e_mountpoint);
+			if (exp->m_export.e_fslocdata)
+				xfree(exp->m_export.e_fslocdata);
 			xfree(exp);
 		}
 		exportlist[i] = NULL;
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 31b38c3..294e1c9 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -236,9 +236,11 @@ putexportent(struct exportent *ep)
 	case FSLOC_REPLICA:
 		fprintf(fp, "replicas=%s,", ep->e_fslocdata);
 		break;
+#ifdef DEBUG
 	case FSLOC_STUB:
 		fprintf(fp, "fsloc=stub,");
 		break;
+#endif
 	default:
 		xlog(L_ERROR, "unknown fsloc method for %s:%s",
 		     ep->e_hostname, ep->e_path);
@@ -504,6 +506,7 @@ bad_option:
 				ep->e_mountpoint = strdup(mp+1);
 			else
 				ep->e_mountpoint = strdup("");
+#ifdef DEBUG
 		} else if (strncmp(opt, "fsloc=", 6) == 0) {
 			if (strcmp(opt+6, "stub") == 0)
 				ep->e_fslocmethod = FSLOC_STUB;
@@ -512,6 +515,7 @@ bad_option:
 				     flname, flline, opt);
 				goto bad_option;
 			}
+#endif
 		} else if (strncmp(opt, "refer=", 6) == 0) {
 			ep->e_fslocmethod = FSLOC_REFER;
 			ep->e_fslocdata = strdup(opt+6);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 40a6b56..22e13a3 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -427,9 +427,11 @@ dump(int verbose)
 			case FSLOC_REPLICA:
 				c = dumpopt(c, "replicas=%s", ep->e_fslocdata);
 				break;
+#ifdef DEBUG
 			case FSLOC_STUB:
 				c = dumpopt(c, "fsloc=stub");
 				break;
+#endif
 			}
 			printf("%c\n", (c != '(')? ')' : ' ');
 		}
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 27a30f9..ab63b03 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -348,6 +348,20 @@ If the client asks for alternative locations for the export point, it
 will be given this list of alternatives. (Note that actual replication
 of the filesystem must be handled elsewhere.)
 
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
diff --git a/utils/mountd/fsloc.c b/utils/mountd/fsloc.c
new file mode 100644
index 0000000..5b094b0
--- /dev/null
+++ b/utils/mountd/fsloc.c
@@ -0,0 +1,188 @@
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
+		xlog(L_NOTICE, "NULL replicas pointer\n");
+		return;
+	}
+	xlog(L_NOTICE, "replicas listsize=%i\n", sp->h_num);
+	for (i=0; i<sp->h_num; i++) {
+		xlog(L_NOTICE, "    %s:%s\n",
+		       sp->h_mp[i]->h_host, sp->h_mp[i]->h_path);
+	}
+}
+
+#ifdef DEBUG
+/* Called by setting 'Method = stub' in config file.  Just returns
+ * some syntactically correct gibberish for testing purposes.
+ */
+static struct servers *method_stub(char *key)
+{
+	struct servers *sp;
+	struct mount_point *mp;
+
+	xlog(L_NOTICE, "called method_stub\n");
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
+#endif	/* DEBUG */
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
+			xlog(L_WARNING, "invalid entry '%s'", list[i]);
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
+	xlog(L_NOTICE, "method_list(%s)\n", data);
+	for (ptr--, listsize=1; ptr; ptr=index(ptr, ':'), listsize++)
+		ptr++;
+	list = malloc(listsize * sizeof(char *));
+	copy = strdup(data);
+	if (copy)
+		xlog(L_NOTICE, "converted to %s\n", copy);
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
+#ifdef DEBUG
+	case FSLOC_STUB:
+		sp = method_stub(data);
+		break;
+#endif
+	default:
+		xlog(L_WARNING, "Unknown method = %i", method);
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

--------------080805070608000508090802
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080805070608000508090802
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080805070608000508090802--
