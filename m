Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:46779 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756027AbeASUTk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jan 2018 15:19:40 -0500
Subject: [PATCH v2 1/2] rdma/ib: Add trace point macros to display
 human-readable values
From: Chuck Lever <chuck.lever@oracle.com>
To: jgg@ziepe.ca, dledford@redhat.com, anna.schumaker@netapp.com,
        leon@kernel.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 19 Jan 2018 15:19:38 -0500
Message-ID: <20180119201938.3084.8798.stgit@manet.1015granger.net>
In-Reply-To: <20180119201640.3084.73639.stgit@manet.1015granger.net>
References: <20180119201640.3084.73639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These can be shared with all kernel ULPs, and more can easily be
added as needed.

Note: checkpatch.pl has some heartburn with the TRACE_DEFINE_ENUM
macros and the LIST macros. These follow the same style as other
header files under include/tracing/events , thus should be
considered acceptable exceptions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rdma.h |  129 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 129 insertions(+)
 create mode 100644 include/trace/events/rdma.h

diff --git a/include/trace/events/rdma.h b/include/trace/events/rdma.h
new file mode 100644
index 0000000..aa19afc
--- /dev/null
+++ b/include/trace/events/rdma.h
@@ -0,0 +1,129 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (c) 2017 Oracle.  All rights reserved.
+ */
+
+/*
+ * enum ib_event_type, from include/rdma/ib_verbs.h
+ */
+
+#define IB_EVENT_LIST				\
+	ib_event(CQ_ERR)			\
+	ib_event(QP_FATAL)			\
+	ib_event(QP_REQ_ERR)			\
+	ib_event(QP_ACCESS_ERR)			\
+	ib_event(COMM_EST)			\
+	ib_event(SQ_DRAINED)			\
+	ib_event(PATH_MIG)			\
+	ib_event(PATH_MIG_ERR)			\
+	ib_event(DEVICE_FATAL)			\
+	ib_event(PORT_ACTIVE)			\
+	ib_event(PORT_ERR)			\
+	ib_event(LID_CHANGE)			\
+	ib_event(PKEY_CHANGE)			\
+	ib_event(SM_CHANGE)			\
+	ib_event(SRQ_ERR)			\
+	ib_event(SRQ_LIMIT_REACHED)		\
+	ib_event(QP_LAST_WQE_REACHED)		\
+	ib_event(CLIENT_REREGISTER)		\
+	ib_event(GID_CHANGE)			\
+	ib_event_end(WQ_FATAL)
+
+#undef ib_event
+#undef ib_event_end
+
+#define ib_event(x)		TRACE_DEFINE_ENUM(IB_EVENT_##x);
+#define ib_event_end(x)		TRACE_DEFINE_ENUM(IB_EVENT_##x);
+
+IB_EVENT_LIST
+
+#undef ib_event
+#undef ib_event_end
+
+#define ib_event(x)		{ IB_EVENT_##x, #x },
+#define ib_event_end(x)		{ IB_EVENT_##x, #x }
+
+#define rdma_show_ib_event(x) \
+		__print_symbolic(x, IB_EVENT_LIST)
+
+/*
+ * enum ib_wc_status type, from include/rdma/ib_verbs.h
+ */
+#define IB_WC_STATUS_LIST			\
+	ib_wc_status(SUCCESS)			\
+	ib_wc_status(LOC_LEN_ERR)		\
+	ib_wc_status(LOC_QP_OP_ERR)		\
+	ib_wc_status(LOC_EEC_OP_ERR)		\
+	ib_wc_status(LOC_PROT_ERR)		\
+	ib_wc_status(WR_FLUSH_ERR)		\
+	ib_wc_status(MW_BIND_ERR)		\
+	ib_wc_status(BAD_RESP_ERR)		\
+	ib_wc_status(LOC_ACCESS_ERR)		\
+	ib_wc_status(REM_INV_REQ_ERR)		\
+	ib_wc_status(REM_ACCESS_ERR)		\
+	ib_wc_status(REM_OP_ERR)		\
+	ib_wc_status(RETRY_EXC_ERR)		\
+	ib_wc_status(RNR_RETRY_EXC_ERR)		\
+	ib_wc_status(LOC_RDD_VIOL_ERR)		\
+	ib_wc_status(REM_INV_RD_REQ_ERR)	\
+	ib_wc_status(REM_ABORT_ERR)		\
+	ib_wc_status(INV_EECN_ERR)		\
+	ib_wc_status(INV_EEC_STATE_ERR)		\
+	ib_wc_status(FATAL_ERR)			\
+	ib_wc_status(RESP_TIMEOUT_ERR)		\
+	ib_wc_status_end(GENERAL_ERR)
+
+#undef ib_wc_status
+#undef ib_wc_status_end
+
+#define ib_wc_status(x)		TRACE_DEFINE_ENUM(IB_WC_##x);
+#define ib_wc_status_end(x)	TRACE_DEFINE_ENUM(IB_WC_##x);
+
+IB_WC_STATUS_LIST
+
+#undef ib_wc_status
+#undef ib_wc_status_end
+
+#define ib_wc_status(x)		{ IB_WC_##x, #x },
+#define ib_wc_status_end(x)	{ IB_WC_##x, #x }
+
+#define rdma_show_wc_status(x) \
+		__print_symbolic(x, IB_WC_STATUS_LIST)
+
+/*
+ * enum rdma_cm_event_type, from include/rdma/rdma_cm.h
+ */
+#define RDMA_CM_EVENT_LIST			\
+	rdma_cm_event(ADDR_RESOLVED)		\
+	rdma_cm_event(ADDR_ERROR)		\
+	rdma_cm_event(ROUTE_RESOLVED)		\
+	rdma_cm_event(ROUTE_ERROR)		\
+	rdma_cm_event(CONNECT_REQUEST)		\
+	rdma_cm_event(CONNECT_RESPONSE)		\
+	rdma_cm_event(CONNECT_ERROR)		\
+	rdma_cm_event(UNREACHABLE)		\
+	rdma_cm_event(REJECTED)			\
+	rdma_cm_event(ESTABLISHED)		\
+	rdma_cm_event(DISCONNECTED)		\
+	rdma_cm_event(DEVICE_REMOVAL)		\
+	rdma_cm_event(MULTICAST_JOIN)		\
+	rdma_cm_event(MULTICAST_ERROR)		\
+	rdma_cm_event(ADDR_CHANGE)		\
+	rdma_cm_event_end(TIMEWAIT_EXIT)
+
+#undef rdma_cm_event
+#undef rdma_cm_event_end
+
+#define rdma_cm_event(x)	TRACE_DEFINE_ENUM(RDMA_CM_EVENT_##x);
+#define rdma_cm_event_end(x)	TRACE_DEFINE_ENUM(RDMA_CM_EVENT_##x);
+
+RDMA_CM_EVENT_LIST
+
+#undef rdma_cm_event
+#undef rdma_cm_event_end
+
+#define rdma_cm_event(x)	{ RDMA_CM_EVENT_##x, #x },
+#define rdma_cm_event_end(x)	{ RDMA_CM_EVENT_##x, #x }
+
+#define rdma_show_cm_event(x) \
+		__print_symbolic(x, RDMA_CM_EVENT_LIST)

