Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58270 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751508AbdALCWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 21:22:07 -0500
Date: Wed, 11 Jan 2017 21:22:06 -0500
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] exportfs: support "security_label" export option
Message-ID: <20170112022206.GA303@fieldses.org>
References: <1484187481-32723-1-git-send-email-bfields@redhat.com>
 <1484187481-32723-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1484187481-32723-3-git-send-email-bfields@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

On recent kernels only exports with NFSEXP_SECURITY_LABEL set will
export security labels.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 support/include/nfs/export.h | 3 ++-
 support/nfs/exports.c        | 4 ++++
 utils/exportfs/exportfs.c    | 2 ++
 utils/exportfs/exports.man   | 8 ++++++++
 4 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
index 1194255899bd..0eca828ee3ad 100644
--- a/support/include/nfs/export.h
+++ b/support/include/nfs/export.h
@@ -18,7 +18,8 @@
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
 #define NFSEXP_NOREADDIRPLUS	0x0040
-/* 80, 100 unused */
+#define NFSEXP_SECURITY_LABEL	0x0080
+/* 0x100 unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index d992747c13a1..92bd6e60ddf7 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -274,6 +274,8 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
 		fprintf(fp, "nordirplus,");
+	if (ep->e_flags & NFSEXP_SECURITY_LABEL)
+		fprintf(fp, "security_label,");
 	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
@@ -543,6 +545,8 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 			setflags(NFSEXP_ASYNC, active, ep);
 		else if (!strcmp(opt, "nordirplus"))
 			setflags(NFSEXP_NOREADDIRPLUS, active, ep);
+		else if (!strcmp(opt, "security_label"))
+			setflags(NFSEXP_SECURITY_LABEL, active, ep);
 		else if (!strcmp(opt, "nohide"))
 			setflags(NFSEXP_NOHIDE, active, ep);
 		else if (!strcmp(opt, "hide"))
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 15a15835a01f..38039978ef5f 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -705,6 +705,8 @@ dump(int verbose, int export_format)
 				c = dumpopt(c, "insecure_locks");
 			if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
 				c = dumpopt(c, "nordirplus");
+			if (ep->e_flags & NFSEXP_SECURITY_LABEL)
+				c = dumpopt(c, "security_label");
 			if (ep->e_flags & NFSEXP_NOACL)
 				c = dumpopt(c, "no_acl");
 			if (ep->e_flags & NFSEXP_PNFS)
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 93092463153b..d8de6bec2583 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -417,6 +417,14 @@ devices. The default can be explicitly requested with the
 .I no_pnfs
 option.
 
+.TP
+.IR security_label
+With this option set, clients using NFSv4.2 or higher will be able to
+set and retrieve security labels (such as those used by SELinux).  This
+will only work if all clients use a consistent security policy.  Note
+that early kernels did not support this export option, and instead
+enabled security labels by default.
+
 .SS User ID Mapping
 .PP
 .B nfsd
-- 
2.9.3

