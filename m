Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FF1148E0CF
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 12:21:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789734074; cv=none; b=Vwk5HcIO2hJ7ik2hm4B6oF+tJDFina9mcPmT6aW5Zg1IkTy3jUwueGuyTVTYMRqYvglwf8yFutB/80Xd0PFYIjIzeLw/xinfxx6vmkA9o+QIHsfWcE3vbi0G+nBj4o4PVx0NJ+YJIMCPPweq+x6BoICAjOI12dhWoJsK3lJ6LZg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789734074; c=relaxed/simple;
	bh=no3j5Ot6XevjaWq4na0UWT1345dxB5BF+wl8fyCRSwI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nhC0jp0ZxT/qsXeAdfdp8s7+YbBbvYDTI036ewNOrsABOW3Iu7sJsvNCgkUKmEFNk+rGNh3x2mRMPxZcsr2NXn3Sl+9pRTtCdAdMZMaWwwzY1Bukjaz57H/90L1WO0K/mPANC/iT6uh5TlIB5bMgQsxmp8OmCm0DqvEjGjZC+LE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=EGuly1GR; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="EGuly1GR"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-4be07e7c54dso375537b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 05:21:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789734068; x=1790338868; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/x5Rk7BvCeXGoug10RDzotU8J1Kqmvwsg6h7Bs8mo9Q=;
        b=EGuly1GR5Tx+5qZ6ea6nKIVmXE9K1XLQwvh8nGAAHseZDUd7WiQfr2iXsE3o2LAzqi
         ivyLG+9DNeceb+S2qsE3y6XbDiKRuJ1vLTn7uwhpg3XYHn73UbvPDeWGebYxJEPxGoot
         Ni2mIIn25Lg1HAJGM/e6YT3ar85R1ZwwS14vOtS00eIUL5+OU05vLS6ShnKaZb2Rlt5u
         Dtu6thXBCxrpR7PsWAw9PQ3rxVXDix4vZtBX+QWG7R5r8nExDfR5gBfCh+aEPGRU+Mxc
         ZWE3ZYYdB9kvqcRpfRDrBQQJ/94kaUvmKoCAQnkqL8aB/LCTIt3puT8mKZ9Dx3nVCa5G
         WiMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789734068; x=1790338868;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/x5Rk7BvCeXGoug10RDzotU8J1Kqmvwsg6h7Bs8mo9Q=;
        b=kfc2p41AkUy87K/uAYojx1KZHgLJzQDc7GOD6uFWAuDWuFmmknnsPvNzSiGEh+oAsg
         UXVi1SEBcWCF4ML1MLY8l3lLTCHhjp9Lc66qSJHW9x7/JhtpOObjwRFgcTwEWcvGfIjI
         oiSUaKR/7W9m3MadyWr5qnz6n3LvOMFjtkPIMXkg//yM0pyvzvXkv2jNrOdbqL2nNjuO
         8qLN0lqx4VCNP1tOI1dDUugQW4msM63anHsusnVqWjV2NGW/ULqkHvOQng9jhli5VGmd
         Ef1nQHnkCaevtr2d5de+ntf95vjawOlp0goglFqM1bxecI33bslknBI9FBRZeOKVBqiH
         9HEA==
X-Gm-Message-State: AFuF++k12Dv8moXJf+XDKmmcy7A6EhMsTprEmm4MdhBIK58CbNe9lnO1
	vX2mREoB2bYEsKRbfFoqzEAemBscAqCZ8whIcjuVXvBpNxBzsWBLvcittSA8/phjUQ8=
X-Gm-Gg: AYBFou0YunP4YhQfNUCVyuBnTGFVcSVAplREqmFgSnW1th2JHsFo5OT94llW4i1nOcI
	GlxRRSmm6V1xp9hSqmeYGcAcFudfpbneBUAbQAMPRKsllZPXmh4STECwExY/v49GjGybPmfm2N2
	0sxZEi2nRWf1c4IcYb0lXnzNlMuBqZa0+O+jfRe9fADakbx12MsCo5bAcDAWPEC55E/6upzEmb6
	nK1s+wBXabPw104Aag2MXO0NnV8anFCRlDhoNIDmOhegKRI1VFqydMe6lacThh+KjQzMYbyIgzl
	2jgOX+gAJQdoypXU+BB97cdPKxtgq8W38cVULvT1GjrLZokLrazXLs63ZmSGZaNs4/Si4LTU2Jf
	TyqgKN6ApvY5QZh4gRnY/2TtoliBJXGqw77FN7unwUcZrcy+wkCUV7SsigKl19sTQfr3LEHPU92
	yRdEASQz+n9Mb635GRtfWTmjZ6VzBPgwftQg55hIGQMbYgsh4NLEu1b+bCO2Qw6U537Zz66wsrq
	We+2x1fearDnW+VwhoRhkfTNa37DJEKWz8=
