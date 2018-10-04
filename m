Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56078 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726277AbeJDHyW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 03:54:22 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Date: Thu, 04 Oct 2018 11:02:43 +1000
Subject: [PATCH 2/3] VFS: allow MAY_ flags to be easily extended.
Cc: Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, David Howells <dhowells@redhat.com>,
        coda@cs.cmu.edu, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Message-ID: <153861496332.30373.4846710512713338280.stgit@noble>
In-Reply-To: <153861471803.30373.6184444014227748848.stgit@noble>
References: <153861471803.30373.6184444014227748848.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSD uses permission flags similar to the MAY_* flags,
with some overlap, and depends on the overlap matching.
This is currently a little fragile and hard to extend.

So add __MAY_UNUSED to identify the first unused flag,
and have NFSD use that flag and later flags for its
non-standard permissions.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfsd/vfs.h      |   33 ++++++++++++++++++---------------
 include/linux/fs.h |    2 ++
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a7e107309f76..2b1c70d3757a 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -13,23 +13,26 @@
  * Flags for nfsd_permission
  */
 #define NFSD_MAY_NOP			0
-#define NFSD_MAY_EXEC			0x001 /* == MAY_EXEC */
-#define NFSD_MAY_WRITE			0x002 /* == MAY_WRITE */
-#define NFSD_MAY_READ			0x004 /* == MAY_READ */
-#define NFSD_MAY_SATTR			0x008
-#define NFSD_MAY_TRUNC			0x010
-#define NFSD_MAY_LOCK			0x020
-#define NFSD_MAY_MASK			0x03f
+#define NFSD_MAY_EXEC			MAY_EXEC
+#define NFSD_MAY_WRITE			MAY_WRITE
+#define NFSD_MAY_READ			MAY_READ
+#define NFSD_MAY_SATTR			(__MAY_UNUSED << 0)
+#define NFSD_MAY_TRUNC			(__MAY_UNUSED << 1)
+#define NFSD_MAY_LOCK			(__MAY_UNUSED << 2)
+#define __NFSD_MAY_FIRST_HINT		(__MAY_UNUSED << 3)
+#define NFSD_MAY_MASK			(__NFSD_MAY_FIRST_HINT - 1)
 
 /* extra hints to permission and open routines: */
-#define NFSD_MAY_OWNER_OVERRIDE		0x040
-#define NFSD_MAY_LOCAL_ACCESS		0x080 /* for device special files */
-#define NFSD_MAY_BYPASS_GSS_ON_ROOT	0x100
-#define NFSD_MAY_NOT_BREAK_LEASE	0x200
-#define NFSD_MAY_BYPASS_GSS		0x400
-#define NFSD_MAY_READ_IF_EXEC		0x800
-
-#define NFSD_MAY_64BIT_COOKIE		0x1000 /* 64 bit readdir cookies for >= NFSv3 */
+#define NFSD_MAY_OWNER_OVERRIDE		(__NFSD_MAY_FIRST_HINT << 0)
+/* for device special files */
+#define NFSD_MAY_LOCAL_ACCESS		(__NFSD_MAY_FIRST_HINT << 1)
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT	(__NFSD_MAY_FIRST_HINT << 2)
+#define NFSD_MAY_NOT_BREAK_LEASE	(__NFSD_MAY_FIRST_HINT << 3)
+#define NFSD_MAY_BYPASS_GSS		(__NFSD_MAY_FIRST_HINT << 4)
+#define NFSD_MAY_READ_IF_EXEC		(__NFSD_MAY_FIRST_HINT << 5)
+
+/* 64 bit readdir cookies for >= NFSv3 */
+#define NFSD_MAY_64BIT_COOKIE		(__NFSD_MAY_FIRST_HINT << 6)
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5a8878a88cbb..b0076cb0f738 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -103,6 +103,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
  */
 #define MAY_ACT_AS_OWNER	0x00000100
 
+#define	__MAY_UNUSED		0x00000100
+
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
  * to O_WRONLY and O_RDWR via the strange trick in do_dentry_open()
