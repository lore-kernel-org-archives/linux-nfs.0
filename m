Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:52810 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbbANQpP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:45:15 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so11472819pac.11
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:45:15 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 06/50] nfs41: allow LD to choose DS connection auth flavor
Date: Wed, 14 Jan 2015 08:44:12 -0800
Message-Id: <1421253896-73106-7-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
References: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

flexfile layout may use different auth flavor as specified by MDS.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayoutdev.c |  3 ++-
 fs/nfs/internal.h                 |  3 ++-
 fs/nfs/nfs4client.c               |  5 +++--
 fs/nfs/pnfs.h                     |  2 +-
 fs/nfs/pnfs_nfs.c                 | 10 ++++++----
 5 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 27bdd8c..5e4b0ce 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -278,7 +278,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		goto out_test_devid;
 
 	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
-			     dataserver_retrans);
+			     dataserver_retrans,
+			     s->nfs_client->cl_rpcclient->cl_auth->au_flavor);
 
 out_test_devid:
 	if (filelayout_test_devid_unavailable(devid))
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index efaa31c..7d7c36f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -189,7 +189,8 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     const struct sockaddr *ds_addr,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
-					     unsigned int ds_retrans);
+					     unsigned int ds_retrans,
+					     rpc_authflavor_t au_flavor);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 0331125..61d552d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -837,7 +837,8 @@ error:
  */
 struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		const struct sockaddr *ds_addr, int ds_addrlen,
-		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans)
+		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
+		rpc_authflavor_t au_flavor)
 {
 	struct nfs_client_initdata cl_init = {
 		.addr = ds_addr,
@@ -862,7 +863,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	 */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
 	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
-			     mds_clp->cl_rpcclient->cl_auth->au_flavor);
+			     au_flavor);
 
 	dprintk("<-- %s %p\n", __func__, clp);
 	return clp;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9a8937c..2ea9e9a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -314,7 +314,7 @@ struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
 				      gfp_t gfp_flags);
 void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans);
+			  unsigned int retrans, rpc_authflavor_t au_flavor);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 5a92e76..106ee08 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -553,7 +553,8 @@ static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
 static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
-				 unsigned int retrans)
+				 unsigned int retrans,
+				 rpc_authflavor_t au_flavor)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs4_pnfs_ds_addr *da;
@@ -569,7 +570,7 @@ static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
 		clp = nfs4_set_ds_client(mds_srv->nfs_client,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
-					timeo, retrans);
+					timeo, retrans, au_flavor);
 		if (!IS_ERR(clp))
 			break;
 	}
@@ -600,12 +601,13 @@ out_put:
  */
 void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans)
+			  unsigned int retrans, rpc_authflavor_t au_flavor)
 {
 	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		int err = 0;
 
-		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo, retrans);
+		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo,
+					    retrans, au_flavor);
 		if (err)
 			nfs4_mark_deviceid_unavailable(devid);
 		nfs4_clear_ds_conn_bit(ds);
-- 
1.9.3

