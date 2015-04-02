Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33242 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbbDBIgj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2015 04:36:39 -0400
From: Christoph Hellwig <hch@lst.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs-utils: add support for the "pnfs" export option
Date: Thu,  2 Apr 2015 10:36:00 +0200
Message-Id: <1427963760-23995-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This goes along with the patch just sent to Bruce to make pnfs
support conditional.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 support/include/nfs/export.h | 1 +
 support/nfs/exports.c        | 5 +++++
 utils/exportfs/exportfs.c    | 2 ++
 3 files changed, 8 insertions(+)

diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
index 2f59e6a..1194255 100644
--- a/support/include/nfs/export.h
+++ b/support/include/nfs/export.h
@@ -26,6 +26,7 @@
 #define	NFSEXP_CROSSMOUNT	0x4000
 #define NFSEXP_NOACL		0x8000 /* reserved for possible ACL related use */
 #define NFSEXP_V4ROOT		0x10000
+#define NFSEXP_PNFS            0x20000
 /*
  * All flags supported by the kernel before addition of the
  * export_features interface:
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 4b17d3c..9b325b9 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -275,6 +275,7 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
 		fprintf(fp, "nordirplus,");
+	fprintf(fp, "%spnfs", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -581,6 +582,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 			clearflags(NFSEXP_NOACL, active, ep);
 		else if (strcmp(opt, "no_acl") == 0)
 			setflags(NFSEXP_NOACL, active, ep);
+		else if (!strcmp(opt, "pnfs"))
+			setflags(NFSEXP_PNFS, active, ep);
+		else if (!strcmp(opt, "no_pnfs"))
+			clearflags(NFSEXP_PNFS, active, ep);
 		else if (strncmp(opt, "anonuid=", 8) == 0) {
 			char *oe;
 			ep->e_anonuid = strtol(opt+8, &oe, 10);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 48eac00..8758231 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -821,6 +821,8 @@ dump(int verbose, int export_format)
 				c = dumpopt(c, "nordirplus");
 			if (ep->e_flags & NFSEXP_NOACL)
 				c = dumpopt(c, "no_acl");
+			if (ep->e_flags & NFSEXP_PNFS)
+				c = dumpopt(c, "pnfs");
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
 			if (ep->e_uuid)
-- 
1.9.1

