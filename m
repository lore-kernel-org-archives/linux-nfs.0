Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC3BD493636
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329800; cv=none; b=cv4VIBxrgkZp0juqKnBBPfYf3Lq0PuciyxfrVQOzeiYTnh9aFokHB5LfZqDjWeUqJGk0xLGmbFPm6AC+JiPB2vPSow+gOCEZWUAkumLrfhxjQC1chBsnKRox8zyWrbohVZmZJu0wNbtKs9iJKSfaIHj5HgXftZdW1OVVuquBy0U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329800; c=relaxed/simple;
	bh=a5Hs6Q9Jmth2Id/CvhJF/2SkuEOIIWZFU8pNpi9Fn94=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KGQlXtf6DXccciKDOf0YPbby4tAdAA6uE4XTO6N1r9+zv7lyOGQv5p6EAsSqbI+K8eVcDYP8rudGRHbzzUsphymnqGUUa+xFRERoHGbe6Qrg+wV/Ff379LVPxKUMsPTE+vqmFiDhH63PjEGgdvsh3gRJ+p1U0X3+WFMnTAE+lSY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=jLAvQLFC; arc=none smtp.client-ip=209.85.167.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jLAvQLFC"
Received: by mail-oi1-f175.google.com with SMTP id 5614622812f47-4a4cb36ae00so1098302b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329798; x=1787934598; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+shcJhiLN3IOyda48AerdF2SFX6//YlvQjCg3FaXXSw=;
        b=jLAvQLFCRCrPuFG4RkfbSmpGEPJMdI6PdDaHg9yEuiIIE4vu5YOjqxcWU6HRXNqiBo
         uKmCV9Q0qv9YrWa4OY6/dBTq+a+Jpqah9jP7ee2KiFzxIVWnGOp0lv0HsRWOOVLh/8AM
         1ArjdQ9/CUHeWyDmnS1t457CS9e8PMaSk6vcfs6EQMqtW5aB3I1OJMEdXtWsuPfOCVFr
         p/VLxVC1KadG7QVi5Wvm1JtnjY5r0Hs4FG9YMubsvxsOGELY4DyDzIHkjaj7mg8/MfSz
         LC6a4Qsd4bezvI0PKksQ9fRNxf8OEUx0deHO9I69UPGdC+8CeJJn/Z9SIh48y2IIDTIC
         3UdA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329798; x=1787934598;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=+shcJhiLN3IOyda48AerdF2SFX6//YlvQjCg3FaXXSw=;
        b=S+TWytuncQsBntWxGPIg2srC4tmvrhxQzbjPDcSEd5XF4wYZiicNUDmtnHuAjNMCqp
         I5adzlN5KzfxbvE7TMiVUSh2UVikSN/4xzG89cEra/CFoAsVOoUCONQonl+Q4wx1CfJg
         2etLozhCrKLoEn7hMAml1fuj8Yy5iYXAT5nypQhuScZDbPyvkLHIa2+ClayBW2WcJcGw
         FTnj1cddDkPfTJLKIGOO2yXyJmptghEg668/SKHyMTm1+4Fnx4D1KMPRcEEz3k4F5daP
         IzqHzveJVe1Te5tlmVhusVDeMRAz2TWmZ+PIjZYVW/9V8tHlxu/AW7yVqFpw8vd4jfFx
         MAkQ==
X-Gm-Message-State: AOJu0YwguxmPHXrBHshKvyRJFYrXwj3tI50UfUkO9SPxo4BeLcjbrSYf
	h9AHtpPhycd4VPLFY0q3dVHaazJLIUUL9vgai17fZRWtTcucxn1JBmEV68wtRrtdVjo=
X-Gm-Gg: AR+sD10+X3EgyoYPClwzzjeIz32nfL+yx85asFW/eDQh0asRuHuB4+WMTDamDwph43R
	6PuES18T19WQ4YrTf8xo6WtNH7TZmlV1zRObTUD1sQyUrFvzysEU5S2ebL2fL5vaqbbg6ndM3P1
	SM+6+wUUio/37P/toPEhspJOZ6R5wMJk+lDCwBm9QIcXE5EgnPdM1jRgyjeuC9T1q5FYweUUli6
	5B3rcaBiIrWT4FEcmc0GNGf0TFvbDbs30Qb/xBMq07KUDRwFl2F8bcDAWH0PVAN3V+9AYBD8Thk
	DhuapS6V0Ht3NJDl0p2hZ9xKUolUU1/kdwPMjELKAVGAZ81RYgVINvBclleBLa0oabpyeUykqN6
	tK0GnML0D17xXIRhNSu2p3OZzGmN9Mm2JvYHlr4tzpsJzagYy3byve735MbSUOzNh/5SJFC2cLr
	0pGVo1CGUj38Z3CB1+ObCXj6Y6JrTQVMLSsHdz/YVb397y2uq0lv/enIVMe5dRb5vdBIgsPEBhx
	VnYydzsG9FFsHrHHvRBapWH
