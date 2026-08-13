Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C18242C51D
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653831; cv=none; b=Ckw0aSGYgFRKp08Rmm5EloUXZ5LAOxNlHhVSsrIV7mduZP5G2BYEe5nv87Wj5WwWD0ZmNSWguMxpEopwQzEYv7KsRZWBh1+fjDnDFm4YUM0K43BpnKwzjTLllh+mRrEabZZB9teAe1nJcR7OrwJgOI3FIyOKOzcy1ekLsbCjo8I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653831; c=relaxed/simple;
	bh=k6ZwzIPQs4h92PgzWCs41BeAnnMKefxmBCle9WbaSS4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YZpM2iTv9WkH9R5Xku8Ten1Xx70PInsToLdF3fiOrMyrB2mEcv5YvOgv2X/XGYOIT/KBX3elF7IHTwYLXsdvbzoBfoyz9WIzqVRpicoO2MOXMjP0WWHPLq3SFhkyYW6Ar5I+plqj2oqW74lXF31OGnWetlSV5YuqDJ/X2R/ORgs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=bJEZP+0N; arc=none smtp.client-ip=209.85.167.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="bJEZP+0N"
Received: by mail-oi1-f175.google.com with SMTP id 5614622812f47-4af81963f35so150964b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653829; x=1787258629; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=3r7qyH5qgBKbDwbCAoa6M5CoaeA0sXScn3uJhj2Oesk=;
        b=bJEZP+0NN/2lXtNCbmQyUoWv3FL3PRZK4Hfn/ujBQNavBA2Fx9dM59mwiwSGIhc1r0
         Xz9G4vrqVPOji3zNltZ5GkNDRtA1Ngb+zXbzMePacTMyAqSPw6+djv34oCErMzoc8/xa
         XA0QDEpW2ne3txuk8G+VTjf5dvWA80Oj5kNuzVw1IfVqhiJdUOO8jlAdbTu5b+cfsgIt
         KpiKfbEMltWaYwz/u4V7qQGNPlayn7XRrinSuF0JHFFVMZir64lbIGriMzHzJ9+slkRl
         COP6cAS0ch1xoRZPvi6DTy0awAgsVjPkHwM4UAxWw0ZfJVG0NGj+iXciIwtiLo/mibXY
         vGJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653829; x=1787258629;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=3r7qyH5qgBKbDwbCAoa6M5CoaeA0sXScn3uJhj2Oesk=;
        b=i3KV//qZGEovH993uYZSCKyIrtEfSb7+FdKq0hEiRPXLxPCUwUllxHBssYjInkk3Ig
         jPFFpUqqhbZn0RU/74jhon3Qi8jpd6bgWeU57zzsNpP7VjmCS8PvTyMaN6Jq8hFUpuQw
         avJb9KBmI07ThlqyZfjtVpHu65o8RDCSJ8LiCSutK31BaBdLoI8ROZjI/zm78ZyMlJ0e
         ekJw6FITfcDqj5jeytvmcm2GTmjK6Z66pA6OMdNOfkAeaimzfy04i2yA960wkQk6+OD3
         LXYq9lG5AiVqGkayItD7kFo+R3+kvpRpMPlgJqU2yLS0Vc+5lBJd3aZdqqZt2Nq5HyY0
         Mddw==
X-Gm-Message-State: AOJu0Yx8Z78EqnkAlFlBnDxySiWMsJWEWwMQIuu14D6TTEZyt05QOXA3
	ODm9eSZxR1jEWh07KIRbT4dyJaRREnRSqIL6cefkX68p25O7uWq9E3JuIqODKYfT/kyMcIPWdtO
	H7QFy
