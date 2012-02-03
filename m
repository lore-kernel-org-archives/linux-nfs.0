Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757548Ab2BCVKB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 16:10:01 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/6] locks: break delegations on any attribute modification
Date: Fri,  3 Feb 2012 16:09:56 -0500
Message-Id: <1328303397-3872-6-git-send-email-bfields@redhat.com>
In-Reply-To: <20120203205818.GE2999@fieldses.org>
References: <20120203205818.GE2999@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

NFSv4 uses leases to guarantee that clients can cache metadata as well
as data.

This covers chmod, chown, etc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/attr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 95053ad..ac97995 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -232,6 +232,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
+	error = break_lease(inode, BREAK_ONLY_DELEGS|BREAK_R_AND_W_LEASES);
+	if (error)
+		return error;
 
 	if (inode->i_op->setattr)
 		error = inode->i_op->setattr(dentry, attr);
-- 
1.7.5.4

