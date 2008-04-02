From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] [NFS/NOMMU]: fix bug - executing FDPIC ELF on NFS mount triggers BUG() at mm/nommu.c:862:/do_mmap_private()
Date: Tue,  1 Apr 2008 20:23:39 -0700
Message-ID: <1207106619-7673-1-git-send-email-cooloney@kernel.org>
Cc: linux-kernel@vger.kernel.org, Bryan Wu <cooloney@kernel.org>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759302AbYDAMYD@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS needs a NOMMU version mmap function to support uClinux on NOMMU machine
http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_id=141&tracker_item_id=3992

Signed-off-by: Bryan Wu <cooloney@kernel.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>
---
 fs/nfs/file.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ef57a5a..5d2e9d9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -64,7 +64,11 @@ const struct file_operations nfs_file_operations = {
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+#ifdef CONFIG_MMU
 	.mmap		= nfs_file_mmap,
+#else
+	.mmap		= generic_file_mmap,
+#endif
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
 	.release	= nfs_file_release,
-- 
1.5.4.3
