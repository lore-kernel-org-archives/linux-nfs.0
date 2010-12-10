Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab0LJGIq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:46 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLj023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:45 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/22] Revert "FIXME: NFS: clear fsinfo before sendign rpc"
Date: Thu,  9 Dec 2010 20:22:43 -0500
Message-Id: <1291944177-7819-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 462e3c258daa62a5331a0febff3e224da6af5481.

Not needed since layouttype is initialized by
commit 85e174ba6b: NFS: set layout driver

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/client.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dbf43e7..172175f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -950,7 +950,6 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 			goto out_error;
 	}
 
-	memset(&fsinfo, 0, sizeof(fsinfo));
 	fsinfo.fattr = fattr;
 	fsinfo.layouttype = 0;
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
-- 
1.7.2.1

