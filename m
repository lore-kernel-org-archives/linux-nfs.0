Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B459542C4EF
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653823; cv=none; b=qwcsfQgwKDWppUG6J95Dgrp4C1q20t59E9SToASiFYduNXlOREh4SxqSqep00o9yR5kKjpOBtTRYjlAU6dCf9w+/nr2IMBJQ36xMkP5r4N65cw/d3aCXS7cJKPBwVh2FO6KOwftSCmaAoM9l6dBTBO27qQhVlVcK2ev60+cwMGw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653823; c=relaxed/simple;
	bh=/f+bZ9KZPt84LMSIwwhlk5nQELV6vLd1NvoV4tkfB8Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WJa29MXIyxcwp5Lw2K5Zz5If583ml7bF3MasOpt/6xLjI/LDww5PgCTTcWliSezNjhwxVxe2cYEb4W9rBW+KETtElUsjEOVOkqZK3yJcJc5Cv3OIu3hY2WXSnwqMMz9dx2YztKN64oYF58colPrrnoka+tNmA9KAmuRIfJ+agfI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=JL3nXMtm; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="JL3nXMtm"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4ab47c40e7eso151497b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653820; x=1787258620; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DOkmhEZoTiIOghmXnQgRNxDKH2kzj/FEWLdizeMkRuk=;
        b=JL3nXMtmSJxh8/VLSdy/YCcfWIJyg6d+WN6B0qFCqgO82qpJVdI+M+7BVOG3mBBPl9
         3ZTdz0sCAYKmckITlRjT15LPYKKkSdhLT3quKek24c7VwLYe248TbzsnITElBqlraGPY
         xtnaQ/sQDuGGI2EM38HLGhwE2T727U304JCPLGww3KNrquIALzaqgoH7WIjarZI1NMaD
         9spaZHwIW/2nZBOGYdK+VtVUsBVQs/OYrI0nB1yDPZ5RGGLb+N9YoM8LzqUhAgUgszP7
         +QpOJHrqAgXop3o+wuGORBzjDtoGwrA7s/v2H+8dpQeZJKUeWq61tt/baV/kwX1B6k+2
         8J5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653820; x=1787258620;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=DOkmhEZoTiIOghmXnQgRNxDKH2kzj/FEWLdizeMkRuk=;
        b=IGCHqI0B3iPXB82gLmhkaxLjglSoCXyxPJWfuEIorMBDg+rtQLUT82NaNuwYtyZq6p
         5o2hN3yBl9oJ+VtJcNGKpu1WeHntSE1eq7M2h8ynALMqgRqusXUSSlaTJaDCVXYYURR7
         KZtq/4WdfA8LEP47Ko7EAYiDe/EpVa26P9oaFOHhVdcH+w8fau/9lFtQ3sr4zMdUMYDN
         PKSAspPfkxN2qX5z3WOMlxfxJxP4tIjQEFTZN0C9SXLO+nxd6tqFwTA/aQxqNsrjDgaB
         jRQiOP+OpZb8NZnYgPFs3nvycFJBJQSa2SSUoQVCFKPea4253VGyWh8jTaeSMw871nsP
         NsUA==
X-Gm-Message-State: AOJu0YxkKnQXAuNcdrA4Nr78yuYtvLLo9ZSKSvzi4DS1W6wuVYG9VN9R
	FcKb4p8DPDG//7tfHQ792/qJMo4K/hkxbaUdQ5LMrJ5NzjYeKJ7PBW69eLZjTeLfamM=
X-Gm-Gg: AR+sD12Bi3E7/wsM3j7QdQXXV/bYX8YOemn5EbMWtR1RcQ/VBEXkEplibfO4key+Ju6
	gVSNxP76E6RiUs4lHIhEMX7rBh7Mbo1fezts/xalPImPY6gFtg0XxiFmOnpn8IQ2UrexnsoJzeB
	TGI23+aRvYPYZBu8xpNffe/vI2lwMJXiUiNS8FcxLX94hgBINUlKm7qWyUXmGsAvxnRpaISVYKt
	a6rUYt/oww7sA9c1sGNL3slXaYtyDwqqqGl4I9fU+tQE0ZEihAW4e5A3J8rrH5G2Ijiq6/XYS23
	dlMkIMP7BywXSoxAh3bUqdXHlqbdinug/nnOB/L5AE49VUEA3gXJDjzBawoSGzIw/sE1azda+i+
	ctZmlt1bbr4sjAEq/8sMLPnmlbNqZxNbqRM6i7ju4kT0BMsrg0h1wMLX4mK3W+KWg0y/y9sU20m
	BNSJBX09GLnHe4RL4qYB2hSj9RfcZ5RxhfvZ7/788V6lIT6mTP2tKLal9C+U4jMrjv8jRcSw0xr
	8EUaqyf4S0P7NFFwtwdyuPj
