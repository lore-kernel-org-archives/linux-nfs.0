From: Amit Gud <agud@redhat.com>
Subject: [PATCH 2 / 2] Move NFS mount code from util-linux to
 nfs-utils - take2
Date: Mon, 12 Jun 2006 19:08:27 -0400
Message-ID: <448DF3EB.7010601@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000502050306070705090704"
Cc: Amit Gud <gud@eth.net>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpvTA-0007ck-TU
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 16:05:16 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FpvTA-0007xJ-RD
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 16:05:16 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpvT7-0003On-BA
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 16:05:16 -0700
To: Neil Brown <neilb@suse.de>
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
--------------000502050306070705090704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------000502050306070705090704
Content-Type: text/plain;
	name="nfsmount-migration-to-nfsutils-support-v4.patch"
Content-Disposition: inline;
	filename="nfsmount-migration-to-nfsutils-support-v4.patch"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mx1.redhat.com id
	k5CN59hX014106

Adds the support functions needed for mount and umount. This functionalit=
y will someday be available in the form of shared mount library.


Signed-off-by: Amit Gud <agud@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

---
diff -uprN nfs-utils-1.0.8/support/include/conn.h nfs-utils-1.0.8-ag/supp=
ort/include/conn.h
--- nfs-utils-1.0.8/support/include/conn.h	1969-12-31 19:00:00.000000000 =
-0500
+++ nfs-utils-1.0.8-ag/support/include/conn.h	2006-06-12 15:09:32.1218610=
00 -0400
@@ -0,0 +1,42 @@
+/*=20
+ * conn.h -- Connection routines for NFS mount / umount code.
+ *
+ * 2006-06-06 Amit Gud <agud@redhat.com>
+ * - Moved code snippets here from util-linux/mount
+ */
+
+#ifndef _CONN_H
+#define _CONN_H
+
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
+#include <rpc/pmap_prot.h>
+#include <rpc/clnt.h>
+
+#define MNT_SENDBUFSIZE ((u_int)2048)
+#define MNT_RECVBUFSIZE ((u_int)1024)
+
+typedef struct {
+	char **hostname;
+	struct sockaddr_in saddr;
+	struct pmap pmap;
+} clnt_addr_t;
+
+/* RPC call timeout values */
+static const struct timeval TIMEOUT =3D { 20, 0 };
+static const struct timeval RETRY_TIMEOUT =3D { 3, 0 };
+
+int clnt_ping(struct sockaddr_in *, const u_long, const u_long, const u_=
int);
+u_long nfsvers_to_mnt(const u_long);
+u_long mntvers_to_nfs(const u_long);
+int get_socket(struct sockaddr_in *, u_int, int);
+CLIENT * mnt_openclnt(clnt_addr_t *, int *);
+void mnt_closeclnt(CLIENT *, int);
+
+#endif /* _CONN_H */
+
diff -uprN nfs-utils-1.0.8/support/include/fstab.h nfs-utils-1.0.8-ag/sup=
port/include/fstab.h
--- nfs-utils-1.0.8/support/include/fstab.h	1969-12-31 19:00:00.000000000=
 -0500
+++ nfs-utils-1.0.8-ag/support/include/fstab.h	2006-06-12 15:09:32.126862=
000 -0400
@@ -0,0 +1,24 @@
+#ifndef _NFS_FSTAB_H
+#define _NFS_FSTAB_H
+
+#include "nfs_mntent.h"
+
+int mtab_is_writable(void);
+int mtab_does_not_exist(void);
+
+struct mntentchn {
+	struct mntentchn *nxt, *prev;
+	nfs_mntent_t m;
+};
+
+struct mntentchn *mtab_head (void);
+struct mntentchn *getmntoptfile (const char *file);
+struct mntentchn *getmntdirbackward (const char *dir, struct mntentchn *=
mc);
+struct mntentchn *getmntdevbackward (const char *dev, struct mntentchn *=
mc);
+
+void lock_mtab (void);
+void unlock_mtab (void);
+void update_mtab (const char *special, nfs_mntent_t *with);
+
+#endif /* _NFS_FSTAB_H */
+
diff -uprN nfs-utils-1.0.8/support/include/Makefile.am nfs-utils-1.0.8-ag=
/support/include/Makefile.am
--- nfs-utils-1.0.8/support/include/Makefile.am	2005-12-19 23:12:43.00000=
0000 -0500
+++ nfs-utils-1.0.8-ag/support/include/Makefile.am	2006-06-12 15:09:32.13=
0862000 -0400
@@ -3,9 +3,13 @@
 SUBDIRS =3D nfs rpcsvc sys
=20
 noinst_HEADERS =3D \
+	conn.h \
 	exportfs.h \
+	fstab.h \
 	ha-callout.h \
 	misc.h \
+	nfs_mntent.h \
+	nfs_paths.h \
 	nfslib.h \
 	rpcdispatch.h \
 	rpcmisc.h \
@@ -15,6 +19,7 @@ noinst_HEADERS =3D \
 	xio.h \
 	xlog.h \
 	xmalloc.h \
+	xcommon.h \
 	ypupdate.h
=20
 MAINTAINERCLEANFILES =3D Makefile.in
