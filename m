From: andros@netapp.com
Subject: [PATCH 2/3] SQUASHME pnfs_submit: update DS nfs4_set_client
Date: Wed, 12 May 2010 13:39:39 -0400
Message-ID: <1273685980-3340-3-git-send-email-andros@netapp.com>
References: <1273685980-3340-1-git-send-email-andros@netapp.com>
 <1273685980-3340-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56045 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756463Ab0ELRkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 13:40:11 -0400
In-Reply-To: <1273685980-3340-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Dont bother using the hostname, use the client ipaddr field from the MDS
nfs_client for construction of the co_ownrid field the DS EXCHANGE_ID.

Clean up the comments.

Squash into "pnfs: filelayout: device ops"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   28 +++++-----------------------
 1 files changed, 5 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 891c31d..b41f437 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -128,8 +128,6 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	struct rpc_clnt 	*mds_clnt = mds_srv->client;
 	struct nfs_client	*clp = mds_srv->nfs_client;
 	struct sockaddr		*mds_addr;
-	char			ip_addr[16];
-	int			addrlen;
 	int err = 0;
 
 	dprintk("--> %s ip:port %s au_flavor %d\n", __func__,
@@ -156,32 +154,16 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		}
 		goto out;
 	}
-	/* Set timeout to the mds rpc clnt value.
-	 * XXX - find the correct authflavor....
-	 *
-	 * Fake a client ipaddr (used for sessionid) with hostname
-	 * Use hostname since it might be more unique than ipaddr (which
-	 * could be set to the loopback 127.0.0/1.1
-	 *
-	 * XXX: Should sessions continue to use the cl_ipaddr field?
-	 */
-	addrlen = strnlen(utsname()->nodename, sizeof(utsname()->nodename));
-	if (addrlen > sizeof(ip_addr))
-		addrlen = sizeof(ip_addr);
-	memcpy(ip_addr, utsname()->nodename, addrlen);
-
-	/* XXX need a non-nfs_client struct interface to set up
-	 * data server sessions
-	 *
-	 * tmp: nfs4_set_client sets the nfs_server->nfs_client.
-	 *
-	 * We specify a retrans and timeout interval equual to MDS. ??
+	/*
+	 * Set a retrans, timeout interval, and authflavor equual to the MDS
+	 * values. Use the MDS nfs_client cl_ipaddr field so as to use the
+	 * same co_ownerid as the MDS.
 	 */
 	err = nfs4_set_client(&tmp,
 			      mds_srv->nfs_client->cl_hostname,
 			      (struct sockaddr *)&sin,
 			      sizeof(struct sockaddr),
-			      ip_addr,
+			      mds_srv->nfs_client->cl_ipaddr,
 			      mds_clnt->cl_auth->au_flavor,
 			      IPPROTO_TCP,
 			      mds_clnt->cl_xprt->timeout,
-- 
1.6.6

