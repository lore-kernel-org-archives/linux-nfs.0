From: Scott Leerssen <scott@leerssen.com>
Subject: nfs root directory security
Date: 17 Jun 2003 18:28:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055888933.16259.54.camel@sleerssen.racemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-RPt5Flz1RNmm0DUCFaUn"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from user-vc8ft6h.biz.mindspring.com ([216.135.244.209] helo=racemi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SOw5-0005RE-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 15:28:17 -0700
Received: from sleerssen.racemi.com (user-112u24q.biz.mindspring.com [66.47.8.154])
	by racemi.com (8.11.6/8.11.6) with ESMTP id h5HMS4613377
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 18:28:08 -0400
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-RPt5Flz1RNmm0DUCFaUn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Attached is a patch for nfs-utils-1.0.1-2.9 (RedHat) that adds a bit of
security and ease of use for exported filesystems that have lots of
users in lots of subdirectories.

What it does is disallow nfs clients from mounting a directory that is
marked execute only (chmod 0111), controlled by an option
"root_mnt_orig".  This is handy if one has a constantly changing
hierarchy of subdirectories where the client is the only one who knows
where to look for his stuff.  Consider a directory structure that looks
like:

/A/B/C/123
/A/B/C/456
/A/B/C/789

If A, B and C are mode 0111, the nfs client must directly mount 123,
456, or 789.  OK, this is a kind of lame example, but one can easily add
some obscurity to the directory structure under /A and see how
effectively this hides NFS mount points and adds some ease of use when
maintaining a TON of mount points.

Enjoy, and feel free to come up with an option name that doesn't suck.

-- 
Scott Leerssen <scott@leerssen.com>

--=-RPt5Flz1RNmm0DUCFaUn
Content-Disposition: attachment; filename=nfs-utils-1.0.1.mnt-root-orig.patch
Content-Type: text/x-patch; name=nfs-utils-1.0.1.mnt-root-orig.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff -uNr nfs-utils-1.0.1/support/include/nfs/export.h nfs-utils-1.0.1.mnt-root-orig.patch/support/include/nfs/export.h
--- nfs-utils-1.0.1/support/include/nfs/export.h	Wed Feb 27 20:37:44 2002
+++ nfs-utils-1.0.1.mnt-root-orig.patch/support/include/nfs/export.h	Tue Jun 17 13:09:11 2003
@@ -24,6 +24,7 @@
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
 #define NFSEXP_FSID		0x2000
+#define NFSEXP_ROOTMNTORIG	0x4000
 #define NFSEXP_ALLFLAGS		0x3FFF
 
 #endif /* _NSF_EXPORT_H */
diff -uNr nfs-utils-1.0.1/support/nfs/exports.c nfs-utils-1.0.1.mnt-root-orig.patch/support/nfs/exports.c
--- nfs-utils-1.0.1/support/nfs/exports.c	Wed May 29 02:07:43 2002
+++ nfs-utils-1.0.1.mnt-root-orig.patch/support/nfs/exports.c	Tue Jun 17 13:12:15 2003
@@ -176,6 +176,8 @@
 		"no_" : "");
 	fprintf(fp, "%ssecure_locks,", (ep->e_flags & NFSEXP_NOAUTHNLM)?
 		"in" : "");
+	fprintf(fp, "%sroot_mnt_orig,", (ep->e_flags & NFSEXP_ROOTMNTORIG)?
+		"" : "no_");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -346,6 +348,10 @@
 			ep->e_flags |= NFSEXP_ALLSQUASH;
 		else if (strcmp(opt, "no_all_squash") == 0)
 			ep->e_flags &= ~NFSEXP_ALLSQUASH;
+		else if (strcmp(opt, "root_mnt_orig") == 0)
+			ep->e_flags |= NFSEXP_ROOTMNTORIG;
+		else if (!strcmp(opt, "no_root_mnt_orig"))
+			ep->e_flags &= ~NFSEXP_ROOTMNTORIG;
 		else if (strcmp(opt, "subtree_check") == 0)
 			ep->e_flags &= ~NFSEXP_NOSUBTREECHECK;
 		else if (strcmp(opt, "no_subtree_check") == 0)
diff -uNr nfs-utils-1.0.1/utils/mountd/mountd.c nfs-utils-1.0.1.mnt-root-orig.patch/utils/mountd/mountd.c
--- nfs-utils-1.0.1/utils/mountd/mountd.c	Tue Jun 17 13:02:39 2003
+++ nfs-utils-1.0.1.mnt-root-orig.patch/utils/mountd/mountd.c	Tue Jun 17 13:14:42 2003
@@ -264,6 +264,10 @@
 	} else if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
 		xlog(L_WARNING, "%s is not a directory or regular file", p);
 		*error = NFSERR_NOTDIR;
+	} else if ((((S_IRUSR|S_IRGRP|S_IROTH) & stb.st_mode) == 0) &&
+			((exp->m_export.e_flags & NFSEXP_ROOTMNTORIG) == 0)) {
+		xlog(L_WARNING, "%s not readable", p);
+		*error = NFSERR_ACCES;
 	} else {
 		struct nfs_fh_len  *fh;
 

--=-RPt5Flz1RNmm0DUCFaUn--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
