Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCE7B493620
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329799; cv=none; b=jJmB55lOSxnJaQ/dQSt8OsJyAUo/+v7gRVjoxWXRxjGBnSnqBRXOdnoeCxVwllK/fbMI3g0Dk9y53djDLSfyMSVrQUhb7P6umvkYHkB/uzpDjg82OEgCdPTi9kRugJK9OGmVwEQYFLB+PGfUTGvFKssnVanhwApjKag/Jd+YYUw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329799; c=relaxed/simple;
	bh=zopZiN7sTPPgbpM4psRZ3rF4sLisNvLBIyitSU/S/rk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=h0OIq+g7f6DB+o92fd0YeQWX5uqCFECTO+yc8Lj5y3aOe9zYWVQ1iXl05EdMtQ93+G7/WO9BO/23ETc9BUtgbXLAJiGOIA2PRtBREIRmMm3ngIYeTE7rZxvAWRAYkOdZJaAmPz96pGw7W3EOd8ug5XNk+WjMTlpoAIr8elxKtaI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=CaAhAyW8; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CaAhAyW8"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-4a4cb36ae00so1098293b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329797; x=1787934597; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jy0dxsu+qdS+WZ6my6KKgUGeMHHgFFj+cOJ+rNKGd4A=;
        b=CaAhAyW8nfSqIAIVjC1ubvYpGOFEwc40IjEgQNRuX6JFYawpkV/aqcwPspJHXgBWqo
         aifPILfjtx2Ca4K6uJfCLI30VTja0NMT/zhZFH6geGsk/R+2WRKL0Wjjx5nZMHjEAVW8
         Jsjs0mQyA9IBcH/qgbTguKLbN9SqmGgPswo0o7M/7HD0l5nQDyA16t27WhmDb4DKmyad
         Toe/qcEdXJh99HSou9rrrSHpvbYErBzqzrEtdGyLMmRjZbaABA5tPhZEQOXpWkggI5WQ
         5rA9s/uR7iiPgpmhRQ1P4RFHG6ThRi2TeT9l8IfjwBU/yqsjndsukJxwqAlbzJ2UgyBN
         2IDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329797; x=1787934597;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jy0dxsu+qdS+WZ6my6KKgUGeMHHgFFj+cOJ+rNKGd4A=;
        b=pommfwPIroWLUx2QY1qZJRaqZIfoxBlAo7yOqzUf6c7DNzh9Z9tggW7nUaxhmGjo7p
         xzVdjYzffsg+v35TWQdQ2/Mn1MaeoGIzCjgBJnyLub8jIE386gZRFPeN3wXPml3+RUu1
         1aJ5dtbkwiviSMvD6V2z7psKpEMre6lnyE9yqU8QMH41gu9vS4n7pTwrJ6wybRqBOz6o
         KEASxlrr/jsqUXNF/KQ7F/beXnHSPKEVIaX9wg8eNXEvaisWeWSYce61cIfQzxMOmWuH
         0A278fK/tZ4m+KSK0CM0QataCDuSwRZHTcHCUIjC3Bt8BnVbVELUwlEDPMgx+mVI6+QI
         na8g==
X-Gm-Message-State: AOJu0YwgF68OAa88qGzncd4SkdbrELBQW0T1sfmdc8Io4pB0FaER6Rpy
	UPfPivfIXk+YsW2qQ0SGFo7zI85YWQzq32FtSHNWMrF22O/eBNfTwaJUcN2ughQL3qFnv2MYFuK
	V/3SF
