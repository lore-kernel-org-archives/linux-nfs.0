From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 7/9] sunrpc: add encoding and decoding routines for SMB
Date: Sun, 27 Sep 2009 12:50:28 -0400
Message-ID: <1254070230-13125-8-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:63269 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbZI0Q5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:12 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new smb.c file to hold encode and decode routines for SMB packets.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/smb.h     |   42 ++++++++++++++
 include/linux/sunrpc/xprtsmb.h |    6 +-
 net/sunrpc/smb.c               |  120 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 165 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/sunrpc/smb.h
 create mode 100644 net/sunrpc/smb.c

diff --git a/include/linux/sunrpc/smb.h b/include/linux/sunrpc/smb.h
new file mode 100644
index 0000000..304ab8c
--- /dev/null
+++ b/include/linux/sunrpc/smb.h
@@ -0,0 +1,42 @@
+/*
+ *   net/sunrpc/smb.h -- SMB transport for sunrpc
+ *
+ *   Copyright (c) 2009 Red Hat, Inc.
+ *   Author(s): Jeff Layton (jlayton@redhat.com)
+ *
+ *   This library is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU Lesser General Public License as published
+ *   by the Free Software Foundation; either version 2.1 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This library is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ *   the GNU Lesser General Public License for more details.
+ *
+ *   You should have received a copy of the GNU Lesser General Public License
+ *   along with this library; if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+/*
+ * xprtsmb.h
+ *
+ * This file contains the public interfaces for the SMB transport for
+ * the sunrpc layer.
+ */
+
+#ifndef _LINUX_SUNRPC_SMB_H
+#define _LINUX_SUNRPC_SMB_H
+
+/*
+ * This is the generic SMB function. rqstp is either a rpc_rqst (client
+ * side) or svc_rqst pointer (server side).
+ * Encode functions always assume there's enough room in the buffer.
+ */
+typedef int     (*ksmbproc_t)(void *rqstp, __le32 *data, void *obj);
+
+void smb_encode(struct rpc_task *task);
+int smb_decode(struct rpc_task *task);
+
+#endif /* _LINUX_SUNRPC_SMB_H */
diff --git a/include/linux/sunrpc/xprtsmb.h b/include/linux/sunrpc/xprtsmb.h
index d55e85b..731cce2 100644
--- a/include/linux/sunrpc/xprtsmb.h
+++ b/include/linux/sunrpc/xprtsmb.h
@@ -34,9 +34,6 @@
  */
 #define XPRT_TRANSPORT_SMB	1024
 
-int init_smb_xprt(void);
-void cleanup_smb_xprt(void);
-
 /* standard SMB header */
 struct smb_header {
 	__u8		protocol[4];
@@ -56,4 +53,7 @@ struct smb_header {
 /* SMB Header Flags of interest */
 #define SMBFLG_RESPONSE 0x80	/* response from server */
 
+int init_smb_xprt(void);
+void cleanup_smb_xprt(void);
+
 #endif /* _LINUX_SUNRPC_XPRTSMB_H */
diff --git a/net/sunrpc/smb.c b/net/sunrpc/smb.c
new file mode 100644
index 0000000..5511bb2
--- /dev/null
+++ b/net/sunrpc/smb.c
@@ -0,0 +1,120 @@
+/*
+ * net/sunrpc/smb.c -- smb encode and decode routines
+ *
+ * Copyright (C) 2009 Red Hat, Inc -- Jeff Layton <jlayton@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+
+#include <linux/types.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprtsmb.h>
+#include <linux/sunrpc/smb.h>
+#include <linux/smbno.h>
+
+static __le32 *
+smb_verify_header(struct rpc_task *task)
+{
+	struct kvec *iov = &task->tk_rqstp->rq_rcv_buf.head[0];
+	__le32	*p = iov->iov_base;
+
+	if (task->tk_rqstp->rq_rcv_buf.len < sizeof(struct smb_header)) {
+		task->tk_action = call_bind;
+		task->tk_client->cl_stats->rpcretrans++;
+		return ERR_PTR(-EAGAIN);
+	}
+
+	/* FIXME: check for errors and return them */
+
+	/*
+	 * with SMB, we occasionally need to refer back to the SMB header for
+	 * info (flags, etc). The header is fixed-length however, so just
+	 * return a pointer to the start of the SMB header.
+	 */
+	return p;
+}
+
+static __le32 *
+smb_encode_header(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	u32 *p =  (u32 *) req->rq_svec[0].iov_base;
+	struct smb_header *h;
+
+	/* transport header is always 32 bits */
+	++p;
+	memset(p, 0, sizeof(*h));
+
+	h = (struct smb_header *) p;
+
+	h->protocol[0] = 0xFF;
+	h->protocol[1] = 'S';
+	h->protocol[2] = 'M';
+	h->protocol[3] = 'B';
+
+	h->command = task->tk_msg.rpc_proc->p_proc;
+	h->flags2 = SMB_FLAGS2_LONG_PATH_COMPONENTS;
+	h->pid = cpu_to_le16((u16) current->tgid);
+	h->pidhigh = cpu_to_le16((u16) (current->tgid >> 16));
+
+	/*
+	 * SMB MID's are similar to XID's in RPC, but they're only 16 bits.
+	 * For now we just use the xid field and mask off the upper bits.
+	 */
+	req->rq_xid &= 0x0000ffff;
+	h->mid = cpu_to_le16((u16) req->rq_xid);
+
+	req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0], (__be32 *) (h + 1));
+
+	return (__le32 *) (h + 1);
+}
+
+void
+smb_encode(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	__le32 *p;
+	ksmbproc_t encode = (ksmbproc_t) task->tk_msg.rpc_proc->p_encode;
+
+	rpc_xdr_buf_init(&req->rq_snd_buf, req->rq_buffer, req->rq_callsize);
+	rpc_xdr_buf_init(&req->rq_rcv_buf,
+			 (char *)req->rq_buffer + req->rq_callsize,
+			 req->rq_rcvsize);
+
+	p = smb_encode_header(task);
+
+	encode(req, p, NULL);
+	return;
+}
+EXPORT_SYMBOL_GPL(smb_encode);
+
+int
+smb_decode(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
+	__le32		*p;
+
+	p = smb_verify_header(task);
+	if (IS_ERR(p))
+		return  PTR_ERR(p);
+
+	if (decode)
+		task->tk_status = decode(req, p, task->tk_msg.rpc_resp);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(smb_decode);
-- 
1.6.0.6