X-Received: by 2002:a05:6808:5290:b0:495:d7ec:b6ae with SMTP id 5614622812f47-4b2ef3a0a02mr7195252b6e.16.1787329797578;
        Fri, 21 Aug 2026 09:29:57 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:57 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 22/23] NFSv4/pnfs: Key the data-server cache by its address set
Date: Fri, 21 Aug 2026 12:29:26 -0400
Message-ID: <3d0fbb32ca8593f67dfccedc670837fcede0e541.1787327939.git.bcodding@hammerspace.com>
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

Populating the data-server cache was quadratic: every GETDEVICEINFO
decode scanned the whole per-net cache under one spinlock.  At the
anticipated scale of 1024 data servers a striping mount pays that in a
burst at first access, and again on notification-driven re-resolution.

Hash each DS to a bucket keyed on its address set: per-address jhash
over exactly the fields same_sockaddr() compares, combined by addition
so multipath ordering cannot change the bucket, and the existing
comparator as the in-bucket tiebreaker.  Lookup and insert now touch
one bucket; teardown is unchanged (hlist_del_init needs no bucket).

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
 fs/nfs/pnfs_nfs.c | 66 ++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 57 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index e15e0059c56b..dbfb9da9d0f5 100644
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
+ * Bucket index for a DS's address set.  Per-address hashes combine
+ * by addition so the multipath list order cannot change the bucket,
+ * matching the order-independent set comparison above.
+ */
+static u32
+nfs4_ds_addrs_hash(const struct list_head *dsaddrs)
+{
+	const struct nfs4_pnfs_ds_addr *da;
+	u32 h = 0;
+
+	list_for_each_entry(da, dsaddrs, da_node)
+		h += nfs4_ds_addr_hash((const struct sockaddr *)&da->da_addr);
+	return hash_32(h, NFS4_DS_CACHE_HASH_BITS);
+}
+
 /*
  * Lookup DS by addresses.  nfs4_data_server_lock is held
  */
@@ -610,13 +657,11 @@ static struct nfs4_pnfs_ds *
 _data_server_lookup_locked(const struct nfs_net *nn, const struct list_head *dsaddrs)
 {
 	struct nfs4_pnfs_ds *ds;
+	u32 bucket = nfs4_ds_addrs_hash(dsaddrs);
 
-	for (int i = 0; i < NFS4_DS_CACHE_HASH_SIZE; i++)
-		hlist_for_each_entry(ds, &nn->nfs4_data_server_cache[i],
-				     ds_node)
-			if (_same_data_server_addrs_locked(&ds->ds_addrs,
-							   dsaddrs))
-				return ds;
+	hlist_for_each_entry(ds, &nn->nfs4_data_server_cache[bucket], ds_node)
+		if (_same_data_server_addrs_locked(&ds->ds_addrs, dsaddrs))
+			return ds;
 	return NULL;
 }
 
@@ -727,6 +772,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct nfs4_pnfs_ds *tmp_ds, *ds = NULL;
+	struct hlist_head *bucket;
 	char *remotestr;
 
 	if (list_empty(dsaddrs)) {
@@ -740,6 +786,8 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 
 	/* this is only used for debugging, so it's ok if its NULL */
 	remotestr = nfs4_pnfs_remotestr(dsaddrs, gfp_flags);
+	/* @dsaddrs is empty after the splice below. */
+	bucket = &nn->nfs4_data_server_cache[nfs4_ds_addrs_hash(dsaddrs)];
 
 	spin_lock(&nn->nfs4_data_server_lock);
 	tmp_ds = _data_server_lookup_locked(nn, dsaddrs);
@@ -751,7 +799,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 		INIT_HLIST_NODE(&ds->ds_node);
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
-		hlist_add_head(&ds->ds_node, &nn->nfs4_data_server_cache[0]);
+		hlist_add_head(&ds->ds_node, bucket);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
 	} else {
-- 
2.53.0

