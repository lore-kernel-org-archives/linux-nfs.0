Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39862 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab3AUUqv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:46:51 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 03/13] nfs: Add srcaddr member to nfs_client.
Date: Mon, 21 Jan 2013 12:45:49 -0800
Message-Id: <1358801159-18829-4-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/internal.h         |    5 +++++
 fs/nfs/super.c            |    2 ++
 include/linux/nfs_fs_sb.h |    4 ++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 05521ca..80504e1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -119,6 +119,11 @@ struct nfs_parsed_mount_data {
 	struct {
 		struct sockaddr_storage	address;
 		size_t			addrlen;
+	} srcaddr;
+
+	struct {
+		struct sockaddr_storage address;
+		size_t                  addrlen;
 		char			*hostname;
 		u32			version;
 		int			port;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 00be08f..61b3dc9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -968,6 +968,8 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 		data->minorversion	= 0;
 		data->need_mount	= true;
 		data->net		= current->nsproxy->net_ns;
+		data->srcaddr.address.ss_family = AF_UNSPEC;
+		data->srcaddr.addrlen = sizeof(data->srcaddr.address);
 		security_init_mnt_opts(&data->lsm_opts);
 	}
 	return data;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a9e76ee..0f5d16d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -88,6 +88,10 @@ struct nfs_client {
 	struct nfs41_impl_id	*cl_implid;
 #endif /* CONFIG_NFS_V4 */
 
+	/* If we should bind to a local IP, it should be specified below. */
+	struct sockaddr_storage	srcaddr;
+	size_t			srcaddrlen;
+
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
-- 
1.7.3.4

