From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/32] NFSv4: Clean up the nfs.callback_tcpport option
Date: Wed, 19 Aug 2009 19:38:29 -0400
Message-ID: <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbZHSXlA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:00 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7YD028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:48 -0700 (PDT)
In-Reply-To: <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tighten up the validity checking in param_set_port: check for NULL pointers.
Ensure that the option shows up on 'modinfo' output.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 7f604c7..293fa05 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -43,21 +43,29 @@ static struct svc_program nfs4_callback_program;
 unsigned int nfs_callback_set_tcpport;
 unsigned short nfs_callback_tcpport;
 unsigned short nfs_callback_tcpport6;
-static const int nfs_set_port_min = 0;
-static const int nfs_set_port_max = 65535;
+#define NFS_CALLBACK_MAXPORTNR (65535U)
 
-static int param_set_port(const char *val, struct kernel_param *kp)
+static int param_set_portnr(const char *val, struct kernel_param *kp)
 {
-	char *endp;
-	int num = simple_strtol(val, &endp, 0);
-	if (endp == val || *endp || num < nfs_set_port_min || num > nfs_set_port_max)
+	unsigned long num;
+	int ret;
+
+	if (!val)
+		return -EINVAL;
+	ret = strict_strtoul(val, 0, &num);
+	if (ret == -EINVAL || num > NFS_CALLBACK_MAXPORTNR)
 		return -EINVAL;
-	*((int *)kp->arg) = num;
+	*((unsigned int *)kp->arg) = num;
 	return 0;
 }
 
-module_param_call(callback_tcpport, param_set_port, param_get_int,
-		 &nfs_callback_set_tcpport, 0644);
+static int param_get_portnr(char *buffer, struct kernel_param *kp)
+{
+	return param_get_uint(buffer, kp);
+}
+#define param_check_portnr(name, p) __param_check(name, p, unsigned int);
+
+module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
 
 /*
  * This is the NFSv4 callback kernel thread.
-- 
1.6.0.4