diff -uprN nfs-utils-1.0.8/support/include/nfs_mntent.h nfs-utils-1.0.8-a=
g/support/include/nfs_mntent.h
--- nfs-utils-1.0.8/support/include/nfs_mntent.h	1969-12-31 19:00:00.0000=
00000 -0500
+++ nfs-utils-1.0.8-ag/support/include/nfs_mntent.h	2006-06-12 15:09:32.1=
36861000 -0400
@@ -0,0 +1,34 @@
+/*
+ * 2006-06-08 Amit Gud <agud@redhat.com>
+ * - Moved code snippets here from util-linux/mount/my_mntent.h
+ */
+
+#ifndef _NFS_MNTENT_H
+#define _NFS_MNTENT_H
+
+typedef struct nfs_mntent_s {
+	const char *mnt_fsname;
+	const char *mnt_dir;
+	const char *mnt_type;
+	const char *mnt_opts;
+	int mnt_freq;
+	int mnt_passno;
+} nfs_mntent_t;
+
+#define ERR_MAX 5
+
+typedef struct mntFILEstruct {
+	FILE *mntent_fp;
+	char *mntent_file;
+	int mntent_lineno;
+	int mntent_errs;
+	int mntent_softerrs;
+} mntFILE;
+
+mntFILE *nfs_setmntent (const char *file, char *mode);
+void nfs_endmntent (mntFILE *mfp);
+int nfs_addmntent (mntFILE *mfp, nfs_mntent_t *mnt);
+struct nfs_mntent *my_getmntent (mntFILE *mfp);
+nfs_mntent_t *nfs_getmntent (mntFILE *mfp);
+
+#endif /* _NFS_MNTENT_H */
diff -uprN nfs-utils-1.0.8/support/include/nfs_paths.h nfs-utils-1.0.8-ag=
/support/include/nfs_paths.h
--- nfs-utils-1.0.8/support/include/nfs_paths.h	1969-12-31 19:00:00.00000=
0000 -0500
+++ nfs-utils-1.0.8-ag/support/include/nfs_paths.h	2006-06-12 15:09:32.14=
1863000 -0400
@@ -0,0 +1,11 @@
+#ifndef _NFS_PATHS_H
+#define _NFS_PATHS_H
+
+#ifndef _PATH_MOUNTED
+#define _PATH_MOUNTED "/etc/fstab"
+#endif
+#define MOUNTED_LOCK	_PATH_MOUNTED "~"
+#define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"
+
+#endif /* _NFS_PATHS_H */
+
diff -uprN nfs-utils-1.0.8/support/include/nls.h nfs-utils-1.0.8-ag/suppo=
rt/include/nls.h
--- nfs-utils-1.0.8/support/include/nls.h	1969-12-31 19:00:00.000000000 -=
0500
+++ nfs-utils-1.0.8-ag/support/include/nls.h	2006-06-12 15:09:32.14786100=
0 -0400
@@ -0,0 +1,27 @@
+/*=20
+ * 2006-06-08 Amit Gud <agud@redhat.com>
+ * - Copied to nfs-utils/support/include from util-linux/mount
+ */
+
+#ifndef LOCALEDIR
+#define LOCALEDIR "/usr/share/locale"
+#endif
+
+#ifdef ENABLE_NLS
+# include <libintl.h>
+# define _(Text) gettext (Text)
+# ifdef gettext_noop
+#  define N_(String) gettext_noop (String)
+# else
+#  define N_(String) (String)
+# endif
+#else
+# undef bindtextdomain
+# define bindtextdomain(Domain, Directory) /* empty */
+# undef textdomain
+# define textdomain(Domain) /* empty */
+# define _(Text) (Text)
+# define N_(Text) (Text)
+#endif
+
+
diff -uprN nfs-utils-1.0.8/support/include/xcommon.h nfs-utils-1.0.8-ag/s=
upport/include/xcommon.h
--- nfs-utils-1.0.8/support/include/xcommon.h	1969-12-31 19:00:00.0000000=
00 -0500
+++ nfs-utils-1.0.8-ag/support/include/xcommon.h	2006-06-12 15:09:32.1528=
61000 -0400
@@ -0,0 +1,48 @@
+/*
+ * xcommon.h -- Support function prototypes. Functions are in xcommon.c.
+ *
+ * 2006-06-06 Amit Gud <agud@redhat.com>
+ * - Moved code snippets  from mount/sundries.h of util-linux
+ *   and merged code from support/nfs/xmalloc.c by Olaf Kirch <okir@mona=
d.swb.de> here.
+ */
+
+#ifndef _XMALLOC_H
+#define _MALLOC_H
+
+#include <sys/types.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <signal.h>
+#include <stdarg.h>
+#include <stdlib.h>
+#include <string.h>
+
+#define streq(s, t)	(strcmp ((s), (t)) =3D=3D 0)
+
+/* Functions in sundries.c that are used in mount.c and umount.c  */=20
+char *canonicalize (const char *path);
+void nfs_error (const char *fmt, ...);
+void *xmalloc (size_t size);
+void *xrealloc(void *p, size_t size);
+void xfree(void *);
+char *xstrdup (const char *s);
+char *xstrndup (const char *s, int n);
+char *xstrconcat2 (const char *, const char *);
+char *xstrconcat3 (const char *, const char *, const char *);
+char *xstrconcat4 (const char *, const char *, const char *, const char =
*);
+void die (int errcode, const char *fmt, ...);
+
+extern void die(int err, const char *fmt, ...);
+extern void (*at_die)(void);
+
+/* exit status - bits below are ORed */
+#define EX_USAGE	1	/* incorrect invocation or permission */
+#define EX_SYSERR	2	/* out of memory, cannot fork, ... */
+#define EX_SOFTWARE	4	/* internal mount bug or wrong version */
+#define EX_USER		8	/* user interrupt */
+#define EX_FILEIO      16	/* problems writing, locking, ... mtab/fstab *=
/
+#define EX_FAIL	       32	/* mount failure */
+#define EX_SOMEOK      64	/* some mount succeeded */
+#define EX_BG         256       /* retry in background (internal only) *=
/
+
+#endif /* XMALLOC_H */
diff -uprN nfs-utils-1.0.8/support/include/xmalloc.h nfs-utils-1.0.8-ag/s=
upport/include/xmalloc.h
--- nfs-utils-1.0.8/support/include/xmalloc.h	1999-10-18 19:21:12.0000000=
00 -0400
+++ nfs-utils-1.0.8-ag/support/include/xmalloc.h	2006-06-12 15:09:32.1568=
63000 -0400
@@ -1,16 +1 @@
-/*
- * xmalloc	Module for memory allocation. Drop in your
- *		debugging malloc module if you feel like it.
- *
- * Copyright (C) 1995 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifndef XMALLOC_H
-#define XMALLOC_H
-
-void	*xmalloc(size_t size);
-void	*xrealloc(void *ptr, size_t size);
-char	*xstrdup(const char *s);
-void	xfree(void *ptr);
-
-#endif /* XMALLOC_H */
+#include "xcommon.h"
diff -uprN nfs-utils-1.0.8/support/nfs/conn.c nfs-utils-1.0.8-ag/support/=
nfs/conn.c
--- nfs-utils-1.0.8/support/nfs/conn.c	1969-12-31 19:00:00.000000000 -050=
0
+++ nfs-utils-1.0.8-ag/support/nfs/conn.c	2006-06-12 15:09:32.164861000 -=
0400
@@ -0,0 +1,211 @@
+/*
+ * conn.c -- NFS client mount / umount connection code support functions
+ *
+ * 2006-06-06 Amit Gud <agud@redhat.com>
+ * - Moved code snippets to nfs-utils/support/nfs from util-linux/mount/=
nfsmount.c
+ *
+ */
+
+#include <errno.h>
+#include <rpc/rpc.h>
+#include <rpc/pmap_prot.h>
+#include <rpc/pmap_clnt.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
+#include "conn.h"
+
+extern int verbose;
+
+/* Map an NFS version into the corresponding Mountd version */
+u_long nfsvers_to_mnt(const u_long vers)
+{
+	static const u_long nfs_to_mnt[] =3D { 0, 0, 1, 3 };
+	if (vers <=3D 3)
+		return nfs_to_mnt[vers];
+	return 0;
+}
+
+/* Map a Mountd version into the corresponding NFS version */
+u_long mntvers_to_nfs(const u_long vers)
+{
+	static const u_long mnt_to_nfs[] =3D { 0, 2, 2, 3 };
+	if (vers <=3D 3)
+		return mnt_to_nfs[vers];
+	return 0;
+}
+
+/*
+ * Create a socket that is locally bound to a=20
+ * reserve or non-reserve port. For any failures,
+ * RPC_ANYSOCK is returned which will cause=20
+ * the RPC code to create the socket instead.=20
+ */
+int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp)
+{
+	int so, cc, type;
+	struct sockaddr_in laddr;
+	socklen_t namelen =3D sizeof(laddr);
+
+	type =3D (p_prot =3D=3D IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
+	if ((so =3D socket (AF_INET, type, p_prot)) < 0) {
+		rpc_createerr.cf_stat =3D RPC_SYSTEMERROR;
+		rpc_createerr.cf_error.re_errno =3D errno;
+		if (verbose) {
+			fprintf(stderr,=20
+				"mount: Unable to create %s socket: errno %d (%s)\n",
+				p_prot =3D=3D IPPROTO_UDP ? "UDP" : "TCP",=20
+				errno, strerror(errno));
+		}
+		return RPC_ANYSOCK;
+	}
+	laddr.sin_family =3D AF_INET;
+	laddr.sin_port =3D 0;
+	laddr.sin_addr.s_addr =3D htonl(INADDR_ANY);
+	if (resvp) {
+		if (bindresvport(so, &laddr) < 0) {
+			rpc_createerr.cf_stat =3D RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno =3D errno;
+			if (verbose) {
+				fprintf(stderr,=20
+					"mount: Unable to bindresvport %s socket: errno %d (%s)\n",
+					p_prot =3D=3D IPPROTO_UDP ? "UDP" : "TCP",=20
+					errno, strerror(errno));
+			}
+			close(so);
+			return RPC_ANYSOCK;
+		}
+	} else {
+		cc =3D bind(so, (struct sockaddr *)&laddr, namelen);
+		if (cc < 0) {
+			rpc_createerr.cf_stat =3D RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno =3D errno;
+			if (verbose) {
+				fprintf(stderr,=20
+					"mount: Unable to bind to %s socket: errno %d (%s)\n",
+					p_prot =3D=3D IPPROTO_UDP ? "UDP" : "TCP",=20
+					errno, strerror(errno));
+			}
+			close(so);
+			return RPC_ANYSOCK;
+		}
+	}
+	if (type =3D=3D SOCK_STREAM) {
+		cc =3D connect(so, (struct sockaddr *)saddr, namelen);
+		if (cc < 0) {
+			rpc_createerr.cf_stat =3D RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno =3D errno;
+			if (verbose) {
+				fprintf(stderr,=20
+					"mount: Unable to connect to %s:%d, errno %d (%s)\n",
+					inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port),
+					errno, strerror(errno));
+			}
+			close(so);
+			return RPC_ANYSOCK;
+		}
+	}
+	return so;
+}
+
+/*
+ * Sigh... getport() doesn't actually check the version number.
+ * In order to make sure that the server actually supports the service
+ * we're requesting, we open and RPC client, and fire off a NULL
+ * RPC call.
+ */
+int
+clnt_ping(struct sockaddr_in *saddr, const u_long prog, const u_long ver=
s,
+	  const u_int prot)
+{
+	CLIENT *clnt=3DNULL;
+	int sock, stat;
+	static char clnt_res;
+
+	rpc_createerr.cf_stat =3D stat =3D errno =3D 0;
+	sock =3D get_socket(saddr, prot, FALSE);
+	if (sock =3D=3D RPC_ANYSOCK && errno =3D=3D ETIMEDOUT) {
+		/*
+		 * TCP timeout. Bubble up the error to see=20
+		 * how it should be handled.
+		 */
+		rpc_createerr.cf_stat =3D RPC_TIMEDOUT;
+		goto out_bad;
+	}
+
+	switch(prot) {
+	case IPPROTO_UDP:
+		clnt =3D clntudp_bufcreate(saddr, prog, vers,
+					 RETRY_TIMEOUT, &sock,
+					 RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
+		break;
+	case IPPROTO_TCP:
+		clnt =3D clnttcp_create(saddr, prog, vers, &sock,
+				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
+		break;
+	default:
+		goto out_bad;
+	}
+	if (!clnt)
+		goto out_bad;
+	memset(&clnt_res, 0, sizeof(clnt_res));
+	stat =3D clnt_call(clnt, NULLPROC,
+			 (xdrproc_t)xdr_void, (caddr_t)NULL,
+			 (xdrproc_t)xdr_void, (caddr_t)&clnt_res,
+			 TIMEOUT);
+	if (stat) {
+		clnt_geterr(clnt, &rpc_createerr.cf_error);
+		rpc_createerr.cf_stat =3D stat;
+	}
+	clnt_destroy(clnt);
+	if (sock !=3D -1)
+		close(sock);
+
+	if (stat =3D=3D RPC_SUCCESS)
+		return 1;
+
+ out_bad:
+	return 0;
+}
+
+CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
+{
+	struct sockaddr_in *mnt_saddr =3D &mnt_server->saddr;
+	struct pmap *mnt_pmap =3D &mnt_server->pmap;
+	CLIENT *clnt =3D NULL;
+
+	/* contact the mount daemon via TCP */
+	mnt_saddr->sin_port =3D htons((u_short)mnt_pmap->pm_port);
+	*msock =3D get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE);
+
+	switch (mnt_pmap->pm_prot) {
+	case IPPROTO_UDP:
+		clnt =3D clntudp_bufcreate(mnt_saddr,
+					 mnt_pmap->pm_prog, mnt_pmap->pm_vers,
+					 RETRY_TIMEOUT, msock,
+					 MNT_SENDBUFSIZE, MNT_RECVBUFSIZE);
+		break;
+	case IPPROTO_TCP:
+		clnt =3D clnttcp_create(mnt_saddr,
+				      mnt_pmap->pm_prog, mnt_pmap->pm_vers,
+				      msock,
+				      MNT_SENDBUFSIZE, MNT_RECVBUFSIZE);
+		break;
+	}
+	if (clnt) {
+		/* try to mount hostname:dirname */
+		clnt->cl_auth =3D authunix_create_default();
+		return clnt;
+	}
+	return NULL;
+}
+
+void mnt_closeclnt(CLIENT *clnt, int msock)
+{
+	auth_destroy(clnt->cl_auth);
+	clnt_destroy(clnt);
+	close(msock);
+}
+
diff -uprN nfs-utils-1.0.8/support/nfs/fstab.c nfs-utils-1.0.8-ag/support=
/nfs/fstab.c
--- nfs-utils-1.0.8/support/nfs/fstab.c	1969-12-31 19:00:00.000000000 -05=
00
+++ nfs-utils-1.0.8-ag/support/nfs/fstab.c	2006-06-12 15:09:32.171861000 =
-0400
@@ -0,0 +1,487 @@
+/* 1999-02-22 Arkadiusz Mi=B6kiewicz <misiek@pld.ORG.PL>
+ * - added Native Language Support
+ * Sun Mar 21 1999 - Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ * - fixed strerr(errno) in gettext calls
+ *
+ * 2006-06-08 Amit Gud <agud@redhat.com>
+ * - Moved code to nfs-utils/support/nfs from util-linux/mount.
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <mntent.h>
+
+#include "fstab.h"
+#include "xcommon.h"
+#include "nfs_mntent.h"
+#include "nfs_paths.h"
+#include "nls.h"
+
+#define LOCK_TIMEOUT	10
+#define streq(s, t)	(strcmp ((s), (t)) =3D=3D 0)
+#define PROC_MOUNTS		"/proc/mounts"
+
+extern int verbose;
+
+/* Information about mtab. ------------------------------------*/
+static int have_mtab_info =3D 0;
+static int var_mtab_does_not_exist =3D 0;
+static int var_mtab_is_a_symlink =3D 0;
+
+static void
+get_mtab_info(void) {
+	struct stat mtab_stat;
+
+	if (!have_mtab_info) {
+		if (lstat(MOUNTED, &mtab_stat))
+			var_mtab_does_not_exist =3D 1;
+		else if (S_ISLNK(mtab_stat.st_mode))
+			var_mtab_is_a_symlink =3D 1;
+		have_mtab_info =3D 1;
+	}
+}
+
+int
+mtab_does_not_exist(void) {
+	get_mtab_info();
+	return var_mtab_does_not_exist;
+}
+
+static int
+mtab_is_a_symlink(void) {
+        get_mtab_info();
+        return var_mtab_is_a_symlink;
+}
+
+int
+mtab_is_writable() {
+	int fd;
+
+	/* Should we write to /etc/mtab upon an update?
+	   Probably not if it is a symlink to /proc/mounts, since that
+	   would create a file /proc/mounts in case the proc filesystem
+	   is not mounted. */
+	if (mtab_is_a_symlink())
+		return 0;
+
+	fd =3D open(MOUNTED, O_RDWR | O_CREAT, 0644);
+	if (fd >=3D 0) {
+		close(fd);
+		return 1;
+	} else
+		return 0;
+}
+
+/* Contents of mtab and fstab ---------------------------------*/
+
+struct mntentchn mounttable;
+static int got_mtab =3D 0;
+
+static void read_mounttable(void);
+
+struct mntentchn *
+mtab_head() {
+	if (!got_mtab)
+		read_mounttable();
+	return &mounttable;
+}
+
+static void
+my_free(const void *s) {
+	if (s)
+		free((void *) s);
+}
+
+static void
+discard_mntentchn(struct mntentchn *mc0) {
+	struct mntentchn *mc, *mc1;
+
+	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc1) {
+		mc1 =3D mc->nxt;
+		my_free(mc->m.mnt_fsname);
+		my_free(mc->m.mnt_dir);
+		my_free(mc->m.mnt_type);
+		my_free(mc->m.mnt_opts);
+		free(mc);
+	}
+}
+
+static void
+read_mntentchn(mntFILE *mfp, const char *fnam, struct mntentchn *mc0) {
+	struct mntentchn *mc =3D mc0;
+	nfs_mntent_t *mnt;
+
+	while ((mnt =3D nfs_getmntent(mfp)) !=3D NULL) {
+		if (!streq(mnt->mnt_type, MNTTYPE_IGNORE)) {
+			mc->nxt =3D (struct mntentchn *) xmalloc(sizeof(*mc));
+			mc->nxt->prev =3D mc;
+			mc =3D mc->nxt;
+			mc->m =3D *mnt;
+			mc->nxt =3D mc0;
+		}
+	}
+	mc0->prev =3D mc;
+	if (ferror(mfp->mntent_fp)) {
+		int errsv =3D errno;
+		nfs_error(_("warning: error reading %s: %s"),
+		      fnam, strerror (errsv));
+		mc0->nxt =3D mc0->prev =3D NULL;
+	}
+	nfs_endmntent(mfp);
+}
+
+/*
+ * Read /etc/mtab.  If that fails, try /proc/mounts.
+ * This produces a linked list. The list head mounttable is a dummy.
+ * Return 0 on success.
+ */
+static void
+read_mounttable() {
+        mntFILE *mfp;
+        const char *fnam;
+        struct mntentchn *mc =3D &mounttable;
+
+        got_mtab =3D 1;
+        mc->nxt =3D mc->prev =3D NULL;
+
+        fnam =3D MOUNTED;
+        mfp =3D nfs_setmntent (fnam, "r");
+        if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+                int errsv =3D errno;
+                fnam =3D PROC_MOUNTS;
+                mfp =3D nfs_setmntent (fnam, "r");
+                if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+                        nfs_error(_("warning: can't open %s: %s"),
+                              MOUNTED, strerror (errsv));
+                        return;
+                }
+                if (verbose)
+                        printf (_("mount: could not open %s - "
+                                  "using %s instead\n"),
+                                MOUNTED, PROC_MOUNTS);
+        }
+        read_mntentchn(mfp, fnam, mc);
+}
+
+/*
+ * Given the directory name NAME, and the place MCPREV we found it last =
time,
+ * try to find more occurrences.
+ */=20
+struct mntentchn *
+getmntdirbackward (const char *name, struct mntentchn *mcprev) {
+	struct mntentchn *mc, *mc0;
+
+	mc0 =3D mtab_head();
+	if (!mcprev)
+		mcprev =3D mc0;
+	for (mc =3D mcprev->prev; mc && mc !=3D mc0; mc =3D mc->prev)
+		if (streq(mc->m.mnt_dir, name))
+			return mc;
+	return NULL;
+}
+
+/*
+ * Given the device name NAME, and the place MCPREV we found it last tim=
e,
+ * try to find more occurrences.
+ */=20
+struct mntentchn *
+getmntdevbackward (const char *name, struct mntentchn *mcprev) {
+	struct mntentchn *mc, *mc0;
+
+	mc0 =3D mtab_head();
+	if (!mcprev)
+		mcprev =3D mc0;
+	for (mc =3D mcprev->prev; mc && mc !=3D mc0; mc =3D mc->prev)
+		if (streq(mc->m.mnt_fsname, name))
+			return mc;
+	return NULL;
+}
+
+/* Updating mtab ----------------------------------------------*/
+
+/* Flag for already existing lock file. */
+static int we_created_lockfile =3D 0;
+static int lockfile_fd =3D -1;
+
+/* Flag to indicate that signals have been set up. */
+static int signals_have_been_setup =3D 0;
+
+/* Ensure that the lock is released if we are interrupted.  */
+extern char *strsignal(int sig);	/* not always in <string.h> */
+
+static void
+handler (int sig) {
+     die(EX_USER, "%s", strsignal(sig));
+}
+
+static void
+setlkw_timeout (int sig) {
+     /* nothing, fcntl will fail anyway */
+}
+
+/* Remove lock file.  */
+void
+unlock_mtab (void) {
+	if (we_created_lockfile) {
+		close(lockfile_fd);
+		lockfile_fd =3D -1;
+		unlink (MOUNTED_LOCK);
+		we_created_lockfile =3D 0;
+	}
+}
+
+/* Create the lock file.
+   The lock file will be removed if we catch a signal or when we exit. *=
/
+/* The old code here used flock on a lock file /etc/mtab~ and deleted
+   this lock file afterwards. However, as rgooch remarks, that has a
+   race: a second mount may be waiting on the lock and proceed as
+   soon as the lock file is deleted by the first mount, and immediately
+   afterwards a third mount comes, creates a new /etc/mtab~, applies
+   flock to that, and also proceeds, so that the second and third mount
+   now both are scribbling in /etc/mtab.
+   The new code uses a link() instead of a creat(), where we proceed
+   only if it was us that created the lock, and hence we always have
+   to delete the lock afterwards. Now the use of flock() is in principle
+   superfluous, but avoids an arbitrary sleep(). */
+
+/* Where does the link point to? Obvious choices are mtab and mtab~~.
+   HJLu points out that the latter leads to races. Right now we use
+   mtab~.<pid> instead. Use 20 as upper bound for the length of %d. */
+#define MOUNTLOCK_LINKTARGET		MOUNTED_LOCK "%d"
+#define MOUNTLOCK_LINKTARGET_LTH	(sizeof(MOUNTED_LOCK)+20)
+
+void
+lock_mtab (void) {
+	int tries =3D 100000, i;
+	char linktargetfile[MOUNTLOCK_LINKTARGET_LTH];
+
+	at_die =3D unlock_mtab;
+
+	if (!signals_have_been_setup) {
+		int sig =3D 0;
+		struct sigaction sa;
+
+		sa.sa_handler =3D handler;
+		sa.sa_flags =3D 0;
+		sigfillset (&sa.sa_mask);
+ =20
+		while (sigismember (&sa.sa_mask, ++sig) !=3D -1
+		       && sig !=3D SIGCHLD) {
+			if (sig =3D=3D SIGALRM)
+				sa.sa_handler =3D setlkw_timeout;
+			else
+				sa.sa_handler =3D handler;
+			sigaction (sig, &sa, (struct sigaction *) 0);
+		}
+		signals_have_been_setup =3D 1;
+	}
+
+	sprintf(linktargetfile, MOUNTLOCK_LINKTARGET, getpid ());
+
+	i =3D open (linktargetfile, O_WRONLY|O_CREAT, 0);
+	if (i < 0) {
+		int errsv =3D errno;
+		/* linktargetfile does not exist (as a file)
+		   and we cannot create it. Read-only filesystem?
+		   Too many files open in the system?
+		   Filesystem full? */
+		die (EX_FILEIO, _("can't create lock file %s: %s "
+						  "(use -n flag to override)"),
+			 linktargetfile, strerror (errsv));
+	}
+	close(i);
+=09
+	/* Repeat until it was us who made the link */
+	while (!we_created_lockfile) {
+		struct flock flock;
+		int errsv, j;
+
+		j =3D link(linktargetfile, MOUNTED_LOCK);
+		errsv =3D errno;
+
+		if (j =3D=3D 0)
+			we_created_lockfile =3D 1;
+
+		if (j < 0 && errsv !=3D EEXIST) {
+			(void) unlink(linktargetfile);
+			die (EX_FILEIO, _("can't link lock file %s: %s "
+			     "(use -n flag to override)"),
+			     MOUNTED_LOCK, strerror (errsv));
+		}
+
+		lockfile_fd =3D open (MOUNTED_LOCK, O_WRONLY);
+
+		if (lockfile_fd < 0) {
+			int errsv =3D errno;
+			/* Strange... Maybe the file was just deleted? */
+			if (errno =3D=3D ENOENT && tries-- > 0) {
+				if (tries % 200 =3D=3D 0)
+					usleep(30);
+				continue;
+			}
+			(void) unlink(linktargetfile);
+			die (EX_FILEIO, _("can't open lock file %s: %s "
+			     "(use -n flag to override)"),
+			     MOUNTED_LOCK, strerror (errsv));
+		}
+
+		flock.l_type =3D F_WRLCK;
+		flock.l_whence =3D SEEK_SET;
+		flock.l_start =3D 0;
+		flock.l_len =3D 0;
+
+		if (j =3D=3D 0) {
+			/* We made the link. Now claim the lock. */
+			if (fcntl (lockfile_fd, F_SETLK, &flock) =3D=3D -1) {
+				if (verbose) {
+				    int errsv =3D errno;
+				    printf(_("Can't lock lock file %s: %s\n"),
+					   MOUNTED_LOCK, strerror (errsv));
+				}
+				/* proceed anyway */
+			}
+			(void) unlink(linktargetfile);
+		} else {
+			static int tries =3D 0;
+
+			/* Someone else made the link. Wait. */
+			alarm(LOCK_TIMEOUT);
+			if (fcntl (lockfile_fd, F_SETLKW, &flock) =3D=3D -1) {
+				int errsv =3D errno;
+				(void) unlink(linktargetfile);
+				die (EX_FILEIO, _("can't lock lock file %s: %s"),
+				     MOUNTED_LOCK, (errno =3D=3D EINTR) ?
+				     _("timed out") : strerror (errsv));
+			}
+			alarm(0);
+			/* Limit the number of iterations - maybe there
+			   still is some old /etc/mtab~ */
+			++tries;
+			if (tries % 200 =3D=3D 0)
+			   usleep(30);
+			if (tries > 100000) {
+				(void) unlink(linktargetfile);
+				close(lockfile_fd);
+				die (EX_FILEIO, _("Cannot create link %s\n"
+						  "Perhaps there is a stale lock file?\n"),
+					 MOUNTED_LOCK);
+ 			}
+			close(lockfile_fd);
+		}
+	}
+}
+
+/*
+ * Update the mtab.
+ *  Used by umount with null INSTEAD: remove the last DIR entry.
+ *  Used by mount upon a remount: update option part,
+ *   and complain if a wrong device or type was given.
+ *   [Note that often a remount will be a rw remount of /
+ *    where there was no entry before, and we'll have to believe
+ *    the values given in INSTEAD.]
+ */
+
+void
+update_mtab (const char *dir, nfs_mntent_t *instead) {
+	mntFILE *mfp, *mftmp;
+	const char *fnam =3D MOUNTED;
+	struct mntentchn mtabhead;	/* dummy */
+	struct mntentchn *mc, *mc0, *absent =3D NULL;
+
+	if (mtab_does_not_exist() || !mtab_is_writable())
+		return;
+
+	lock_mtab();
+
+	/* having locked mtab, read it again */
+	mc0 =3D mc =3D &mtabhead;
+	mc->nxt =3D mc->prev =3D NULL;
+
+	mfp =3D nfs_setmntent(fnam, "r");
+	if (mfp =3D=3D NULL || mfp->mntent_fp =3D=3D NULL) {
+		int errsv =3D errno;
+		nfs_error (_("cannot open %s (%s) - mtab not updated"),
+		       fnam, strerror (errsv));
+		goto leave;
+	}
+
+	read_mntentchn(mfp, fnam, mc);
+
+	/* find last occurrence of dir */
+	for (mc =3D mc0->prev; mc && mc !=3D mc0; mc =3D mc->prev)
+		if (streq(mc->m.mnt_dir, dir))
+			break;
+	if (mc && mc !=3D mc0) {
+		if (instead =3D=3D NULL) {
+			/* An umount - remove entry */
+			if (mc && mc !=3D mc0) {
+				mc->prev->nxt =3D mc->nxt;
+				mc->nxt->prev =3D mc->prev;
+				free(mc);
+			}
+		} else {
+			/* A remount */
+			mc->m.mnt_opts =3D instead->mnt_opts;
+		}
+	} else if (instead) {
+		/* not found, add a new entry */
+		absent =3D xmalloc(sizeof(*absent));
+		absent->m =3D *instead;
+		absent->nxt =3D mc0;
+		absent->prev =3D mc0->prev;
+		mc0->prev =3D absent;
+		if (mc0->nxt =3D=3D NULL)
+			mc0->nxt =3D absent;
+	}
+
+	/* write chain to mtemp */
+	mftmp =3D nfs_setmntent (MOUNTED_TEMP, "w");
+	if (mftmp =3D=3D NULL || mftmp->mntent_fp =3D=3D NULL) {
+		int errsv =3D errno;
+		nfs_error (_("cannot open %s (%s) - mtab not updated"),
+		       MOUNTED_TEMP, strerror (errsv));
+		goto leave;
+	}
+
+	for (mc =3D mc0->nxt; mc && mc !=3D mc0; mc =3D mc->nxt) {
+		if (nfs_addmntent(mftmp, &(mc->m)) =3D=3D 1) {
+			int errsv =3D errno;
+			die (EX_FILEIO, _("error writing %s: %s"),
+			     MOUNTED_TEMP, strerror (errsv));
+		}
+	}
+
+	discard_mntentchn(mc0);
+
+	if (fchmod (fileno (mftmp->mntent_fp),
+		    S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) < 0) {
+		int errsv =3D errno;
+		fprintf(stderr, _("error changing mode of %s: %s\n"),
+			MOUNTED_TEMP, strerror (errsv));
+	}
+	nfs_endmntent (mftmp);
+
+	{ /*
+	   * If mount is setuid and some non-root user mounts sth,
+	   * then mtab.tmp might get the group of this user. Copy uid/gid
+	   * from the present mtab before renaming.
+	   */
+	    struct stat sbuf;
+	    if (stat (MOUNTED, &sbuf) =3D=3D 0)
+		chown (MOUNTED_TEMP, sbuf.st_uid, sbuf.st_gid);
+	}
+
+	/* rename mtemp to mtab */
+	if (rename (MOUNTED_TEMP, MOUNTED) < 0) {
+		int errsv =3D errno;
+		fprintf(stderr, _("can't rename %s to %s: %s\n"),
+			MOUNTED_TEMP, MOUNTED, strerror(errsv));
+	}
+
+ leave:
+	unlock_mtab();
+}
diff -uprN nfs-utils-1.0.8/support/nfs/Makefile.am nfs-utils-1.0.8-ag/sup=
port/nfs/Makefile.am
--- nfs-utils-1.0.8/support/nfs/Makefile.am	2005-12-19 23:12:44.000000000=
 -0500