X-Received: by 2002:a05:6808:1a03:b0:497:e0bc:afe2 with SMTP id 5614622812f47-4b2412e2cb1mr623215b6e.4.1786653820496;
        Thu, 13 Aug 2026 13:43:40 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:40 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 14/21] pNFS: Add deviceid reference query and collection walkers
Date: Thu, 13 Aug 2026 16:43:10 -0400
Message-ID: <297301fa6d1208c3be634cbd07464ef86fea0935.1786653063.git.bcodding@hammerspace.com>
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

The CB_NOTIFY_DEVICEID DELETE race recovery (RFC 8881 Section
18.40.4) needs to ask whether any live layout still references a
deviceID, and to enumerate those layouts for TEST_STATEID.  Add a
layout_references_deviceid hook (sibling of reresolve_deviceid; the
flexfiles implementation memcmps each mirror stripe's decoded devid,
valid independent of the pinned device node) and two walkers over
the byserver pattern:

- pnfs_layout_deviceid_referenced_byclid(): boolean existence query,
  early-stopping, entirely under i_lock.
- pnfs_layout_collect_deviceid_refs(): collects each matching layout
  with the hdr pinned, the inode grabbed with its superblock active
  (a pinned hdr does not hold its inode -- same discipline as the
  bulk-destroy walker), and the layout stateid and cred snapshotted
  under i_lock, so the caller can issue sleeping RPCs against the
  collection.

No callers yet; no behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  17 +++
 fs/nfs/pnfs.c                          | 155 +++++++++++++++++++++++++
 fs/nfs/pnfs.h                          |  29 +++++
 3 files changed, 201 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f042551dd23a..5b88584f4163 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2505,6 +2505,22 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 	}
 }
 
