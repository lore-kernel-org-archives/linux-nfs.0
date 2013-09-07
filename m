Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50823 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527Ab3IGSqN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 14:46:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] dcache: don't clear DCACHE_DISCONNECTED too early
Date: Sat,  7 Sep 2013 14:46:01 -0400
Message-Id: <1378579561-26868-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1378579561-26868-1-git-send-email-bfields@redhat.com>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

DCACHE_DISCONNECTED should not be cleared until we're sure the dentry is
connected all the way up to the root of the filesystem.  It *shouldn't*
be cleared as soon as the dentry is connected to a parent.  That will
cause bugs at least on exportable filesystems.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index a53f55d..a4560ca 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2404,7 +2404,6 @@ static void __d_materialise_dentry(struct dentry *dentry, struct dentry *anon)
 	spin_unlock(&dentry->d_lock);
 
 	/* anon->d_lock still locked, returns locked */
-	anon->d_flags &= ~DCACHE_DISCONNECTED;
 }
 
 /**
-- 
1.7.9.5

