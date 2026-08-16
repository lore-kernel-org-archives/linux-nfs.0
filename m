Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C053538E100;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786867293; cv=none; b=SQFUR2Wp0CXcSGl55PG4KXnnIgzbi6A4U0F2mwqQS1gaFmugr4Dh2PIpD97Tys+FkYcWjVXmc70iRzYlw+IzBL2BNNgWpfBH10iGEcl/RQRqD8MIBy7zyfl7fROeg13uk4Eh9VwndGUerXAdS+QL6ykgn68BWkjxsKmPyfyYouk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786867293; c=relaxed/simple;
	bh=LA6r3YMDN8e3rQCpTzUWwK2+WYrCHzvRORnV5+xfikQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=KSekJoRm+9dkemxWrIbdRAjYX9yTbnwqgTwUKERz42eHrnNBtV833CdzHk53rJoCYY30us+1gMmzAOlHHeMe6Q19faFH7LfVaM3MVUF5dibbiNDdLaJ2H2wWMAiJzRd4uZRFBjlIMiOsnoZ0w3StLQ2kNxn6OmNKpbORhUQilqY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L6b2CAzs; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L6b2CAzs"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 802F3C2BCFB;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1786867293;
	bh=LA6r3YMDN8e3rQCpTzUWwK2+WYrCHzvRORnV5+xfikQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=L6b2CAzsIdzd/cy29MjnTu58OcOSO3l1qcltFa9N7xX6DZzvc6LB8pXJuEPvKFB/f
	 G1vUAOQhEXh/omIYYNGHhrjXyY9nw99D0KvERC29mYjsdfr7H+H/b7bq6dvXJ7cK2R
	 2LneRCz4H1V+OIf7CBrJG3hVUqkvhApV2R/KmVNHlrjJES2wIXEJ8XvvlDA6PNCQyG
	 xcPl0sHBJNnbP09ohqd/Q3KeeZ+iM6ds4HyWsmtZinoNSiCOvH3J9FjN5n3TDRj4UV
	 AepEM6rJkn8Jh15tSS+czk2n0H2UOkdV3Z1TamFZgQ8zwsjMm2ThQbX4LjgbCy6EdO
	 GeSgCQ9w2cEeA==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 620B8C5DF66;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Sun, 16 Aug 2026 16:01:28 +0800
Subject: [PATCH 2/3] NFSv4/pnfs: key the data server cache on the NFS
 version
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260816-nfs4-fixes-v1-2-a810f21729ab@outlook.com>
References: <20260816-nfs4-fixes-v1-0-a810f21729ab@outlook.com>
In-Reply-To: <20260816-nfs4-fixes-v1-0-a810f21729ab@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Peng Tao <tao.peng@primarydata.com>, 
 Jeff Layton <jeff.layton@primarydata.com>, 
 Tao Peng <bergwolf@primarydata.com>, 
 Weston Andros Adamson <dros@primarydata.com>, 
 Tom Haynes <loghyr@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5932;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=VFSoisGY6SsoJBTL8kcnEnZhI63PwDw+LG5KbdMIJjA=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMa86GdGT5eu/zL1/YVPUU8yRb9Om+DE12D/sv0oS
 09668WFNZM6SlkYxLgYZMUUWY4XXPpm4btFd4vPlmSYOaxMIEMYuDgFYCLVbIwMNxWvll14mthd
 mbhTm1dk08uTun9ebWdn+XXkz4tlwdO272b4xby/d+N2s+DF7ySd+mYGVRnMflTp9HO/2AqXut9
 c0qJbOAF7Ck+K
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

nfs4_pnfs_ds_add() keys the per-net data server cache on the multipath
address set alone, and struct nfs4_pnfs_ds records no version. That
suffices for the files layout driver, which always connects with version
4, but flexfiles takes its version tuple from GETDEVICEINFO per device,
and one address can legitimately serve both NFSv3 and NFSv4.

Two deviceids on one address with different ds_versions[0].version
therefore share a single nfs4_pnfs_ds, and whichever mirror connects
first pins ds_clp to its own version. The other one is handed that
client anyway, so it selects rpc_call_ops for a version the connection
does not speak, and the mismatched sequence-slot handling dereferences
NULL.

