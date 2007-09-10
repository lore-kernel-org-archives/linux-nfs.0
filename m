From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 15/19] RPCRDMA: Kconfig and header file with rpcrdma
 protocol definitions
Date: Mon, 10 Sep 2007 13:49:15 -0400
Message-ID: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUncp-0003fW-So
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:04:44 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUncu-00047C-9n
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:04:48 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI4ggn022128
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:04:42 -0700 (PDT)
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

RPCRDMA: Kconfig and header file with rpcrdma protocol definitions

This file implements the configuration target, protocol template and
constants for the rpcrdma transport framing, for use by the xprtrdma
rpc transport implementation.

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

 fs/Kconfig                      |    8 ++
 include/linux/sunrpc/rpc_rdma.h |  116 ++++++++++++++++++++++++++++++++++++++++
 include/linux/sunrpc/xprtrdma.h |   85 +++++++++++++++++++++++++++++
 3 files changed, 209 insertions(+)

Index: kernel/include/linux/sunrpc/rpc_rdma.h
===================================================================
--- /dev/null
+++ kernel/include/linux/sunrpc/rpc_rdma.h
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
Index: kernel/include/linux/sunrpc/xprtrdma.h
===================================================================
--- /dev/null
+++ kernel/include/linux/sunrpc/xprtrdma.h
@@ -0,0 +1,85 @@
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
+#ifndef _LINUX_SUNRPC_XPRTRDMA_H
+#define _LINUX_SUNRPC_XPRTRDMA_H
+
+/*
+ * RPC transport identifier for RDMA
+ */
+#define XPRT_TRANSPORT_RDMA	256
+
+/*
+ * rpcbind (v3+) RDMA netid.
+ */
+#define RPCBIND_NETID_RDMA	"rdma"
+
+/*
+ * Constants. Max RPC/NFS header is big enough to account for
+ * additional marshaling buffers passed down by Linux client.
+ *
+ * RDMA header is currently fixed max size, and is big enough for a
+ * fully-chunked NFS message (read chunks are the largest). Note only
+ * a single chunk type per message is supported currently.
+ */
+#define RPCRDMA_MIN_SLOT_TABLE	(2U)
+#define RPCRDMA_DEF_SLOT_TABLE	(32U)
+#define RPCRDMA_MAX_SLOT_TABLE	(256U)
+
+#define RPCRDMA_DEF_INLINE  (1024)	/* default inline max */
+
+#define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
+
+#define RDMA_RESOLVE_TIMEOUT	(5*HZ)	/* TBD 5 seconds */
+#define RDMA_CONNECT_RETRY_MAX	(2)	/* retries if no listener backlog */
+
+/* memory registration strategies */
+#define RPCRDMA_PERSISTENT_REGISTRATION (1)
+
+enum rpcrdma_memreg {
+	RPCRDMA_BOUNCEBUFFERS = 0,
+	RPCRDMA_REGISTER,
+	RPCRDMA_MEMWINDOWS,
+	RPCRDMA_MEMWINDOWS_ASYNC,
+	RPCRDMA_MTHCAFMR,
+	RPCRDMA_ALLPHYSICAL,
+	RPCRDMA_LAST
+};
+
+#endif /* _LINUX_SUNRPC_XPRTRDMA_H */
Index: kernel/fs/Kconfig
===================================================================
--- kernel.orig/fs/Kconfig
+++ kernel/fs/Kconfig
@@ -1731,6 +1731,14 @@ config SUNRPC
 config SUNRPC_GSS
 	tristate
 
+config SUNRPC_XPRT_RDMA
+	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL
+	default m
+	help
+	  Adds a client RPC transport for supporting kernel NFS over RDMA
+	  mounts, including Infiniband and iWARP. Experimental.
+
 config SUNRPC_BIND34
 	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
