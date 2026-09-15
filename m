Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABB443BB132
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474981; cv=none; b=NsNMj9V7oZ4OPMHhjWJyTPJPB+kxfjYB5LgcCfqjyzSFaLEzDlFGdUkZgFumhrJ8S35U/PKfI2eistCddb2RJK21vxlM2nrOmQDbaOPPJqGjyRCo1SRkvvQT1DcV0ddRQveBbtVFjgPqzo9PSqrqFOvVKTtYrYJntIDl65/ObI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474981; c=relaxed/simple;
	bh=kY2jVUPNMqyezi/ui6zAR2vgUN+Ly8EHCwOx1d3dTZc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ebzl9iUyvoDrumrf6SUYZEjvoWd5lBWdqgYorKQAdbR4J+NhauM8JQje5jCbv7b5q5OdmGz2VmrjR0/DVhfEfqvCPBxRzKO9S5/NRfrIerUU+LhN3aQ4WPOikhVeF7P6Tm1sm3/ktpzTCV5grdr8NFO/uSSlkP9knG67cDEVtmg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=OdWLjFzx; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OdWLjFzx"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4b37a2ffef2so1295922b6e.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474978; x=1790079778; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=sXoIxHWiMtP7LFlsZQEQeiwBMzIv2lWeDy2CgjqxjRo=;
        b=OdWLjFzxtBHHmq9eTvRdeD4JAEZo9JGubiXjl8ABhEYN2bS7undUUxJLjNeh8jRRrs
         LnAXZ+iRYaZXqWStYZx5k6nfkab9ULeSN1WKsgGZ/4jDQ8o7uc/iAImsazwqsdkHC6gD
         teSD3xp9/B9CsqRQG88vB1E0RBUZlsDXJAMKQQVbBhVUSartkyXvlhHXIZLa1ZCuuzH2
         shOUVqspb1bnTSj/f+AguqnQ3CQUDL6pWdlFx6f5caEAD3GL2RXjD4sCS/XAQRK20+7W
         doRUyAfxvc3QMmC0sM4+nlE3E8YpUmKuW1IcwGvLM8TWNZsm3Jn1hD90wD0u5XNJgvGU
         I5BQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474978; x=1790079778;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sXoIxHWiMtP7LFlsZQEQeiwBMzIv2lWeDy2CgjqxjRo=;
        b=pC6dO/upTALq65DWkCE2M6MUeJCRpxrQxsbStlUd9r5lNXP2lhrBXNDU01OSPigs+M
         yqmORpHlg0SPaHnoefAuBycLXgTjA2BnbjTxYkk6gLw3VHz2r280F3gFA/XsYdyBPgLH
         gs0sv/lsPHzPq1EmXisVVQ2nHd/O6F8bRMBvHk5mxh7NfXYnYCIv6LNwiRbYellfMP6N
         LrxbisUFEMObObJW9qUopwtlbuIzj+Tuo4lG3rbJb1wT/dYENjt0Cc0SPWVmPlyvtZds
         WhhBLWQQ3aMyOqLfCZSsG71/HboQ4J3B3B0T/rqc5LK/CRuZfMXOZarRiSQgMd0DopfI
         fmzQ==
X-Gm-Message-State: AFuF++mx0Y9RapxOxYvjmTvzvL/HZu04RgmSxlq2FWhHG56wpFhejEUT
	xZVKz4APMQ91/YL9vlf8bt4HwcqUdv+3+ORssQWGD8bHzWsZUAPeRZqqJPwsOYDM8qo=
X-Gm-Gg: AYBFou3FMO0lNTkJTNgm4L3LcNRmw8iS53b38/huuEtSA9p3P+8Koj5jMoTJCv7FjrU
	0x+9RalM2OleZndC8BpjgW1u1oLNrzGrlpGk7phWFTHYV/tAz3+0lERJBHPeDFgIA7UBoV1w+Xx
	mgxVrBWB7mlep7NMutG3Frz3SlVLMsIdkam9/MSAmqpQmc8g+xiKpm0Oz/o27yvqnYQdOLCTZOu
	jm25leIvKICNzocSv40KjPl1LPA778A31g1pJ6gauUnHKDZuUVR6FnWHp+K/R5FvLUwEsHNwSSG
	cciz54yWdqDeeHQSX1ygPn+XUExWnqoIiUSApcDk3P7TbzT2zxI9g5Zr89TnHX+4IaO9yrejDh7
	3wLDeMq8Yq//fWBlw0wNRVXpD4TvtPlfw74RTR3EsWpDbdxMx1bONdJT5aWP6VcweY3dPmgR+Pa
	PiVBwiDgvEAdBm4XKZCQd33wMsnztCLGJhEDdMq35zBmNbc0d9iNThsijXoQDaA7Pgvlx58au50
	WF5+jqIW1QtwW2ePKmxKxIDK2r2MDg7Uhw=
X-Received: by 2002:a05:6808:1994:b0:4c3:a091:52f9 with SMTP id 5614622812f47-4c7b32dd937mr5266414b6e.2.1789474978282;
        Tue, 15 Sep 2026 05:22:58 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:57 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 23/24] NFSv4/pnfs: Key the data-server cache by its address set and version
Date: Tue, 15 Sep 2026 08:22:25 -0400
Message-ID: <e97aee2e9ea53df9d7ae784033597d20b7a5eb69.1789474702.git.bcodding@hammerspace.com>
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

Populating the data-server cache was quadratic: every GETDEVICEINFO
decode scanned the whole per-net cache under one spinlock.  At the
anticipated scale of 1024 data servers a striping mount pays that in a
burst at first access, and again on notification-driven re-resolution.

