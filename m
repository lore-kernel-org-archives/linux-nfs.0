Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38807 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaLPTCR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:17 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so14490859pde.40
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:16 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/50] nfs41: allow LD to choose DS connection version/minor_version
Date: Tue, 16 Dec 2014 11:01:12 -0800
Message-Id: <1418756513-95187-10-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

flexfile layout may need to set such when making DS connections.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayoutdev.c |  3 ++-
 fs/nfs/internal.h                 |  1 +
 fs/nfs/nfs4client.c               |  4 ++--
 fs/nfs/pnfs.h                     |  3 ++-
 fs/nfs/pnfs_dev.c                 | 11 +++++++----
 5 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 5e4b0ce..4f372e2 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -278,7 +278,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		goto out_test_devid;
 
 	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
-			     dataserver_retrans,
+			     dataserver_retrans, 4,
+			     s->nfs_client->cl_minorversion,
 			     s->nfs_client->cl_rpcclient->cl_auth->au_flavor);
 
 out_test_devid:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index bf9f79f..70f6ff8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -190,6 +190,7 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
 					     unsigned int ds_retrans,
+					     u32 minor_version,
 					     rpc_authflavor_t au_flavor);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 61d552d..d303627 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -838,14 +838,14 @@ error:
 struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		const struct sockaddr *ds_addr, int ds_addrlen,
 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
-		rpc_authflavor_t au_flavor)
+		u32 minor_version, rpc_authflavor_t au_flavor)
 {
 	struct nfs_client_initdata cl_init = {
 		.addr = ds_addr,
 		.addrlen = ds_addrlen,
 		.nfs_mod = &nfs_v4,
 		.proto = ds_proto,
-		.minorversion = mds_clp->cl_minorversion,
+		.minorversion = minor_version,
 		.net = mds_clp->cl_net,
 	};
 	struct rpc_timeout ds_timeout;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 588b2f1..a5b168c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -308,7 +308,8 @@ struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
 				      gfp_t gfp_flags);
 void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, rpc_authflavor_t au_flavor);
+			  unsigned int retrans, u32 versoin, u32 minor_version,
+			  rpc_authflavor_t au_flavor);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index f819aa3..56f5c16 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -619,6 +619,7 @@ static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
 				 unsigned int retrans,
+				 u32 minor_version,
 				 rpc_authflavor_t au_flavor)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
@@ -635,7 +636,8 @@ static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
 		clp = nfs4_set_ds_client(mds_srv->nfs_client,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
-					timeo, retrans, au_flavor);
+					timeo, retrans, minor_version,
+					au_flavor);
 		if (!IS_ERR(clp))
 			break;
 	}
@@ -666,13 +668,14 @@ out_put:
  */
 void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, rpc_authflavor_t au_flavor)
+			  unsigned int retrans, u32 version,
+			  u32 minor_version, rpc_authflavor_t au_flavor)
 {
 	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		int err = 0;
 
-		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo,
-					    retrans, au_flavor);
+		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo, retrans,
+					    minor_version, au_flavor);
 		if (err)
 			nfs4_mark_deviceid_unavailable(devid);
 		nfs4_clear_ds_conn_bit(ds);
-- 
1.9.3

