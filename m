From: Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH] Add `no_acl' nfs export option
Date: Tue, 8 Jul 2003 16:55:17 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <200307081655.17510.agruen@suse.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_VttC/jT8Xal2QuT"
Cc: Steve Dickson <SteveD@redhat.com>,
	=?iso-8859-1?q?R=FCdiger=20Oertl?= <ro@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--Boundary-00=_VttC/jT8Xal2QuT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

The current kernel nfsd module has a `nfs_permission_mode' parameter, which 
can be used to force nfsd into masking acl permissions off on the server 
side. This is needed if the nfs server has acl support, but there are clients 
that are too old. There is some more documentation in the patch itself. 
Thanks to Steve for proposing this improvement, and for sending an initial 
patch.

Could this please be added to nfs-utils? Thanks.

Regards,
Andreas.

------------------------------------------------------------------
 Andreas Gruenbacher                     SuSE Labs, SuSE Linux AG
 mailto:agruen@suse.de                     Deutschherrnstr. 15-19
 http://www.suse.de/                   D-90429 Nuernberg, Germany

--Boundary-00=_VttC/jT8Xal2QuT
Content-Type: text/x-diff;
  charset="us-ascii";
  name="export-acl.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="export-acl.diff"

Add `no_acl' nfs export option

This patch adds the `acl' and `no_acl' nfs export options, which replace
the nfs_permission_mode module parameter of nfsd.o. The `no_acl' option
tells nfsd to mask off acl permissions so that clients will see a subset
of permissions that is safe even with old clients. Current clients
implement the NFSv3 ACCESS RPC, and therefore do not require the
`no_acl' export option. If no acls are supported in the nfs server, the
`no_acl' export option is not needed, either.

Thanks to Steve Dickson <SteveD@redhat.com> for proposing this.


Andreas Gruenbacher <agruen@suse.de>, SuSE Labs


Index: nfs-utils-1.0.3/support/include/nfs/export.h
===================================================================
--- nfs-utils-1.0.3.orig/support/include/nfs/export.h	2002-02-28 02:37:44.000000000 +0100
+++ nfs-utils-1.0.3/support/include/nfs/export.h	2003-07-08 16:14:26.000000000 +0200
@@ -24,6 +24,7 @@
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
 #define NFSEXP_FSID		0x2000
-#define NFSEXP_ALLFLAGS		0x3FFF
+#define NFSEXP_NOACL		0x4000
+#define NFSEXP_ALLFLAGS		0x7FFF
 
 #endif /* _NSF_EXPORT_H */
Index: nfs-utils-1.0.3/utils/exportfs/exportfs.c
===================================================================
--- nfs-utils-1.0.3.orig/utils/exportfs/exportfs.c	2002-10-11 17:39:55.000000000 +0200
+++ nfs-utils-1.0.3/utils/exportfs/exportfs.c	2003-07-08 16:14:26.000000000 +0200
@@ -347,6 +347,8 @@ dump(int verbose)
 				c = dumpopt(c, "no_subtree_check");
 			if (ep->e_flags & NFSEXP_NOAUTHNLM)
 				c = dumpopt(c, "insecure_locks");
+			if (ep->e_flags & NFSEXP_NOACL)
+				c = dumpopt(c, "no_acl");
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
 			if (ep->e_maptype == CLE_MAP_UGIDD)
Index: nfs-utils-1.0.3/support/nfs/exports.c
===================================================================
--- nfs-utils-1.0.3.orig/support/nfs/exports.c	2002-10-11 17:39:55.000000000 +0200
+++ nfs-utils-1.0.3/support/nfs/exports.c	2003-07-08 16:14:26.000000000 +0200
@@ -182,6 +182,8 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	fprintf(fp, "%ssecure_locks,", (ep->e_flags & NFSEXP_NOAUTHNLM)?
 		"in" : "");
+	fprintf(fp, "%sacl,", (ep->e_flags & NFSEXP_NOACL)?
+		"no_" : "");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -364,6 +366,10 @@ parseopts(char *cp, struct exportent *ep
 			ep->e_flags &= ~NFSEXP_NOAUTHNLM;
 		else if (strcmp(opt, "insecure_locks") == 0)
 			ep->e_flags |= NFSEXP_NOAUTHNLM;
+		else if (strcmp(opt, "acl") == 0)
+			ep->e_flags &= ~NFSEXP_NOACL;
+		else if (strcmp(opt, "no_acl") == 0)
+			ep->e_flags |= NFSEXP_NOACL;
 		else if (strncmp(opt, "mapping=", 8) == 0)
 			ep->e_maptype = parsemaptype(opt+8);
 		else if (strcmp(opt, "map_identity") == 0)	/* old style */
Index: nfs-utils-1.0.3/utils/exportfs/exports.man
===================================================================
--- nfs-utils-1.0.3.orig/utils/exportfs/exports.man	2002-11-19 05:43:21.000000000 +0100
+++ nfs-utils-1.0.3/utils/exportfs/exports.man	2003-07-08 16:44:17.000000000 +0200
@@ -218,6 +218,21 @@ be explicitly requested with either of t
 .IR auth_nlm ,
 or
 .IR secure_locks .
+.TP
+.IR no_acl
+This option tells nfsd to mask off acl permissions so that clients will
+only see a subset of the permissions on the exported file system. This
+subset is safe for NFSv2 clients, and for NFSv3 clients that perform
+access decisions locally. Current NFSv3 clients use the ACCESS RPC
+to perform all access decisions on the server. The
+.I no_acl
+option should be used for nfs exports with acl support that are exported
+to NFSv2 clients, or to NFSv3 clients that don't use the ACCESS RPC.
+This option is not needed for recent NFSv3 clients or if the exported
+file system has no acl support. The default is to export with acl
+support enabled (i.e.,
+.I no_acl
+is off.)
 
 '''.TP
 '''.I noaccess

--Boundary-00=_VttC/jT8Xal2QuT--

