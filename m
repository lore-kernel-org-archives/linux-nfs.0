Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:32391 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753877AbaIXQ4R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 12:56:17 -0400
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        ebiederm@xmission.com, Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] nfs: fix duplicate proc entries
Date: Wed, 24 Sep 2014 18:56:11 +0200
Message-Id: <1411577771-9474-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 65b38851a174
("NFS: Fix /proc/fs/nfsfs/servers and /proc/fs/nfsfs/volumes")

updated the following function:
static int nfs_volume_list_open(struct inode *inode, struct file *file)

it used &nfs_server_list_ops instead of &nfs_volume_list_ops
which means cat /proc/fs/nfsfs/volumes = /proc/fs/nfsfs/servers

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfs/client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8052020..f9f4845 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1320,7 +1320,7 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
  */
 static int nfs_volume_list_open(struct inode *inode, struct file *file)
 {
-	return seq_open_net(inode, file, &nfs_server_list_ops,
+	return seq_open_net(inode, file, &nfs_volume_list_ops,
 			   sizeof(struct seq_net_private));
 }
 
-- 
1.9.3

