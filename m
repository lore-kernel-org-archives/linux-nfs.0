From: "H. J. Lu" <hjl@lucon.org>
Subject: PATCH: Return error on bad export
Date: Thu, 10 Oct 2002 16:04:48 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021010160448.A618@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-88-146.client.attbi.com ([12.234.88.146] helo=lucon.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zmML-00010S-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 16:04:49 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Currently, we don't return an error when exportfs goes bad. Here is a
patch. I will check it in shortly if there is no objection.


H.J.
----
2002-10-10  H.J. Lu <hjl@lucon.org>

	* support/include/exportfs.h (export_errno): New.

	* support/nfs/exports.c: Include <errno.h>.
	(export_errno): New.
	(getexportent): Set export_errno to EINVAL for bad option.
	(parseopts): Likewise.
	Report the location of the default sync/async option.

	* utils/exportfs/exportfs.c (main): Initialize export_errno to
	0. Return export_errno.

Index: support/include/exportfs.h
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/include/exportfs.h,v
retrieving revision 1.3
diff -u -p -r1.3 exportfs.h
--- support/include/exportfs.h	20 Sep 2001 00:37:17 -0000	1.3
+++ support/include/exportfs.h	10 Oct 2002 22:58:39 -0000
@@ -77,4 +77,7 @@ int				rmtab_read(void);
 
 struct nfskey *			key_lookup(char *hname);
 
+/* Record export error.  */
+extern int export_errno;
+
 #endif /* EXPORTFS_H */
Index: support/nfs/exports.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/nfs/exports.c,v
retrieving revision 1.13
diff -u -p -r1.13 exports.c
--- support/nfs/exports.c	29 May 2002 06:07:43 -0000	1.13
+++ support/nfs/exports.c	10 Oct 2002 22:58:39 -0000
@@ -22,6 +22,7 @@
 #include <stdio.h>
 #include <ctype.h>
 #include <unistd.h>
+#include <errno.h>
 #include "nfslib.h"
 #include "exportfs.h"
 #include "xmalloc.h"
@@ -31,6 +32,8 @@
 #define EXPORT_DEFAULT_FLAGS	\
   (NFSEXP_READONLY|NFSEXP_ROOTSQUASH|NFSEXP_GATHERED_WRITES)
 
+int export_errno;
+
 static char	*efname = NULL;
 static XFILE	*efp = NULL;
 static int	first;
@@ -101,6 +104,7 @@ getexportent(int fromkernel, int fromexp
 	}
 	if (ok < 0) {
 		xlog(L_ERROR, "expected client(options...)");
+		export_errno = EINVAL;
 		return NULL;
 	}
 	first = 0;
@@ -114,6 +118,7 @@ getexportent(int fromkernel, int fromexp
 		*opt++ = '\0';
 		if (!(sp = strchr(opt, ')')) || sp[1] != '\0') {
 			syntaxerr("bad option list");
+			export_errno = EINVAL;
 			return NULL;
 		}
 		*sp = '\0';
@@ -122,6 +127,7 @@ getexportent(int fromkernel, int fromexp
 	}
 	if (strlen(exp) >= sizeof(ee.e_hostname)) {
 		syntaxerr("client name too long");
+		export_errno = EINVAL;
 		return NULL;
 	}
 	strncpy(ee.e_hostname, exp, sizeof (ee.e_hostname) - 1);
@@ -370,7 +376,9 @@ parseopts(char *cp, struct exportent *ep
 			if (opt[8]=='\0' || *oe != '\0') {
 				xlog(L_ERROR, "%s: %d: bad anonuid \"%s\"\n",
 				     flname, flline, opt);	
+bad_option:
 				free(opt);
+				export_errno = EINVAL;
 				return -1;
 			}
 		} else if (strncmp(opt, "anongid=", 8) == 0) {
@@ -379,18 +387,15 @@ parseopts(char *cp, struct exportent *ep
 			if (opt[8]=='\0' || *oe != '\0') {
 				xlog(L_ERROR, "%s: %d: bad anongid \"%s\"\n",
 				     flname, flline, opt);	
-				free(opt);
-				return -1;
+				goto bad_option;
 			}
 		} else if (strncmp(opt, "squash_uids=", 12) == 0) {
 			if (parsesquash(opt+12, &squids, &nsquids, &cp) < 0) {
-				free(opt);
-				return -1;
+				goto bad_option;
 			}
 		} else if (strncmp(opt, "squash_gids=", 12) == 0) {
 			if (parsesquash(opt+12, &sqgids, &nsqgids, &cp) < 0) {
-				free(opt);
-				return -1;
+				goto bad_option;
 			}
 		} else if (strncmp(opt, "fsid=", 5) == 0) {
 			char *oe;
@@ -398,16 +403,14 @@ parseopts(char *cp, struct exportent *ep
 			if (opt[5]=='\0' || *oe != '\0') {
 				xlog(L_ERROR, "%s: %d: bad fsid \"%s\"\n",
 				     flname, flline, opt);	
-				free(opt);
-				return -1;
+				goto bad_option;
 			}
 			ep->e_flags |= NFSEXP_FSID;
 		} else {
 			xlog(L_ERROR, "%s:%d: unknown keyword \"%s\"\n",
 					flname, flline, opt);
 			ep->e_flags |= NFSEXP_ALLSQUASH | NFSEXP_READONLY;
-			free(opt);
-			return -1;
+			goto bad_option;
 		}
 		free(opt);
 		while (isblank(*cp))
@@ -421,9 +424,11 @@ parseopts(char *cp, struct exportent *ep
 
 out:
 	if (warn && !had_sync_opt)
-		xlog(L_WARNING, "No 'sync' or 'async' option specified for export \"%s:%s\".\n"
+		xlog(L_WARNING, "%s [%d]: No 'sync' or 'async' option specified for export \"%s:%s\".\n"
 				"  Assuming default behaviour ('sync').\n"
 		     		"  NOTE: this default has changed from previous versions\n",
+
+				flname, flline,
 				ep->e_hostname, ep->e_path);
 
 	return 1;
Index: utils/exportfs/exportfs.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/exportfs/exportfs.c,v
retrieving revision 1.7
diff -u -p -r1.7 exportfs.c
--- utils/exportfs/exportfs.c	28 Feb 2002 01:37:45 -0000	1.7
+++ utils/exportfs/exportfs.c	10 Oct 2002 22:58:39 -0000
@@ -45,6 +45,8 @@ main(int argc, char **argv)
 
 	xlog_open("exportfs");
 
+	export_errno = 0;
+
 	while ((c = getopt(argc, argv, "aio:ruv")) != EOF) {
 		switch(c) {
 		case 'a':
@@ -119,7 +121,7 @@ main(int argc, char **argv)
 	xtab_export_write();
 	xtab_mount_write();
 
-	return 0;
+	return export_errno;
 }
 
 /* we synchronise intention with reality.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
