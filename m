From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH] VFS: Unlink should revoke all outstanding leases on file
Date: Fri, 14 May 2010 17:35:27 +0800
Message-ID: <4BED195F.3070504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org
To: NFSv3 list <linux-nfs@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55776 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752869Ab0ENJct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 05:32:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After client get one file's READ delegation through NFSv4,
server delete this file but don't reclaim the delegation.

This patch add break_lease at may_delete, which can reclaim delegations.

---
 fs/namei.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 16df727..17bafc1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1338,7 +1338,7 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
 		return -ENOENT;
 	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
 		return -EBUSY;
-	return 0;
+	return break_lease(victim->d_inode, FMODE_WRITE);
 }
 
 /*	Check whether we can create an object with dentry child in directory
-- 
1.7.0