+++ nfs-utils-1.0.8-ag/support/nfs/Makefile.am	2006-06-12 15:09:32.175861=
000 -0400
@@ -2,9 +2,9 @@
=20
 noinst_LIBRARIES =3D libnfs.a
 libnfs_a_SOURCES =3D exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
-		   xlog.c xmalloc.c wildmat.c nfssvc.c nfsclient.c \
+		   xlog.c xcommon.c wildmat.c nfssvc.c nfsclient.c \
 		   nfsexport.c getfh.c nfsctl.c lockdsvc.c \
-		   svc_socket.c cacheio.c closeall.c
+		   svc_socket.c cacheio.c closeall.c conn.c fstab.c nfs_mntent.c
=20
 MAINTAINERCLEANFILES =3D Makefile.in
=20
diff -uprN nfs-utils-1.0.8/support/nfs/nfs_mntent.c nfs-utils-1.0.8-ag/su=
pport/nfs/nfs_mntent.c
--- nfs-utils-1.0.8/support/nfs/nfs_mntent.c	1969-12-31 19:00:00.00000000=
0 -0500
+++ nfs-utils-1.0.8-ag/support/nfs/nfs_mntent.c	2006-06-12 15:09:32.18186=
1000 -0400
@@ -0,0 +1,226 @@
+/* Private version of the libc *mntent() routines. */
+/* Note slightly different prototypes. */
+
+/* 1999-02-22 Arkadiusz Mi=B6kiewicz <misiek@pld.ORG.PL>
+ * - added Native Language Support
+ *
+ * 2006-06-08 Amit Gud <agud@redhat.com>
+ * - Moved to nfs-utils/support/nfs from util-linux/mount
+ */
+
+#include <stdio.h>
+#include <string.h>		/* for index */
+#include <ctype.h>		/* for isdigit */
+#include <sys/stat.h>		/* for umask */
+
+#include "nfs_mntent.h"
+#include "nls.h"
+#include "xcommon.h"
+
+/* Unfortunately the classical Unix /etc/mtab and /etc/fstab
+   do not handle directory names containing spaces.
+   Here we mangle them, replacing a space by \040.
+   What do other Unices do? */
+
+static unsigned char need_escaping[] =3D { ' ', '\t', '\n', '\\' };
+
+static char *
+mangle(const unsigned char *s) {
+	char *ss, *sp;
+	int n;
+
+	n =3D strlen(s);
+	ss =3D sp =3D xmalloc(4*n+1);
+	while(1) {
+		for (n =3D 0; n < sizeof(need_escaping); n++) {
+			if (*s =3D=3D need_escaping[n]) {
+				*sp++ =3D '\\';
+				*sp++ =3D '0' + ((*s & 0300) >> 6);
+				*sp++ =3D '0' + ((*s & 070) >> 3);
+				*sp++ =3D '0' + (*s & 07);
+				goto next;
+			}
+		}
+		*sp++ =3D *s;
+		if (*s =3D=3D 0)
+			break;
+	next:
+		s++;
+	}
+	return ss;
+}
+
+static int
+is_space_or_tab (char c) {
+	return (c =3D=3D ' ' || c =3D=3D '\t');
+}
+
+static char *
+skip_spaces(char *s) {
+	while (is_space_or_tab(*s))
+		s++;
+	return s;
+}
+
+static char *
+skip_nonspaces(char *s) {
+	while (*s && !is_space_or_tab(*s))
+		s++;
+	return s;
+}
+
+#define isoctal(a) (((a) & ~7) =3D=3D '0')
+
+/* returns malloced pointer - no more strdup required */
+static char *
+unmangle(char *s) {
+	char *ret, *ss, *sp;
+
+	ss =3D skip_nonspaces(s);
+	ret =3D sp =3D xmalloc(ss-s+1);
+	while(s !=3D ss) {
+		if (*s =3D=3D '\\' && isoctal(s[1]) && isoctal(s[2]) && isoctal(s[3]))=
 {
+			*sp++ =3D 64*(s[1] & 7) + 8*(s[2] & 7) + (s[3] & 7);
+			s +=3D 4;
+		} else
+			*sp++ =3D *s++;
+	}
+	*sp =3D 0;
+	return ret;
+}
+
+/*
+ * fstat'ing the file and allocating a buffer holding all of it
+ * may be a bad idea: if the file is /proc/mounts, the stat
+ * returns 0.
+ * (On the other hand, mangling and unmangling is meaningless
+ *  for /proc/mounts.)
+ */
+
+mntFILE *
+nfs_setmntent (const char *file, char *mode) {
+	mntFILE *mfp =3D xmalloc(sizeof(*mfp));
+	mode_t old_umask =3D umask(077);
+
+	mfp->mntent_fp =3D fopen(file, mode);
+	umask(old_umask);
+	mfp->mntent_file =3D xstrdup(file);
+	mfp->mntent_errs =3D (mfp->mntent_fp =3D=3D NULL);
+	mfp->mntent_softerrs =3D 0;
+	mfp->mntent_lineno =3D 0;
+	return mfp;
+}
+
+void
+nfs_endmntent (mntFILE *mfp) {
+	if (mfp) {
+		if (mfp->mntent_fp)
+			fclose(mfp->mntent_fp);
+		if (mfp->mntent_file)
+			free(mfp->mntent_file);
+		free(mfp);
+	}
+}
+
+int
+nfs_addmntent (mntFILE *mfp, nfs_mntent_t *mnt) {
+	char *m1, *m2, *m3, *m4;
+	int res;
+
+	if (fseek (mfp->mntent_fp, 0, SEEK_END))
+		return 1;			/* failure */
+
+	m1 =3D mangle(mnt->mnt_fsname);
+	m2 =3D mangle(mnt->mnt_dir);
+	m3 =3D mangle(mnt->mnt_type);
+	m4 =3D mangle(mnt->mnt_opts);
+
+	res =3D fprintf (mfp->mntent_fp, "%s %s %s %s %d %d\n",
+		       m1, m2, m3, m4, mnt->mnt_freq, mnt->mnt_passno);
+
+	free(m1);
+	free(m2);
+	free(m3);
+	free(m4);
+	return (res < 0) ? 1 : 0;
+}
+
+/* Read the next entry from the file fp. Stop reading at an incorrect en=
try. */
+nfs_mntent_t *
+nfs_getmntent (mntFILE *mfp) {
+	static char buf[4096];
+	static nfs_mntent_t me;
+	char *s;
+
+ again:
+	if (mfp->mntent_errs || mfp->mntent_softerrs >=3D ERR_MAX)
+		return NULL;
+
+	/* read the next non-blank non-comment line */
+	do {
+		if (fgets (buf, sizeof(buf), mfp->mntent_fp) =3D=3D NULL)
+			return NULL;
+
+		mfp->mntent_lineno++;
+		s =3D index (buf, '\n');
+		if (s =3D=3D NULL) {
+			/* Missing final newline?  Otherwise extremely */
+			/* long line - assume file was corrupted */
+			if (feof(mfp->mntent_fp)) {
+				fprintf(stderr, _("[mntent]: warning: no final "
+					"newline at the end of %s\n"),
+					mfp->mntent_file);
+				s =3D index (buf, 0);
+			} else {
+				mfp->mntent_errs =3D 1;
+				goto err;
+			}
+		}
+		*s =3D 0;
+		if (--s >=3D buf && *s =3D=3D '\r')
+			*s =3D 0;
+		s =3D skip_spaces(buf);
+	} while (*s =3D=3D '\0' || *s =3D=3D '#');
+
+	me.mnt_fsname =3D unmangle(s);
+	s =3D skip_nonspaces(s);
+	s =3D skip_spaces(s);
+	me.mnt_dir =3D unmangle(s);
+	s =3D skip_nonspaces(s);
+	s =3D skip_spaces(s);
+	me.mnt_type =3D unmangle(s);
+	s =3D skip_nonspaces(s);
+	s =3D skip_spaces(s);
+	me.mnt_opts =3D unmangle(s);
+	s =3D skip_nonspaces(s);
+	s =3D skip_spaces(s);
+
+	if (isdigit(*s)) {
+		me.mnt_freq =3D atoi(s);
+		while(isdigit(*s)) s++;
+	} else
+		me.mnt_freq =3D 0;
+	if(*s && !is_space_or_tab(*s))
+		goto err;
+
+	s =3D skip_spaces(s);
+	if(isdigit(*s)) {
+		me.mnt_passno =3D atoi(s);
+		while(isdigit(*s)) s++;
+	} else
+		me.mnt_passno =3D 0;
+	if(*s && !is_space_or_tab(*s))
+		goto err;
+
+	/* allow more stuff, e.g. comments, on this line */
+
+	return &me;
+
+ err:
+	mfp->mntent_softerrs++;
+	fprintf(stderr, _("[mntent]: line %d in %s is bad%s\n"),
+		mfp->mntent_lineno, mfp->mntent_file,
+		(mfp->mntent_errs || mfp->mntent_softerrs >=3D ERR_MAX) ?
+		_("; rest of file ignored") : "");
+	goto again;
+}
diff -uprN nfs-utils-1.0.8/support/nfs/xcommon.c nfs-utils-1.0.8-ag/suppo=
rt/nfs/xcommon.c
--- nfs-utils-1.0.8/support/nfs/xcommon.c	1969-12-31 19:00:00.000000000 -=
0500
+++ nfs-utils-1.0.8-ag/support/nfs/xcommon.c	2006-06-12 15:09:32.18786100=
0 -0400
@@ -0,0 +1,185 @@
+/*
+ * xcommon.c - various functions put together to avoid basic error check=
ing.
+ *
+ * added fcntl locking by Kjetil T. (kjetilho@math.uio.no) - aeb, 950927
+ *
+ * 1999-02-22 Arkadiusz Mi=B6kiewicz <misiek@pld.ORG.PL>
+ * - added Native Language Support
+ *
+ * 2006-06-06 Amit Gud <agud@redhat.com>
+ * - Moved code snippets here from mount/sundries.c of util-linux
+ *   and merged code from support/nfs/xmalloc.c by Olaf Kirch <okir@mona=
d.swb.de> here.
+ */
+
+#include <unistd.h>
+#include <ctype.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include "xcommon.h"
+#include "nls.h"	/* _() */
+
+void (*at_die)(void ) =3D NULL;
+
+char *
+xstrndup (const char *s, int n) {
+     char *t;
+
+     if (s =3D=3D NULL)
+	  die (EX_SOFTWARE, _("bug in xstrndup call"));
+
+     t =3D xmalloc(n+1);
+     strncpy(t,s,n);
+     t[n] =3D 0;
+
+     return t;
+}
+
+char *
+xstrconcat2 (const char *s, const char *t) {
+     char *res;
+
+     if (!s) s =3D "";
+     if (!t) t =3D "";
+     res =3D xmalloc(strlen(s) + strlen(t) + 1);
+     strcpy(res, s);
+     strcat(res, t);
+     return res;
+}
+
+/* frees its first arg - typical use: s =3D xstrconcat3(s,t,u); */
+char *
+xstrconcat3 (const char *s, const char *t, const char *u) {
+     char *res;
+
+     if (!s) s =3D "";
+     if (!t) t =3D "";
+     if (!u) u =3D "";
+     res =3D xmalloc(strlen(s) + strlen(t) + strlen(u) + 1);
+     strcpy(res, s);
+     strcat(res, t);
+     strcat(res, u);
+     free((void *) s);
+     return res;
+}
+
+/* frees its first arg - typical use: s =3D xstrconcat4(s,t,u,v); */
+char *
+xstrconcat4 (const char *s, const char *t, const char *u, const char *v)=
 {
+     char *res;
+
+     if (!s) s =3D "";
+     if (!t) t =3D "";
+     if (!u) u =3D "";
+     if (!v) v =3D "";
+     res =3D xmalloc(strlen(s) + strlen(t) + strlen(u) + strlen(v) + 1);
+     strcpy(res, s);
+     strcat(res, t);
+     strcat(res, u);
+     strcat(res, v);
+     free((void *) s);
+     return res;
+}
+
+/* Non-fatal error.  Print message and return.  */
+/* (print the message in a single printf, in an attempt
+    to avoid mixing output of several threads) */
+void
+nfs_error (const char *fmt, ...) {
+     va_list args;
+     char *fmt2;
+
+     fmt2 =3D xstrconcat2 (fmt, "\n");
+     va_start (args, fmt);
+     vfprintf (stderr, fmt2, args);
+     va_end (args);
+     free (fmt2);
+}
+
+/* Make a canonical pathname from PATH.  Returns a freshly malloced stri=
ng.
+   It is up the *caller* to ensure that the PATH is sensible.  i.e.
+   canonicalize ("/dev/fd0/.") returns "/dev/fd0" even though ``/dev/fd0=
/.''
+   is not a legal pathname for ``/dev/fd0''.  Anything we cannot parse
+   we return unmodified.   */
+char *canonicalize (const char *path) {
+	char canonical[PATH_MAX+2];
+
+	if (path =3D=3D NULL)
+		return NULL;
+
+#if 1
+	if (streq(path, "none") ||
+	    streq(path, "proc") ||
+	    streq(path, "devpts"))
+		return xstrdup(path);
+#endif
+	if (realpath (path, canonical))
+		return xstrdup(canonical);
+
+	return xstrdup(path);
+}
+
+/* Fatal error.  Print message and exit.  */
+void
+die(int err, const char *fmt, ...) {
+	va_list args;
+
+	va_start(args, fmt);
+	vfprintf(stderr, fmt, args);
+	fprintf(stderr, "\n");
+	va_end(args);
+
+	if (at_die)
+		(*at_die)();
+
+	exit(err);
+}
+
+static void
+die_if_null(void *t) {
+	if (t =3D=3D NULL)
+		die(EX_SYSERR, _("not enough memory"));
+}
+
+void *
+xmalloc (size_t size) {
+	void *t;
+
+	if (size =3D=3D 0)
+		return NULL;
+
+	t =3D malloc(size);
+	die_if_null(t);
+
+	return t;
+}
+
+void *
+xrealloc (void *p, size_t size) {
+	void *t;
+
+	t =3D realloc(p, size);
+	die_if_null(t);
+
+	return t;
+}
+
+void
+xfree(void *ptr)
+{
+	free(ptr);
+}
+
+char *
+xstrdup (const char *s) {
+	char *t;
+
+	if (s =3D=3D NULL)
+		return NULL;
+
+	t =3D strdup(s);
+	die_if_null(t);
+
+	return t;
+}
diff -uprN nfs-utils-1.0.8/support/nfs/xmalloc.c nfs-utils-1.0.8-ag/suppo=
rt/nfs/xmalloc.c
--- nfs-utils-1.0.8/support/nfs/xmalloc.c	2005-12-19 23:12:44.000000000 -=
0500
+++ nfs-utils-1.0.8-ag/support/nfs/xmalloc.c	1969-12-31 19:00:00.00000000=
0 -0500
@@ -1,50 +0,0 @@
-/*
- * support/nfs/xmalloc.c
- *
- * malloc with NULL checking.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <stdlib.h>
-#include <string.h>
-#include "xmalloc.h"
-#include "xlog.h"
-
-void *
-xmalloc(size_t size)
-{
-	void	*ptr;
-
-	if (!(ptr =3D malloc(size)))
-		xlog(L_FATAL, "malloc: out of memory");
-	return ptr;
-}
-
-void *
-xrealloc(void *ptr, size_t size)
-{
-	if (!(ptr =3D realloc(ptr, size)))
-		xlog(L_FATAL, "realloc: out of memory");
-	return ptr;
-}
-
-void
-xfree(void *ptr)
-{
-	free(ptr);
-}
-
-char *
-xstrdup(const char *str)
-{
-	char	*ret;
-
-	if (!(ret =3D strdup(str)))
-		xlog(L_FATAL, "strdup: out of memory");
-	return ret;
-}

--------------000502050306070705090704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--------------000502050306070705090704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000502050306070705090704--
