Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51946 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab1FGRdt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:49 -0400
Date: Tue, 7 Jun 2011 13:33:47 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 65/88] pnfs-block: Add support for simple rpc pipefs
Message-ID: <0f08ca4384d0690a48f9d93898997bbb1d9a5068.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Eric Anderle <eanderle@umich.edu>
Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h       |    4 +
 include/linux/sunrpc/simple_rpc_pipefs.h |  111 ++++++++
 net/sunrpc/Makefile                      |    2 +-
 net/sunrpc/simple_rpc_pipefs.c           |  424 ++++++++++++++++++++++++++++++
 4 files changed, 540 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
 create mode 100644 net/sunrpc/simple_rpc_pipefs.c

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 6f942c9..2177d50 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -12,6 +12,10 @@ struct rpc_pipe_msg {
 	size_t len;
 	size_t copied;
 	int errno;
+#define PIPEFS_AUTOFREE_RPCMSG       0x01 /* frees rpc_pipe_msg */
+#define PIPEFS_AUTOFREE_RPCMSG_DATA  0x02 /* frees rpc_pipe_msg->data */
+#define PIPEFS_AUTOFREE_UPCALL_MSG   PIPEFS_AUTOFREE_RPCMSG_DATA
+	u8 flags;
 };
 
 struct rpc_pipe_ops {
diff --git a/include/linux/sunrpc/simple_rpc_pipefs.h b/include/linux/sunrpc/simple_rpc_pipefs.h
new file mode 100644
index 0000000..02e8147
--- /dev/null
+++ b/include/linux/sunrpc/simple_rpc_pipefs.h
@@ -0,0 +1,111 @@
+/*
+ *  Copyright (c) 2008 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  David M. Richter <richterd@citi.umich.edu>
+ *
+ *  Drawing on work done by Andy Adamson <andros@citi.umich.edu> and
+ *  Marius Eriksen <marius@monkey.org>.  Thanks for the help over the
+ *  years, guys.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *  With thanks to CITI's project sponsor and partner, IBM.
+ */
+
+#ifndef _SIMPLE_RPC_PIPEFS_H_
+#define _SIMPLE_RPC_PIPEFS_H_
+
+#include <linux/fs.h>
+#include <linux/list.h>
+#include <linux/mount.h>
+#include <linux/sched.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+
+
+#define payload_of(headerp)  ((void *)(headerp + 1))
+
+/*
+ * struct pipefs_hdr -- the generic message format for simple_rpc_pipefs.
+ * Messages may simply be the header itself, although having an optional
+ * data payload follow the header allows much more flexibility.
+ *
+ * Messages are created using pipefs_alloc_init_msg() and
+ * pipefs_alloc_init_msg_padded(), both of which accept a pointer to an
+ * (optional) data payload.
+ *
+ * Given a struct pipefs_hdr *msg that has a struct foo payload, the data
+ * can be accessed using: struct foo *foop = payload_of(msg)
+ */
+struct pipefs_hdr {
+	u32 msgid;
+	u8  type;
+	u8  flags;
+	u16 totallen; /* length of entire message, including hdr itself */
+	u32 status;
+};
+
+/*
+ * struct pipefs_list -- a type of list used for tracking callers who've made an
+ * upcall and are blocked waiting for a reply.
+ *
+ * See pipefs_queue_upcall_waitreply() and pipefs_assign_upcall_reply().
+ */
+struct pipefs_list {
+	struct list_head list;
+	spinlock_t list_lock;
+};
+
+
+/* See net/sunrpc/simple_rpc_pipefs.c for more info on using these functions. */
+extern struct dentry *pipefs_mkpipe(const char *name,
+				    const struct rpc_pipe_ops *ops,
+				    int wait_for_open);
+extern void pipefs_closepipe(struct dentry *pipe);
+extern void pipefs_init_list(struct pipefs_list *list);
+extern struct pipefs_hdr *pipefs_alloc_init_msg(u32 msgid, u8 type, u8 flags,
+						void *data, u16 datalen);
+extern struct pipefs_hdr *pipefs_alloc_init_msg_padded(u32 msgid, u8 type,
+						       u8 flags, void *data,
+						       u16 datalen, u16 padlen);
+extern struct pipefs_hdr *pipefs_queue_upcall_waitreply(struct dentry *pipe,
+							struct pipefs_hdr *msg,
+							struct pipefs_list
+							*uplist, u8 upflags,
+							u32 timeout);
+extern int pipefs_queue_upcall_noreply(struct dentry *pipe,
+				       struct pipefs_hdr *msg, u8 upflags);
+extern int pipefs_assign_upcall_reply(struct pipefs_hdr *reply,
+				      struct pipefs_list *uplist);
+extern struct pipefs_hdr *pipefs_readmsg(struct file *filp,
+					 const char __user *src, size_t len);
+extern ssize_t pipefs_generic_upcall(struct file *filp,
+				     struct rpc_pipe_msg *rpcmsg,
+				     char __user *dst, size_t buflen);
+extern void pipefs_generic_destroy_msg(struct rpc_pipe_msg *rpcmsg);
+
+#endif /* _SIMPLE_RPC_PIPEFS_H_ */
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 9d2fca5..e102040 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -12,7 +12,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    addr.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
-	    svc_xprt.o
+	    svc_xprt.o simple_rpc_pipefs.o
 sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/simple_rpc_pipefs.c b/net/sunrpc/simple_rpc_pipefs.c
new file mode 100644
index 0000000..c9306aa
--- /dev/null
+++ b/net/sunrpc/simple_rpc_pipefs.c
@@ -0,0 +1,424 @@
+/*
+ *  net/sunrpc/simple_rpc_pipefs.c
+ *
+ *  Copyright (c) 2008 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  David M. Richter <richterd@citi.umich.edu>
+ *
+ *  Drawing on work done by Andy Adamson <andros@citi.umich.edu> and
+ *  Marius Eriksen <marius@monkey.org>.  Thanks for the help over the
+ *  years, guys.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *  With thanks to CITI's project sponsor and partner, IBM.
+ */
+
+#include <linux/completion.h>
+#include <linux/uaccess.h>
+#include <linux/module.h>
+#include <linux/sunrpc/simple_rpc_pipefs.h>
+
+
+/*
+ * Make an rpc_pipefs pipe named @name at the root of the mounted rpc_pipefs
+ * filesystem.
+ *
+ * If @wait_for_open is non-zero and an upcall is later queued but the userland
+ * end of the pipe has not yet been opened, the upcall will remain queued until
+ * the pipe is opened; otherwise, the upcall queueing will return with -EPIPE.
+ */
+struct dentry *pipefs_mkpipe(const char *name, const struct rpc_pipe_ops *ops,
+			     int wait_for_open)
+{
+	struct dentry *dir, *pipe;
+	struct vfsmount *mnt;
+
+	mnt = rpc_get_mount();
+	if (IS_ERR(mnt)) {
+		pipe = ERR_CAST(mnt);
+		goto out;
+	}
+	dir = mnt->mnt_root;
+	if (!dir) {
+		pipe = ERR_PTR(-ENOENT);
+		goto out;
+	}
+	pipe = rpc_mkpipe(dir, name, NULL, ops,
+			  wait_for_open ? RPC_PIPE_WAIT_FOR_OPEN : 0);
+out:
+	return pipe;
+}
+EXPORT_SYMBOL(pipefs_mkpipe);
+
+/*
+ * Shutdown a pipe made by pipefs_mkpipe().
+ * XXX: do we need to retain an extra reference on the mount?
+ */
+void pipefs_closepipe(struct dentry *pipe)
+{
+	rpc_unlink(pipe);
+	rpc_put_mount();
+}
+EXPORT_SYMBOL(pipefs_closepipe);
+
+/*
+ * Initialize a struct pipefs_list -- which are a way to keep track of callers
+ * who're blocked having made an upcall and are awaiting a reply.
+ *
+ * See pipefs_queue_upcall_waitreply() and pipefs_find_upcall_msgid() for how
+ * to use them.
+ */
+inline void pipefs_init_list(struct pipefs_list *list)
+{
+	INIT_LIST_HEAD(&list->list);
+	spin_lock_init(&list->list_lock);
+}
+EXPORT_SYMBOL(pipefs_init_list);
+
+/*
+ * Alloc/init a generic pipefs message header and copy into its message body
+ * an arbitrary data payload.
+ *
+ * struct pipefs_hdr's are meant to serve as generic, general-purpose message
+ * headers for easy rpc_pipefs I/O.  When an upcall is made, the
+ * struct pipefs_hdr is assigned to a struct rpc_pipe_msg and delivered
+ * therein.  --And yes, the naming can seem a little confusing at first:
+ *
+ * When one thinks of an upcall "message", in simple_rpc_pipefs that's a
+ * struct pipefs_hdr (possibly with an attached message body).  A
+ * struct rpc_pipe_msg is actually only the -vehicle- by which the "real"
+ * message is delivered and processed.
+ */
+struct pipefs_hdr *pipefs_alloc_init_msg_padded(u32 msgid, u8 type, u8 flags,
+					   void *data, u16 datalen, u16 padlen)
+{
+	u16 totallen;
+	struct pipefs_hdr *msg = NULL;
+
+	totallen = sizeof(*msg) + datalen + padlen;
+	if (totallen > PAGE_SIZE) {
+		msg = ERR_PTR(-E2BIG);
+		goto out;
+	}
+
+	msg = kzalloc(totallen, GFP_KERNEL);
+	if (!msg) {
+		msg = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	msg->msgid = msgid;
+	msg->type = type;
+	msg->flags = flags;
+	msg->totallen = totallen;
+	memcpy(payload_of(msg), data, datalen);
+out:
+	return msg;
+}
+EXPORT_SYMBOL(pipefs_alloc_init_msg_padded);
+
+/*
+ * See the description of pipefs_alloc_init_msg_padded().
+ */
+struct pipefs_hdr *pipefs_alloc_init_msg(u32 msgid, u8 type, u8 flags,
+				    void *data, u16 datalen)
+{
+	return pipefs_alloc_init_msg_padded(msgid, type, flags, data,
+					    datalen, 0);
+}
+EXPORT_SYMBOL(pipefs_alloc_init_msg);
+
+
+static void pipefs_init_rpcmsg(struct rpc_pipe_msg *rpcmsg,
+			       struct pipefs_hdr *msg, u8 upflags)
+{
+	memset(rpcmsg, 0, sizeof(*rpcmsg));
+	rpcmsg->data = msg;
+	rpcmsg->len = msg->totallen;
+	rpcmsg->flags = upflags;
+}
+
+static struct rpc_pipe_msg *pipefs_alloc_init_rpcmsg(struct pipefs_hdr *msg,
+						     u8 upflags)
+{
+	struct rpc_pipe_msg *rpcmsg;
+
+	rpcmsg = kmalloc(sizeof(*rpcmsg), GFP_KERNEL);
+	if (!rpcmsg)
+		return ERR_PTR(-ENOMEM);
+
+	pipefs_init_rpcmsg(rpcmsg, msg, upflags);
+	return rpcmsg;
+}
+
+
+/* represents an upcall that'll block and wait for a reply */
+struct pipefs_upcall {
+	u32 msgid;
+	struct rpc_pipe_msg rpcmsg;
+	struct list_head list;
+	wait_queue_head_t waitq;
+	struct pipefs_hdr *reply;
+};
+
+
+static void pipefs_init_upcall_waitreply(struct pipefs_upcall *upcall,
+					 struct pipefs_hdr *msg, u8 upflags)
+{
+	upcall->reply = NULL;
+	upcall->msgid = msg->msgid;
+	INIT_LIST_HEAD(&upcall->list);
+	init_waitqueue_head(&upcall->waitq);
+	pipefs_init_rpcmsg(&upcall->rpcmsg, msg, upflags);
+}
+
+static int __pipefs_queue_upcall_waitreply(struct dentry *pipe,
+					   struct pipefs_upcall *upcall,
+					   struct pipefs_list *uplist,
+					   u32 timeout)
+{
+	int err = 0;
+	DECLARE_WAITQUEUE(wq, current);
+
+	add_wait_queue(&upcall->waitq, &wq);
+	spin_lock(&uplist->list_lock);
+	list_add(&upcall->list, &uplist->list);
+	spin_unlock(&uplist->list_lock);
+
+	err = rpc_queue_upcall(pipe->d_inode, &upcall->rpcmsg);
+	if (err < 0)
+		goto out;
+
+	if (timeout) {
+		/* retval of 0 means timer expired */
+		err = schedule_timeout_uninterruptible(timeout);
+		if (err == 0 && upcall->reply == NULL)
+			err = -ETIMEDOUT;
+	} else {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule();
+		__set_current_state(TASK_RUNNING);
+	}
+
+out:
+	spin_lock(&uplist->list_lock);
+	list_del_init(&upcall->list);
+	spin_unlock(&uplist->list_lock);
+	remove_wait_queue(&upcall->waitq, &wq);
+	return err;
+}
+
+/*
+ * Queue a pipefs msg for an upcall to userspace, place the calling thread
+ * on @uplist, and block the thread to wait for a reply.  If @timeout is
+ * nonzero, the thread will be blocked for at most @timeout jiffies.
+ *
+ * (To convert time units into jiffies, consider the functions
+ *  msecs_to_jiffies(), usecs_to_jiffies(), timeval_to_jiffies(), and
+ *  timespec_to_jiffies().)
+ *
+ * Once a reply is received by your downcall handler, call
+ * pipefs_assign_upcall_reply() with @uplist to find the corresponding upcall,
+ * assign the reply, and wake the waiting thread.
+ *
+ * This function's return value pointer may be an error and should be checked
+ * with IS_ERR() before attempting to access the reply message.
+ *
+ * Callers are responsible for freeing @msg, unless pipefs_generic_destroy_msg()
+ * is used as the ->destroy_msg() callback and the PIPEFS_AUTOFREE_UPCALL_MSG
+ * flag is set in @upflags.  See also rpc_pipe_fs.h.
+ */
+struct pipefs_hdr *pipefs_queue_upcall_waitreply(struct dentry *pipe,
+					    struct pipefs_hdr *msg,
+					    struct pipefs_list *uplist,
+					    u8 upflags, u32 timeout)
+{
+	int err = 0;
+	struct pipefs_upcall upcall;
+
+	pipefs_init_upcall_waitreply(&upcall, msg, upflags);
+	err = __pipefs_queue_upcall_waitreply(pipe, &upcall, uplist, timeout);
+	if (err < 0) {
+		kfree(upcall.reply);
+		upcall.reply = ERR_PTR(err);
+	}
+
+	return upcall.reply;
+}
+EXPORT_SYMBOL(pipefs_queue_upcall_waitreply);
+
+/*
+ * Queue a pipefs msg for an upcall to userspace and immediately return (i.e.,
+ * no reply is expected).
+ *
+ * Callers are responsible for freeing @msg, unless pipefs_generic_destroy_msg()
+ * is used as the ->destroy_msg() callback and the PIPEFS_AUTOFREE_UPCALL_MSG
+ * flag is set in @upflags.  See also rpc_pipe_fs.h.
+ */
+int pipefs_queue_upcall_noreply(struct dentry *pipe, struct pipefs_hdr *msg,
+				u8 upflags)
+{
+	int err = 0;
+	struct rpc_pipe_msg *rpcmsg;
+
+	upflags |= PIPEFS_AUTOFREE_RPCMSG;
+	rpcmsg = pipefs_alloc_init_rpcmsg(msg, upflags);
+	if (IS_ERR(rpcmsg)) {
+		err = PTR_ERR(rpcmsg);
+		goto out;
+	}
+	err = rpc_queue_upcall(pipe->d_inode, rpcmsg);
+out:
+	return err;
+}
+EXPORT_SYMBOL(pipefs_queue_upcall_noreply);
+
+
+static struct pipefs_upcall *pipefs_find_upcall_msgid(u32 msgid,
+						 struct pipefs_list *uplist)
+{
+	struct pipefs_upcall *upcall;
+
+	spin_lock(&uplist->list_lock);
+	list_for_each_entry(upcall, &uplist->list, list)
+		if (upcall->msgid == msgid)
+			goto out;
+	upcall = NULL;
+out:
+	spin_unlock(&uplist->list_lock);
+	return upcall;
+}
+
+/*
+ * In your rpc_pipe_ops->downcall() handler, once you've read in a downcall
+ * message and have determined that it is a reply to a waiting upcall,
+ * you can use this function to find the appropriate upcall, assign the result,
+ * and wake the upcall thread.
+ *
+ * The reply message must have the same msgid as the original upcall message's.
+ *
+ * See also pipefs_queue_upcall_waitreply() and pipefs_readmsg().
+ */
+int pipefs_assign_upcall_reply(struct pipefs_hdr *reply,
+			       struct pipefs_list *uplist)
+{
+	int err = 0;
+	struct pipefs_upcall *upcall;
+
+	upcall = pipefs_find_upcall_msgid(reply->msgid, uplist);
+	if (!upcall) {
+		printk(KERN_ERR "%s: ERROR: have reply but no matching upcall "
+			"for msgid %d\n", __func__, reply->msgid);
+		err = -ENOENT;
+		goto out;
+	}
+	upcall->reply = reply;
+	wake_up(&upcall->waitq);
+out:
+	return err;
+}
+EXPORT_SYMBOL(pipefs_assign_upcall_reply);
+
+/*
+ * Generic method to read-in and return a newly-allocated message which begins
+ * with a struct pipefs_hdr.
+ */
+struct pipefs_hdr *pipefs_readmsg(struct file *filp, const char __user *src,
+			     size_t len)
+{
+	int err = 0, hdrsize;
+	struct pipefs_hdr *msg = NULL;
+
+	hdrsize = sizeof(*msg);
+	if (len < hdrsize) {
+		printk(KERN_ERR "%s: ERROR: header is too short (%d vs %d)\n",
+		       __func__, (int) len, hdrsize);
+		err = -EINVAL;
+		goto out;
+	}
+
+	msg = kzalloc(len, GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto out;
+	}
+	if (copy_from_user(msg, src, len))
+		err = -EFAULT;
+out:
+	if (err) {
+		kfree(msg);
+		msg = ERR_PTR(err);
+	}
+	return msg;
+}
+EXPORT_SYMBOL(pipefs_readmsg);
+
+/*
+ * Generic rpc_pipe_ops->upcall() handler implementation.
+ *
+ * Don't call this directly: to make an upcall, use
+ * pipefs_queue_upcall_waitreply() or pipefs_queue_upcall_noreply().
+ */
+ssize_t pipefs_generic_upcall(struct file *filp, struct rpc_pipe_msg *rpcmsg,
+			      char __user *dst, size_t buflen)
+{
+	char *data;
+	ssize_t len, left;
+
+	data = (char *)rpcmsg->data + rpcmsg->copied;
+	len = rpcmsg->len - rpcmsg->copied;
+	if (len > buflen)
+		len = buflen;
+
+	left = copy_to_user(dst, data, len);
+	if (left < 0) {
+		rpcmsg->errno = left;
+		return left;
+	}
+
+	len -= left;
+	rpcmsg->copied += len;
+	rpcmsg->errno = 0;
+	return len;
+}
+EXPORT_SYMBOL(pipefs_generic_upcall);
+
+/*
+ * Generic rpc_pipe_ops->destroy_msg() handler implementation.
+ *
+ * Items are only freed if @rpcmsg->flags has been set appropriately.
+ * See pipefs_queue_upcall_noreply() and rpc_pipe_fs.h.
+ */
+void pipefs_generic_destroy_msg(struct rpc_pipe_msg *rpcmsg)
+{
+	if (rpcmsg->flags & PIPEFS_AUTOFREE_UPCALL_MSG)
+		kfree(rpcmsg->data);
+	if (rpcmsg->flags & PIPEFS_AUTOFREE_RPCMSG)
+		kfree(rpcmsg);
+}
+EXPORT_SYMBOL(pipefs_generic_destroy_msg);
-- 
1.7.4.1

