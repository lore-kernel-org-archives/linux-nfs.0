Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47724 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab2CIW3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:29:37 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] locks: break delegations on rename
Date: Fri,  9 Mar 2012 17:29:32 -0500
Message-Id: <1331332174-22621-5-git-send-email-bfields@redhat.com>
In-Reply-To: <20120309222114.GA22423@fieldses.org>
References: <20120309222114.GA22423@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index eb4166f..21a1d65 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3092,6 +3092,14 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
 		goto out;
 
+	error = break_deleg(source, O_WRONLY);
+	if (error)
+		goto out;
+	if (target) {
+		error = break_deleg(target, O_WRONLY);
+		if (error)
+			goto out;
+	}
 	error = old_dir->i_op->rename(old_dir, old_dentry, new_dir, new_dentry);
 	if (error)
 		goto out;
-- 
1.7.5.4

