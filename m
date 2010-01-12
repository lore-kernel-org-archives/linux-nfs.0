Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986Ab0ALOYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2010 09:24:44 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Avoid warnings when CONFIG_NFS_V4=n
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Date: Tue, 12 Jan 2010 14:23:40 +0000
Message-ID: <20100112142340.2862.5903.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

