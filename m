Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:34573 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbbG3Nwe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:52:34 -0400
Received: by ykax123 with SMTP id x123so34371036yka.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:52:33 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] nfsd: move some file caching helpers to a common header
Date: Thu, 30 Jul 2015 09:52:14 -0400
Message-Id: <1438264341-18048-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll want to reuse some of this for common open file caching
infrastructure.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.h | 25 +++++++++++++++++++++++++
 fs/nfsd/nfs4state.c | 17 ++---------------
 2 files changed, 27 insertions(+), 15 deletions(-)
 create mode 100644 fs/nfsd/filecache.h

diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
new file mode 100644
index 000000000000..9051ee54faa3
--- /dev/null
+++ b/fs/nfsd/filecache.h
@@ -0,0 +1,25 @@
+#ifndef _FS_NFSD_FILECACHE_H
+#define _FS_NFSD_FILECACHE_H
+
+#include <linux/jhash.h>
+#include <linux/sunrpc/xdr.h>
+
+#include "export.h"
+
+/* hash table for nfs4_file */
+#define NFSD_FILE_HASH_BITS                   8
+#define NFSD_FILE_HASH_SIZE                  (1 << NFSD_FILE_HASH_BITS)
+
+static inline unsigned int
+nfsd_fh_hashval(struct knfsd_fh *fh)
+{
+	return jhash2(fh->fh_base.fh_pad, XDR_QUADLEN(fh->fh_size), 0);
+}
+
+static inline unsigned int
+file_hashval(struct knfsd_fh *fh)
+{
+	return nfsd_fh_hashval(fh) & (NFSD_FILE_HASH_SIZE - 1);
+}
+
+#endif /* _FS_NFSD_FILECACHE_H */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 75f617a052cf..79795c898dd1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -49,6 +49,7 @@
 
 #include "netns.h"
 #include "pnfs.h"
+#include "filecache.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -381,21 +382,7 @@ static unsigned int ownerstr_hashval(struct xdr_netobj *ownername)
 	return ret & OWNER_HASH_MASK;
 }
 
-/* hash table for nfs4_file */
-#define FILE_HASH_BITS                   8
-#define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
-
-static unsigned int nfsd_fh_hashval(struct knfsd_fh *fh)
-{
-	return jhash2(fh->fh_base.fh_pad, XDR_QUADLEN(fh->fh_size), 0);
-}
-
-static unsigned int file_hashval(struct knfsd_fh *fh)
-{
-	return nfsd_fh_hashval(fh) & (FILE_HASH_SIZE - 1);
-}
-
-static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
+static struct hlist_head file_hashtbl[NFSD_FILE_HASH_SIZE];
 
 static void
 __nfs4_file_get_access(struct nfs4_file *fp, u32 access)
-- 
2.4.3

