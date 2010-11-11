Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25689 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211Ab0KKCLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 21:11:23 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] pnfs-submit: callbacks cannot use an nfs_client that is being freed
Date: Thu, 11 Nov 2010 09:10:40 -0500
Message-Id: <1289484640-4100-4-git-send-email-andros@netapp.com>
In-Reply-To: <1289484640-4100-3-git-send-email-andros@netapp.com>
References: <1289484640-4100-1-git-send-email-andros@netapp.com>
 <1289484640-4100-2-git-send-email-andros@netapp.com>
 <1289484640-4100-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Guarantee that the nfs_client exists when referenced to by callback processing
by not procssing callbacks on an nfs_client in the process of being freed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dbf43e7..86657ee 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -392,7 +392,9 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 		if (!nfs_sockaddr_match_ipaddr(addr, clap))
 			continue;
 
-		atomic_inc(&clp->cl_count);
+		/* Don't return an nfs_client that is being freed */
+		if (!atomic_inc_not_zero(&clp->cl_count))
+			continue;
 		spin_unlock(&nfs_client_lock);
 		return clp;
 	}
@@ -425,7 +427,9 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 		if (!nfs_sockaddr_match_ipaddr(sap, clap))
 			continue;
 
-		atomic_inc(&clp->cl_count);
+		/* Don't return an nfs_client that is being freed */
+		if (!atomic_inc_not_zero(&clp->cl_count))
+			continue;
 		spin_unlock(&nfs_client_lock);
 		return clp;
 	}
-- 
1.6.6

