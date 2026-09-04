Received: from mail-qk1-f180.google.com (mail-qk1-f180.google.com [209.85.222.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28F23477291
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540831; cv=none; b=aPzJMhokTB3iy2QBWiLOhv2cZt57l+cEkFU2Mn+oFei5EUJRpaH2/H/ON8hUCY+ZGaa+ARG/Gp3V28yEd3gQg/l4JMQ5y6jFmZhFkknacmr2DPemisEjDzgRBPm42ub72kT3X+bCqwHNN44PViOAqbyQXaqxzsGMn4D1kRnFZ5k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540831; c=relaxed/simple;
	bh=Q1qMDK1btzvRVKgGZtKQWVi+F+RmIBrqbRWz94I716w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=G+vr8YFpvlPe0xNmKo1j1GDexiZnPy0eTFDDtyQDgJpLLpG5FEUuZt0+bCQRhFIaT+uAHRbo6sOu+SXchtbukEhiSFOkCspULTmrb+WuHAF0NTOA+O9CjQEnHh3azdZf+HdQk1iu2tKS2MOeW3jpdPZcHm/MSqD8dfWRVdiTr9I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=mLFYkFVz; arc=none smtp.client-ip=209.85.222.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="mLFYkFVz"
Received: by mail-qk1-f180.google.com with SMTP id af79cd13be357-92e99ef0902so103436785a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540829; x=1789145629; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=30zpz/hp9h99J4b3MazAYDutlBZi1+6lyhFcAVUUo9g=;
        b=mLFYkFVz4EWuPfz5yMF3L8y6m/SDVI2y3fdQliPSRXGCtAEYf3ZAh/c6n1iyctrP/p
         ULkTmTjw7ZDhOGTJl42Wel96gDcz/othhOV5Uclasfdudjez5nRvjxd8Puy2QbI1nKN/
         qu311e0nNp4f6KfyI5wqZQErc0BA3ef0bv8NgGhfLbA+2SVBnDctTWjvM/HwG/dw6tqT
         HEB6qDLZMTsjCU8tNyCu+nJvNCyU+QIbaqbjwOXIZTQEEnI2GmYKw3CJ13jDSs79AKVg
         WHYEFiOhwXLTIFzEKyZnoaJC6H7wnMZCuQVc912dRiE9gBrQTNAxB9DI4SD8bR9DCIGo
         VTbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540829; x=1789145629;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=30zpz/hp9h99J4b3MazAYDutlBZi1+6lyhFcAVUUo9g=;
        b=Tnsg5n+ltMd+LgJIwYB+cZW1AcQ+4NbbyFbCbyvhTVUUbsxRBMc77xlZDL0k6ZQWjY
         CkjANidxVbMInpYnErT5n34HK3Jlu0sf60c8/0NIaMHAELJbJgv0rKMNOlQuAgjmudHJ
         6HeiLFSpZzRqas3GCXNm/CNWSmOyEaI6DJbNFkcs9oClQ9d4v5OjDRJpNU+718Su+vLo
         B0ZW8hrjutEdnn1rIFCQzOHcdVgMW8c6OMaqBXMrJrz0ka5ypGmdHTZI6St8DEHzdY/B
         UMWtTKVgTRPcD8roqISMSoqSCQkRU3g2C2RKs8lBFeMCksya9LPS41E2Zc/VsQx1Zy5K
         kM1g==
X-Gm-Message-State: AFuF++mPRVvAdvZpeaMZVIzVI5eG8HD382APPVEqM8Zldln/nU0nMIj1
	m/BpWj0Qsm6rOZWWZjb0xCnydDIv09KUL/6dXEPtZEpk0PXUesWfsmlaesgT7wUAM5s=
X-Gm-Gg: AYBFou3TPa6qSpQ46vUZXVMfN6y2kZRNPJyVm7/GGW989I7MHWDC/EVaN6r17EOcsMH
	LY+IvzhN9v+hkj/6+WlpoUiQOzMdjYo/fr2xD7RfGavDpoldqlmH0k5wMi73bPOqsdMRCSm8fIo
	xdTom+379yb9mDnY8zPI/HrNRcMDY7VQcJ6vPYC5HhPip5T9biohy6dslCUaj2KYeVeIs9hl6Hx
	YoAAwRzENy5yN6tNOcATqd7ZgXALGnwBB+cZxskOAVf7srTUmjioejmPKYZ1oP4gCfw2Ohacvup
	6JO8dIyCHB9nYoiX0NSwJlgnPjxAtoOex7CGQsm2ARUF+lu63nzfys/7O7vOA99uNjzecnsjL8o
	V4Ptem5Gy9ko5Dp2qdi21oM+cdEZ7gJFezpEsnnoheXfyNdP7Oa95z+eLE91hgVVL2yBUsnTDDU
	YYN3MnTg61ti+3QJry+CEA04Z2EX9LFYw9cPyxPu9l2ngoLL/dBrWBmBNMCBr9Jj6ipLInaf3lc
	jM4py5ekG6gRSMgpcV2tblO
X-Received: by 2002:a05:620a:6209:b0:937:3a1d:175a with SMTP id af79cd13be357-93980328b7bmr561285585a.3.1788540824042;
        Fri, 04 Sep 2026 09:53:44 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 22/24] NFSv4/pnfs: Re-home the data-server cache onto hash buckets
Date: Fri,  4 Sep 2026 12:53:21 -0400
Message-ID: <dc8f4679d2cc78d9392eb07b9d480586d89c620c.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The per-net data-server cache is a single list, and every
GETDEVICEINFO decode walks all of it looking for a match, so filling
the cache costs O(n^2) in the number of data servers -- which a
striping mount does in one burst, at the same scale the deviceid
cache was just sized for.  Key it by the DS address set instead.

This patch is the mechanical half: nfs4_pnfs_ds.ds_node becomes an
hlist_node, netns init and teardown cover every bucket, and removal
uses hlist_del_init (which needs no bucket reference).  Insertion
still targets bucket 0 and lookup still scans every entry, so
behavior is unchanged; the key comes next.  Splitting it this way
keeps a bisect able to tell a list-conversion bug from a hash-key
bug.

The buckets live in struct nfs_net, so this costs 2KB per network
namespace on 64-bit, paid once nfs.ko is loaded whether or not that
namespace ever mounts NFS.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/client.c   |  6 ++++--
 fs/nfs/netns.h    |  5 ++++-
 fs/nfs/pnfs.h     |  2 +-
 fs/nfs/pnfs_nfs.c | 19 +++++++++++--------
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60386330aeec..dbb5131375f8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1295,7 +1295,8 @@ void nfs_clients_init(struct net *net)
 	INIT_LIST_HEAD(&nn->nfs_volume_list);
 #if IS_ENABLED(CONFIG_NFS_V4)
 	idr_init(&nn->cb_ident_idr);
-	INIT_LIST_HEAD(&nn->nfs4_data_server_cache);
+	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&nn->nfs4_data_server_cache[i]);
 	spin_lock_init(&nn->nfs4_data_server_lock);
 #endif /* CONFIG_NFS_V4 */
 	spin_lock_init(&nn->nfs_client_lock);
