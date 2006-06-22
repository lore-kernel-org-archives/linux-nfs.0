From: Amit Gud <gud@eth.net>
Subject: [PATCH] Merge nfsmount.x and mount.x into mount.x
Date: Thu, 22 Jun 2006 12:49:24 -0400
Message-ID: <449ACA14.7080604@eth.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070903030705050400060306"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtSJa-0001zG-Et
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 09:46:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FtSJY-0005XJ-Ov
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 09:45:58 -0700
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
--------------070903030705050400060306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------070903030705050400060306
Content-Type: text/plain;
 name="x-files-merge.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x-files-merge.patch"

Merge utils/mount/nfsmount.x and support/export/mount.x into support/export/mount.x.

Signed-off-by: Amit Gud <agud@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

---
diff -uprN -X dontdiff nfs-utils/utils/mount/Makefile.am nfs-utils-ag/utils/mount/Makefile.am
--- nfs-utils/utils/mount/Makefile.am	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/mount/Makefile.am	2006-06-22 11:08:02.000000000 -0400
@@ -2,48 +2,16 @@
 
 man8_MANS	= mount.nfs.man umount.nfs.man
 
-RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
-
-GENFILES_CLNT	= nfsmount_clnt.c
-GENFILES_XDR	= nfsmount_xdr.c
-GENFILES_H	= nfsmount.h
-
-GENFILES	= $(GENFILES_CLNT) $(GENFILES_XDR) $(GENFILES_H)
-
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS)
 mount_nfs_SOURCES = mount.c nfsmount.c nfs4mount.c nfsumount.c \
-		  nfsmount_xdr.c mount_constants.h nfs4_mount.h nfsmount.h \
-		  nfs_mount4.h
-
-BUILT_SOURCES = $(GENFILES)
-mount_nfs_LDADD = ../../support/nfs/libnfs.a
-
-
-$(RPCGEN):
-	make -C ../../tools/rpcgen all
-
-$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
-	test -f $@ && rm -rf $@ || true
-	$(RPCGEN) -l -o $@ $<
-
-$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
-	test -f $@ && rm -rf $@ || true
-	$(RPCGEN) -m -o $@ $<
-
-$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
-	test -f $@ && rm -rf $@ || true
-	$(RPCGEN) -c -o $@ $<
-
-$(GENFILES_H): %.h: %.x $(RPCGEN)
-	test -f $@ && rm -rf $@ || true
-	$(RPCGEN) -h -o $@ $<
+		  mount_constants.h nfs4_mount.h nfs_mount4.h
 
+mount_nfs_LDADD = ../../support/nfs/libnfs.a \
+		  ../../support/export/libexport.a
 
 MAINTAINERCLEANFILES = Makefile.in
 
