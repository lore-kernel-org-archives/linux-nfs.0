From: andros@netapp.com
Subject: [PATCH 1/1] pnfs: use mds pseudoflavor for ds
Date: Fri, 12 Feb 2010 13:24:48 -0500
Message-ID: <1265999088-3507-2-git-send-email-andros@netapp.com>
References: <1265999088-3507-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36630 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754766Ab0BLSZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 13:25:54 -0500
In-Reply-To: <1265999088-3507-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index e9674a9..b75fe46 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -222,7 +222,8 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	int			addrlen;
 	int err = 0;
 
-	dprintk("--> %s ip:port %s\n", __func__, ds->r_addr);
+	dprintk("--> %s ip:port %s au_flavor %d\n", __func__,
+		ds->r_addr, mds_clnt->cl_auth->au_flavor);
 
 	sin.sin_family = AF_INET;
 	sin.sin_addr.s_addr = ds->ds_ip_addr;
@@ -254,7 +255,7 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 			      (struct sockaddr *)&sin,
 			      sizeof(struct sockaddr),
 			      ip_addr,
-			      RPC_AUTH_UNIX,
+			      mds_clnt->cl_auth->au_flavor,
 			      IPPROTO_TCP,
 			      mds_clnt->cl_xprt->timeout,
 			      1 /* minorversion */);
-- 
1.6.6

