Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34483 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933175AbcBAPX0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 10:23:26 -0500
Received: by mail-ig0-f178.google.com with SMTP id ik10so38134528igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 07:23:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 13/13] pnfs/NFSv4.1: Add multipath capabilities to pNFS flexfiles servers over NFSv3
Date: Mon,  1 Feb 2016 10:22:35 -0500
Message-Id: <1454340155-7670-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454340155-7670-13-git-send-email-trond.myklebust@primarydata.com>
References: <1454340155-7670-1-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-2-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-3-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-4-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-5-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-6-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-7-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-8-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-9-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-10-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-11-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-12-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-13-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This adds multipathing to pNFS over NFSv3 as described in the flexfiles
draft spec.
Ideally, we'd like to do the same for pNFS files, but the NFSv4.1 protocol
requires a call to EXCHANGE_ID in order to test that the connection can do
session trunking.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 81ac6480f9e7..4aaed890048f 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -606,12 +606,22 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
-		clp = get_v3_ds_connect(mds_srv->nfs_client,
+		if (!IS_ERR(clp)) {
+			struct xprt_create xprt_args = {
+				.ident = XPRT_TRANSPORT_TCP,
+				.net = clp->cl_net,
+				.dstaddr = (struct sockaddr *)&da->da_addr,
+				.addrlen = da->da_addrlen,
+				.servername = clp->cl_hostname,
+			};
+			/* Add this address as an alias */
+			rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
+					rpc_clnt_test_and_add_xprt, NULL);
+		} else
+			clp = get_v3_ds_connect(mds_srv->nfs_client,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
 					timeo, retrans, au_flavor);
-		if (!IS_ERR(clp))
-			break;
 	}
 
 	if (IS_ERR(clp)) {
-- 
2.5.0

