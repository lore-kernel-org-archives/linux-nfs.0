Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36742 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbbC0Qvn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:51:43 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 03/39] vfs: Shrink struct posix_acl
Date: Fri, 27 Mar 2015 17:50:01 +0100
Message-Id: <b43adc91dab492ac565715aa5168d375bb3ec0d1.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a hole in struct posix_acl because its struct rcu_head member is too
large; at least on on 64-bit architectures, the hole cannot be closed by
changing the definition of struct posix_acl. So instead, remove the struct
rcu_head member from struct posix_acl, make sure that acls are always big
enough to fit a struct rcu_head, and cast to struct rcu_head * when disposing
of an acl.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/posix_acl.c            | 5 +++--
 include/linux/posix_acl.h | 7 ++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 3a48bb7..efe983e 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -140,8 +140,9 @@ EXPORT_SYMBOL(posix_acl_init);
 struct posix_acl *
 posix_acl_alloc(int count, gfp_t flags)
 {
-	const size_t size = sizeof(struct posix_acl) +
-	                    count * sizeof(struct posix_acl_entry);
+	const size_t size = max(sizeof(struct rcu_head),
+		sizeof(struct posix_acl) +
+		count * sizeof(struct posix_acl_entry));
 	struct posix_acl *acl = kmalloc(size, flags);
 	if (acl)
 		posix_acl_init(acl, count);
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 3e96a6a..66cf477 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -43,10 +43,7 @@ struct posix_acl_entry {
 };
 
 struct posix_acl {
-	union {
-		atomic_t		a_refcount;
-		struct rcu_head		a_rcu;
-	};
+	atomic_t		a_refcount;
 	unsigned int		a_count;
 	struct posix_acl_entry	a_entries[0];
 };
@@ -73,7 +70,7 @@ static inline void
 posix_acl_release(struct posix_acl *acl)
 {
 	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		kfree_rcu(acl, a_rcu);
+		__kfree_rcu((struct rcu_head *)acl, 0);
 }
 
 
-- 
2.1.0

