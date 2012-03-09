Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47726 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756821Ab2CIW3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:29:37 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] locks: break delegations on any attribute modification
Date: Fri,  9 Mar 2012 17:29:34 -0500
Message-Id: <1331332174-22621-7-git-send-email-bfields@redhat.com>
In-Reply-To: <20120309222114.GA22423@fieldses.org>
References: <20120309222114.GA22423@fieldses.org>
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
index 95053ad..b8b5676 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -232,6 +232,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
+	error = break_deleg(inode, O_WRONLY);
+	if (error)
+		return error;
 
 	if (inode->i_op->setattr)
 		error = inode->i_op->setattr(dentry, attr);
-- 
1.7.5.4