+/* Called under @lo's inode i_lock. */
+static bool ff_layout_references_deviceid(struct pnfs_layout_hdr *lo,
+					  const struct nfs4_deviceid *id)
+{
+	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
+	struct nfs4_ff_layout_mirror *mirror;
+	u32 dss_id;
+
+	list_for_each_entry(mirror, &flo->mirrors, mirrors)
+		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++)
+			if (memcmp(&mirror->dss[dss_id].devid, id,
+				   sizeof(*id)) == 0)
+				return true;
+	return false;
+}
+
 /*
  * The server changed the mapping for deviceid @id (CB_NOTIFY_DEVICEID
  * CHANGE).  Un-pin every stripe device node resolved from @id in @lo's
@@ -3141,6 +3157,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deviceid_node,
 	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
+	.layout_references_deviceid = ff_layout_references_deviceid,
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3020eee50918..101fd23f2547 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2944,6 +2944,161 @@ pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
 	}
 }
 
+struct pnfs_deviceid_ref_args {
+	const struct pnfs_layoutdriver_type *ld;
+	const struct nfs4_deviceid *id;
+	struct list_head *result;
+	bool found;
+};
+
+static int pnfs_layout_deviceid_referenced_byserver(
+		struct nfs_server *server, void *data)
+{
+	struct pnfs_deviceid_ref_args *args = data;
+	struct pnfs_layout_hdr *lo;
+	struct inode *inode;
+
+	if (server->pnfs_curr_ld != args->ld)
+		return 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
+		inode = lo->plh_inode;
+		if (!inode)
+			continue;
+		spin_lock(&inode->i_lock);
+		if (lo->plh_inode == inode && pnfs_layout_is_valid(lo) &&
+		    args->ld->layout_references_deviceid(lo, args->id))
+			args->found = true;
+		spin_unlock(&inode->i_lock);
+		if (args->found)
+			break;
+	}
+	rcu_read_unlock();
+	return args->found;
+}
+
+/*
+ * pnfs_layout_deviceid_referenced_byclid - does any live layout of
+ * @clp's servers using @ld still reference deviceid @id?
+ */
+bool
+pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id)
+{
+	struct pnfs_deviceid_ref_args args = {
+		.ld = ld,
+		.id = id,
+	};
+
+	if (!ld->layout_references_deviceid)
+		return false;
+
+	nfs_client_for_each_server(clp,
+			pnfs_layout_deviceid_referenced_byserver, &args);
+	return args.found;
+}
+
+static int pnfs_layout_collect_deviceid_refs_byserver(
+		struct nfs_server *server, void *data)
+{
+	struct pnfs_deviceid_ref_args *args = data;
+	struct nfs4_deviceid_ref *ref;
+	struct pnfs_layout_hdr *lo;
+	struct inode *inode;
+	bool matched;
+
+	if (server->pnfs_curr_ld != args->ld)
+		return 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
+		inode = lo->plh_inode;
+		if (!inode ||
+		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags))
+			continue;
+
+		ref = kzalloc_obj(*ref, GFP_ATOMIC);
+		if (!ref)
+			break;	/* act on what was collected */
+
+		spin_lock(&inode->i_lock);
+		matched = lo->plh_inode == inode && pnfs_layout_is_valid(lo) &&
+			  args->ld->layout_references_deviceid(lo, args->id);
+		if (matched) {
+			/* a valid layout's lsegs hold hdr references, so
+			 * this cannot become the last reference
+			 */
+			pnfs_get_layout_hdr(lo);
+			ref->lo = lo;
+			nfs4_stateid_copy(&ref->stateid, &lo->plh_stateid);
+			ref->cred = get_cred(lo->plh_lc_cred);
+		}
+		spin_unlock(&inode->i_lock);
+
+		if (!matched) {
+			kfree(ref);
+			continue;
+		}
+		/* the pinned hdr does not hold the inode: grab it (and
+		 * keep the superblock active) for use across RPCs
+		 */
+		ref->inode = nfs_igrab_and_active(inode);
+		if (!ref->inode) {
+			pnfs_put_layout_hdr(lo);
+			put_cred(ref->cred);
+			kfree(ref);
+			continue;
+		}
+		list_add_tail(&ref->node, args->result);
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
+/*
+ * pnfs_layout_collect_deviceid_refs - collect live layouts
+ * referencing a deviceid
+ *
+ * Collect every valid layout of @clp's servers using @ld whose
+ * layout_references_deviceid hook matches @id onto @result as
+ * nfs4_deviceid_ref entries safe to use across sleeping RPCs.
+ * Release with pnfs_layout_put_deviceid_refs().
+ */
+void
+pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id,
+				struct list_head *result)
+{
+	struct pnfs_deviceid_ref_args args = {
+		.ld = ld,
+		.id = id,
+		.result = result,
+	};
+
+	if (!ld->layout_references_deviceid)
+		return;
+
+	nfs_client_for_each_server(clp,
+			pnfs_layout_collect_deviceid_refs_byserver, &args);
+}
+
+void
+pnfs_layout_put_deviceid_refs(struct list_head *result)
+{
+	struct nfs4_deviceid_ref *ref, *tmp;
+
+	list_for_each_entry_safe(ref, tmp, result, node) {
+		list_del(&ref->node);
+		put_cred(ref->cred);
+		pnfs_put_layout_hdr(ref->lo);
+		nfs_iput_and_deactive(ref->inode);
+		kfree(ref);
+	}
+}
+
 /* Check if we have we have a valid layout but if there isn't an intersection
  * between the request and the pgio->pg_lseg, put this pgio->pg_lseg away.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f3c55c86c256..96ab15c5c6ad 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -181,6 +181,12 @@ struct pnfs_layoutdriver_type {
 				   const struct nfs4_deviceid *id,
 				   bool immediate,
 				   struct list_head *put_list);
+	/*
+	 * Does @lo hold any reference to deviceid @id?  Called under
+	 * @lo's inode i_lock; must not sleep.
+	 */
+	bool (*layout_references_deviceid)(struct pnfs_layout_hdr *lo,
+					   const struct nfs4_deviceid *id);
 
 	int (*prepare_layoutreturn) (struct nfs4_layoutreturn_args *);
 
@@ -368,6 +374,29 @@ void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
 				const struct pnfs_layoutdriver_type *ld,
 				const struct nfs4_deviceid *id,
 				bool immediate);
+bool pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id);
+
+/*
+ * One live layout referencing a deviceID, collected for the
+ * CB_NOTIFY_DEVICEID DELETE recovery: the hdr is pinned, the inode
+ * igrab'd with its superblock active, and the layout stateid and
+ * cred snapshotted for TEST_STATEID.
+ */
+struct nfs4_deviceid_ref {
+	struct list_head node;
+	struct pnfs_layout_hdr *lo;
+	struct inode *inode;
+	nfs4_stateid stateid;
+	const struct cred *cred;
+};
+
+void pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id,
+				struct list_head *result);
+void pnfs_layout_put_deviceid_refs(struct list_head *result);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
-- 
2.53.0

