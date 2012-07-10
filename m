Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47281 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756419Ab2GJR33 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 13:29:29 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix an NFSv4 mount regression
Date: Tue, 10 Jul 2012 13:29:23 -0400
Message-Id: <1341941363-12589-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The helper nfs_fs_mount() will always call nfs4_try_mount with the
mount_info->fill_super argument pointing to nfs_fill_super, which is
NFSv2/v3 only.
Fix is to have nfs4_try_mount replace it with nfs4_fill_super.

The regression was introduced by commit c40f8d1d (NFS: Create a common
fs_mount() function)

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 906f09c..0622819 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2860,6 +2860,8 @@ static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
 
+	mount_info->fill_super = nfs4_fill_super;
+
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
 	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
-- 
1.7.10.4

