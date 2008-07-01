From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] nfs: sysctl's should use USER_HZ not HZ
Date: Tue, 1 Jul 2008 11:44:29 -0700
Message-ID: <20080701114429.539d7fb0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36966 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758543AbYGASoa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2008 14:44:30 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 7324B4F4310
	for <linux-nfs@vger.kernel.org>; Tue,  1 Jul 2008 11:44:30 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oEwjiiIcNDEe for <linux-nfs@vger.kernel.org>;
	Tue,  1 Jul 2008 11:44:30 -0700 (PDT)
Received: from extreme (pool-71-245-98-107.ptldor.fios.verizon.net [71.245.98.107])
	by mail.vyatta.com (Postfix) with ESMTP id 29A744F430F
	for <linux-nfs@vger.kernel.org>; Tue,  1 Jul 2008 11:44:30 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no good way to tell what the internal value of kernel HZ is
from userspace, so all administrative interfaces are supposed to use
either USER_HZ (100) or other absolute time units.  Two of the NFS sysctl
values are still using HZ, and can be simply converted to USER_HZ.

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

--- a/fs/nfs/sysctl.c	2008-07-01 11:37:13.000000000 -0700
+++ b/fs/nfs/sysctl.c	2008-07-01 11:38:21.000000000 -0700
@@ -37,7 +37,7 @@ static ctl_table nfs_cb_sysctls[] = {
 		.data = &nfs_idmap_cache_timeout,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_jiffies,
+		.proc_handler = &proc_dointvec_userhz_jiffies,
 		.strategy = &sysctl_jiffies,
 	},
 #endif
@@ -47,7 +47,7 @@ static ctl_table nfs_cb_sysctls[] = {
 		.data		= &nfs_mountpoint_expiry_timeout,
 		.maxlen		= sizeof(nfs_mountpoint_expiry_timeout),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= &proc_dointvec_userhz_jiffies,
 		.strategy	= &sysctl_jiffies,
 	},
 	{
