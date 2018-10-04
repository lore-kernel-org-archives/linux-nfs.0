Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56212 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726277AbeJDHyc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 03:54:32 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Date: Thu, 04 Oct 2018 11:02:43 +1000
Subject: [PATCH 3/3] NFSD - Use MAY_ACT_AS_OWNER
Cc: Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, David Howells <dhowells@redhat.com>,
        coda@cs.cmu.edu, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Message-ID: <153861496336.30373.7984309432171094818.stgit@noble>
In-Reply-To: <153861471803.30373.6184444014227748848.stgit@noble>
References: <153861471803.30373.6184444014227748848.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSD_MAY_OWNER_OVERRIDE has exactly the same meaning
as the new MAY_ACT_AS_OWNER flag, so simplify the
code by making use of the identity.

The move NFSD_MAY_OWNER_OVERRIDE into NFSD_MAY_MASK, but that
is not a problem is it is always set together with a flag
that is already in the MASK.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfsd/vfs.c |   11 ++++++-----
 fs/nfsd/vfs.h |   14 +++++++-------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 55a099e47ba2..d89d23e6e2fe 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2038,12 +2038,13 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 	 * We must trust the client to do permission checking - using "ACCESS"
 	 * with NFSv3.
 	 */
-	if ((acc & NFSD_MAY_OWNER_OVERRIDE) &&
-	    uid_eq(inode->i_uid, current_fsuid()))
-		return 0;
 
-	/* This assumes  NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC} */
-	err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
+	/*
+	 * This works as NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC}
+	 * and NFSD_MAY_OWNER_OVERRIDE == MAY_ACT_AS_OWNER
+	 */
+	err = inode_permission(inode, (acc & (MAY_READ|MAY_WRITE|
+					      MAY_EXEC|MAY_ACT_AS_OWNER)));
 
 	/* Allow read access to binaries even when mode 111 */
 	if (err == -EACCES && S_ISREG(inode->i_mode) &&
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 2b1c70d3757a..f6e96dba76a5 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -16,6 +16,7 @@
 #define NFSD_MAY_EXEC			MAY_EXEC
 #define NFSD_MAY_WRITE			MAY_WRITE
 #define NFSD_MAY_READ			MAY_READ
+#define NFSD_MAY_OWNER_OVERRIDE		MAY_ACT_AS_OWNER
 #define NFSD_MAY_SATTR			(__MAY_UNUSED << 0)
 #define NFSD_MAY_TRUNC			(__MAY_UNUSED << 1)
 #define NFSD_MAY_LOCK			(__MAY_UNUSED << 2)
@@ -23,16 +24,15 @@
 #define NFSD_MAY_MASK			(__NFSD_MAY_FIRST_HINT - 1)
 
 /* extra hints to permission and open routines: */
-#define NFSD_MAY_OWNER_OVERRIDE		(__NFSD_MAY_FIRST_HINT << 0)
 /* for device special files */
-#define NFSD_MAY_LOCAL_ACCESS		(__NFSD_MAY_FIRST_HINT << 1)
-#define NFSD_MAY_BYPASS_GSS_ON_ROOT	(__NFSD_MAY_FIRST_HINT << 2)
-#define NFSD_MAY_NOT_BREAK_LEASE	(__NFSD_MAY_FIRST_HINT << 3)
-#define NFSD_MAY_BYPASS_GSS		(__NFSD_MAY_FIRST_HINT << 4)
-#define NFSD_MAY_READ_IF_EXEC		(__NFSD_MAY_FIRST_HINT << 5)
+#define NFSD_MAY_LOCAL_ACCESS		(__NFSD_MAY_FIRST_HINT << 0)
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT	(__NFSD_MAY_FIRST_HINT << 1)
+#define NFSD_MAY_NOT_BREAK_LEASE	(__NFSD_MAY_FIRST_HINT << 2)
+#define NFSD_MAY_BYPASS_GSS		(__NFSD_MAY_FIRST_HINT << 3)
+#define NFSD_MAY_READ_IF_EXEC		(__NFSD_MAY_FIRST_HINT << 4)
 
 /* 64 bit readdir cookies for >= NFSv3 */
-#define NFSD_MAY_64BIT_COOKIE		(__NFSD_MAY_FIRST_HINT << 6)
+#define NFSD_MAY_64BIT_COOKIE		(__NFSD_MAY_FIRST_HINT << 5)
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
