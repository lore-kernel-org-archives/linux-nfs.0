From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/8] NFS: Avoid warnings when CONFIG_NFS_V4=n
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.89074.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64240 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461Ab0AYWEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:09 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM4964014275
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:09 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Avoid the following warnings when CONFIG_NFS_V4=n:

	fs/nfs/sysctl.c:19: warning: unused variable `nfs_set_port_max'
	fs/nfs/sysctl.c:18: warning: unused variable `nfs_set_port_min'

by making those variables contingent on NFSv4 being configured.

Signed-off-by: David Howells <dhowells@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/sysctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 70e1fbb..ad4d2e7 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -15,8 +15,10 @@
 
 #include "callback.h"
 
+#ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
+#endif
 static struct ctl_table_header *nfs_callback_sysctl_table;
 
 static ctl_table nfs_cb_sysctls[] = {

