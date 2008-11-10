From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 11/85] nfs41: nfs_client.cl_minorversion
Date: Mon, 10 Nov 2008 22:19:44 +0200
Message-ID: <1226348384-7372-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60720 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbYKJUTu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:19:50 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This field is set to the nfsv4 minor version for this mount.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |    1 +
 include/linux/nfs_fs_sb.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index fe0bac9..c6e9b4e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1030,6 +1030,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		error = PTR_ERR(clp);
 		goto error;
 	}
+	clp->cl_minorversion = server->minorversion;
 	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour);
 	if (error < 0)
 		goto error_put;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index bfc83cc..8379dd5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -69,7 +69,8 @@ struct nfs_client {
 	 */
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
-#endif
+	u32			cl_minorversion;
+#endif /* CONFIG_NFS_V4 */
 };
 
 /*
-- 
1.6.0.2

