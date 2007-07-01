From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 01/10] rdma: ONCRPC RDMA Header File
Date: Sun, 01 Jul 2007 18:12:26 -0500
Message-ID: <20070701231225.29354.76212.stgit@dell3.ogc.int>
References: <20070701230258.29354.89949.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I58ah-00036J-G4
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 16:12:27 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I58ak-0003KM-CB
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 16:12:31 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 7005F7C77F
	for <nfs@lists.sourceforge.net>; Sun,  1 Jul 2007 18:12:26 -0500 (CDT)
In-Reply-To: <20070701230258.29354.89949.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


These are the core data types that are used to process the ONCRPC protocol
in the NFS-RDMA client and server.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 include/linux/sunrpc/rpc_rdma.h |  116 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
new file mode 100644
index 0000000..0013a0d
--- /dev/null
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -0,0 +1,116 @@
+/*
+ * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the BSD-type
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *      Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer.
+ *
+ *      Redistributions in binary form must reproduce the above
+ *      copyright notice, this list of conditions and the following
+ *      disclaimer in the documentation and/or other materials provided
+ *      with the distribution.
+ *
+ *      Neither the name of the Network Appliance, Inc. nor the names of
+ *      its contributors may be used to endorse or promote products
+ *      derived from this software without specific prior written
+ *      permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _LINUX_SUNRPC_RPC_RDMA_H
+#define _LINUX_SUNRPC_RPC_RDMA_H
+
+struct rpcrdma_segment {
+	uint32_t rs_handle;	/* Registered memory handle */
+	uint32_t rs_length;	/* Length of the chunk in bytes */
+	uint64_t rs_offset;	/* Chunk virtual address or offset */
+};
+
+/*
+ * read chunk(s), encoded as a linked list.
+ */
+struct rpcrdma_read_chunk {
+	uint32_t rc_discrim;	/* 1 indicates presence */
+	uint32_t rc_position;	/* Position in XDR stream */
+	struct rpcrdma_segment rc_target;
+};
+
+/*
+ * write chunk, and reply chunk.
+ */
+struct rpcrdma_write_chunk {
+	struct rpcrdma_segment wc_target;
+};
+
+/*
+ * write chunk(s), encoded as a counted array.
+ */
+struct rpcrdma_write_array {
+	uint32_t wc_discrim;	/* 1 indicates presence */
+	uint32_t wc_nchunks;	/* Array count */
+	struct rpcrdma_write_chunk wc_array[0];
+};
+
+struct rpcrdma_msg {
+	uint32_t rm_xid;	/* Mirrors the RPC header xid */
+	uint32_t rm_vers;	/* Version of this protocol */
+	uint32_t rm_credit;	/* Buffers requested/granted */
+	uint32_t rm_type;	/* Type of message (enum rpcrdma_proc) */
+	union {
+
+		struct {			/* no chunks */
+			uint32_t rm_empty[3];	/* 3 empty chunk lists */
+		} rm_nochunks;
+
+		struct {			/* no chunks and padded */
+			uint32_t rm_align;	/* Padding alignment */
+			uint32_t rm_thresh;	/* Padding threshold */
+			uint32_t rm_pempty[3];	/* 3 empty chunk lists */
+		} rm_padded;
+
+		uint32_t rm_chunks[0];	/* read, write and reply chunks */
+
+	} rm_body;
+};
+
+#define RPCRDMA_HDRLEN_MIN	28
+
+enum rpcrdma_errcode {
+	ERR_VERS = 1,
+	ERR_CHUNK = 2
+};
+
+struct rpcrdma_err_vers {
+	uint32_t rdma_vers_low;	/* Version range supported by peer */
+	uint32_t rdma_vers_high;
+};
+
+enum rpcrdma_proc {
+	RDMA_MSG = 0,		/* An RPC call or reply msg */
+	RDMA_NOMSG = 1,		/* An RPC call or reply msg - separate body */
+	RDMA_MSGP = 2,		/* An RPC call or reply msg with padding */
+	RDMA_DONE = 3,		/* Client signals reply completion */
+	RDMA_ERROR = 4		/* An RPC RDMA encoding error */
+};
+
+#endif				/* _LINUX_SUNRPC_RPC_RDMA_H */

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
