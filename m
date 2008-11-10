From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 10/85] nfs41: struct nfs_server minorversion
Date: Mon, 10 Nov 2008 22:19:34 +0200
Message-ID: <1226348374-7339-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60716 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbYKJUTj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:19:39 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mike Sager <sager@netapp.com>

Set nfs_server minorversion from mount option (or default).
During client initialization, use this minorversion.

Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |    2 ++
 include/linux/nfs_fs_sb.h |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7547600..fe0bac9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1112,6 +1112,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	server->minorversion = data->minorversion;
+
 	/* set up the general RPC client */
 	error = nfs4_init_server(server, data);
 	if (error < 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4e477ae..bfc83cc 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -115,6 +115,7 @@ struct nfs_server {
 	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
 						   that are supported on this
 						   filesystem */
+	u32			minorversion;
 #endif
 	void (*destroy)(struct nfs_server *);
 
-- 
1.6.0.2

