From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] Add `no_acl' nfs export option
Date: Mon, 14 Jul 2003 13:09:44 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <200307141309.44623.agruen@suse.de>
References: <200307081655.17510.agruen@suse.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_49oE/rltuj1G6IB"
Cc: Steve Dickson <SteveD@redhat.com>,
	=?iso-8859-1?q?R=FCdiger=20Oertl?= <ro@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <200307081655.17510.agruen@suse.de>
List-ID: <nfs.lists.sourceforge.net>


--Boundary-00=_49oE/rltuj1G6IB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

I noticed that the bit I wanted is already reserved in nfs-utils-1.0.4. Here 
is an updated nfs-utils patch. I am also attaching a patch against 
linux-2.6.0-test1.

Could someone please reserve the bit? Thanks.

Cheers,
Andreas.

On Tuesday 08 July 2003 16:55, Andreas Gruenbacher wrote:
> Hello,
>
> The current kernel nfsd module has a `nfs_permission_mode' parameter, which
> can be used to force nfsd into masking acl permissions off on the server
> side. This is needed if the nfs server has acl support, but there are
> clients that are too old. There is some more documentation in the patch
> itself. Thanks to Steve for proposing this improvement, and for sending an
> initial patch.
>
> Could this please be added to nfs-utils? Thanks.

------------------------------------------------------------------
 Andreas Gruenbacher                     SuSE Labs, SuSE Linux AG
 mailto:agruen@suse.de                     Deutschherrnstr. 15-19
 http://www.suse.de/                   D-90429 Nuernberg, Germany

--Boundary-00=_49oE/rltuj1G6IB
Content-Type: text/x-diff;
  charset="iso-8859-1";
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


Index: nfs-utils-1.0.4/support/include/nfs/export.h
===================================================================
--- nfs-utils-1.0.4.orig/support/include/nfs/export.h	2003-05-21 07:59:24.000000000 +0200
+++ nfs-utils-1.0.4/support/include/nfs/export.h	2003-07-14 12:57:07.000000000 +0200
@@ -25,6 +25,7 @@
 #define NFSEXP_NOAUTHNLM	0x0800
 #define NFSEXP_FSID		0x2000
 #define	NFSEXP_CROSSMNT		0x4000
-#define NFSEXP_ALLFLAGS		0x7FFF
+#define NFSEXP_NOACL		0x8000
+#define NFSEXP_ALLFLAGS		0xFFFF
 
 #endif /* _NSF_EXPORT_H */
Index: nfs-utils-1.0.4/utils/exportfs/exportfs.c
===================================================================
--- nfs-utils-1.0.4.orig/utils/exportfs/exportfs.c	2003-07-03 03:28:53.000000000 +0200
+++ nfs-utils-1.0.4/utils/exportfs/exportfs.c	2003-07-14 12:56:26.000000000 +0200
@@ -378,6 +378,8 @@ dump(int verbose)
 				c = dumpopt(c, "no_subtree_check");
 			if (ep->e_flags & NFSEXP_NOAUTHNLM)
 				c = dumpopt(c, "insecure_locks");
+			if (ep->e_flags & NFSEXP_NOACL)
+				c = dumpopt(c, "no_acl");
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
 			if (ep->e_mountpoint)
Index: nfs-utils-1.0.4/support/nfs/exports.c
===================================================================
--- nfs-utils-1.0.4.orig/support/nfs/exports.c	2003-05-30 07:17:56.000000000 +0200
+++ nfs-utils-1.0.4/support/nfs/exports.c	2003-07-14 12:56:26.000000000 +0200
@@ -185,6 +185,8 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	fprintf(fp, "%ssecure_locks,", (ep->e_flags & NFSEXP_NOAUTHNLM)?
 		"in" : "");
+	fprintf(fp, "%sacl,", (ep->e_flags & NFSEXP_NOACL)?
+		"no_" : "");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -374,6 +376,10 @@ parseopts(char *cp, struct exportent *ep
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
Index: nfs-utils-1.0.4/utils/exportfs/exports.man
===================================================================
--- nfs-utils-1.0.4.orig/utils/exportfs/exports.man	2003-05-30 07:17:56.000000000 +0200
+++ nfs-utils-1.0.4/utils/exportfs/exports.man	2003-07-14 12:56:26.000000000 +0200
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

--Boundary-00=_49oE/rltuj1G6IB
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="nfsd-export-acl.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="nfsd-export-acl.diff"

Index: linux-2.6.0-test1/include/linux/nfsd/export.h
===================================================================
--- linux-2.6.0-test1.orig/include/linux/nfsd/export.h	2003-05-27 03:00:40.000000000 +0200
+++ linux-2.6.0-test1/include/linux/nfsd/export.h	2003-07-14 13:06:33.000000000 +0200
@@ -41,7 +41,8 @@
 #define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
 #define NFSEXP_FSID		0x2000
 #define	NFSEXP_CROSSMNT		0x4000
-#define NFSEXP_ALLFLAGS		0x7FFF
+#define	NFSEXP_NOACL		0x8000
+#define NFSEXP_ALLFLAGS		0xFFFF
 
 
 #ifdef __KERNEL__

--Boundary-00=_49oE/rltuj1G6IB--

