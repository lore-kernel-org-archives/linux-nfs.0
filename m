Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59110 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab1IUO63 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 10:58:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/6] leases: break leases on any attribute modification
Date: Wed, 21 Sep 2011 10:58:16 -0400
Message-Id: <1316617097-21384-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1316617097-21384-1-git-send-email-bfields@redhat.com>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFSv4 uses leases to guarantee that clients can cash metadata as well as
data.

(I suspect the same is true for Samba.)

This covers chmod, chown, etc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/attr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 538e279..4ce31cb 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -231,6 +231,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
+	error = break_lease(inode, O_WRONLY);
+	if (error)
+		return error;
 
 	if (inode->i_op->setattr)
 		error = inode->i_op->setattr(dentry, attr);
-- 
1.7.4.1

