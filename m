Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52657 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab1LFU5W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 15:57:22 -0500
Received: by qcqz2 with SMTP id z2so2624517qcq.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 12:57:21 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 6 Dec 2011 15:57:21 -0500
Message-ID: <CAN-5tyErML04W7N3YVYyK0qq8OR_Ae+d4MzNXYyAVTMad39bFw@mail.gmail.com>
Subject: pnfs nfsd compile problems
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Latest pnfs-all-latest (commit
58deb32bd36e92f5f44ac6d5e5ab3c36732c4ebd) doesn't compile if
CONFIG_PNFSD_BLOCK is not enabled.

1st compile error is in (and probably gcc version dependent):
  CC [M]  fs/nfsd/nfsctl.o
In file included from fs/nfsd/nfsctl.c:18:0:
include/linux/nfsd/nfsd4_block.h: In function ‘pnfs_block_enabled’:
include/linux/nfsd/nfsd4_block.h:104:46: error: parameter name omitted
include/linux/nfsd/nfsd4_block.h:104:46: error: parameter name omitted
make[2]: *** [fs/nfsd/nfsctl.o] Error 1

Something like this fixed that problem:
diff --git a/include/linux/nfsd/nfsd4_block.h b/include/linux/nfsd/nfsd4_block.h
index 9c2941f..7d620a0 100644
--- a/include/linux/nfsd/nfsd4_block.h
+++ b/include/linux/nfsd/nfsd4_block.h
@@ -101,7 +101,7 @@ extern bl_comm_t    *bl_comm_global;        // Ugly...

 #else

-static inline bool pnfs_block_enabled(struct inode *, int) { return false; }
+static inline bool pnfs_block_enabled(struct inode *a, int b) { return false; }
 static inline void nfsd_bl_init(void) {}

 #endif /* CONFIG_PNFSD_BLOCK */

However, next is

  CC [M]  fs/nfsd/vfs.o
fs/nfsd/vfs.c: In function ‘_nfsd_setattr’:
fs/nfsd/vfs.c:389:5: error: implicit declaration of function
‘bl_layoutrecall’ [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

make[2]: *** [fs/nfsd/vfs.o] Error 1

Perhaps, bl_layoutrecall() should be defined regardless if
CONFIG_PNFSD_BLOCK is defined?

So a combined patch for both is:
diff --git a/include/linux/nfsd/nfsd4_block.h b/include/linux/nfsd/nfsd4_block.h
index 9c2941f..06a33ca 100644
--- a/include/linux/nfsd/nfsd4_block.h
+++ b/include/linux/nfsd/nfsd4_block.h
@@ -101,7 +101,8 @@ extern bl_comm_t    *bl_comm_global;        // Ugly...

 #else

-static inline bool pnfs_block_enabled(struct inode *, int) { return false; }
+int bl_layoutrecall(struct inode *inode, int type, u64 offset, u64
len, bool with_nfs4_state_lock);
+static inline bool pnfs_block_enabled(struct inode *a, int b) { return false; }
 static inline void nfsd_bl_init(void) {}

 #endif /* CONFIG_PNFSD_BLOCK */

Then, the next problem is
  CC [M]  fs/nfsd/export.o
fs/nfsd/export.c: In function ‘pnfsd_check_export’:
fs/nfsd/export.c:387:30: error: ‘bl_export_ops’ undeclared (first use
in this function)
fs/nfsd/export.c:387:30: note: each undeclared identifier is reported
only once for each function it appears in
make[2]: *** [fs/nfsd/export.o] Error 1

This structure is only defined if CONFIG_PNFSD_BLOCK defined...

Something like this to fix?
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 82c8194..62550dc 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -384,7 +384,9 @@ static int pnfsd_check_export(struct inode *inode, int *flag
        if (pnfs_block_enabled(inode, *flags)) {
                if (!inode->i_sb->s_pnfs_op) {
                        dprintk("set pnfs block export structure\n");
+#if defined(CONFIG_PNFSD_BLOCK)
                        inode->i_sb->s_pnfs_op = &bl_export_ops;
+#endif
                } else
                        dprintk("pnfs block enabled, fs provided s_pnfs_op\n");
                dprintk("pnfs block enabled, sb=%p s_pnfs_op=%p\n",