-CLEANFILES = $(GENFILES)
-
 install-exec-hook:
 	(cd $(DESTDIR)$(sbindir) && \
 	  ln -sf $(sbin_PROGRAMS) mount.nfs4 && \
diff -uprN -X dontdiff nfs-utils/utils/mount/mount.c nfs-utils-ag/utils/mount/mount.c
--- nfs-utils/utils/mount/mount.c	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/mount/mount.c	2006-06-22 12:37:27.000000000 -0400
@@ -37,7 +37,7 @@
 #include "nfs_mount.h"
 #include "nfs4_mount.h"
 #include "nfsumount.h"
-#include "nfsmount.h"
+#include "mount.h"
 
 char *progname;
 int nomtab;
diff -uprN -X dontdiff nfs-utils/utils/mount/nfsmount.c nfs-utils-ag/utils/mount/nfsmount.c
--- nfs-utils/utils/mount/nfsmount.c	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/mount/nfsmount.c	2006-06-22 11:07:14.000000000 -0400
@@ -59,7 +59,7 @@
 
 #include "conn.h"
 #include "xcommon.h"
-#include "nfsmount.h"
+#include "mount.h"
 #include "nfsumount.h"
 #include "nfs_mount.h"
 #include "mount_constants.h"
@@ -1084,11 +1084,11 @@ nfsmount(const char *spec, const char *n
 		}
 #if NFS_MOUNT_VERSION >= 5
 		mountres = &mntres.nfsv3.mountres3_u.mountinfo;
-		i = mountres->auth_flavours.auth_flavours_len;
+		i = mountres->auth_flavors.auth_flavors_len;
 		if (i <= 0) 
-			goto noauth_flavours;
+			goto noauth_flavors;
 
-		flavor = mountres->auth_flavours.auth_flavours_val;
+		flavor = mountres->auth_flavors.auth_flavors_val;
 		while (--i >= 0) {
 			if (flavor[i] == data.pseudoflavor)
 				yum = 1;
@@ -1106,7 +1106,7 @@ nfsmount(const char *spec, const char *n
 			nfs_call_umount(&mnt_server, &dirname);
 			goto fail;
 		}
-noauth_flavours:
+noauth_flavors:
 #endif
 		fhandle = &mntres.nfsv3.mountres3_u.mountinfo.fhandle;
 		memset(data.old_root.data, 0, NFS_FHSIZE);
diff -uprN -X dontdiff nfs-utils/utils/mount/nfsmount.x nfs-utils-ag/utils/mount/nfsmount.x
--- nfs-utils/utils/mount/nfsmount.x	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/mount/nfsmount.x	1969-12-31 19:00:00.000000000 -0500
@@ -1,336 +0,0 @@
-%/*
-% * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
-% * unrestricted use provided that this legend is included on all tape
-% * media and as a part of the software program in whole or part.  Users
-% * may copy or modify Sun RPC without charge, but are not authorized
-% * to license or distribute it to anyone else except as part of a product or
-% * program developed by the user or with the express written consent of
-% * Sun Microsystems, Inc.
-% *
-% * SUN RPC IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING THE
-% * WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
-% * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
-% *
-% * Sun RPC is provided with no support and without any obligation on the
-% * part of Sun Microsystems, Inc. to assist in its use, correction,
-% * modification or enhancement.
-% *
-% * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
-% * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY SUN RPC
-% * OR ANY PART THEREOF.
-% *
-% * In no event will Sun Microsystems, Inc. be liable for any lost revenue
-% * or profits or other special, indirect and consequential damages, even if
-% * Sun has been advised of the possibility of such damages.
-% *
-% * Sun Microsystems, Inc.
-% * 2550 Garcia Avenue
-% * Mountain View, California  94043
-% */
-
-%/*
-% * Copyright (c) 1985, 1990 by Sun Microsystems, Inc.
-% */
-%
-%/* from @(#)mount.x	1.3 91/03/11 TIRPC 1.0 */
-
-/*
- * Protocol description for the mount program
- */
-
-#ifdef RPC_HDR
-%#ifndef _rpcsvc_mount_h
-%#define _rpcsvc_mount_h
-#endif
-
-#ifdef RPC_CLNT
-%#include <string.h>		/* for memset() */
-#endif
-%#include <asm/types.h>
-
-const MNTPATHLEN = 1024;	/* maximum bytes in a pathname argument */
-const MNTNAMLEN = 255;		/* maximum bytes in a name argument */
-const FHSIZE = 32;		/* size in bytes of a file handle */
-const FHSIZE3 = 64;		/* size in bytes of a file handle */
-
-/*
- * The fhandle is the file handle that the server passes to the client.
- * All file operations are done using the file handles to refer to a file
- * or a directory. The file handle can contain whatever information the
- * server needs to distinguish an individual file.
- */
-typedef opaque fhandle[FHSIZE];	
-typedef opaque fhandle3<FHSIZE3>;
-
-enum mountstat3 {
-	MNT_OK			= 0,		/* no error */
-	MNT3ERR_PERM		= 1,		/* not owner */
-	MNT3ERR_NOENT		= 2,		/* No such file or directory */
-	MNT3ERR_IO		= 5,		/* I/O error */
-	MNT3ERR_ACCES		= 13,		/* Permission denied */
-	MNT3ERR_NOTDIR		= 20,		/* Not a directory */
-	MNT3ERR_INVAL		= 22,		/* Invalid argument */
-	MNT3ERR_NAMETOOLONG	= 63,		/* File name too long */
-	MNT3ERR_NOTSUPP		= 10004,	/* Operation not supported */
-	MNT3ERR_SERVERFAULT	= 10006		/* A failure on the server */
-};
-
-/*
- * If a status of zero is returned, the call completed successfully, and 
- * a file handle for the directory follows. A non-zero status indicates
- * some sort of error. The status corresponds with UNIX error numbers.
- */
-union fhstatus switch (unsigned fhs_status) {
-case 0:
-	fhandle fhs_fhandle;
-default:
-	void;
-};
-
-struct mountres3_ok {
-	fhandle3 fhandle;
-	int auth_flavours<>;
-};
-
-union mountres3 switch (mountstat3 fhs_status) {
-case MNT_OK:
-	mountres3_ok mountinfo;
-default:
-	void;
-};
-
-/*
- * The type dirpath is the pathname of a directory
- */
-typedef string dirpath<MNTPATHLEN>;
-
-/*
- * The type name is used for arbitrary names (hostnames, groupnames)
- */
-typedef string name<MNTNAMLEN>;
-
-/*
- * A list of who has what mounted
- */
-typedef struct mountbody *mountlist;
-struct mountbody {
-	name ml_hostname;
-	dirpath ml_directory;
-	mountlist ml_next;
-};
-
-/*
- * A list of netgroups
- */
-typedef struct groupnode *groups;
-struct groupnode {
-	name gr_name;
-	groups gr_next;
-};
-
-/*
- * A list of what is exported and to whom
- */
-typedef struct exportnode *exports;
-struct exportnode {
-	dirpath ex_dir;
-	groups ex_groups;
-	exports ex_next;
-};
-
-/*
- * POSIX pathconf information
- */
-struct ppathcnf {
-	int	pc_link_max;	/* max links allowed */
-	short	pc_max_canon;	/* max line len for a tty */
-	short	pc_max_input;	/* input a tty can eat all at once */
-	short	pc_name_max;	/* max file name length (dir entry) */
-	short	pc_path_max;	/* max path name length (/x/y/x/.. ) */
-	short	pc_pipe_buf;	/* size of a pipe (bytes) */
-	u_char	pc_vdisable;	/* safe char to turn off c_cc[i] */
-	char	pc_xxx;		/* alignment padding; cc_t == char */
-	short	pc_mask[2];	/* validity and boolean bits */
-};
-
-program MOUNTPROG {
-	/*
-	 * Version one of the mount protocol communicates with version two
-	 * of the NFS protocol. The only connecting point is the fhandle 
-	 * structure, which is the same for both protocols.
-	 */
-	version MOUNTVERS {
-		/*
-		 * Does no work. It is made available in all RPC services
-		 * to allow server reponse testing and timing
-		 */
-		void
-		MOUNTPROC_NULL(void) = 0;
-
-		/*	
-		 * If fhs_status is 0, then fhs_fhandle contains the
-	 	 * file handle for the directory. This file handle may
-		 * be used in the NFS protocol. This procedure also adds
-		 * a new entry to the mount list for this client mounting
-		 * the directory.
-		 * Unix authentication required.
-		 */
-		fhstatus 
-		MOUNTPROC_MNT(dirpath) = 1;
-
-		/*
-		 * Returns the list of remotely mounted filesystems. The 
-		 * mountlist contains one entry for each hostname and 
-		 * directory pair.
-		 */
-		mountlist
-		MOUNTPROC_DUMP(void) = 2;
-
-		/*
-		 * Removes the mount list entry for the directory
-		 * Unix authentication required.
-		 */
-		void
-		MOUNTPROC_UMNT(dirpath) = 3;
-
-		/*
-		 * Removes all of the mount list entries for this client
-		 * Unix authentication required.
-		 */
-		void
-		MOUNTPROC_UMNTALL(void) = 4;
-
-		/*
-		 * Returns a list of all the exported filesystems, and which
-		 * machines are allowed to import it.
-		 */
-		exports
-		MOUNTPROC_EXPORT(void)  = 5;
-
-		/*
-		 * Identical to MOUNTPROC_EXPORT above
-		 */
-		exports
-		MOUNTPROC_EXPORTALL(void) = 6;
-	} = 1;
-
-	/*
-	 * Version two of the mount protocol communicates with version two
-	 * of the NFS protocol.
-	 * The only difference from version one is the addition of a POSIX
-	 * pathconf call.
-	 */
-	version MOUNTVERS_POSIX {
-		/*
-		 * Does no work. It is made available in all RPC services
-		 * to allow server reponse testing and timing
-		 */
-		void
-		MOUNTPROC_NULL(void) = 0;
-
-		/*	
-		 * If fhs_status is 0, then fhs_fhandle contains the
-	 	 * file handle for the directory. This file handle may
-		 * be used in the NFS protocol. This procedure also adds
-		 * a new entry to the mount list for this client mounting
-		 * the directory.
-		 * Unix authentication required.
-		 */
-		fhstatus 
-		MOUNTPROC_MNT(dirpath) = 1;
-
-		/*
-		 * Returns the list of remotely mounted filesystems. The 
-		 * mountlist contains one entry for each hostname and 
-		 * directory pair.
-		 */
-		mountlist
-		MOUNTPROC_DUMP(void) = 2;
-
-		/*
-		 * Removes the mount list entry for the directory
-		 * Unix authentication required.
-		 */
-		void
-		MOUNTPROC_UMNT(dirpath) = 3;
-
-		/*
-		 * Removes all of the mount list entries for this client
-		 * Unix authentication required.
-		 */
-		void
-		MOUNTPROC_UMNTALL(void) = 4;
-
-		/*
-		 * Returns a list of all the exported filesystems, and which
-		 * machines are allowed to import it.
-		 */
-		exports
-		MOUNTPROC_EXPORT(void)  = 5;
-
-		/*
-		 * Identical to MOUNTPROC_EXPORT above
-		 */
-		exports
-		MOUNTPROC_EXPORTALL(void) = 6;
-
-		/*
-		 * POSIX pathconf info (Sun hack)
-		 */
-		ppathcnf
-		MOUNTPROC_PATHCONF(dirpath) = 7;
-	} = 2;
-	version MOUNT_V3 {
-		/*
-		 * Does no work. It is made available in all RPC services
-		 * to allow server reponse testing and timing
-		 */
-		void
-		MOUNTPROC3_NULL(void) = 0;
-
-		/*	
-		 * If fhs_status is 0, then fhs_fhandle contains the
-	 	 * file handle for the directory. This file handle may
-		 * be used in the NFS protocol. This procedure also adds
-		 * a new entry to the mount list for this client mounting
-		 * the directory.
-		 * Unix authentication required.
-		 */
-		mountres3
-		MOUNTPROC3_MNT(dirpath) = 1;
-
-		/*
-		 * Returns the list of remotely mounted filesystems. The 
-		 * mountlist contains one entry for each hostname and 
-		 * directory pair.
-		 */
-		mountlist
-		MOUNTPROC3_DUMP(void) = 2;
-
-		/*
-		 * Removes the mount list entry for the directory
-		 * Unix authentication required.
-		 */
-		void
-		MOUNTPROC3_UMNT(dirpath) = 3;
-
-		/*
-		 * Removes all of the mount list entries for this client
-		 * Unix authentication required.
-		 */
-		void
-		MOUNTPROC3_UMNTALL(void) = 4;
-
-		/*
-		 * Returns a list of all the exported filesystems, and which
-		 * machines are allowed to import it.
-		 */
-		exports
-		MOUNTPROC3_EXPORT(void)  = 5;
-
-	} = 3;
-} = 100005;
-
-#ifdef RPC_HDR
-%#endif /*!_rpcsvc_mount_h*/
-#endif
diff -uprN -X dontdiff nfs-utils/utils/mount/nfsumount.c nfs-utils-ag/utils/mount/nfsumount.c
--- nfs-utils/utils/mount/nfsumount.c	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/mount/nfsumount.c	2006-06-22 11:13:23.000000000 -0400
@@ -30,7 +30,7 @@
 #include "conn.h"
 
 #include "mount_constants.h"
-#include "nfsmount.h"
+#include "mount.h"
 #include "nfsumount.h"
 
 #if !defined(MNT_FORCE)
diff -uprN -X dontdiff nfs-utils/utils/mount/nfsumount.h nfs-utils-ag/utils/mount/nfsumount.h
--- nfs-utils/utils/mount/nfsumount.h	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/mount/nfsumount.h	2006-06-22 11:07:14.000000000 -0400
@@ -2,7 +2,7 @@
 #define _NFS_UMOUNT_H
 
 #include "conn.h"
-#include "nfsmount.h"
+#include "mount.h"
 
 int nfsumount(int, char **);
 int nfs_call_umount(clnt_addr_t *, dirpath *);

--------------070903030705050400060306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------070903030705050400060306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070903030705050400060306--
