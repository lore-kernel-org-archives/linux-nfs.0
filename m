Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20990 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536Ab0I2LKQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:10:16 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: clear fsinfo before sendign rpc
Date: Wed, 29 Sep 2010 13:10:13 +0200
Message-Id: <1285758613-26897-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

To initialize all values to zero, in case the server or protocol version
do no support particular attributes.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 23d740c..beb206e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -942,6 +942,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 			goto out_error;
 	}
 
+	memset(&fsinfo, 0, sizeof(fsinfo));
 	fsinfo.fattr = fattr;
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
 	if (error < 0)
-- 
1.7.2.3

