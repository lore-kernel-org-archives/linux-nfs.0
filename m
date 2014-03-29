Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:37134 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaC2CX5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Mar 2014 22:23:57 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so5573066pdi.21
        for <linux-nfs@vger.kernel.org>; Fri, 28 Mar 2014 19:23:57 -0700 (PDT)
Message-ID: <53362EB3.2040809@gmail.com>
Date: Sat, 29 Mar 2014 10:23:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSD: Clear wcc data between compound ops
References: <533299E9.6010806@gmail.com> <20140328211920.GD6041@fieldses.org> <5335FAB2.8050404@gmail.com> <20140329005831.GO6041@fieldses.org>
In-Reply-To: <20140329005831.GO6041@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Testing NFS4.0 by pynfs, I got some messeages as,
"nfsd: inode locked twice during operation."

When one compound RPC contains two or more ops that locks
the filehandle,the second op will cause the message.

As two SETATTR ops, after the first SETATTR, nfsd will not call
fh_put() to release current filehandle, it means filehandle have
unlocked with fh_post_saved = 1.
The second SETATTR find fh_post_saved = 1, and printk the message.

v2: introduce helper fh_clear_wcc().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
  fs/nfsd/nfs4proc.c |  2 ++
  fs/nfsd/nfsfh.h    | 14 +++++++++++++-
  2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 550faf2..9849c61 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1358,6 +1358,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
  			goto encode_op;
  		}

+		fh_clear_wcc(current_fh);
+
  		/* If op is non-idempotent */
  		if (opdesc->op_flags & OP_MODIFIES_SOMETHING) {
  			plen = opdesc->op_rsize_bop(rqstp, op);
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 4775bc4..ad67964 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -133,6 +133,17 @@ fh_init(struct svc_fh *fhp, int maxsize)

  #ifdef CONFIG_NFSD_V3
  /*
+ * The wcc data stored in current_fh should be cleared
+ * between compound ops.
+ */
+static inline void
+fh_clear_wcc(struct svc_fh *fhp)
+{
+	fhp->fh_post_saved = 0;
+	fhp->fh_pre_saved = 0;
+}
+
+/*
   * Fill in the pre_op attr for the wcc data
   */
  static inline void
@@ -152,7 +163,8 @@ fill_pre_wcc(struct svc_fh *fhp)

  extern void fill_post_wcc(struct svc_fh *);
  #else
-#define	fill_pre_wcc(ignored)
+#define fh_clear_wcc(ignored)
+#define fill_pre_wcc(ignored)
  #define fill_post_wcc(notused)
  #endif /* CONFIG_NFSD_V3 */

-- 
1.9.0

