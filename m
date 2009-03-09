From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFS: Do not display the setting of the "intr" mount option
Date: Mon, 09 Mar 2009 14:20:34 -0400
Message-ID: <20090309182033.14860.72421.stgit@ingres.1015granger.net>
References: <20090309181917.14860.88916.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46650 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbZCISUw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2009 14:20:52 -0400
In-Reply-To: <20090309181917.14860.88916.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "intr" mount option has been deprecated for a while, but
/proc/mounts continues to display "nointr" whether "intr" or "nointr"
has been specified for a mount point.

Since these options do not have any effect, simply do not display
them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d6686f4..520fe6f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -508,7 +508,6 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		const char *nostr;
 	} nfs_info[] = {
 		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
-		{ NFS_MOUNT_INTR, ",intr", ",nointr" },
 		{ NFS_MOUNT_POSIX, ",posix", "" },
 		{ NFS_MOUNT_NOCTO, ",nocto", "" },
 		{ NFS_MOUNT_NOAC, ",noac", "" },

