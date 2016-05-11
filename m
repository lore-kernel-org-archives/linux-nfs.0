Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:63470 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbcEKTI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 15:08:56 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 09/10] NFS test pnfs data server multipath session trunking aliases
Date: Wed, 11 May 2016 15:08:24 -0400
Message-ID: <1462993705-14673-10-git-send-email-andros@netapp.com>
In-Reply-To: <1462993705-14673-1-git-send-email-andros@netapp.com>
References: <1462993705-14673-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Try all multipath addresses for a data server. The first address that
successfully connects and creates a session is the mount address.
All subsequent addresses are tested for session trunking and
added as aliases.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs_nfs.c | 51 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 37 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 4aaed89..b1e2b94 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -654,13 +654,43 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
-		clp = nfs4_set_ds_client(mds_srv->nfs_client,
-					(struct sockaddr *)&da->da_addr,
-					da->da_addrlen, IPPROTO_TCP,
-					timeo, retrans, minor_version,
-					au_flavor);
-		if (!IS_ERR(clp))
-			break;
+		if (!IS_ERR(clp) && clp->cl_mvops->session_trunk) {
+			struct xprt_create xprt_args = {
+				.ident = XPRT_TRANSPORT_TCP,
+				.net = clp->cl_net,
+				.dstaddr = (struct sockaddr *)&da->da_addr,
+				.addrlen = da->da_addrlen,
+				.servername = clp->cl_hostname,
+			};
+			struct nfs4_add_xprt_data xprtdata = {
+				.clp = clp,
+			};
+			xprtdata.cred = nfs4_get_clid_cred(clp);
+
+			/**
+			 * Test this address for session trunking and
+			 * add as an alias
+			 */
+			rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
+					  clp->cl_mvops->session_trunk,
+					  &xprtdata);
+		} else {
+			clp = nfs4_set_ds_client(mds_srv->nfs_client,
+						(struct sockaddr *)&da->da_addr,
+						da->da_addrlen, IPPROTO_TCP,
+						timeo, retrans, minor_version,
+						au_flavor);
+			if (IS_ERR(clp))
+				continue;
+
+			status = nfs4_init_ds_session(clp,
+					mds_srv->nfs_client->cl_lease_time);
+			if (status) {
+				nfs_put_client(clp);
+				clp = ERR_PTR(-EIO);
+				continue;
+			}
+		}
 	}
 
 	if (IS_ERR(clp)) {
@@ -668,18 +698,11 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 		goto out;
 	}
 
-	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
-	if (status)
-		goto out_put;
-
 	smp_wmb();
 	ds->ds_clp = clp;
 	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
 out:
 	return status;
-out_put:
-	nfs_put_client(clp);
-	goto out;
 }
 
 /*
-- 
1.8.3.1

