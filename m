Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756564Ab1LNNyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:54:54 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDssfi025788
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:54:54 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDspPm026219
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:54:53 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] nfsd: add the infrastructure to handle the clstate upcall
Date: Wed, 14 Dec 2011 08:54:51 -0500
Message-Id: <1323870891-3124-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
References: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and add a mechanism for switching between the "legacy" tracker and
the new one. The decision is made by looking to see whether the
v4recoverydir exists. If it does, then the legacy client tracker is
used.

If it's not, then the kernel will create a "clstate" pipe in rpc_pipefs.
That pipe is used to talk to a daemon for handling the upcall.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |  321 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 320 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 62fd534..a754293 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1,5 +1,6 @@
 /*
 *  Copyright (c) 2004 The Regents of the University of Michigan.
+*  Copyright (c) 2011 Jeff Layton <jlayton@redhat.com>
 *  All rights reserved.
 *
 *  Andy Adamson <andros@citi.umich.edu>
@@ -36,6 +37,10 @@
 #include <linux/namei.h>
 #include <linux/crypto.h>
 #include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfsd/clstate.h>
 
 #include "nfsd.h"
 #include "state.h"
@@ -467,12 +472,326 @@ static const struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
 	.grace_done	= nfsd4_recdir_purge_old,
 };
 
+/* Globals */
+#define NFSD_PIPE_DIR		"/nfsd"
+
+static struct dentry *clstate_pipe;
+
+/* list of clstate_msg's that are currently in use */
+static DEFINE_SPINLOCK(clstate_lock);
+static LIST_HEAD(clstate_list);
+static unsigned int clstate_xid;
+
+struct clstate_upcall {
+	struct list_head	cu_list;
+	struct task_struct *	cu_task;
+	struct clstate_msg	cu_msg;
+};
+
+static int
+nfsd4_clstate_upcall(struct clstate_msg *cmsg)
+{
+	int ret;
+	struct rpc_pipe_msg msg;
+
+	memset(&msg, 0, sizeof(msg));
+	msg.data = cmsg;
+	msg.len = sizeof(*cmsg);
+
+	ret = rpc_queue_upcall(clstate_pipe->d_inode, &msg);
+	if (ret < 0)
+		goto out;
+
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	__set_current_state(TASK_RUNNING);
+
+out:
+	return ret;
+}
+
+ssize_t clstate_pipe_downcall(struct file *filp, const char __user *src,
+			     size_t mlen)
+{
+	struct clstate_upcall *tmp, *cup;
+	struct clstate_msg *cmsg = (struct clstate_msg *)src;
+	uint32_t xid;
+
+	if (mlen != sizeof(*cmsg)) {
+		dprintk("%s: got %lu bytes, expected %lu\n", __func__, mlen,
+			sizeof(*cmsg));
+		return -EINVAL;
+	}
+
+	/* copy just the xid so we can try to find that */
+	if (copy_from_user(&xid, &cmsg->cm_xid, sizeof(xid)) != 0) {
+		dprintk("%s: error when copying xid from userspace", __func__);
+		return -EFAULT;
+	}
+
+	/* walk the list and find corresponding xid */
+	cup = NULL;
+	spin_lock(&clstate_lock);
+	list_for_each_entry(tmp, &clstate_list, cu_list) {
+		if (get_unaligned(&tmp->cu_msg.cm_xid) == xid) {
+			cup = tmp;
+			list_del_init(&cup->cu_list);
+			break;
+		}
+	}
+	spin_unlock(&clstate_lock);
+
+	/* couldn't find upcall? */
+	if (!cup) {
+		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__,
+			cup->cu_msg.cm_xid);
+		return -EINVAL;
+	}
+
+	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
+		return -EFAULT;
+
+	wake_up_process(cup->cu_task);
+	return mlen;
+}
+
+void
+clstate_pipe_destroy_msg(struct rpc_pipe_msg *msg)
+{
+	struct clstate_msg *cmsg = msg->data;
+	struct clstate_upcall *cup = container_of(cmsg, struct clstate_upcall,
+						 cu_msg);
+
+	if (msg->errno >= 0)
+		return;
+	wake_up_process(cup->cu_task);
+}
+
+static const struct rpc_pipe_ops clstate_upcall_ops = {
+	.upcall		= rpc_pipe_generic_upcall,
+	.downcall	= clstate_pipe_downcall,
+	.destroy_msg	= clstate_pipe_destroy_msg,
+};
+
+int
+nfsd4_init_clstate_pipe(void)
+{
+	int ret;
+	struct path path;
+	struct vfsmount *mnt;
+
+	if (clstate_pipe)
+		return 0;
+
+	mnt = rpc_get_mount();
+	if (IS_ERR(mnt))
+		return PTR_ERR(mnt);
+
+	ret = vfs_path_lookup(mnt->mnt_root, mnt, NFSD_PIPE_DIR, 0, &path);
+	if (ret)
+		goto err;
+
+	clstate_pipe = rpc_mkpipe(path.dentry, "clstate", NULL,
+				 &clstate_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
+	path_put(&path);
+	if (!IS_ERR(clstate_pipe))
+		return 0;
+
+	ret = PTR_ERR(clstate_pipe);
+err:
+	rpc_put_mount();
+	return ret;
+}
+
+void
+nfsd4_remove_clstate_pipe(void)
+{
+	int ret;
+
+	ret = rpc_unlink(clstate_pipe);
+	if (ret)
+		printk(KERN_ERR "NFSD: error removing clstate pipe: %d\n", ret);
+	clstate_pipe = NULL;
+	rpc_put_mount();
+}
+
+static struct clstate_upcall *
+alloc_clstate_upcall(void)
+{
+	struct clstate_upcall *new, *tmp;
+
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return new;
+
+	/* FIXME: hard cap on number in flight? */
+restart_search:
+	spin_lock(&clstate_lock);
+	list_for_each_entry(tmp, &clstate_list, cu_list) {
+		if (tmp->cu_msg.cm_xid == clstate_xid) {
+			clstate_xid++;
+			spin_unlock(&clstate_lock);
+			goto restart_search;
+		}
+	}
+	new->cu_task = current;
+	new->cu_msg.cm_vers = CLSTATE_MAX_UPCALL_VERSION;
+	put_unaligned(clstate_xid++, &new->cu_msg.cm_xid);
+	list_add(&new->cu_list, &clstate_list);
+	spin_unlock(&clstate_lock);
+
+	dprintk("%s: allocated xid %u\n", __func__, new->cu_msg.cm_xid);
+
+	return new;
+}
+
+static void
+free_clstate_upcall(struct clstate_upcall *victim)
+{
+	spin_lock(&clstate_lock);
+	list_del(&victim->cu_list);
+	spin_unlock(&clstate_lock);
+	kfree(victim);
+}
+
+/* Ask daemon to create a new record */
+static int
+nfsd4_clstate_create(struct nfs4_client *clp)
+{
+	int ret;
+	struct clstate_upcall *cup;
+
+	/* Don't upcall if it's already stored */
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return -EEXIST;
+
+	cup = alloc_clstate_upcall();
+	if (!cup)
+		return -ENOMEM;
+
+	cup->cu_msg.cm_cmd = Cl_Create;
+	cup->cu_msg.cm_len = clp->cl_name.len;
+	memcpy(cup->cu_msg.cm_u.cm_id, clp->cl_name.data, clp->cl_name.len);
+	rpc_ntop((struct sockaddr *)&clp->cl_daddr, cup->cu_msg.cm_addr,
+			sizeof(cup->cu_msg.cm_addr));
+
+	ret = nfsd4_clstate_upcall(&cup->cu_msg);
+	if (!ret) {
+		ret = cup->cu_msg.cm_status;
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+	}
+
+	free_clstate_upcall(cup);
+	return ret;
+}
+
+/* Ask daemon to remove a record */
+static int
+nfsd4_clstate_remove(struct nfs4_client *clp)
+{
+	int ret;
+	struct clstate_upcall *cup;
+
+	/* Don't upcall if it's already stored */
+	if (!test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return -ENOENT;
+
+	cup = alloc_clstate_upcall();
+	if (!cup)
+		return -ENOMEM;
+
+	cup->cu_msg.cm_cmd = Cl_Expire;
+	cup->cu_msg.cm_len = clp->cl_name.len;
+	memcpy(cup->cu_msg.cm_u.cm_id, clp->cl_name.data, clp->cl_name.len);
+	rpc_ntop((struct sockaddr *)&clp->cl_daddr, cup->cu_msg.cm_addr,
+			sizeof(cup->cu_msg.cm_addr));
+
+	ret = nfsd4_clstate_upcall(&cup->cu_msg);
+	if (!ret) {
+		ret = cup->cu_msg.cm_status;
+		clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+	}
+
+	free_clstate_upcall(cup);
+	return ret;
+}
+
+/* Check for presence of a record, and update its timestamp */
+static int
+nfsd4_clstate_check(struct nfs4_client *clp)
+{
+	int ret;
+	struct clstate_upcall *cup;
+
+	/* Don't upcall if we know there's already a record */
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return -ENOENT;
+
+	cup = alloc_clstate_upcall();
+	if (!cup)
+		return -ENOMEM;
+
+	cup->cu_msg.cm_cmd = Cl_Allow;
+	cup->cu_msg.cm_len = clp->cl_name.len;
+	memcpy(cup->cu_msg.cm_u.cm_id, clp->cl_name.data, clp->cl_name.len);
+	rpc_ntop((struct sockaddr *)&clp->cl_daddr, cup->cu_msg.cm_addr,
+			sizeof(cup->cu_msg.cm_addr));
+
+	ret = nfsd4_clstate_upcall(&cup->cu_msg);
+	if (!ret) {
+		ret = cup->cu_msg.cm_status;
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+	}
+
+	free_clstate_upcall(cup);
+	return ret;
+}
+
+static int
+nfsd4_clstate_grace_done(time_t boot_time)
+{
+	int ret;
+	struct clstate_upcall *cup;
+
+	cup = alloc_clstate_upcall();
+	if (!cup)
+		return -ENOMEM;
+
+	cup->cu_msg.cm_cmd = Cl_GraceDone;
+	cup->cu_msg.cm_u.cm_gracetime = (int64_t)boot_time;
+	ret = nfsd4_clstate_upcall(&cup->cu_msg);
+	if (!ret)
+		ret = cup->cu_msg.cm_status;
+
+	free_clstate_upcall(cup);
+	return ret;
+}
+
+static const struct nfsd4_client_tracking_ops nfsd4_clstate_tracking_ops = {
+	.init		= nfsd4_init_clstate_pipe,
+	.exit		= nfsd4_remove_clstate_pipe,
+	.create		= nfsd4_clstate_create,
+	.remove		= nfsd4_clstate_remove,
+	.check		= nfsd4_clstate_check,
+	.grace_done	= nfsd4_clstate_grace_done,
+};
+
 int
 nfsd4_client_tracking_init(void)
 {
 	int status;
+	struct path path;
 
-	client_tracking_ops = &nfsd4_legacy_tracking_ops;
+	if (!client_tracking_ops) {
+		client_tracking_ops = &nfsd4_clstate_tracking_ops;
+		status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
+		if (!status) {
+			if (S_ISDIR(path.dentry->d_inode->i_mode))
+				client_tracking_ops =
+						&nfsd4_legacy_tracking_ops;
+			path_put(&path);
+		}
+	}
 	status = client_tracking_ops->init();
 	if (status) {
 		printk(KERN_WARNING "NFSD: Unable to initialize client "
-- 
1.7.1

