Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54714 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbbAVXg4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:36:56 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so4648949pdj.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:36:56 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 10/51] nfs41: create NFSv3 DS connection if specified
Date: Thu, 22 Jan 2015 15:35:42 -0800
Message-Id: <1421969783-92997-11-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 51 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index ad211a4..5c6cb00 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -550,7 +550,44 @@ static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
 	wake_up_bit(&ds->ds_state, NFS4DS_CONNECTING);
 }
 
-static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
+static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
+				 struct nfs4_pnfs_ds *ds,
+				 unsigned int timeo,
+				 unsigned int retrans,
+				 rpc_authflavor_t au_flavor)
+{
+	struct nfs_client *clp = ERR_PTR(-EIO);
+	struct nfs4_pnfs_ds_addr *da;
+	int status = 0;
+
+	dprintk("--> %s DS %s au_flavor %d\n", __func__,
+		ds->ds_remotestr, au_flavor);
+
+	list_for_each_entry(da, &ds->ds_addrs, da_node) {
+		dprintk("%s: DS %s: trying address %s\n",
+			__func__, ds->ds_remotestr, da->da_remotestr);
+
+		clp = nfs3_set_ds_client(mds_srv->nfs_client,
+					(struct sockaddr *)&da->da_addr,
+					da->da_addrlen, IPPROTO_TCP,
+					timeo, retrans, au_flavor);
+		if (!IS_ERR(clp))
+			break;
+	}
+
+	if (IS_ERR(clp)) {
+		status = PTR_ERR(clp);
+		goto out;
+	}
+
+	smp_wmb();
+	ds->ds_clp = clp;
+	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
+out:
+	return status;
+}
+
+static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
 				 unsigned int retrans,
@@ -609,8 +646,19 @@ void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		int err = 0;
 
-		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo, retrans,
-					    minor_version, au_flavor);
+		if (version == 3) {
+			err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo,
+						       retrans, au_flavor);
+		} else if (version == 4) {
+			err = _nfs4_pnfs_v4_ds_connect(mds_srv, ds, timeo,
+						       retrans, minor_version,
+						       au_flavor);
+		} else {
+			dprintk("%s: unsupported DS version %d\n", __func__,
+				version);
+			err = -EPROTONOSUPPORT;
+		}
+
 		if (err)
 			nfs4_mark_deviceid_unavailable(devid);
 		nfs4_clear_ds_conn_bit(ds);
-- 
1.9.3

