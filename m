Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34520 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab1FIXDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:03:31 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 03/11] nfs:  Add srcaddr member to nfs_client.
Date: Thu,  9 Jun 2011 16:02:47 -0700
Message-Id: <1307660575-6994-4-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
References: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>


Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 b9056cb... 8a8ae87... M	fs/nfs/internal.h
:100644 100644 ce40e5c... cb41131... M	fs/nfs/super.c
:100644 100644 87694ca... 9db4473... M	include/linux/nfs_fs_sb.h
 fs/nfs/internal.h         |    5 +++++
 fs/nfs/super.c            |    2 ++
 include/linux/nfs_fs_sb.h |    4 ++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b9056cb..8a8ae87 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -96,6 +96,11 @@ struct nfs_parsed_mount_data {
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
index ce40e5c..cb41131 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -904,6 +904,8 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 		data->auth_flavor_len	= 1;
 		data->version		= version;
 		data->minorversion	= 0;
+		data->srcaddr.address.ss_family = AF_UNSPEC;
+		data->srcaddr.addrlen = sizeof(data->srcaddr.address);
 	}
 	return data;
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87694ca..9db4473 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -80,6 +80,10 @@ struct nfs_client {
 	struct list_head	cl_layouts;
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

