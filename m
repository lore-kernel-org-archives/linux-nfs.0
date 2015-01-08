Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:44363 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbbAHRqh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 12:46:37 -0500
From: Christoph Hellwig <hch@lst.de>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH 09/12] ceph: remove call to bdi_unregister
Date: Thu,  8 Jan 2015 18:45:30 +0100
Message-Id: <1420739133-27514-10-git-send-email-hch@lst.de>
In-Reply-To: <1420739133-27514-1-git-send-email-hch@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bdi_destroy already does all the work, and if we delay freeing the
anon bdev we can get away with just that single call.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/super.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index 50f06cd..e350cc1 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -40,17 +40,6 @@ static void ceph_put_super(struct super_block *s)
 
 	dout("put_super\n");
 	ceph_mdsc_close_sessions(fsc->mdsc);
-
-	/*
-	 * ensure we release the bdi before put_anon_super releases
-	 * the device name.
-	 */
-	if (s->s_bdi == &fsc->backing_dev_info) {
-		bdi_unregister(&fsc->backing_dev_info);
-		s->s_bdi = NULL;
-	}
-
-	return;
 }
 
 static int ceph_statfs(struct dentry *dentry, struct kstatfs *buf)
@@ -1002,11 +991,16 @@ out_final:
 static void ceph_kill_sb(struct super_block *s)
 {
 	struct ceph_fs_client *fsc = ceph_sb_to_client(s);
+	dev_t dev = s->s_dev;
+
 	dout("kill_sb %p\n", s);
+
 	ceph_mdsc_pre_umount(fsc->mdsc);
-	kill_anon_super(s);    /* will call put_super after sb is r/o */
+	generic_shutdown_super(s);
 	ceph_mdsc_destroy(fsc);
+
 	destroy_fs_client(fsc);
+	free_anon_bdev(dev);
 }
 
 static struct file_system_type ceph_fs_type = {
-- 
1.9.1

