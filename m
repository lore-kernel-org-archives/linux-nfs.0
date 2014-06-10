Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbaFJKoS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2014 06:44:18 -0400
From: Mateusz Guzik <mguzik@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org.#.3.4+
Subject: [PATCH] NFS: populate ->net in mount data when remounting
Date: Tue, 10 Jun 2014 12:44:12 +0200
Message-Id: <1402397052-13970-1-git-send-email-mguzik@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise the kernel oopses when remounting with IPv6 server because
net is dereferenced in dev_get_by_name.

Use net ns of current thread so that dev_get_by_name does not operate on
foreign ns. Changing the address is prohibited anyway so this should not
affect anything.

Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org # 3.4+
---
 fs/nfs/super.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2cb5694..104ef01 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2248,6 +2248,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
 	data->version = nfsvers;
 	data->minorversion = nfss->nfs_client->cl_minorversion;
+	data->net = current->nsproxy->net_ns;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);
 
-- 
1.8.3.1