X-Gm-Gg: AR+sD10s6VEepYCAS4Ne2GqXXBxKOrWC+brQonM/fgEXam5kc+vpqrs1WsqZu17qa4J
	FCQ0VxySJ578OLX3uEBI/NCtlNmAgAAZisqjq8MxT3PLHKE09Wscx/RI9lkOVH1f/Y6E7WbW1et
	WJNKmqsEgfrpyLKFOvK/wKhOCN1+aD5zaE4HuTEr1CVkOGEZaqr3XDSUSthCXjViAwwm+WExpbs
	ECgDN59rjAHU3ouum1JVT//G2FdZUSlrwI/qPUwF/8vRrz1dyH+eLost001CaTVfQF1QWSkCTXn
	w9z8sB+IBJDH+B+U8lilkDcxGO8+g7l4JvSIoULsqhUt8d3m5Wh2y/vaXwi1T0JRCyREDVJ4hWp
	GNjbdxn8/QYwjuE6z+IN02cvxjV4VDiNYH8B1VE6AHJnBmrAvDGJAM3M1EkIlSmfTZPzBpUzNGu
	CgHFZ/ujtFvCRG2pN5CP9xiOK8YYl6b+lxSMp9LaEMjApRrYi0EZu33T8+K3zoxMkPOFc4aWVOE
	Ul4k9d9iGFYC/RzBZ9/L7SH
X-Received: by 2002:a05:6808:138a:b0:497:c1f1:1511 with SMTP id 5614622812f47-4b241e783e7mr701874b6e.16.1786653829012;
        Thu, 13 Aug 2026 13:43:49 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:48 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 20/21] NFSv4/pnfs: Key the data-server cache by its address set
Date: Thu, 13 Aug 2026 16:43:16 -0400
Message-ID: <80584abd9bb30509483e42ad12ba75543c9d5d1f.1786653063.git.bcodding@hammerspace.com>
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

Populating the data-server cache was quadratic: every GETDEVICEINFO
decode scanned the whole per-net cache under one spinlock, with an
O(n*m) address-set comparison per entry.  A striping mount with
hundreds to ~1000 distinct data servers pays that in a burst at
first access and again on notification-driven re-resolution.

Hash each DS to a bucket keyed on its address set: per-address
jhash over exactly the fields same_sockaddr() compares, combined by
addition so multipath ordering cannot change the bucket, and the
existing comparator as the in-bucket tiebreaker.  Lookup and insert
now touch one bucket; teardown is unchanged (hlist_del_init needs no
bucket).

The comparator also tightens from subset to set-equality to agree
with the order-independent key.  The subset test was itself a latent
bug: two data servers where one's address set contained the other's
were wrongly merged into whichever was cached first.  A flexfiles or
files-layout device decodes a deterministic multipath list per
GETDEVICEINFO, so equal sets are what servers actually hand out.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 73 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 64 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index e15e0059c56b..a94f4a2933cd 100644
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
@@ -577,8 +579,10 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 }
 
 /*
- * Checks if 'dsaddrs1' contains a subset of 'dsaddrs2'. If it does,
- * declare a match.
+ * Checks if 'dsaddrs1' and 'dsaddrs2' contain the same set of
+ * addresses.  If they do, declare a match.  Equal element counts
+ * plus a subset test give set equality (neither side can hold
+ * duplicates: each list decodes one device's multipath addresses).
  */
 static bool
 _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
@@ -588,6 +592,10 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 	struct sockaddr *sa1, *sa2;
 	bool match = false;
 
+	if (list_count_nodes((struct list_head *)dsaddrs1) !=
+	    list_count_nodes((struct list_head *)dsaddrs2))
+		return false;
+
 	list_for_each_entry(da1, dsaddrs1, da_node) {
 		sa1 = (struct sockaddr *)&da1->da_addr;
 		match = false;
@@ -603,6 +611,53 @@ _same_data_server_addrs_locked(const struct list_head *dsaddrs1,
 	return match;
 }
 
+/*
+ * Hash exactly the fields same_sockaddr() compares: family, address
+ * bytes and port.  The v6 scope id is deliberately left out -- it
+ * only discriminates link-local addresses, and hashing it would be
+ * harmless but pointless: unequal link-local addresses that share a
+ * bucket are still separated by the comparator.
+ */
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
@@ -610,13 +665,11 @@ static struct nfs4_pnfs_ds *
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
 
@@ -751,7 +804,9 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, gfp_t gfp_fla
 		INIT_HLIST_NODE(&ds->ds_node);
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
-		hlist_add_head(&ds->ds_node, &nn->nfs4_data_server_cache[0]);
+		hlist_add_head(&ds->ds_node,
+			&nn->nfs4_data_server_cache[
+				nfs4_ds_addrs_hash(&ds->ds_addrs)]);
 		dprintk("%s add new data server %s\n", __func__,
 			ds->ds_remotestr);
 	} else {
-- 
2.53.0

