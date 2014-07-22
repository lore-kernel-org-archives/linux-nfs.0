Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:44935 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933649AbaGVW1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 18:27:33 -0400
From: Kamal Mostafa <kamal@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        kernel-team@lists.ubuntu.com
Cc: Mateusz Guzik <mguzik@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 3.8 072/116] NFS: populate ->net in mount data when remounting
Date: Tue, 22 Jul 2014 15:21:23 -0700
Message-Id: <1406067727-19683-73-git-send-email-kamal@canonical.com>
In-Reply-To: <1406067727-19683-1-git-send-email-kamal@canonical.com>
References: <1406067727-19683-1-git-send-email-kamal@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

3.8.13.27 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Mateusz Guzik <mguzik@redhat.com>

commit a914722f333b3359d2f4f12919380a334176bb89 upstream.

Otherwise the kernel oopses when remounting with IPv6 server because
net is dereferenced in dev_get_by_name.

Use net ns of current thread so that dev_get_by_name does not operate on
foreign ns. Changing the address is prohibited anyway so this should not
affect anything.

Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 fs/nfs/super.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b056b16..f4d000a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2167,6 +2167,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
 	data->nfs_server.port = nfss->port;
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
+	data->net = current->nsproxy->net_ns;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);
 
-- 
1.9.1

