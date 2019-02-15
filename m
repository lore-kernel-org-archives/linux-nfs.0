Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71325C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:09:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37D26222A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:09:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391895AbfBOQJB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:09:01 -0500
Received: from mx1.redhat.com ([209.132.183.28]:44798 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729453AbfBOQJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:09:01 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3ACCC4FCDB;
        Fri, 15 Feb 2019 16:09:00 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3E992600C7;
        Fri, 15 Feb 2019 16:08:58 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 10/27] containers: Provide fs_context op for container
 setting
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:08:57 +0000
Message-ID: <155024693750.21651.5133054585005541648.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 15 Feb 2019 16:09:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide an fs_context op to notify a filesystem that a container has been
set.  The filesystem should do whatever cleanup it needs, then call
do_set_container() and then re-set its container/namespace dependent stuff.

This allows the following:

 (1) proc and mqueue mounts to set the correct pid and ipc namespaces
     respectively.

 (2) afs to discard the old default cell before the net namespace is
     changed (ie. while it is still pinned), after which it can get the new
     default cell.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/super.c             |   18 ++++++++++++++++++
 fs/fs_context.c            |   32 ++++++++++++++++++++++++++------
 fs/proc/root.c             |    9 +++++++++
 include/linux/fs_context.h |    2 ++
 ipc/mqueue.c               |   10 ++++++++++
 5 files changed, 65 insertions(+), 6 deletions(-)

diff --git a/fs/afs/super.c b/fs/afs/super.c
index 4e33a7038bc5..a349e213bdc8 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -569,6 +569,23 @@ static int afs_get_tree(struct fs_context *fc)
 	return ret;
 }
 
+static void afs_set_container(struct fs_context *fc)
+{
+	struct afs_fs_context *ctx = fc->fs_private;
+	struct afs_cell *cell;
+
+	afs_put_cell(ctx->net, ctx->cell);
+	do_set_container(fc);
+
+	/* Default to the workstation cell. */
+	rcu_read_lock();
+	cell = afs_lookup_cell_rcu(ctx->net, NULL, 0);
+	rcu_read_unlock();
+	if (IS_ERR(cell))
+		cell = NULL;
+	ctx->cell = cell;
+}
+
 static void afs_free_fc(struct fs_context *fc)
 {
 	struct afs_fs_context *ctx = fc->fs_private;
@@ -583,6 +600,7 @@ static void afs_free_fc(struct fs_context *fc)
 static const struct fs_context_operations afs_context_ops = {
 	.free		= afs_free_fc,
 	.parse_param	= afs_parse_param,
+	.set_container	= afs_set_container,
 	.get_tree	= afs_get_tree,
 };
 
diff --git a/fs/fs_context.c b/fs/fs_context.c
index fc76ac02d618..c0f333cc0e16 100644
--- a/fs/fs_context.c
+++ b/fs/fs_context.c
@@ -170,18 +170,38 @@ int vfs_parse_fs_param(struct fs_context *fc, struct fs_parameter *param)
 }
 EXPORT_SYMBOL(vfs_parse_fs_param);
 
+/**
+ * do_set_container - Helper to set container
+ * @fc: The fs_context to adjust
+ *
+ * This is called to effect the change of namespaces associated with the
+ * container.  The reason that this isn't rolled into vfs_set_container() is
+ * that the filesystem may need to do some cleanup on the old namespaces (which
+ * are currently pinned by the container) before calling this.
+ *
+ * The user namespace is not changed as that is used for security checks.
+ */
+void do_set_container(struct fs_context *fc)
+{
+	put_net(fc->net_ns);
+	fc->net_ns = get_net(fc->container->ns->net_ns);
+}
+EXPORT_SYMBOL(do_set_container);
+
 /*
- * Specify a container in which a superblock will exist.
+ * Specify a container in which a superblock will exist.  This should be called
+ * before calling vfs_parse_fs_param.  If ->set_container() is supplied by the
+ * filesystem, it should call do_set_container().
  */
 void vfs_set_container(struct fs_context *fc, struct container *container)
 {
 	if (container) {
-		put_user_ns(fc->user_ns);
-		put_net(fc->net_ns);
-
+		put_container(fc->container);
 		fc->container = get_container(container);
-		fc->user_ns = get_user_ns(container->cred->user_ns);
-		fc->net_ns = get_net(container->ns->net_ns);
+		if (fc->ops->set_container)
+			fc->ops->set_container(fc);
+		else
+			do_set_container(fc);
 	}
 }
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index aa802006d855..f8e124ce0888 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -164,6 +164,14 @@ static int proc_get_tree(struct fs_context *fc)
 	return vfs_get_super(fc, vfs_get_keyed_super, proc_fill_super);
 }
 
+static void proc_set_container(struct fs_context *fc)
+{
+	struct proc_fs_context *ctx = fc->fs_private;
+
+	put_pid_ns(ctx->pid_ns);
+	ctx->pid_ns = get_pid_ns(fc->container->pid_ns);
+}
+
 static void proc_fs_context_free(struct fs_context *fc)
 {
 	struct proc_fs_context *ctx = fc->fs_private;
@@ -176,6 +184,7 @@ static void proc_fs_context_free(struct fs_context *fc)
 static const struct fs_context_operations proc_fs_context_ops = {
 	.free		= proc_fs_context_free,
 	.parse_param	= proc_parse_param,
+	.set_container	= proc_set_container,
 	.get_tree	= proc_get_tree,
 	.reconfigure	= proc_reconfigure,
 };
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index 45486080eb84..086e4f24705a 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -118,6 +118,7 @@ struct fs_context_operations {
 	int (*dup)(struct fs_context *fc, struct fs_context *src_fc);
 	int (*parse_param)(struct fs_context *fc, struct fs_parameter *param);
 	int (*parse_monolithic)(struct fs_context *fc, void *data);
+	void (*set_container)(struct fs_context *fc);
 	int (*get_tree)(struct fs_context *fc);
 	int (*reconfigure)(struct fs_context *fc);
 };
@@ -138,6 +139,7 @@ extern int vfs_parse_fs_param(struct fs_context *fc, struct fs_parameter *param)
 extern int vfs_parse_fs_string(struct fs_context *fc, const char *key,
 			       const char *value, size_t v_size);
 extern int generic_parse_monolithic(struct fs_context *fc, void *data);
+extern void do_set_container(struct fs_context *fc);
 extern void vfs_set_container(struct fs_context *fc, struct container *container);
 extern int vfs_get_tree(struct fs_context *fc);
 extern void put_fs_context(struct fs_context *fc);
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 2a9a8be49f5b..821fb227800f 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -33,6 +33,7 @@
 #include <linux/mutex.h>
 #include <linux/nsproxy.h>
 #include <linux/pid.h>
+#include <linux/container.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
 #include <linux/slab.h>
@@ -329,6 +330,14 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 	return ERR_PTR(ret);
 }
 
+static void mqueue_set_container(struct fs_context *fc)
+{
+	struct mqueue_fs_context *ctx = fc->fs_private;
+
+	put_ipc_ns(ctx->ipc_ns);
+	ctx->ipc_ns = get_ipc_ns(fc->container->ns->ipc_ns);
+}
+
 static int mqueue_fill_super(struct super_block *sb, struct fs_context *fc)
 {
 	struct inode *inode;
@@ -1569,6 +1578,7 @@ static const struct super_operations mqueue_super_ops = {
 
 static const struct fs_context_operations mqueue_fs_context_ops = {
 	.free		= mqueue_fs_context_free,
+	.set_container	= mqueue_set_container,
 	.get_tree	= mqueue_get_tree,
 };
 

