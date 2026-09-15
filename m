Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 538943B95FA
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474979; cv=none; b=scphalPMsUOC3OCQgZ+U8vFA1SXFwohHqnQLCRf1SviamGyqsBpbkcDlvmNzL5DipXhR8Ntgg/2fg9OgdOPQVlDsV/1+h7UBZe/z2lGR70iurd8SL0UJOEr4P+QgCMXYYMxx+AS106LY0E4NxjIopNV0ZREE9ridONXJDeF0drE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474979; c=relaxed/simple;
	bh=4oaSpzYtxP1Z14QGzX5wl884OvIc4lqjgbKGfkVUd8A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OCZqwDdZoJRCRdv8jJTGM3Fw+wy5ba7ZuPc3cU3kNEXWGmN6BBWKPO4YjLbn2y3IzvGZGVBfadz/5gigjRF9604St3gn+rclhg5KdBZpl2bCnOpivrTHcr+0nkaey6qy2kvvNCyqjpzvu8z62py/C2/HLtbJJfRx1SUQTHJOZNA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=PltSt3sO; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="PltSt3sO"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4b37a30eb3bso2056954b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474977; x=1790079777; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bZbr6XuFeCvRcHghrirDjHoJifb10Ip6gc/z2lyu20I=;
        b=PltSt3sOCctideNFu70x7keRW0INFxKw0fyl8FDIiVuJP3Gfd+h9911Jf3eGmw6Gxd
         H0yZVQ5O037ob0u3bELfnitKsnrQKn0aQ2tdFtBKi5y9FPzvVzUg0WVkp6QigZptrvHZ
         mKYHQxklk4+O2jpNektdx1eggTfjgjScY6y36l4q3AHLkRlWokeqAQRPQo+Ps4pEKYog
         Q9KyHWlXiIbCv5hhqbczUnyzwMjZAm5VQWspRmfGj5JEuFlMIyIPS5jG3i3pKU+OKJtS
         S4Xb6FKKHrmDVXsAvKoEbuuZJs0KH989407XaNAOpDRwXkRbMMxlrhIVO7gs2HwiK/9W
         QKiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474977; x=1790079777;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=bZbr6XuFeCvRcHghrirDjHoJifb10Ip6gc/z2lyu20I=;
        b=IG4DhzOodByKZLeWlRl7MmBF8LLsR/zPcKz33Ce2XlVcAw2SHyjrAT8kleVHfT4E8P
         HBwu+NtdiFpUqyNUGBIVZm02r/rElRd/dZFTEWGF7HlmFY89XJ5574e2fklBY92y/AUs
         WofCdQatbEpWtmK7e1L4gPz/din2kxqvlVFyfYyxVofEWnDPeYKeDbZJymZrXwNoCSL6
         n9JZKS13wBe0SS2qXzuygpT3ihvnUgtQjntkNN0FSiGFh27Q2+Qz8iyJEOUTeeW1EL1T
         c2RIIzP3d782XpRMI5zuSazd8Blh0PCE8jGycbMoWTTDI1MITbuLwyfpgCmpZEssqwCY
         OAzA==
X-Gm-Message-State: AFuF++n2DMJ0kIQJYXmq1iic49xlWsdikBoUXNSeIXLRF+x4wDR7syhU
	Y93tmP5OjxCrXArRtN3oGc30NwYKNVVwMhB8yFQfyU9KZZX51qeitdPdkLYAuKA5Vck=
X-Gm-Gg: AYBFou2kE9FfmDxe89OVeVvBHxVPzj7mFm6/KZN7JxufvjRByd5FnBixMhSUVBgtcCw
	iVoiH7uUcos+DUhOx3XfJdnLmVf43YKRELSt7PdmrTgOJCC5F57DBnbEzmJzmVAmCFAHDLDw9xc
	057C5UDsPH8O61FcWURr+gGC9twvukLSgsLYONTZAQgXRakB3kMmjCxv5AUOoaoBsqDl0/R5/yY
	1l959wgfQMwomkSxMpRS4oJmd/xLFVkSbzdSLEPJPw62OjV8YRwYB+zayFILwlPESXsBWng7azx
	OirlALBZm5c9PFs21X51BvL7dmcI1Et+E/+mhua1TNdR/tKlJ/6LIQKvZ3oEG/fw/8UxW+budU0
	Dv88L5HhxG1iQvYEh1a/fgrWWxN/SdeZCEsPxyfW2p9QXJp9iSTPc7mCUO/EWGcWQDaDNnAgbuS
	liTP1P1KDqJmGum1X7F0gG1hfdJcth7nH9cEjF06EihGs0u9uuoD5+OhVugywrrdtXQZUfZmlMt
	vWU7E5J8z03s4UqA/M9nyFCrxknV1uVlstdONiar6KvhQ==
X-Received: by 2002:a05:6808:3518:b0:4b2:5529:ed3c with SMTP id 5614622812f47-4c7b36db046mr6951051b6e.7.1789474977058;
        Tue, 15 Sep 2026 05:22:57 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:56 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 22/24] NFSv4/pnfs: Re-home the data-server cache onto hash buckets
Date: Tue, 15 Sep 2026 08:22:24 -0400
Message-ID: <91fcf4f64186fb459e3af9c83fe5344cfab6dfae.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
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
index 18ea4e8e0d85..3a1c012ba18e 100644
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

