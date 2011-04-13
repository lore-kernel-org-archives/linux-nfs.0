Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5315 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757105Ab1DMSbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 14:31:34 -0400
Message-ID: <4DA5EC02.2070906@netapp.com>
Date: Wed, 13 Apr 2011 14:31:30 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/6] NFS: don't negotiate when user specifies sec flavor
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


We were always attempting sec flavor negotiation, even if the user
told us a specific sec flavor to use.  If that sec flavor fails,
we should return an error rather than continuing with sec flavor
negotiation.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 fs/nfs/super.c    |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e27ebf..b8e1ac6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -46,6 +46,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/nfs_mount.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/module.h>
@@ -2234,7 +2235,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
 	int status = nfs4_lookup_root(server, fhandle, info);
-	if (status == -EPERM)
+	if ((status == -EPERM) && !(server->flags & NFS_MOUNT_SECFLAVOUR))
 		status = nfs4_find_root_sec(server, fhandle, info);
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2b8e9a5..74482e6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1004,6 +1004,7 @@ static int nfs_parse_security_flavors(char *value,
 		return 0;
 	}
 
+	mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 	mnt->auth_flavor_len = 1;
 	return 1;
 }
-- 
1.7.4.4

