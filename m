From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/32] SUNRPC: convert some sysctls into module parameters
Date: Wed, 19 Aug 2009 19:38:28 -0400
Message-ID: <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736AbZHSXlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:01 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe90V028534
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:49 -0700 (PDT)
In-Reply-To: <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Parameters like the minimum reserved port, and the number of slot entries
should really be module parameters rather than sysctls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 Documentation/kernel-parameters.txt |   21 ++++++++++++++
 net/sunrpc/xprtsock.c               |   52 +++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index dd1a6d4..2f18206 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2391,6 +2391,18 @@ and is between 256 and 4096 characters. It is defined in the file
 	stifb=		[HW]
 			Format: bpp:<bpp1>[:<bpp2>[:<bpp3>...]]
 
+	sunrpc.min_resvport=
+	sunrpc.max_resvport=
+			[NFS,SUNRPC]
+			SunRPC servers often require that client requests
+			originate from a privileged port (i.e. a port in the
+			range 0 < portnr < 1024).
+			An administrator who wishes to reserve some of these
+			ports for other uses may adjust the range that the
+			kernel's sunrpc client considers to be privileged
+			using these two parameters to set the minimum and
+			maximum port values.
+
 	sunrpc.pool_mode=
 			[NFS]
 			Control how the NFS server code allocates CPUs to
@@ -2407,6 +2419,15 @@ and is between 256 and 4096 characters. It is defined in the file
 			pernode	    one pool for each NUMA node (equivalent
 				    to global on non-NUMA machines)
 
+	sunrpc.tcp_slot_table_entries=
+	sunrpc.udp_slot_table_entries=
+			[NFS,SUNRPC]
+			Sets the upper limit on the number of simultaneous
+			RPC calls that can be sent from the client to a
+			server. Increasing these values may allow you to
+			improve throughput, but will also increase the
+			amount of memory reserved for use by the client.
+
 	swiotlb=	[IA-64] Number of I/O TLB slabs
 
 	switches=	[HW,M68k]
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 83c73c4..585a864 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2412,3 +2412,55 @@ void cleanup_socket_xprt(void)
 	xprt_unregister_transport(&xs_udp_transport);
 	xprt_unregister_transport(&xs_tcp_transport);
 }
+
+static int param_set_uint_minmax(const char *val, struct kernel_param *kp,
+		unsigned int min, unsigned int max)
+{
+	unsigned long num;
+	int ret;
+
+	if (!val)
+		return -EINVAL;
+	ret = strict_strtoul(val, 0, &num);
+	if (ret == -EINVAL || num < min || num > max)
+		return -EINVAL;
+	*((unsigned int *)kp->arg) = num;
+	return 0;
+}
+
+static int param_set_portnr(const char *val, struct kernel_param *kp)
+{
+	return param_set_uint_minmax(val, kp,
+			RPC_MIN_RESVPORT,
+			RPC_MAX_RESVPORT);
+}
+
+static int param_get_portnr(char *buffer, struct kernel_param *kp)
+{
+	return param_get_uint(buffer, kp);
+}
+#define param_check_portnr(name, p) \
+	__param_check(name, p, unsigned int);
+
+module_param_named(min_resvport, xprt_min_resvport, portnr, 0644);
+module_param_named(max_resvport, xprt_max_resvport, portnr, 0644);
+
+static int param_set_slot_table_size(const char *val, struct kernel_param *kp)
+{
+	return param_set_uint_minmax(val, kp,
+			RPC_MIN_SLOT_TABLE,
+			RPC_MAX_SLOT_TABLE);
+}
+
+static int param_get_slot_table_size(char *buffer, struct kernel_param *kp)
+{
+	return param_get_uint(buffer, kp);
+}
+#define param_check_slot_table_size(name, p) \
+	__param_check(name, p, unsigned int);
+
+module_param_named(tcp_slot_table_entries, xprt_tcp_slot_table_entries,
+		   slot_table_size, 0644);
+module_param_named(udp_slot_table_entries, xprt_udp_slot_table_entries,
+		   slot_table_size, 0644);
+
-- 
1.6.0.4