Hash each DS to a bucket keyed on the whole cache key -- per-address
jhash over exactly the fields same_sockaddr() compares, combined by
addition so multipath ordering cannot change the bucket, then the NFS
version folded in -- with the existing comparator as the in-bucket
tiebreaker.  Lookup and insert now touch one bucket; teardown is
unchanged (hlist_del_init needs no bucket).

Keying on the whole set requires the comparator to test set equality,
so it is tightened from the subset test it did before -- a subset
match would hash to a different bucket and simply never be found.
That test was also wrong in a way worth naming.  It answered "is
dsaddrs1 a subset of dsaddrs2", and the caller passes the cached list
first, so a cached data server whose address set was contained in an
incoming one was returned for that incoming set.  The aliasing was
therefore one-directional: cache {A,B} first and an incoming {A} did
not match, but cache {A} first and an incoming {A,B} did.

The consequence was mild, which is why it went unnoticed: every
address on one device's multipath list names the same data server, so
a merged entry's addresses are all paths that server also advertised.
The effect is lost path diversity and a truncated ds_remotestr (and
the netaddr flexfiles reports in layoutstats), not I/O sent to the
wrong server.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 68 ++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 58 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index f88a9784988a..c9bbcb765f4a 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -15,6 +15,8 @@
 
 #include "nfs4session.h"
 #include "internal.h"
+#include <linux/hash.h>
+#include <linux/jhash.h>
 #include "pnfs.h"
 #include "netns.h"
 #include "nfs4trace.h"
@@ -577,8 +579,8 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 }
 
 /*
- * Checks if 'dsaddrs1' contains a subset of 'dsaddrs2'. If it does,
- * declare a match.
+ * Checks if 'dsaddrs1' and 'dsaddrs2' hold the same set of addresses.
+ * If they do, declare a match.
  */
 static bool
 _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
@@ -588,6 +590,10 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 	struct sockaddr *sa1, *sa2;
 	bool match = false;
 
+	if (list_count_nodes((struct list_head *)dsaddrs1) !=
+	    list_count_nodes((struct list_head *)dsaddrs2))
+		return false;
+
 	list_for_each_entry(da1, dsaddrs1, da_node) {
 		sa1 = (struct sockaddr *)&da1->da_addr;
 		match = false;
@@ -603,6 +609,47 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 	return match;
 }
 
+/* Hash family, address bytes, and port - as same_sockaddr() */
+static u32
+nfs4_ds_addr_hash(const struct sockaddr *sa)
+{
+	u32 h = sa->sa_family;
+
+	switch (sa->sa_family) {
+	case AF_INET: {
+		const struct sockaddr_in *a = (const struct sockaddr_in *)sa;
+
+		h = jhash(&a->sin_addr.s_addr, sizeof(a->sin_addr.s_addr), h);
+		h = jhash(&a->sin_port, sizeof(a->sin_port), h);
+		break;
+	}
+	case AF_INET6: {
+		const struct sockaddr_in6 *a = (const struct sockaddr_in6 *)sa;
+
+		h = jhash(&a->sin6_addr, sizeof(a->sin6_addr), h);
+		h = jhash(&a->sin6_port, sizeof(a->sin6_port), h);
+		break;
+	}
+	}
+	return h;
+}
+
+/*
+ * Bucket index for a DS cache key.  Per-address hashes combine by
+ * addition so the multipath list order cannot change the bucket,
+ * matching the order-independent set comparison above.
+ */
+static u32
+nfs4_ds_cache_hash(const struct list_head *dsaddrs, u32 version)
+{
+	const struct nfs4_pnfs_ds_addr *da;
+	u32 h = 0;
+
+	list_for_each_entry(da, dsaddrs, da_node)
+		h += nfs4_ds_addr_hash((const struct sockaddr *)&da->da_addr);
+	return hash_32(jhash_1word(version, h), NFS4_DS_CACHE_HASH_BITS);
+}
+
 /*
  * Lookup DS by addresses and NFS version.  nfs4_data_server_lock is held
  */
@@ -611,14 +658,12 @@ _data_server_lookup_locked(const struct nfs_net *nn,
 			   const struct list_head *dsaddrs, u32 version)
 {
 	struct nfs4_pnfs_ds *ds;
+	u32 bucket = nfs4_ds_cache_hash(dsaddrs, version);
 
-	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
-		hlist_for_each_entry(ds, &nn->nfs4_data_server_cache[i],
-				     ds_node)
-			if (ds->ds_version == version &&
-			    _same_data_server_addrs_locked(&ds->ds_addrs,
-							   dsaddrs))
-				return ds;
+	hlist_for_each_entry(ds, &nn->nfs4_data_server_cache[bucket], ds_node)
+		if (ds->ds_version == version &&
+		    _same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
+			return ds;
 	return NULL;
 }
 
@@ -735,6 +780,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct nfs4_pnfs_ds *tmp_ds, *ds = NULL;
+	struct hlist_head *bucket;
 	char *remotestr;
 
 	if (list_empty(dsaddrs)) {
@@ -748,6 +794,8 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
 
 	/* this is only used for debugging, so it's ok if its NULL */
 	remotestr = nfs4_pnfs_remotestr(dsaddrs, gfp_flags);
+	/* @dsaddrs is empty after the splice below. */
+	bucket = &nn->nfs4_data_server_cache[nfs4_ds_cache_hash(dsaddrs, version)];
 
 	spin_lock(&nn->nfs4_data_server_lock);
 	tmp_ds = _data_server_lookup_locked(nn, dsaddrs, version);
@@ -760,7 +808,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
 		ds->ds_version = version;
-		hlist_add_head(&ds->ds_node, &nn->nfs4_data_server_cache[0]);
+		hlist_add_head(&ds->ds_node, bucket);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
 	} else {
-- 
2.53.0

