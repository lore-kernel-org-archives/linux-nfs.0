Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52438 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156Ab0LQRx7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 12:53:59 -0500
Date: Fri, 17 Dec 2010 12:53:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nick Piggin <npiggin@kernel.dk>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH] fs/dcache: use standard list macro for d_find_alias
Message-ID: <20101217175355.GA11515@fieldses.org>
References: <20101112184353.GA32745@fieldses.org>
 <AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
 <20101115174837.GB10044@fieldses.org>
 <AANLkTim1QjTwOZ4SHdMy8Y6TOAnaOYtTwgwHXfH5H5Xn@mail.gmail.com>
 <AANLkTinMq1W1vx-jZnf7cb1cAnh9OyoVRYtVS7zpujfs@mail.gmail.com>
 <20101129193248.GA9897@fieldses.org>
 <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
 <20101203223326.GB28763@fieldses.org>
 <20101213051944.GA8688@amd>
 <20101214220102.GM24828@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101214220102.GM24828@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

While I'm here....  Am I overlooking some reason we're not doing this
the easy way?

diff --git a/fs/dcache.c b/fs/dcache.c
index 23702a9..5ed93cd 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -358,16 +358,9 @@ EXPORT_SYMBOL(dget_locked);
 
 static struct dentry * __d_find_alias(struct inode *inode, int want_discon)
 {
-	struct list_head *head, *next, *tmp;
 	struct dentry *alias, *discon_alias=NULL;
 
-	head = &inode->i_dentry;
-	next = inode->i_dentry.next;
-	while (next != head) {
-		tmp = next;
-		next = tmp->next;
-		prefetch(next);
-		alias = list_entry(tmp, struct dentry, d_alias);
+	list_for_each_entry(alias, &inode->i_dentry, d_alias) {
  		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
 			if (IS_ROOT(alias) &&
 			    (alias->d_flags & DCACHE_DISCONNECTED))
-- 
1.7.1

