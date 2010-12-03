Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32812 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644Ab0LCRLm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 12:11:42 -0500
Subject: [PATCH] NFS: suppressing showing of default mount port value in /proc
	fixed
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 03 Dec 2010 20:11:45 +0300
Message-ID: <20101203170138.22955.86546.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Default value for mount server port is set to NFS_UNSPEC_PORT (-1) and will not
be changed during parsing mount options for mound data version 6. This default
value will be showed for mountport in /proc/mounts always since current default
check is for zero value. This small mistake leads to big problem, because
during umount.nfs execution from old user-space utils (at least nfs-utils
1.0.9) this value will be used as the server port to connect to. This request
will be rejected (since port is 65535) and thus nfs mount point can't be
unmounted.

Kernel version affected: 2.6.37-rc4

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/super.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6d6e21d..fd4cac8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -681,7 +681,8 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 
 	if (nfss->mountd_version || showdefaults)
 		seq_printf(m, ",mountvers=%u", nfss->mountd_version);
-	if (nfss->mountd_port || showdefaults)
+	if (nfss->mountd_port != (unsigned short)NFS_UNSPEC_PORT ||
+			showdefaults)
 		seq_printf(m, ",mountport=%u", nfss->mountd_port);
 
 	nfs_show_mountd_netid(m, nfss, showdefaults);

