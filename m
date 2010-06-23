From: andros@netapp.com
Subject: [PATCH 10/10] SQUASHME pnfs-submit: remove struct nfs_server from stack
Date: Wed, 23 Jun 2010 15:21:18 -0400
Message-ID: <1277320878-3726-11-git-send-email-andros@netapp.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
 <1277320878-3726-2-git-send-email-andros@netapp.com>
 <1277320878-3726-3-git-send-email-andros@netapp.com>
 <1277320878-3726-4-git-send-email-andros@netapp.com>
 <1277320878-3726-5-git-send-email-andros@netapp.com>
 <1277320878-3726-6-git-send-email-andros@netapp.com>
 <1277320878-3726-7-git-send-email-andros@netapp.com>
 <1277320878-3726-8-git-send-email-andros@netapp.com>
 <1277320878-3726-9-git-send-email-andros@netapp.com>
 <1277320878-3726-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447Ab0FWTWa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 15:22:30 -0400
In-Reply-To: <1277320878-3726-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 5842c09..8e9d04a 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -121,9 +121,7 @@ _data_server_lookup(u32 ip_addr, u32 port)
 static int
 nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 {
-	struct nfs_server	tmp = {
-		.nfs_client = NULL,
-	};
+	struct nfs_server	*tmp;
 	struct sockaddr_in	sin;
 	struct rpc_clnt 	*mds_clnt = mds_srv->client;
 	struct nfs_client	*clp = mds_srv->nfs_client;
@@ -154,12 +152,18 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		}
 		goto out;
 	}
+
+	/* Temporay server for nfs4_set_client */
+	tmp = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (!tmp)
+		goto out;
+
 	/*
 	 * Set a retrans, timeout interval, and authflavor equual to the MDS
 	 * values. Use the MDS nfs_client cl_ipaddr field so as to use the
 	 * same co_ownerid as the MDS.
 	 */
-	err = nfs4_set_client(&tmp,
+	err = nfs4_set_client(tmp,
 			      mds_srv->nfs_client->cl_hostname,
 			      (struct sockaddr *)&sin,
 			      sizeof(struct sockaddr),
@@ -169,9 +173,9 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 			      mds_clnt->cl_xprt->timeout,
 			      1 /* minorversion */);
 	if (err < 0)
-		goto out;
+		goto out_free;
 
-	clp = tmp.nfs_client;
+	clp = tmp->nfs_client;
 
 	/* Ask for only the EXCHGID4_FLAG_USE_PNFS_DS pNFS role */
 	dprintk("%s EXCHANGE_ID for clp %p\n", __func__, clp);
@@ -211,6 +215,8 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	dprintk("%s: ip=%x, port=%hu, rpcclient %p\n", __func__,
 				ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
 				clp->cl_rpcclient);
+out_free:
+	kfree(tmp);
 out:
 	dprintk("%s Returns %d\n", __func__, err);
 	return err;
-- 
1.6.6

