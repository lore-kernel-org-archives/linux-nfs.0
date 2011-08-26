Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15005 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202Ab1HZUw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 16:52:58 -0400
Message-ID: <4E5807A8.2020600@netapp.com>
Date: Fri, 26 Aug 2011 16:52:56 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Add "device" tag to /proc/self/mountstats
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfsiostat was failing to find mounted filesystems on recent kernels due
to changes in the VFS that resulted in a missing "device" tag in the
/proc/self/mountstats file.  This patch re-adds the "device" tag for NFS
mount data in /proc/self/mountstats.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b961cea..e6a0317 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -766,8 +766,10 @@ static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
 	devname = nfs_path(&dummy, mnt->mnt_root, page, PAGE_SIZE);
 	if (IS_ERR(devname))
 		err = PTR_ERR(devname);
-	else
+	else {
+		seq_puts(m, "device ");
 		seq_escape(m, devname, " \t\n\\");
+	}
 	free_page((unsigned long)page);
 	return err;
 }
-- 
1.7.6
