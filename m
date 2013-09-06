Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49117 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503Ab3IFPny (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 11:43:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        Nick Piggin <npiggin@kernel.dk>
Subject: [PATCH 2/3] dcache: Don't set DISCONNECTED on "pseudo filesystem" dentries
Date: Fri,  6 Sep 2013 11:43:49 -0400
Message-Id: <1378482230-16312-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1378482230-16312-1-git-send-email-bfields@redhat.com>
References: <1378482230-16312-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I can't for the life of me see any reason why anyone would care whether
a dentry that is never hooked into the dentry cache would need
DCACHE_DISCONNECTED set.

This originates from 4b936885ab04dc6e0bb0ef35e0e23c1a7364d9e5 "fs:
improve scalability of pseudo filesystems", which probably just made the
false assumption the DCACHE_DISCONNECTED was meant to be set on anything
not connected to a parent somehow.

So this is just confusing.  Ideally the only uses of DCACHE_DISCONNECTED
would be in the filehandle-lookup code, which needs it to ensure
dentries are connected into the dentry tree before use.

I left d_alloc_pseudo there even though it's now equivalent to
__d_alloc(), just on the theory the name is better documentation of its
intended use outside dcache.c.

Cc: Nick Piggin <npiggin@kernel.dk>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 934f02d..ec66780 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1308,12 +1308,13 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 }
 EXPORT_SYMBOL(d_alloc);
 
+/*
+ * For filesystems that do not actually use the dentry cache at all, and
+ * only ever deal in IS_ROOT() dentries:
+ */
 struct dentry *d_alloc_pseudo(struct super_block *sb, const struct qstr *name)
 {
-	struct dentry *dentry = __d_alloc(sb, name);
-	if (dentry)
-		dentry->d_flags |= DCACHE_DISCONNECTED;
-	return dentry;
+	return __d_alloc(sb, name);
 }
 EXPORT_SYMBOL(d_alloc_pseudo);
 
-- 
1.7.9.5

