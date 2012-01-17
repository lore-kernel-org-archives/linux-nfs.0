Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50558 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754957Ab2AQQAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:00:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 5/6] locks: break delegations on any attribute modification
Date: Tue, 17 Jan 2012 11:00:28 -0500
Message-Id: <1326816029-13913-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1326816029-13913-1-git-send-email-bfields@redhat.com>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
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
index 7ee7ba4..15a2a09 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -232,6 +232,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
+	error = break_lease(inode, BREAK_ONLY_DELEGS|BREAK_ALL_LEASES);
+	if (error)
+		return error;
 
 	if (inode->i_op->setattr)
 		error = inode->i_op->setattr(dentry, attr);
-- 
1.7.5.4

