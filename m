Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bband-dyn38.178-41-141.t-com.sk ([178.41.141.38]:19049 "EHLO
	ip4-83-240-18-248.cust.nbox.cz" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933454AbaGROCh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 10:02:37 -0400
From: Jiri Slaby <jslaby@suse.cz>
To: stable@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Mateusz Guzik <mguzik@redhat.com>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 3.12 037/170] NFS: populate ->net in mount data when remounting
Date: Fri, 18 Jul 2014 14:10:42 +0200
Message-Id: <708fc7633ef80d411ab112d2ec64dd5826c9863a.1405685481.git.jslaby@suse.cz>
In-Reply-To: <48e8cad86bb1241c08bdaa80db022c25068ff8e0.1405685481.git.jslaby@suse.cz>
References: <48e8cad86bb1241c08bdaa80db022c25068ff8e0.1405685481.git.jslaby@suse.cz>
In-Reply-To: <cover.1405685481.git.jslaby@suse.cz>
References: <cover.1405685481.git.jslaby@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mateusz Guzik <mguzik@redhat.com>

3.12-stable review patch.  If anyone has any objections, please let me know.

===============

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
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 fs/nfs/super.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a03b9c6f9489..64940b5286db 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2197,6 +2197,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
 	data->nfs_server.port = nfss->port;
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
+	data->net = current->nsproxy->net_ns;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);
 
-- 
2.0.0

