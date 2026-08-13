Received: from mail-oi1-f180.google.com (mail-oi1-f180.google.com [209.85.167.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F04E42C51D
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653829; cv=none; b=keZL2VK2u0gCBk6xH/BQ4YuncpOXRTUH4G0u54hvo4xmg/CTYU4khkFS5Ge3Rny1Nj/LQIPR69FehmKepkxV9J1f4zmhvqzzZ9Ple0c7p7btB1Qxr7FyKShjijVuYWwNZw+gqxTh5mxZWbFQeAx7x6vTVMhP8JflqCyntVUBGyM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653829; c=relaxed/simple;
	bh=2dQP59pI6wfWgIFahR0zL+/0tKRW3AYXzV7wZcKdA1I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ic4+SMj6UORV3VpCx46Si0VzywiHjBpsa6Yz4sZGkR/0GCM7sD+L+I4PGMU8F77CGdUCvlAWWiD0/8UARs/muyAUutmssL81oh32xNBEk2pNn0+wOtYNIPRktv3zCTWC0NPY1XjH5M3dRKBnTgfXBpeVvxHRu778/YHAaWpr0Fs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=XsX482x/; arc=none smtp.client-ip=209.85.167.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XsX482x/"
Received: by mail-oi1-f180.google.com with SMTP id 5614622812f47-4ab8cb2a6e4so173464b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653827; x=1787258627; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rinWyt/IfqBNcIfy2yQNgaLqOtvYErKLbAcRv++5RR4=;
        b=XsX482x/K4IOSbKSi6TpB9QDhzOM0Zwd5JggrohNvWEVYV8wedhxLz+/GnvtU1MA7m
         HTeDSC3Lsech8dNcRXhaOSFo3wRSZwAYiVkeG3eeI2AiKZi7pfhsojs6PZzWRdar0DRJ
         i3E04vmCWQyPBhPIF03Pmeh7UoEHcAObfncrKh46jNKGEtzPnFDHWN+ESKY2sJlo70MX
         7NcxtujWaJg6y1BbtmUzyiWlKUycI2/w06SIfbSaEwhMg0JvBtnVThSe/fCga4ni+QJw
         gCiYBBtTvJuyvlm+9bp4/wLTG0MD8iCpL3pVZFvbX9NBKS0u+PS6+zOcGcA3pQn5cuN7
         4hlg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653827; x=1787258627;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=rinWyt/IfqBNcIfy2yQNgaLqOtvYErKLbAcRv++5RR4=;
        b=G4DUHA1z4Y3Dczhs83VXv+j2t2MNng1K1RdQ3LOy4OesidCA9nvg5H2dXtGoI60tzk
         HMQ1a7mwWwNIGpzAjTkvTYPNlOC/dI4pyrdjWIrYGKqfZ2RYPcL8RfS+2pGDeIQNb7TW
         vFWNeB9TSTgvUAxDmlZbGoqgS+LaHdRZFR7iOLtaPLtRK2cczHUl6zRgiNYKvQ0eo8E4
         oyySLBZM1UpSVv2SVsfB3BQbQAjbqM0M9k6qznEHDlCUAAbpGK0xu/xyV5f2zbRdGBiy
         X5R8aNBPQ0RlFUqn2gxRC9YUxcHISmQdIRxfTPsPEa0MuqxfCYd4iz2XEx6XTxO/w0qX
         Q0og==
X-Gm-Message-State: AOJu0Yx4UMxyFHMqK+cI+zZAAW5+Kh9gc7ammrtDpVPRuL2b4w/3JfaO
	KNliPrnlvO45rqPxq0vV/LWNyrNau97+Yam1jJggirLKsQn/50/Sw4WUkP+UsFFq8HE=
X-Gm-Gg: AR+sD10SuGBzYWhLGg69fC9L4SGCXUXZfvKkAiMHbeuFSY1HQIH+EpL4u7xWRmxrEEE
	6uKnXitVuocVw7pxP0cX5gLu3HzHZNmwMULGvxMvM/1hYmI7JjQj86Zs6cZUq+Dwu6UvxSYSsIj
	881+Tf9/oQ13xIbZ8QbY5qCpyJhn0t+2b3PzzWQREDvyZathPus17v9PAbp62pw68fpdg0Ul3Ix
	KurPzCmhioTvKGLipIee9GvQcdG5rzLhGsLN7Z3E5Jf0ual9TMlm+cCTFnoEDRQVMXbhg3+tJQr
	JoY99wCU06wIWi47sGR4nnhifafx0Gbk3HyDVQRT8SrxWMaNT58vGLPsruxzxU+SXxxshNBDVX/
	ssG/bJjz9ixzr6adALIoiCpgNB5bY5r8M0MNzjUrxdBM9JyE7AJiRZ5TfCQBGBZM/DDa/Ldjfbm
	BiQA5NR+/S8qKSU6NqXGhfosfQQr0Tc0T0u8HJZNAdCFYhUp2F5lJ140wxJni1BGBapl5XLCr1R
	Y5Vdmv3UGbBxGcOJmqsSzUp
X-Received: by 2002:a05:6808:23c6:b0:486:8a11:6e8b with SMTP id 5614622812f47-4b2412f17c5mr792890b6e.2.1786653827074;
        Thu, 13 Aug 2026 13:43:47 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:46 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 19/21] NFSv4/pnfs: Re-home the data-server cache onto hash buckets
Date: Thu, 13 Aug 2026 16:43:15 -0400
Message-ID: <844b2583b5d0dd08575909b9dae7fdfe804c73ad.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Mechanical conversion of the per-net data-server cache from a single
list_head to an array of hlist buckets: nfs4_pnfs_ds.ds_node becomes
an hlist_node, netns init/teardown cover every bucket, and removal
uses hlist_del_init (which needs no bucket reference).

Insertion still targets bucket 0 and lookup still scans every entry,
so behavior and cost are unchanged -- keying the buckets by the DS
address set comes next.  Splitting the structural churn from the
keying keeps a bisect able to tell a list-conversion bug from a
hash-key bug.

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
index 36658579100d..f21118554272 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -31,7 +31,10 @@ struct nfs_net {
 	unsigned short nfs_callback_tcpport;
 	unsigned short nfs_callback_tcpport6;
 	int cb_users[NFS4_MAX_MINOR_VERSION + 1];
-	struct list_head nfs4_data_server_cache;
+#define NFS4_DS_CACHE_HASH_BITS 8
+#define NFS4_DS_CACHE_HASH_SIZE (1 << NFS4_DS_CACHE_HASH_BITS)
+	/* hashed by nfs4_ds_addrs_hash() over the DS's address set */
+	struct hlist_head nfs4_data_server_cache[NFS4_DS_CACHE_HASH_SIZE];
 	spinlock_t nfs4_data_server_lock;
 #endif /* CONFIG_NFS_V4 */
 	struct nfs_netns_client *nfs_client;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1ce1cbc32f77..e0a7ae5fe8e9 100644
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

