Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7574 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab0LFI7c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Dec 2010 03:59:32 -0500
Subject: [PATCH v2] NFS: suppressing showing of default mount port value in
	/proc fixed
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 06 Dec 2010 12:00:31 +0300
Message-ID: <20101206085553.2172.24863.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Update: added check for zero value as it was before (note: can't simply check
mountd_port for positive value because it's typeof unsigned short)

Default value for mount server port is set to NFS_UNSPEC_PORT (-1) and will not
be changed during parsing mount options for mound data version 6. This default
value will be showed for mountport in /proc/mounts always since current default
check is for zero value. This small mistake leads to big problem, because
during umount.nfs execution from old user-space utils (at least nfs-utils
1.0.9) this value will be used as the server port to connect to. This request
will be rejected (since port is 65535) and thus nfs mount point can't be
unmounted.

Note from Chuck Lever (chuck.lever@oracle.com): this is only possible if
/etc/mtab is a link to /proc/mounts.  Not all systems have this configuration.

---
 fs/nfs/super.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6d6e21d..449024f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -681,7 +681,9 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 
 	if (nfss->mountd_version || showdefaults)
 		seq_printf(m, ",mountvers=%u", nfss->mountd_version);
-	if (nfss->mountd_port || showdefaults)
+	if ((nfss->mountd_port &&
+		nfss->mountd_port != (unsigned short)NFS_UNSPEC_PORT) || 
+		showdefaults)
 		seq_printf(m, ",mountport=%u", nfss->mountd_port);
 
 	nfs_show_mountd_netid(m, nfss, showdefaults);

