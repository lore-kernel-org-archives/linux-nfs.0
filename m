From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 33/33] make nfs_automount_list static
Date: Sat, 19 Apr 2008 16:40:55 -0400
Message-ID: <20080419204055.14124.6787.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Adrian Bunk <bunk@kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756459AbYDSUu3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:29 -0400
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

nfs_automount_list can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/namespace.c     |    2 +-
 include/linux/nfs_fs.h |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 607f6eb..af4d0f1 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -20,7 +20,7 @@
 
 static void nfs_expire_automounts(struct work_struct *work);
 
-LIST_HEAD(nfs_automount_list);
+static LIST_HEAD(nfs_automount_list);
 static DECLARE_DELAYED_WORK(nfs_automount_task, nfs_expire_automounts);
 int nfs_mountpoint_expiry_timeout = 500 * HZ;
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7f0602c..27d6a8d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -430,7 +430,6 @@ extern void nfs_unregister_sysctl(void);
 /*
  * linux/fs/nfs/namespace.c
  */
-extern struct list_head nfs_automount_list;
 extern const struct inode_operations nfs_mountpoint_inode_operations;
 extern const struct inode_operations nfs_referral_inode_operations;
 extern int nfs_mountpoint_expiry_timeout;

