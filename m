From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/7] nfsd: introduce export flag for v4 pseudoroot
Date: Tue,  1 Dec 2009 19:39:37 -0500
Message-ID: <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	Steve Dickson <SteveD@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <SteveD@redhat.com>

NFSv4 differs from v2 and v3 in that it presents a single unified
filesystem tree, whereas v2 and v3 exported multiple filesystem (whose
roots could be found using a separate mount protocol).

Our original NFSv4 server implementation asked the administrator to
designate a single filesystem as the NFSv4 root, then to mount
filesystems they wished to export underneath.  (Often using bind mounts
of already-existing filesystems.)

This was conceptually simple, and allowed easy implementation, but
created a serious obstacle to upgrading between v2/v3: since the paths
to v4 filesystems were different, administrators would have to adjust
all the paths in client-side mount commands when switching to v4.

Various workarounds are possible.  For example, the administrator could
export "/" and designate it as the v4 root.  However, the security risks
of that approach are obvious, and in any case we shouldn't be requiring
the administrator to take extra steps to fix this problem; instead, the
server should present consistent paths across different versions by
default.

These patches take a modified version of that approach: we provide a new
export option which exports only a subset of a filesystem.  With this
flag, it becomes safe for mountd to export "/" by default, with no need
for additional configuration.

We begin just by defining the new flag.

Signed-Off-By: Steve Dickson <steved@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c            |    1 +
 include/linux/nfsd/export.h |   12 +++++++++++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b73baba..b9e4977 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1439,6 +1439,7 @@ static struct flags {
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
+	{ NFSEXP_V4ROOT, {"v4root", ""}},
 #ifdef MSNFS
 	{ NFSEXP_MSNFS, {"msnfs", ""}},
 #endif
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index a6d9ef2..e963ba9 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -39,7 +39,17 @@
 #define NFSEXP_FSID		0x2000
 #define	NFSEXP_CROSSMOUNT	0x4000
 #define	NFSEXP_NOACL		0x8000	/* reserved for possible ACL related use */
-#define NFSEXP_ALLFLAGS		0xFE3F
+/*
+ * The NFSEXP_V4ROOT flag causes the kernel to give access only to NFSv4
+ * clients, and only to the single directory that is the root of the
+ * export; further lookup and readdir operations are treated as if every
+ * subdirectory was a mountpoint, and ignored if they are not themselves
+ * exported.  This is used by nfsd and mountd to construct the NFSv4
+ * pseudofilesystem, which provides access only to paths leading to each
+ * exported filesystem.
+ */
+#define	NFSEXP_V4ROOT		0x10000
+#define NFSEXP_ALLFLAGS		0x1FE3F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
-- 
1.6.3.3

