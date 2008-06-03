From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] VM: add kzalloc_node inline
Date: Tue, 03 Jun 2008 07:17:57 -0400
Message-ID: <20080603111757.8769.69366.stgit@dantu.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbYFCLR7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jun 2008 07:17:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...to get zeroed out memory from a particular NUMA node

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---

 include/linux/slab.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 805ed4b..c2ad350 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -276,6 +276,17 @@ static inline void *kzalloc(size_t size, gfp_t flags)
 	return kmalloc(size, flags | __GFP_ZERO);
 }
 
+/**
+ * kzalloc_node - allocate zeroed memory from a particular memory node.
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kmalloc).
+ * @node: memory node from which to allocate
+ */
+static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
+{
+	return kmalloc_node(size, flags | __GFP_ZERO, node);
+}
+
 #ifdef CONFIG_SLABINFO
 extern const struct seq_operations slabinfo_op;
 ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);