@@ -1315,7 +1316,8 @@ void nfs_clients_exit(struct net *net)
 	WARN_ON_ONCE(!list_empty(&nn->nfs_client_list));
 	WARN_ON_ONCE(!list_empty(&nn->nfs_volume_list));
 #if IS_ENABLED(CONFIG_NFS_V4)
-	WARN_ON_ONCE(!list_empty(&nn->nfs4_data_server_cache));
+	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
+		WARN_ON_ONCE(!hlist_empty(&nn->nfs4_data_server_cache[i]));
 #endif /* CONFIG_NFS_V4 */
 }
 
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 36658579100d..560fa95726b0 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -31,7 +31,10 @@ struct nfs_net {
 	unsigned short nfs_callback_tcpport;
 	unsigned short nfs_callback_tcpport6;
 	int cb_users[NFS4_MAX_MINOR_VERSION + 1];
-	struct list_head nfs4_data_server_cache;
+#define NFS4_DS_CACHE_HASH_BITS 8
+#define NFS4_DS_CACHE_HASH_SIZE (1 << NFS4_DS_CACHE_HASH_BITS)
+	/* every entry is still in bucket 0 until the key is added */
+	struct hlist_head nfs4_data_server_cache[NFS4_DS_CACHE_HASH_SIZE];
 	spinlock_t nfs4_data_server_lock;
 #endif /* CONFIG_NFS_V4 */
 	struct nfs_netns_client *nfs_client;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 734f8531c819..8b612f3679a3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -57,7 +57,7 @@ struct nfs4_pnfs_ds_addr {
 };
 
 struct nfs4_pnfs_ds {
-	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
+	struct hlist_node	ds_node;  /* nfs_net nfs4_data_server_cache */
 	char			*ds_remotestr;	/* comma sep list of addrs */
 	struct list_head	ds_addrs;
 	const struct net	*ds_net;
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index e0e3fc7414e6..f88a9784988a 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -604,7 +604,7 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 }
 
 /*
- * Lookup DS by addresses and NFS version.  nfs4_ds_cache_lock is held
+ * Lookup DS by addresses and NFS version.  nfs4_data_server_lock is held
  */
 static struct nfs4_pnfs_ds *
 _data_server_lookup_locked(const struct nfs_net *nn,
@@ -612,10 +612,13 @@ _data_server_lookup_locked(const struct nfs_net *nn,
 {
 	struct nfs4_pnfs_ds *ds;
 
-	list_for_each_entry(ds, &nn->nfs4_data_server_cache, ds_node)
-		if (ds->ds_version == version &&
-		    _same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
-			return ds;
+	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
+		hlist_for_each_entry(ds, &nn->nfs4_data_server_cache[i],
+				     ds_node)
+			if (ds->ds_version == version &&
+			    _same_data_server_addrs_locked(&ds->ds_addrs,
+							   dsaddrs))
+				return ds;
 	return NULL;
 }
 
@@ -666,7 +669,7 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 	struct nfs_net *nn = net_generic(ds->ds_net, nfs_net_id);
 
 	if (refcount_dec_and_lock(&ds->ds_count, &nn->nfs4_data_server_lock)) {
-		list_del_init(&ds->ds_node);
+		hlist_del_init(&ds->ds_node);
 		spin_unlock(&nn->nfs4_data_server_lock);
 		destroy_ds(ds);
 	}
@@ -753,11 +756,11 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
 		list_splice_init(dsaddrs, &ds->ds_addrs);
 		ds->ds_remotestr = remotestr;
 		refcount_set(&ds->ds_count, 1);
-		INIT_LIST_HEAD(&ds->ds_node);
+		INIT_HLIST_NODE(&ds->ds_node);
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
 		ds->ds_version = version;
-		list_add(&ds->ds_node, &nn->nfs4_data_server_cache);
+		hlist_add_head(&ds->ds_node, &nn->nfs4_data_server_cache[0]);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
 	} else {
-- 
2.53.0

