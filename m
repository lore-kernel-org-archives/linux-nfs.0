Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48550 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129Ab1HYQT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Aug 2011 12:19:58 -0400
Date: Thu, 25 Aug 2011 12:19:57 -0400
To: linux-nfs@vger.kernel.org
Cc: Leonardo Borda <leonardoborda@gmail.com>
Subject: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20110825161957.GC1114@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

A client that wants to execute a file must be able to read it.  Read
opens over nfs are therefore implicitly allowed for executable files
even when those files are not readable.

NFSv2/v3 get this right by using a passed-in NFSD_MAY_OWNER_OVERRIDE on
read requests, but NFSv4 has gotten this wrong ever since
dc730e173785e29b297aa605786c94adaffe2544 "nfsd4: fix owner-override on
open", when we realized that the file owner shouldn't override
permissions on non-reclaim NFSv4 opens.

So we can't use NFSD_MAY_OWNER_OVERRIDE to tell nfsd_permission to allow
reads of executable files.

So, do the same thing we do whenever we encounter another weird NFS
permission nit: define yet another NFSD_MAY_* flag.

The industry's future standardization on 128-bit processors will be
motivated primarily by the need for integers with enough bits for all
the NFSD_MAY_* flags.

Reported-by: Leonardo Borda <leonardoborda@gmail.com>
Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 ++
 fs/nfsd/vfs.c      |    3 ++-
 fs/nfsd/vfs.h      |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d30253a..3fb07ac 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -156,6 +156,8 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 		!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
 		return nfserr_inval;
 
+	accmode |= NFSD_MAY_READ_IF_EXEC;
+
 	if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
 		accmode |= NFSD_MAY_READ;
 	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4c22870..75c35fa 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2116,7 +2116,8 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 
 	/* Allow read access to binaries even when mode 111 */
 	if (err == -EACCES && S_ISREG(inode->i_mode) &&
-	    acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE))
+	     (acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE) ||
+	      acc == (NFSD_MAY_READ | NFSD_MAY_READ_IF_EXEC)))
 		err = inode_permission(inode, MAY_EXEC);
 
 	return err? nfserrno(err) : 0;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index e0bbac0..a22e40e 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -25,6 +25,7 @@
 #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
 #define NFSD_MAY_NOT_BREAK_LEASE 512
 #define NFSD_MAY_BYPASS_GSS	1024
+#define NFSD_MAY_READ_IF_EXEC	2048
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
-- 
1.7.4.1

