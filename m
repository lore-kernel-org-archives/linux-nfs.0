From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 04/10] rdma: SVCRDMA Transport Module
Date: Fri, 19 Oct 2007 16:56:17 -0500
Message-ID: <20071019215617.31937.60594.stgit@dell3.ogc.int>
References: <20071019215304.31937.28876.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IizpK-0006uH-9C
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:56:18 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IizpP-0002vh-7t
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:56:23 -0700
In-Reply-To: <20071019215304.31937.28876.stgit@dell3.ogc.int>
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


This file implements the RDMA transport module initialization and
termination logic and registers the transport sysctl variables.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_rdma.c |  280 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 280 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc_rdma.c b/net/sunrpc/svc_rdma.c
new file mode 100644
index 0000000..a8b1ed3
--- /dev/null
+++ b/net/sunrpc/svc_rdma.c
@@ -0,0 +1,280 @@
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
+#define MAX_RDMA_STAT_LEN	32
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
+	if (!stat)
+		return -EINVAL;
+
+	if (write)
+		atomic_set(stat, 0);
+	else {
+		char str_buf[32];
+		char *data;
+		int len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
+		if (len)
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
+		if (len)
+			if (copy_to_user(str_buf, buffer, len))
+				return -EFAULT;
+		*lenp = len;
+		*ppos += len;
+	}
+	return 0;
+}
+
+static struct ctl_table_header *svcrdma_table_header;
+static ctl_table svcrdma_parm_table[] = {
+	{
+		.ctl_name	= CTL_RDMA_MAX_REQUESTS,
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
+		.ctl_name	= CTL_RDMA_MAX_REQ_SIZE,
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
+		.ctl_name	= CTL_RDMA_ORD,
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
+		.ctl_name	= CTL_RDMA_STAT_READ,
+		.procname	= "rdma_stat_read",
+		.data		= &rdma_stat_read,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_RECV,
+		.procname	= "rdma_stat_recv",
+		.data		= &rdma_stat_recv,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_WRITE,
+		.procname	= "rdma_stat_write",
+		.data		= &rdma_stat_write,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_SQ_STARVE,
+		.procname	= "rdma_stat_sq_starve",
+		.data		= &rdma_stat_sq_starve,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_RQ_STARVE,
+		.procname	= "rdma_stat_rq_starve",
+		.data		= &rdma_stat_rq_starve,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_RQ_POLL,
+		.procname	= "rdma_stat_rq_poll",
+		.data		= &rdma_stat_rq_poll,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_RQ_PROD,
+		.procname	= "rdma_stat_rq_prod",
+		.data		= &rdma_stat_rq_prod,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_SQ_POLL,
+		.procname	= "rdma_stat_sq_poll",
+		.data		= &rdma_stat_sq_poll,
+		.maxlen		= MAX_RDMA_STAT_LEN,
+		.mode		= 0644,
+		.proc_handler	= &read_reset_stat,
+	},
+	{
+		.ctl_name	= CTL_RDMA_STAT_SQ_PROD,
+		.procname	= "rdma_stat_sq_prod",
+		.data		= &rdma_stat_sq_prod,
+		.maxlen		= MAX_RDMA_STAT_LEN,
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
+		.ctl_name	= CTL_SVCRDMA,
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
