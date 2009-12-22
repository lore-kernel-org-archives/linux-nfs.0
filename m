From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Avoid warnings when CONFIG_NFS_V4=n
Date: Tue, 22 Dec 2009 18:00:25 +0000
Message-ID: <20091222180025.22975.51433.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, dhowells@redhat.com
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233AbZLVSBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Dec 2009 13:01:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid the following warnings when CONFIG_NFS_V4=n:

	fs/nfs/sysctl.c:19: warning: unused variable `nfs_set_port_max'
	fs/nfs/sysctl.c:18: warning: unused variable `nfs_set_port_min'

by making those variables contingent on NFSv4 being configured.

Signed-off-by: David Howells <dhowells@redhat.com>
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

