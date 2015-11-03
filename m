Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932357AbbKCPUh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 10:20:37 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v13 26/51] xfs: Plug memory leak in xfs_attrmulti_attr_set
Date: Tue,  3 Nov 2015 16:17:02 +0100
Message-Id: <1446563847-14005-27-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When setting attributes via XFS_IOC_ATTRMULTI_BY_HANDLE, the user-space
buffer is copied into a new kernel-space buffer via memdup_user; that
buffer then isn't freed.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Dave Chinner <david@fromorbit.com>
---
 fs/xfs/xfs_ioctl.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index ea7d85a..e939c20 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -482,6 +482,7 @@ xfs_attrmulti_attr_set(
 	__uint32_t		flags)
 {
 	unsigned char		*kbuf;
+	int			error;
 
 	if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
 		return -EPERM;
@@ -492,7 +493,9 @@ xfs_attrmulti_attr_set(
 	if (IS_ERR(kbuf))
 		return PTR_ERR(kbuf);
 
-	return xfs_attr_set(XFS_I(inode), name, kbuf, len, flags);
+	error = xfs_attr_set(XFS_I(inode), name, kbuf, len, flags);
+	kfree(kbuf);
+	return error;
 }
 
 int
-- 
2.5.0

