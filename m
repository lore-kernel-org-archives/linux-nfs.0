From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/24] NFS: Prevent the mount code from looping forever on broken exports
Date: Fri, 16 Apr 2010 16:31:22 -0400
Message-ID: <1271449882-8580-25-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-21-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-22-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-23-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-24-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16405 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932488Ab0DPUbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:43 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlJ026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:39 -0700 (PDT)
In-Reply-To: <1271449882-8580-24-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep a global count of how many referrals that the current task has
traversed on a path lookup. Return ELOOP if the count exceeds
MAX_NESTED_LINKS.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cb196eb..33f355f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2672,6 +2672,72 @@ out_freepage:
 	free_page((unsigned long)page);
 }
 
+struct nfs_referral_count {
+	struct list_head list;
+	const struct task_struct *task;
+	unsigned int referral_count;
+};
+
+static LIST_HEAD(nfs_referral_count_list);
+static DEFINE_SPINLOCK(nfs_referral_count_list_lock);
+
+static struct nfs_referral_count *nfs_find_referral_count(void)
+{
+	struct nfs_referral_count *p;
+
+	list_for_each_entry(p, &nfs_referral_count_list, list) {
+		if (p->task == current)
+			return p;
+	}
+	return NULL;
+}
+
+#define NFS_MAX_NESTED_REFERRALS 2
+
+static int nfs_referral_loop_protect(void)
+{
+	struct nfs_referral_count *p, *new;
+	int ret = -ENOMEM;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		goto out;
+	new->task = current;
+	new->referral_count = 1;
+
+	ret = 0;
+	spin_lock(&nfs_referral_count_list_lock);
+	p = nfs_find_referral_count();
+	if (p != NULL) {
+		if (p->referral_count >= NFS_MAX_NESTED_REFERRALS)
+			ret = -ELOOP;
+		else
+			p->referral_count++;
+	} else {
+		list_add(&new->list, &nfs_referral_count_list);
+		new = NULL;
+	}
+	spin_unlock(&nfs_referral_count_list_lock);
+	kfree(new);
+out:
+	return ret;
+}
+
+static void nfs_referral_loop_unprotect(void)
+{
+	struct nfs_referral_count *p;
+
+	spin_lock(&nfs_referral_count_list_lock);
+	p = nfs_find_referral_count();
+	p->referral_count--;
+	if (p->referral_count == 0)
+		list_del(&p->list);
+	else
+		p = NULL;
+	spin_unlock(&nfs_referral_count_list_lock);
+	kfree(p);
+}
+
 static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 		const char *export_path, struct vfsmount *mnt_target)
 {
@@ -2689,9 +2755,14 @@ static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 	if (IS_ERR(ns_private))
 		goto out_mntput;
 
+	ret = nfs_referral_loop_protect();
+	if (ret != 0)
+		goto out_put_mnt_ns;
+
 	ret = vfs_path_lookup(root_mnt->mnt_root, root_mnt,
 			export_path, LOOKUP_FOLLOW, nd);
 
+	nfs_referral_loop_unprotect();
 	put_mnt_ns(ns_private);
 
 	if (ret != 0)
@@ -2709,6 +2780,8 @@ static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 	kfree(nd);
 	down_write(&s->s_umount);
 	return 0;
+out_put_mnt_ns:
+	put_mnt_ns(ns_private);
 out_mntput:
 	mntput(root_mnt);
 out_err:
-- 
1.6.6.1

