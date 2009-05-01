From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Do not display the setting of the "intr" mount option
Date: Fri, 01 May 2009 12:34:27 -0400
Message-ID: <20090501163402.25637.67939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:60846 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbZEAQej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 12:34:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "intr" mount option has been deprecated for a while, but
/proc/mounts continues to display "nointr" whether "intr" or "nointr"
has been specified for a mount point.

Since these options do not have any effect, simply do not display
them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Trond-

For 2.6.31?

 fs/nfs/super.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6717200..7a81cb6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -514,7 +514,6 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		const char *nostr;
 	} nfs_info[] = {
 		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
-		{ NFS_MOUNT_INTR, ",intr", ",nointr" },
 		{ NFS_MOUNT_POSIX, ",posix", "" },
 		{ NFS_MOUNT_NOCTO, ",nocto", "" },
 		{ NFS_MOUNT_NOAC, ",noac", "" },

