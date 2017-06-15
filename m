Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20115 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752416AbdFOOrS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jun 2017 10:47:18 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170615100713.GH31671@ZenIV.linux.org.uk>
References: <20170615100713.GH31671@ZenIV.linux.org.uk> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk> <149745354300.10897.4615400686590211820.stgit@warthog.procyon.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: dhowells@redhat.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 25/27] ipc: Convert mqueue fs to fs_context [ver #5]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 15 Jun 2017 15:47:09 +0100
Message-ID: <18687.1497538029@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> wrote:

> > +	if (ctx->ipc_ns != ns) {
> 
> How could they possibly be equal?  You are setting that ns up here, right?
> How could it be in any process' nsproxy?

Fair point.

> Ugh, again...  Is there any reason for dynamic allocation of that thing in
> this particular case?  AFAICS, these contortions are all due to going through
> vfs_new_fs_context()/put_fs_context().  And it's not as if they had been
> refcounted...

I can statically initialise it as below, but whilst I don't need to call
vfs_new_fs_context() and put_fs_context(), I do have to call the security
hooks (Smack makes no distinction for internal filesystems) to set up the
security context and clean it up, and I do have to have the error handling for
in case kern_mount_data_fc() fails.

So it actually makes both the source and the object file bigger.  Now, I could
hide some of this inside a pair of inline functions, but it doesn't help that
much.

What might be better is to provide a function that wraps the vfs_get_tree()
and kern_mount_data_fc() calls and the cleanup.

David
---
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index f2e1d1d69961..a18a5f6763f9 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1431,8 +1431,15 @@ static struct file_system_type mqueue_fs_type = {
 
 int mq_init_ns(struct ipc_namespace *ns)
 {
-	struct mqueue_fs_context *ctx;
-	struct fs_context *fc;
+	struct mqueue_fs_context ctx = {
+		.fc.ops		= &mqueue_fs_context_ops,
+		.fc.fs_type	= &mqueue_fs_type,
+		.fc.cred	= current_cred(),
+		.fc.user_ns	= current_user_ns(),
+		.fc.purpose	= FS_CONTEXT_FOR_NEW,
+		.ipc_ns		= ns,
+	};
+	struct super_block *sb;
 	struct vfsmount *mnt;
 	int ret;
 
@@ -1443,29 +1450,32 @@ int mq_init_ns(struct ipc_namespace *ns)
 	ns->mq_msg_default   = DFLT_MSG;
 	ns->mq_msgsize_default  = DFLT_MSGSIZE;
 
-	fc = vfs_new_fs_context(&mqueue_fs_type, NULL, 0, FS_CONTEXT_FOR_NEW);
-	if (IS_ERR(fc))
-		return PTR_ERR(fc);
-
-	ctx = container_of(fc, struct mqueue_fs_context, fc);
-	put_ipc_ns(ctx->ipc_ns);
-	ctx->ipc_ns = get_ipc_ns(ns);
+	ret = security_fs_context_alloc(&ctx.fc, NULL);
+	if (ret < 0)
+		return ret;
 
-	ret = vfs_get_tree(fc);
+	ret = vfs_get_tree(&ctx.fc);
 	if (ret < 0)
 		goto out_fc;
 
-	mnt = kern_mount_data_fc(fc);
+	mnt = kern_mount_data_fc(&ctx.fc);
 	if (IS_ERR(mnt)) {
 		ret = PTR_ERR(mnt);
-		goto out_fc;
+		goto out_root;
 	}
 
 	ns->mq_mnt = mnt;
 	ret = 0;
 out_fc:
-	put_fs_context(fc);
+	security_fs_context_free(&ctx.fc);
 	return ret;
+
+out_root:
+	sb = ctx.fc.root->d_sb;
+	dput(ctx.fc.root);
+	ctx.fc.root = NULL;
+	deactivate_super(sb);
+	goto out_fc;
 }
 
 void mq_clear_sbinfo(struct ipc_namespace *ns)