X-Received: by 2002:a05:6808:19a3:b0:4ca:9375:131c with SMTP id 5614622812f47-4cb6a5e5d5dmr5013588b6e.29.1789734067754;
        Fri, 18 Sep 2026 05:21:07 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4cd6ab7d9d3sm883331b6e.18.2026.09.18.05.21.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Sep 2026 05:21:06 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@kernel.org>
Subject: [PATCH 2/2] NFSv4/pnfs: Let unused data server connections linger
Date: Fri, 18 Sep 2026 08:21:02 -0400
Message-ID: <84d9205181ec20687f73baba489ec9a44da22dfe.1789733774.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789733774.git.bcodding@hammerspace.com>
References: <cover.1789733774.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A metadata server that does not support deviceid notifications makes
the client set NFS_DEVICEID_NOCACHE, and a NOCACHE deviceid node is
freed as soon as the last layout referring to it is returned.

The next IO will then do a synchronous connect and NULL ping inline in
pg_init(), plus the remaining nconnect-1 transports reconnecting lazily as
RPCs land on them.  With a wide stripe and a large nconnect this introduces
a hefty penalty for eeach layout cycle.

Allow the transports to linger.  Keep the nfs4_pnfs_ds hashed once its last
user goes away, and let a per-entry delayed work tear it down if nothing
claims it within dataserver_linger seconds.

he linger defaults to 120 seconds and can be set to zero to restore
the previous behavior.  sunrpc already disconnects an idle transport
after five minutes, so an entry that is never claimed again holds
objects and slot tables rather than open connections.

Assisted-by: Claude:claude-opus-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c     |  4 +-
 fs/nfs/pnfs.h     |  4 ++
 fs/nfs/pnfs_nfs.c | 95 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 101 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ade314de1738..b7a7fab68498 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -111,8 +111,10 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
 		if (nfss->pnfs_curr_ld->clear_layoutdriver)
 			nfss->pnfs_curr_ld->clear_layoutdriver(nfss);
 		/* Decrement the MDS count. Purge the deviceid cache if zero */
