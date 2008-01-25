From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 088/100] rdma: SVCRDMA Transport Module
Date: Fri, 25 Jan 2008 18:17:08 -0500
Message-ID: <1201303040-7779-88-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47548 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762189AbYAYXS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:28 -0500
In-Reply-To: <1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

This file implements the RDMA transport module initialization and
termination logic and registers the transport sysctl variables.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/xprtrdma/svc_rdma.c |  266 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 266 insertions(+), 0 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma.c

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
new file mode 100644
index 0000000..88c0ca2
--- /dev/null
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -0,0 +1,266 @@
+/*
+ * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
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
+ *
+ * Author: Tom Tucker <tom@opengridcomputing.com>
+ */
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/sysctl.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/svc_rdma.h>
+
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
+
+/* RPC/RDMA parameters */
+unsigned int svcrdma_ord = RPCRDMA_ORD;
+static unsigned int min_ord = 1;
+static unsigned int max_ord = 4096;
+unsigned int svcrdma_max_requests = RPCRDMA_MAX_REQUESTS;
+static unsigned int min_max_requests = 4;
+static unsigned int max_max_requests = 16384;
+unsigned int svcrdma_max_req_size = RPCRDMA_MAX_REQ_SIZE;
+static unsigned int min_max_inline = 4096;
+static unsigned int max_max_inline = 65536;
+
+atomic_t rdma_stat_recv;
+atomic_t rdma_stat_read;
+atomic_t rdma_stat_write;
+atomic_t rdma_stat_sq_starve;
+atomic_t rdma_stat_rq_starve;
+atomic_t rdma_stat_rq_poll;
+atomic_t rdma_stat_rq_prod;
+atomic_t rdma_stat_sq_poll;
+atomic_t rdma_stat_sq_prod;
+
+/*
+ * This function implements reading and resetting an atomic_t stat
+ * variable through read/write to a proc file. Any write to the file
+ * resets the associated statistic to zero. Any read returns it's
+ * current value.
+ */
+static int read_reset_stat(ctl_table *table, int write,
+			   struct file *filp, void __user *buffer, size_t *lenp,
+			   loff_t *ppos)
+{
+	atomic_t *stat = (atomic_t *)table->data;
+
+	if (!stat)
+		return -EINVAL;
+
+	if (write)
+		atomic_set(stat, 0);
+	else {
+		char str_buf[32];
+		char *data;
+		int len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
+		if (len >= 32)
+			return -EFAULT;
+		len = strlen(str_buf);
+		if (*ppos > len) {
+			*lenp = 0;
+			return 0;
+		}
+		data = &str_buf[*ppos];
+		len -= *ppos;
+		if (len > *lenp)
+			len = *lenp;
+		if (len && copy_to_user(buffer, str_buf, len))
+			return -EFAULT;
+		*lenp = len;
+		*ppos += len;
+	}
+	return 0;
+}
+
+static struct ctl_table_header *svcrdma_table_header;
+static ctl_table svcrdma_parm_table[] = {
+	{
+		.procname	= "max_requests",
+		.data		= &svcrdma_max_requests,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_max_requests,
+		.extra2		= &max_max_requests
+	},
+	{
+		.procname	= "max_req_size",
+		.data		= &svcrdma_max_req_size,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_max_inline,
+		.extra2		= &max_max_inline
+	},
+	{
+		.procname	= "max_outbound_read_requests",
+		.data		= &svcrdma_ord,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_ord,
+		.extra2		= &max_ord,
+	},
+
+	{
+		.procname	= "rdma_stat_read",
+		.data		= &rdma_stat_read,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_recv",
+		.data		= &rdma_stat_recv,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_write",
+		.data		= &rdma_stat_write,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_sq_starve",
+		.data		= &rdma_stat_sq_starve,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_rq_starve",
+		.data		= &rdma_stat_rq_starve,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_rq_poll",
+		.data		= &rdma_stat_rq_poll,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_rq_prod",
+		.data		= &rdma_stat_rq_prod,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_sq_poll",
+		.data		= &rdma_stat_sq_poll,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.procname	= "rdma_stat_sq_prod",
+		.data		= &rdma_stat_sq_prod,
+		.maxlen		= sizeof(atomic_t),
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+static ctl_table svcrdma_table[] = {
+	{
+		.procname	= "svc_rdma",
+		.mode		= 0555,
+		.child		= svcrdma_parm_table
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+static ctl_table svcrdma_root_table[] = {
+	{
+		.ctl_name	= CTL_SUNRPC,
+		.procname	= "sunrpc",
+		.mode		= 0555,
+		.child		= svcrdma_table
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+void svc_rdma_cleanup(void)
+{
+	dprintk("SVCRDMA Module Removed, deregister RPC RDMA transport\n");
+	if (svcrdma_table_header) {
+		unregister_sysctl_table(svcrdma_table_header);
+		svcrdma_table_header = NULL;
+	}
+	svc_unreg_xprt_class(&svc_rdma_class);
+}
+
+int svc_rdma_init(void)
+{
+	dprintk("SVCRDMA Module Init, register RPC RDMA transport\n");
+	dprintk("\tsvcrdma_ord      : %d\n", svcrdma_ord);
+	dprintk("\tmax_requests     : %d\n", svcrdma_max_requests);
+	dprintk("\tsq_depth         : %d\n",
+		svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT);
+	dprintk("\tmax_inline       : %d\n", svcrdma_max_req_size);
+	if (!svcrdma_table_header)
+		svcrdma_table_header =
+			register_sysctl_table(svcrdma_root_table);
+
+	/* Register RDMA with the SVC transport switch */
+	svc_reg_xprt_class(&svc_rdma_class);
+	return 0;
+}
+MODULE_AUTHOR("Tom Tucker <tom@opengridcomputing.com>");
+MODULE_DESCRIPTION("SVC RDMA Transport");
+MODULE_LICENSE("Dual BSD/GPL");
+module_init(svc_rdma_init);
+module_exit(svc_rdma_cleanup);
-- 
1.5.4.rc2.60.gb2e62