Add the version to the cache key so the two cannot alias, giving each
version its own nfs4_pnfs_ds and connection while both mirrors stay
usable. Only the major version is compared, since that is what selects
rpc_call_ops and rpc_ops; v4.0 and v4.1 keep sharing a client. The files
layout driver passes the 4 it already hardcodes at connect time.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Cc: stable@vger.kernel.org
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 fs/nfs/filelayout/filelayoutdev.c         |  3 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 ++-
 fs/nfs/pnfs.h                             |  3 ++-
 fs/nfs/pnfs_nfs.c                         | 14 +++++++++-----
 4 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 7226989ee4d5..9ddcaf86fcef 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -170,7 +170,8 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 			goto out_err_free_deviceid;
 		}
 
-		dsaddr->ds_list[i] = nfs4_pnfs_ds_add(net, &dsaddrs, gfp_flags);
+		dsaddr->ds_list[i] = nfs4_pnfs_ds_add(net, &dsaddrs, 4,
+						      gfp_flags);
 		if (!dsaddr->ds_list[i])
 			goto out_err_drain_dsaddrs;
 		trace_fl_getdevinfo(server, &pdev->dev_id, dsaddr->ds_list[i]->ds_remotestr);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 1109462a9699..c716fd99e8ef 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -153,7 +153,8 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	new_ds->ds_versions = ds_versions;
 	new_ds->ds_versions_cnt = version_count;
 
-	new_ds->ds = nfs4_pnfs_ds_add(net, &dsaddrs, gfp_flags);
+	new_ds->ds = nfs4_pnfs_ds_add(net, &dsaddrs, ds_versions[0].version,
+				      gfp_flags);
 	if (!new_ds->ds)
 		goto out_err_drain_dsaddrs;
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index eb39859c216c..f06a03ac4fa3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -63,6 +63,7 @@ struct nfs4_pnfs_ds {
 	const struct net	*ds_net;
 	struct nfs_client	*ds_clp;
 	refcount_t		ds_count;
+	u32			ds_version;	/* cache key, with ds_addrs */
 	unsigned long		ds_state;
 #define NFS4DS_CONNECTING	0	/* ds is establishing connection */
 };
@@ -417,7 +418,7 @@ void pnfs_generic_write_commit_done(struct rpc_task *task, void *data);
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
 				      struct list_head *dsaddrs,
-				      gfp_t gfp_flags);
+				      u32 version, gfp_t gfp_flags);
 void nfs4_pnfs_v3_ds_connect_unload(void);
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 648c95b78eea..49c621cde43a 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -603,15 +603,17 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 }
 
 /*
- * Lookup DS by addresses.  nfs4_ds_cache_lock is held
+ * Lookup DS by addresses and NFS version.  nfs4_ds_cache_lock is held
  */
 static struct nfs4_pnfs_ds *
-_data_server_lookup_locked(const struct nfs_net *nn, const struct list_head *dsaddrs)
+_data_server_lookup_locked(const struct nfs_net *nn,
+			   const struct list_head *dsaddrs, u32 version)
 {
 	struct nfs4_pnfs_ds *ds;
 
 	list_for_each_entry(ds, &nn->nfs4_data_server_cache, ds_node)
-		if (_same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
+		if (ds->ds_version == version &&
+		    _same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
 			return ds;
 	return NULL;
 }
@@ -719,7 +721,8 @@ nfs4_pnfs_remotestr(struct list_head *dsaddrs, gfp_t gfp_flags)
  * uncached and return cached struct nfs4_pnfs_ds.
  */
 struct nfs4_pnfs_ds *
-nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_flags)
+nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
+		 gfp_t gfp_flags)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct nfs4_pnfs_ds *tmp_ds, *ds = NULL;
@@ -738,7 +741,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 	remotestr = nfs4_pnfs_remotestr(dsaddrs, gfp_flags);
 
 	spin_lock(&nn->nfs4_data_server_lock);
-	tmp_ds = _data_server_lookup_locked(nn, dsaddrs);
+	tmp_ds = _data_server_lookup_locked(nn, dsaddrs, version);
 	if (tmp_ds == NULL) {
 		INIT_LIST_HEAD(&ds->ds_addrs);
 		list_splice_init(dsaddrs, &ds->ds_addrs);
@@ -747,6 +750,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 		INIT_LIST_HEAD(&ds->ds_node);
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
+		ds->ds_version = version;
 		list_add(&ds->ds_node, &nn->nfs4_data_server_cache);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);

-- 
2.51.2


