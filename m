From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 9/9] smbtest: simple module for testing SMB/RPC code
Date: Sun, 27 Sep 2009 12:50:30 -0400
Message-ID: <1254070230-13125-10-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:63267 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbZI0Q5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:12 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Proof of concept module. This just sends a NEGOTIATE_PROTOCOL request to
a server and verifies the response.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/Makefile          |    2 +
 fs/smbtest/Makefile  |    1 +
 fs/smbtest/smbtest.c |  204 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 207 insertions(+), 0 deletions(-)
 create mode 100644 fs/smbtest/Makefile
 create mode 100644 fs/smbtest/smbtest.c

diff --git a/fs/Makefile b/fs/Makefile
index af6d047..0e9d1df 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -124,3 +124,5 @@ obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_BTRFS_FS)		+= btrfs/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
 obj-$(CONFIG_EXOFS_FS)          += exofs/
+
+obj-m				+= smbtest/
diff --git a/fs/smbtest/Makefile b/fs/smbtest/Makefile
new file mode 100644
index 0000000..d861f82
--- /dev/null
+++ b/fs/smbtest/Makefile
@@ -0,0 +1 @@
+obj-m += smbtest.o
diff --git a/fs/smbtest/smbtest.c b/fs/smbtest/smbtest.c
new file mode 100644
index 0000000..cfcb672
--- /dev/null
+++ b/fs/smbtest/smbtest.c
@@ -0,0 +1,204 @@
+/*
+ * fs/smbtest/smbtest.c -- proof of concept test for SMB code in sunrpc
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
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/inet.h>
+#include <linux/sched.h>
+#include <linux/smbno.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/xprtsmb.h>
+#include <linux/sunrpc/smb.h>
+
+#define CIFS_NEGOTIATE			0
+#define SMB_COM_NEGOTIATE		0x72
+
+static char server_address[INET6_ADDRSTRLEN];
+module_param_string(server_address, server_address, INET6_ADDRSTRLEN, 0);
+MODULE_PARM_DESC(server_address, "IPv4 address of server");
+
+typedef struct negotiate_req {
+        __u8 WordCount;
+        __le16 ByteCount;
+        unsigned char DialectsArray[1];
+} __attribute__((packed)) NEGOTIATE_REQ;
+
+typedef struct negotiate_rsp {
+        __u8 WordCount;
+        __le16 DialectIndex; /* 0xFFFF = no dialect acceptable */
+        __u8 SecurityMode;
+        __le16 MaxMpxCount;
+        __le16 MaxNumberVcs;
+        __le32 MaxBufferSize;
+        __le32 MaxRawSize;
+        __le32 SessionKey;
+        __le32 Capabilities;    /* see below */
+        __le32 SystemTimeLow;
+        __le32 SystemTimeHigh;
+        __le16 ServerTimeZone;
+        __u8 EncryptionKeyLength;
+        __u16 ByteCount;
+        union {
+                unsigned char EncryptionKey[1]; /* cap extended security off */
+                /* followed by Domain name - if extended security is off */
+                /* followed by 16 bytes of server GUID */
+                /* then security blob if cap_extended_security negotiated */
+                struct {
+                        unsigned char GUID[16];
+                        unsigned char SecurityBlob[1];
+                } __attribute__((packed)) extended_response;
+        } __attribute__((packed)) u;
+} __attribute__((packed)) NEGOTIATE_RSP;
+
+/*
+ * SMB doesn't mandate that buffers are always quadword aligned. XDR/RPC
+ * does however and that concept is pretty pervasive in the sunrpc code.
+ * Eventually, it might be better to specify sizes in bytes, but it doesn't
+ * really matter much.
+ */
+#define SMB_HDR_QUADS XDR_QUADLEN(sizeof(struct smb_header))
+
+static int
+smb_enc_negotiate(struct rpc_rqst *req, NEGOTIATE_REQ *buf, void *obj)
+{
+	char *dialects = buf->DialectsArray;
+
+	buf->WordCount = 0;
+	buf->ByteCount = 12;
+
+	dialects[0] = 0x02; /* buffer format byte */
+	strncpy(&dialects[1], "NT LM 0.12", 1000);
+
+	req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0],
+					(__be32 *) &dialects[12]);
+
+	return 0;
+}
+
+static int
+smb_dec_negotiate(void *rqstp, char *data, void *obj)
+{
+	NEGOTIATE_RSP *buf = (NEGOTIATE_RSP *) (data + sizeof(struct smb_header));
+
+	printk("smbtest: Server wants dialect index %u\n",
+		le16_to_cpu(buf->DialectIndex));
+	return 0;
+}
+
+static struct rpc_procinfo	smbtest_procedures[] = {
+[CIFS_NEGOTIATE] = {
+		.p_proc		= SMB_COM_NEGOTIATE,
+		.p_encode	= (kxdrproc_t) smb_enc_negotiate,
+		.p_decode	= (kxdrproc_t) smb_dec_negotiate,
+		.p_arglen	= XDR_QUADLEN(sizeof(NEGOTIATE_REQ) + 1024),
+		.p_replen	= XDR_QUADLEN(sizeof(NEGOTIATE_RSP) + 1024),
+		.p_timer	= 0,
+		.p_statidx	= CIFS_NEGOTIATE,
+		.p_name		= "NEGOTIATE",
+	},
+};
+
+static struct rpc_version	smbtest_version1 = {
+	.number		= 1,
+	.nrprocs	= ARRAY_SIZE(smbtest_procedures),
+	.procs		= smbtest_procedures,
+};
+
+static struct rpc_version *	smbtest_version[] = {
+	[1] = &smbtest_version1,
+};
+
+static struct rpc_stat smbtest_stats;
+
+static struct rpc_program cifs_rpc_prog = {
+		.name			= "smbtest",
+		.number			= 0,
+		.nrvers			= ARRAY_SIZE(smbtest_version),
+		.version		= smbtest_version,
+		.stats			= &smbtest_stats,
+};
+
+static struct rpc_clnt	*smbtest_clnt;
+
+static int smbtest_init(void)
+{
+	struct sockaddr_in sin = {
+		.sin_family = AF_INET,
+		.sin_port = htons(445),
+	};
+	u8 *addr = (u8 *) &sin.sin_addr.s_addr;
+	int status;
+	struct rpc_create_args create_args = {
+		.protocol		= XPRT_TRANSPORT_SMB,
+		.address		= (struct sockaddr *) &sin,
+		.addrsize		= sizeof(sin),
+		.servername		= "cifs",
+		.program		= &cifs_rpc_prog,
+		.version		= 1,
+		.authflavor		= RPC_AUTH_NULL,
+		.encode			= smb_encode,
+		.decode			= smb_decode,
+		.callhdr_size		= SMB_HDR_QUADS,
+		.replhdr_size		= SMB_HDR_QUADS,
+		.flags			= RPC_CLNT_CREATE_NOPING |
+					  RPC_CLNT_CREATE_NONPRIVPORT,
+	};
+
+	NEGOTIATE_REQ		req = { };
+	NEGOTIATE_RSP		rsp = { };
+
+	struct rpc_message msg = {
+		.rpc_argp	= &req,
+		.rpc_resp	= &rsp,
+	};
+
+	if (!in4_pton(server_address, -1, addr, '\0', NULL)) {
+		printk("smbtest: in4_pton failed\n");
+		return -EINVAL;
+	}
+
+	smbtest_clnt = rpc_create(&create_args);
+	if (IS_ERR(smbtest_clnt)) {
+		printk("smbtest: rpc client creation failed\n");
+		return PTR_ERR(smbtest_clnt);
+	}
+	printk("smbtest: rpc client create succeeded\n");
+
+	msg.rpc_proc = &smbtest_clnt->cl_procinfo[CIFS_NEGOTIATE];
+	status = rpc_call_sync(smbtest_clnt, &msg, 0);
+	printk("smbtest: rpc_call_sync returned %d\n", status);
+
+	return status;
+}
+
+static void smbtest_exit(void)
+{
+	printk("%s\n", __func__);
+	rpc_shutdown_client(smbtest_clnt);
+}
+
+module_init(smbtest_init);
+module_exit(smbtest_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jeff Layton <jlayton@samba.org>");
-- 
1.6.0.6