-		if (atomic_dec_and_test(&nfss->nfs_client->cl_mds_count))
+		if (atomic_dec_and_test(&nfss->nfs_client->cl_mds_count)) {
 			nfs4_deviceid_purge_client(nfss->nfs_client);
+			nfs4_pnfs_ds_reap_net(nfss->nfs_client->cl_net);
+		}
 		module_put(nfss->pnfs_curr_ld->owner);
 	}
 	nfss->pnfs_curr_ld = NULL;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5cde5db63d29..5ce1a0746e09 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -58,6 +58,7 @@ struct nfs4_pnfs_ds_addr {
 
 struct nfs4_pnfs_ds {
 	struct hlist_node	ds_node;  /* nfs_net nfs4_data_server_cache */
+	struct hlist_node	ds_tmpnode; /* for batched disposal */
 	char			*ds_remotestr;	/* comma sep list of addrs */
 	struct list_head	ds_addrs;
 	const struct net	*ds_net;
@@ -66,6 +67,8 @@ struct nfs4_pnfs_ds {
 	u32			ds_version;	/* cache key, with ds_addrs */
 	unsigned long		ds_state;
 #define NFS4DS_CONNECTING	0	/* ds is establishing connection */
+	unsigned long		ds_idle;	/* jiffies of the last put */
+	struct delayed_work	ds_reaper;
 };
 
 struct pnfs_layout_segment {
@@ -498,6 +501,7 @@ int pnfs_generic_commit_pagelist(struct inode *inode,
 int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo, int max);
 void pnfs_generic_write_commit_done(struct rpc_task *task, void *data);
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
+void nfs4_pnfs_ds_reap_net(const struct net *net);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
 				      struct list_head *dsaddrs,
 				      u32 version, gfp_t gfp_flags);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 6d6a4d05d13e..14d419b8bfc7 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -695,7 +695,22 @@ void nfs4_pnfs_ds_addr_list_free(struct list_head *dsaddrs)
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_addr_list_free);
 
-static void destroy_ds(struct nfs4_pnfs_ds *ds)
+static unsigned int dataserver_linger = 120;
+module_param(dataserver_linger, uint, 0644);
+MODULE_PARM_DESC(dataserver_linger,
+		 "Seconds an unused pNFS data server connection is cached (0 disables)");
+
+/* Clamped so that a large value cannot overflow the jiffies conversion */
+static unsigned long nfs4_ds_linger(void)
+{
+	unsigned int secs = READ_ONCE(dataserver_linger);
+
+	if (!secs)
+		return 0;
+	return min(secs, 3600U) * HZ;
+}
+
+static void __destroy_ds(struct nfs4_pnfs_ds *ds)
 {
 	dprintk("--> %s\n", __func__);
 	ifdebug(FACILITY)
@@ -709,9 +724,79 @@ static void destroy_ds(struct nfs4_pnfs_ds *ds)
 	kfree(ds);
 }
 
+static void destroy_ds(struct nfs4_pnfs_ds *ds)
+{
+	cancel_delayed_work_sync(&ds->ds_reaper);
+	__destroy_ds(ds);
+}
+
+static void nfs4_pnfs_ds_reap_work(struct work_struct *work)
+{
+	struct nfs4_pnfs_ds *ds = container_of(to_delayed_work(work),
+					       struct nfs4_pnfs_ds, ds_reaper);
+	struct nfs_net *nn = net_generic(ds->ds_net, nfs_net_id);
+	unsigned long linger, expires;
+
+	spin_lock(&nn->nfs4_data_server_lock);
+	if (hlist_unhashed(&ds->ds_node) ||
+	    refcount_read(&ds->ds_count) > 1) {
+		spin_unlock(&nn->nfs4_data_server_lock);
+		return;
+	}
+	linger = nfs4_ds_linger();
+	expires = ds->ds_idle + linger;
+	/*
+	 * Was the DS revived and put again after we were queued?
+	 */
+	if (linger && time_before(jiffies, expires)) {
+		queue_delayed_work(nfsiod_workqueue, &ds->ds_reaper,
+				   expires - jiffies);
+		spin_unlock(&nn->nfs4_data_server_lock);
+		return;
+	}
+	hlist_del_init(&ds->ds_node);
+	spin_unlock(&nn->nfs4_data_server_lock);
+
+	if (refcount_dec_and_test(&ds->ds_count))
+		__destroy_ds(ds);
+}
+
+/*
+ * Tear down every unused data server in @net immediately
+ */
+void nfs4_pnfs_ds_reap_net(const struct net *net)
+{
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+	struct nfs4_pnfs_ds *ds;
+	struct hlist_node *tmp;
+	HLIST_HEAD(dispose);
+	int i;
+
+	spin_lock(&nn->nfs4_data_server_lock);
+	for (i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++) {
+		hlist_for_each_entry_safe(ds, tmp,
+					  &nn->nfs4_data_server_cache[i],
+					  ds_node) {
+			if (refcount_read(&ds->ds_count) > 1)
+				continue;
+			hlist_del_init(&ds->ds_node);
+			hlist_add_head(&ds->ds_tmpnode, &dispose);
+		}
+	}
+	spin_unlock(&nn->nfs4_data_server_lock);
+
+	while (!hlist_empty(&dispose)) {
+		ds = hlist_entry(dispose.first, struct nfs4_pnfs_ds, ds_tmpnode);
+		hlist_del(&ds->ds_tmpnode);
+		if (refcount_dec_and_test(&ds->ds_count))
+			destroy_ds(ds);
+	}
+}
+
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 {
 	struct nfs_net *nn = net_generic(ds->ds_net, nfs_net_id);
+	unsigned long linger = nfs4_ds_linger();
 
 	spin_lock(&nn->nfs4_data_server_lock);
 	refcount_dec(&ds->ds_count);
@@ -719,6 +804,13 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 		spin_unlock(&nn->nfs4_data_server_lock);
 		return;
 	}
+
+	if (linger) {
+		ds->ds_idle = jiffies;
+		queue_delayed_work(nfsiod_workqueue, &ds->ds_reaper, linger);
+		spin_unlock(&nn->nfs4_data_server_lock);
+		return;
+	}
 	hlist_del_init(&ds->ds_node);
 	spin_unlock(&nn->nfs4_data_server_lock);
 
@@ -815,6 +907,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
 		ds->ds_version = version;
+		INIT_DELAYED_WORK(&ds->ds_reaper, nfs4_pnfs_ds_reap_work);
 		hlist_add_head(&ds->ds_node, bucket);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
-- 
2.53.0

