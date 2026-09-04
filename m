Received: from mail-qv1-f46.google.com (mail-qv1-f46.google.com [209.85.219.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03D2550EBFA
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540832; cv=none; b=h6BPClUNR1+X7bGbdjDQ7vehmBel8b4ElrX9bSIbSnN70rX8h0QcElkygCTiGJiNQfvvPvax8M7SRKwU27ASpYEvpI9A5zVnTQH5Rai9CUrfhm2kE1AE7GLzgXiUk6cba64GJ8l4KF9ohTFJEZrJw94zBhF5loX3I2qKhj7TJdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540832; c=relaxed/simple;
	bh=kY2jVUPNMqyezi/ui6zAR2vgUN+Ly8EHCwOx1d3dTZc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GG5knpAf+JW7lRAY1TzMLz/q/YPWW7HfCWFxZYESx2ct8Z9kfOac34OWidkXRVroW13JTMufPCczIg7DxicMurf5OAtHdAm7NROup839vmdv9TcE0S3QxGh2+tSy7KcWolUg20GT2urxoKxeIp2d1YKVwFUbJbZ37zgOpcZD0Ns=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=oQnJyler; arc=none smtp.client-ip=209.85.219.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="oQnJyler"
Received: by mail-qv1-f46.google.com with SMTP id 6a1803df08f44-90cc39e06bdso14689336d6.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540830; x=1789145630; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=sXoIxHWiMtP7LFlsZQEQeiwBMzIv2lWeDy2CgjqxjRo=;
        b=oQnJylerCXVYGAMn5s+yEt4UKfDl98YzaUdVbmdZQzX3ZZmXb4619rfZo2pBEDrG7c
         pcOoAx2FjBrORkJ9NiyP1vjypbXjk3tyWk8d918qMQh8HRlAMacBJwL0KQzMYK7/FUVV
         IvigNWcMpITDa2umtFpy2PfrLQZyiRCFig5M0t/6smzUpCf+Wd3baVsYIHkLqG9Go1pS
         VwmG+VJ3C9K8/fDok8JPAVMbekuttSYB9ekpx4Izy/r0/30K1hXjcTzGbuYGDsl32Hey
         hSBzujhU12ywicL011PQl2LtUjz53yTcR7nWTdFNc/WShN5XhKtS+0yYej2geNlLMRCh
         ZwCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540830; x=1789145630;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sXoIxHWiMtP7LFlsZQEQeiwBMzIv2lWeDy2CgjqxjRo=;
        b=G33Gt1bJPbfVTcQ+5nFS77oqNG6Sj/5nR3RBF9tFvyUccESLdiv5p4ui0uZi4fA157
         nBmYj/GOzEX+MVj6OgZsctxDrC0fvw5P/BwmFb4uecueCpdSJ/JubwnqYV4vHfh/uhSz
         t3oNyvrrpKUS01rBpWwR780J3nY7xnz0Xu0fpMlcx7aoACFRIt5UX+z4ERWT2r78DHaU
         Ab9t6ANfgUVV1a9Aom6HNJoB2xpYWN+z0o891Louapl6ES5mFWS2+tu4sM1Fm7dbPUx+
         nGOg95A9IjwfDJ4pxtb4JryWCcGbOEgj1GGzeG8O44jwuvyq/nQvsIBeI1M+pXpPLR/q
         ZJXA==
X-Gm-Message-State: AFuF++nN+NSqWxgMBa0cN1H1RURJGHk6yAHuqHGFg4kgN6c5I5bI0pF2
	2Jm8lBfX+ouFQjbDFUS1m3dc3JdTuZxJGMr4R2RPojHC3I++rSWnJ2bRK85QK5dVoLM=
X-Gm-Gg: AYBFou3rQuRx8P7KLVNeShXTGbc8Hw7WIPoh6u3xffa0AZGSMNkqRe/vNs8MNJBIpn9
	lsR3g51GgeUCE5LDR9hJwMBsXrScP00HWXfl6qP+q+tqHr+FKDmL3aeIpmOf/PO36oWZoDsGoy9
	JuD/MzIT96VjE3QovxRJ1nev+98K+Y5cXrMTTiH32atfmdk287qU7DpI4Wi7eQcNK+WdmiZGHtC
	pA8EFRBLoM3Jx5RbAwZPPzwahTXfOluzcSbGIlBZu+8BKO1iXYCc5DBWm+Cg0kl8JqP58Phjtgq
	sCIegbM64NMLeO25Wj8q0/pMi+D9WAPp7AF75SAWIerClUlmmzRrwQzAUW3fHjuIoXMOA8oN0e+
	IxswmOuSwIE8+tsnjFeVvwYmBcCB+TK6XcONg/EXbAwXFENBGyV5/UBo7zV0jrShuLU64KPYzs6
	kRpM1yixDwLa4P9JHfXMyyPYaI6Ja7KytMruMrDddllvliYSTseuPWMZMMwhur5oEfz8Dn53m77
	K2tKYxemLnwbcePBKUkcBFfdSh3caxribw=
X-Received: by 2002:a05:620a:a90a:b0:939:6dfa:48fc with SMTP id af79cd13be357-939804fae28mr625851785a.50.1788540824808;
        Fri, 04 Sep 2026 09:53:44 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:44 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 23/24] NFSv4/pnfs: Key the data-server cache by its address set and version
Date: Fri,  4 Sep 2026 12:53:22 -0400
Message-ID: <afcf61827c76091a7fde7a27a2537b5d647016cc.1788530385.git.bcodding@hammerspace.com>
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