X-Gm-Gg: AR+sD13w8sBnaWLX5SMwK12QdA65Vbs9t0SHlkcwl5u1FyLqNsc66he2emcqE5dQiYY
	8TkDx2CudQMdncNslqy/3mPdj0TScnhSgBofTP7Zgt0KyWsC2Al1biJJF5pYyCNHUfUTuy9cUej
	JJf+hGm2hhpCznNDO/dWYYuhaezMfgSsTqMZejGSFaQify9Vx1ZAQvfHM3GKk1ssskFi49rcvHK
	+FkR2xelskcWM7NXyUkxmXhWMLpFjWKHTZDG87FoHAZvsK9Lp+3vs1TO9TMYnbJOD7Ynoiq2lTB
	HVrxMe46xr1N5hg9pJELd0AKa6WPz61P+lxFKbYY9cFyL6da16mIh59yB8d5Fffj/D07pqQiVmK
	/P5rXn02F00bK84MeebRiXlIWsQDSXds8oys8ZSFY2BHPeKLCWyYW60bsV4Ek++3k/R12/tHG+O
	xFatciv6L/zf3cPQx1qf9HlOUo6gQ6sQ3hgpmf0GjZKM82ZhbMaaLhUGIOAMJvDPoe6rugbz4EY
	0sMOtdAHsCh1YSQRVaQLHN8
X-Received: by 2002:a05:6808:6902:b0:496:10e6:f76e with SMTP id 5614622812f47-4b2ef0aef25mr7486057b6e.4.1787329796482;
        Fri, 21 Aug 2026 09:29:56 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:55 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 21/23] NFSv4/pnfs: Re-home the data-server cache onto hash buckets
Date: Fri, 21 Aug 2026 12:29:25 -0400
Message-ID: <e3333000da2f15f8d6f800942b4dac4405e05898.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
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
 fs/nfs/pnfs_nfs.c | 17 ++++++++++-------
 4 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4dcb91ab3039..10eeb14d251b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1283,7 +1283,8 @@ void nfs_clients_init(struct net *net)
 	INIT_LIST_HEAD(&nn->nfs_volume_list);
 #if IS_ENABLED(CONFIG_NFS_V4)
 	idr_init(&nn->cb_ident_idr);
-	INIT_LIST_HEAD(&nn->nfs4_data_server_cache);
+	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&nn->nfs4_data_server_cache[i]);
 	spin_lock_init(&nn->nfs4_data_server_lock);
 #endif /* CONFIG_NFS_V4 */
 	spin_lock_init(&nn->nfs_client_lock);
@@ -1303,7 +1304,8 @@ void nfs_clients_exit(struct net *net)
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
index 3149a487afb8..1ddd4610ae47 100644
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
index f40368f839d0..e15e0059c56b 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -604,16 +604,19 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 }
 
 /*
- * Lookup DS by addresses.  nfs4_ds_cache_lock is held
+ * Lookup DS by addresses.  nfs4_data_server_lock is held
  */
 static struct nfs4_pnfs_ds *
 _data_server_lookup_locked(const struct nfs_net *nn, const struct list_head *dsaddrs)
 {
 	struct nfs4_pnfs_ds *ds;
 
-	list_for_each_entry(ds, &nn->nfs4_data_server_cache, ds_node)
-		if (_same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
-			return ds;
+	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
+		hlist_for_each_entry(ds, &nn->nfs4_data_server_cache[i],
+				     ds_node)
+			if (_same_data_server_addrs_locked(&ds->ds_addrs,
+							   dsaddrs))
+				return ds;
 	return NULL;
 }
 
@@ -659,7 +662,7 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 	struct nfs_net *nn = net_generic(ds->ds_net, nfs_net_id);
 
 	if (refcount_dec_and_lock(&ds->ds_count, &nn->nfs4_data_server_lock)) {
-		list_del_init(&ds->ds_node);
+		hlist_del_init(&ds->ds_node);
 		spin_unlock(&nn->nfs4_data_server_lock);
 		destroy_ds(ds);
 	}
@@ -745,10 +748,10 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 		list_splice_init(dsaddrs, &ds->ds_addrs);
 		ds->ds_remotestr = remotestr;
 		refcount_set(&ds->ds_count, 1);
-		INIT_LIST_HEAD(&ds->ds_node);
+		INIT_HLIST_NODE(&ds->ds_node);
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
-		list_add(&ds->ds_node, &nn->nfs4_data_server_cache);
+		hlist_add_head(&ds->ds_node, &nn->nfs4_data_server_cache[0]);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
 	} else {
-- 
2.53.0

