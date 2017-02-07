Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33368 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753433AbdBGNuF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:50:05 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so12866688iom.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:50:05 -0800 (PST)
Subject: [PATCH 6/7] sunrpc: record rpc client pointer in seq->private
 directly
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <61d64474-fad2-7dc5-10e9-0034e03d704b@gmail.com>
Date: Tue, 7 Feb 2017 21:49:57 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pos in rpc_clnt_iter is useless, drop it and record clnt in seq_private.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/debugfs.c | 35 ++++++++++-------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index e7b4d93..c8fd0b6 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -16,11 +16,6 @@ static struct dentry *rpc_xprt_dir;
 
 unsigned int rpc_inject_disconnect;
 
-struct rpc_clnt_iter {
-	struct rpc_clnt	*clnt;
-	loff_t		pos;
-};
-
 static int
 tasks_show(struct seq_file *f, void *v)
 {
@@ -47,12 +42,10 @@ static void *
 tasks_start(struct seq_file *f, loff_t *ppos)
 	__acquires(&clnt->cl_lock)
 {
-	struct rpc_clnt_iter *iter = f->private;
+	struct rpc_clnt *clnt = f->private;
 	loff_t pos = *ppos;
-	struct rpc_clnt *clnt = iter->clnt;
 	struct rpc_task *task;
 
-	iter->pos = pos + 1;
 	spin_lock(&clnt->cl_lock);
 	list_for_each_entry(task, &clnt->cl_tasks, tk_task)
 		if (pos-- == 0)
@@ -63,12 +56,10 @@ tasks_start(struct seq_file *f, loff_t *ppos)
 static void *
 tasks_next(struct seq_file *f, void *v, loff_t *pos)
 {
-	struct rpc_clnt_iter *iter = f->private;
-	struct rpc_clnt *clnt = iter->clnt;
+	struct rpc_clnt *clnt = f->private;
 	struct rpc_task *task = v;
 	struct list_head *next = task->tk_task.next;
 
-	++iter->pos;
 	++*pos;
 
 	/* If there's another task on list, return it */
@@ -81,9 +72,7 @@ static void
 tasks_stop(struct seq_file *f, void *v)
 	__releases(&clnt->cl_lock)
 {
-	struct rpc_clnt_iter *iter = f->private;
-	struct rpc_clnt *clnt = iter->clnt;
-
+	struct rpc_clnt *clnt = f->private;
 	spin_unlock(&clnt->cl_lock);
 }
 
@@ -96,17 +85,13 @@ static const struct seq_operations tasks_seq_operations = {
 
 static int tasks_open(struct inode *inode, struct file *filp)
 {
-	int ret = seq_open_private(filp, &tasks_seq_operations,
-					sizeof(struct rpc_clnt_iter));
-
+	int ret = seq_open(filp, &tasks_seq_operations);
 	if (!ret) {
 		struct seq_file *seq = filp->private_data;
-		struct rpc_clnt_iter *iter = seq->private;
-
-		iter->clnt = inode->i_private;
+		struct rpc_clnt *clnt = seq->private = inode->i_private;
 
-		if (!atomic_inc_not_zero(&iter->clnt->cl_count)) {
-			seq_release_private(inode, filp);
+		if (!atomic_inc_not_zero(&clnt->cl_count)) {
+			seq_release(inode, filp);
 			ret = -EINVAL;
 		}
 	}
@@ -118,10 +103,10 @@ static int
 tasks_release(struct inode *inode, struct file *filp)
 {
 	struct seq_file *seq = filp->private_data;
-	struct rpc_clnt_iter *iter = seq->private;
+	struct rpc_clnt *clnt = seq->private;
 
-	rpc_release_client(iter->clnt);
-	return seq_release_private(inode, filp);
+	rpc_release_client(clnt);
+	return seq_release(inode, filp);
 }
 
 static const struct file_operations tasks_fops = {
-- 
2.9.3

