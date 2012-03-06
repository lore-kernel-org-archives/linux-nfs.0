Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44390 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030629Ab2CFP3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 10:29:01 -0500
Received: by mail-gy0-f174.google.com with SMTP id r11so2280207ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Mar 2012 07:29:00 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, skinsbursky@parallels.com
Subject: [PATCH v9 3/6] nfsd: add a per-net-namespace struct for nfsd
Date: Tue,  6 Mar 2012 10:28:50 -0500
Message-Id: <1331047733-1641-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1331047733-1641-1-git-send-email-jlayton@redhat.com>
References: <1331047733-1641-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eventually, we'll need this when nfsd gets containerized fully. For
now, create a struct on a per-net-namespace basis that will just hold
a pointer to the cld_net structure. That struct will hold all of the
per-net data that we need for the cld tracker.

Eventually we can add other pernet objects to struct nfsd_net.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/netns.h  |   34 ++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c |   15 ++++++++++++++-
 2 files changed, 48 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfsd/netns.h

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
new file mode 100644
index 0000000..12e0cff
--- /dev/null
+++ b/fs/nfsd/netns.h
@@ -0,0 +1,34 @@
+/*
+ * per net namespace data structures for nfsd
+ *
+ * Copyright (C) 2012, Jeff Layton <jlayton@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 51
+ * Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#ifndef __NFSD_NETNS_H__
+#define __NFSD_NETNS_H__
+
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+struct cld_net;
+
+struct nfsd_net {
+	struct cld_net *cld_net;
+};
+
+extern int nfsd_net_id;
+#endif /* __NFSD_NETNS_H__ */
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 64c24af..141197e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -19,6 +19,7 @@
 #include "nfsd.h"
 #include "cache.h"
 #include "fault_inject.h"
+#include "netns.h"
 
 /*
  *	We have a single directory with several nodes in it.
@@ -1124,14 +1125,23 @@ static int create_proc_exports_entry(void)
 }
 #endif
 
+int nfsd_net_id;
+static struct pernet_operations nfsd_net_ops = {
+	.id   = &nfsd_net_id,
+	.size = sizeof(struct nfsd_net),
+};
+
 static int __init init_nfsd(void)
 {
 	int retval;
 	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
 
+	retval = register_pernet_subsys(&nfsd_net_ops);
+	if (retval < 0)
+		return retval;
 	retval = nfsd4_init_slabs();
 	if (retval)
-		return retval;
+		goto out_unregister_pernet;
 	nfs4_state_init();
 	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
 	if (retval)
@@ -1169,6 +1179,8 @@ out_free_stat:
 	nfsd_fault_inject_cleanup();
 out_free_slabs:
 	nfsd4_free_slabs();
+out_unregister_pernet:
+	unregister_pernet_subsys(&nfsd_net_ops);
 	return retval;
 }
 
@@ -1184,6 +1196,7 @@ static void __exit exit_nfsd(void)
 	nfsd4_free_slabs();
 	nfsd_fault_inject_cleanup();
 	unregister_filesystem(&nfsd_fs_type);
+	unregister_pernet_subsys(&nfsd_net_ops);
 }
 
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
-- 
1.7.7.6

