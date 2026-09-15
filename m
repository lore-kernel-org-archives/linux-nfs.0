Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 578A23BADB1
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474974; cv=none; b=XJtgQeEsq2c+nLHBZOQO242SniAWCrioiCSYZPMKGxO0XW4BR+PEpwjy89Ater/CTSjmkOwgA6XxUDB8R59nAMUe28AZzg39+MUOptKQ2LdeQsOTAu1DDUB/ROI8k9tXWIYqEKGvVR39hW/MoT7aw9gzWXqBju9znp69RNlMp+0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474974; c=relaxed/simple;
	bh=TuIC/fxup3Tnkafr3k7zD0RQNqs7Oy/Xbfhb36VIDAU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MmmvS3jvv5Iy4lTuoHriZJ1ZpKKELDY0WvbwevFs+PV1ymSKt37cBwR6mexNW56EACH8GYwufTCM5L/cAt1ZX7UKh/md0Wy6YWN3kfmphDn7qZ8ClvPjkVfac96F2A6pEPzwjjruWd6gozbCyCV53y1JKR7wsKa96lBusF0Fz+8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=C5pGZfmb; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="C5pGZfmb"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4b37a36887bso1807258b6e.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474971; x=1790079771; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NkDCsyENQtS0v62rjEiO7QgDAI+u/uUyEsjd18DXAyU=;
        b=C5pGZfmbDcM0gw7O/ZHA78R4PUAcEl39r1wmTVSjzCUCjihP2rwkVhrer/IFw60/PI
         IsapJf8TvtDb7YQ1TBqEjutpm/MJR7m0XDXGlEYlSx9OZdMhOekHvjwWPOoYjaNSbnrn
         FwJuAb+huseXXnYAcyUWtwJUwT6fXNLpyiop/NTMzNXOudMoopD+JrGZT6EsHsxKUX95
         qIXcaXXqpzXt0PU+XovACk17MZTX5CIfWyLc7BABr6/tLCJ5+rdMlSAnqt3g2ltNGKU4
         r5/wXwXZ+utV1r87aIpI/Y5hgIw8kd3ShSNy8k3dlfyh2tNOkJFqbmQgN1WgbmRnIdqN
         9SIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474971; x=1790079771;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NkDCsyENQtS0v62rjEiO7QgDAI+u/uUyEsjd18DXAyU=;
        b=GJG/pfiZWNhCN9KwUrJwRhjxnmEaJsXV5Wwk0w8JfUHJRNXH5kTbYR5q9ngSPMqbuA
         9EbvVX7wNLCQ4JokBVk6ljQ2z5FApzKQO65hY6W5XPyb/WNxhB06RSaURASqfwrXwCea
         tx5S6tNJikxQf9MGmBmlBzAMOJ/DiJ0hhDPNx5F33fYcOHq3zscXXjfdcWozFK8ZsTyt
         Uo6bGFkL2nheZ+N3m+G8xCY68/x4iMlS2FwKWzEqPZCFRK8uOTyv13S/BLZaJ+9aqKU1
         cIfUQdWhuVc1vYfysUYJTdhSYZj+YNwv+blcjlqExsi8RrImhujH2fApLeIuRGoCpJRr
         v3gA==
X-Gm-Message-State: AFuF++kvJ6v9vJeulXAi+wVbsPJF8jodFzIP9e0134sUkDFtmCUJj0dT
	vuzLcB31r2wVzGGPQsij4eaEV1WkrUbC62JKrJqy2/8N1pIwqsD+Khzh47qnhoBeUOw=
X-Gm-Gg: AYBFou33ksOG8t/5MLFbHanmONmjo2fEBn05SE2my2FlFXUORqe6oS0EchsA2ITdbQd
	kPwu76RZwMnW1jcKXuAZUH60TyZFZftlRAvUFeRLYHkvrr698fLPxciKI00NaOH7Orx++2hswZR
	M9KPIrqE/olIFlQj9EKmBMiEUnkaz32rcN1Ys0bmX56ImJjHOaJCLSqVfXWts9Ra7m+NhAD4JlX
	wZWXELTqIaApNcSSkDUOS9F26GG4RNM4XeGX4SCK/PIvbjAcKG9rZ1NYMkIWXH0Q8HccFvCAUSV
	4/4R36aQ5DndfIYrfo3Wvxs5deovOrvH+4OaPxgDdtrcWHkcqrrT70jdtS/Oc7hoQbJJT2bIH/5
	kkHLpO4uW6Aj4y6LSyiSDL+qb3gGPOUlaPdtZxWS3p8Td0yyeNMrS0bhTyquRT8z5jnbxuwuizn
	3XBUJdg2VoTV5X22CliGaiZQ9gDB6etUn1rNy2sjlWPKTY9vmNTU2gDhzv0PBgs9TN+utGnqRpA
	CJPdUIySoFNoC68qjx+EJ2l3/xnU96JpLg=
X-Received: by 2002:a05:6808:6807:b0:4c6:a5e8:c792 with SMTP id 5614622812f47-4c7b684d694mr5354650b6e.41.1789474971099;
        Tue, 15 Sep 2026 05:22:51 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:50 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 17/24] pNFS: Add deviceid reference query and collection walkers
Date: Tue, 15 Sep 2026 08:22:19 -0400
Message-ID: <657aa7a3a78899efdaedb0acfd9ad17d075d133a.1789474702.git.bcodding@hammerspace.com>
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

The collection walker pins each matching header with a plain
pnfs_get_layout_hdr(), which cannot resurrect a dying header because
the walker holds i_lock and has checked NFS_I()->layout == lo.
pnfs_put_layout_hdr() drops the last reference under i_lock --
refcount_dec_and_lock() only decrements one to zero once it holds the
lock -- and clears NFS_I()->layout in that same critical section,
before it unlocks and frees.  So a header still installed on its inode
cannot have reached a zero refcount.

That argument deliberately does not rest on NFS_LAYOUT_INVALID_STID.
A header can reach its final put while still valid: a full
LAYOUTRETURN ends in pnfs_layoutreturn_free_lsegs(), which resets the
layout stateid rather than invalidating it, and that is the ordinary
end of life for a return-on-close layout.  The validity check the
walkers do apply is a policy filter, not a lifetime guarantee.

Because pnfs_put_layout_hdr() can send a layoutreturn and sleep, a
header pinned for a layout whose inode can no longer be grabbed is put
after the RCU read-side critical section, not within it.

Both ways the walk can end early report it.  A GFP_ATOMIC allocation
failure aborts with -ENOMEM, and an inode that can no longer be
grabbed -- igrab() fails from I_FREEING on, while the layout may still
be valid and still name the deviceID -- aborts with -EAGAIN.  Either
way the caller is told the collection is partial instead of receiving
a short list it would read as "no references".

No callers yet; no behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  17 +++
 fs/nfs/pnfs.c                          | 164 +++++++++++++++++++++++++
 fs/nfs/pnfs.h                          |  29 +++++
 3 files changed, 210 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9caf4b3b45ae..12b7be95a9c3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2527,6 +2527,22 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
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
  * Un-pin every stripe node resolved from @id: in-flight I/O drains on the
  * old node through its own reference, the next I/O re-resolves.
@@ -3155,6 +3171,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deviceid_node,
 	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
+	.layout_references_deviceid = ff_layout_references_deviceid,
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d9a181ed1eae..5ddc57b7db57 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2937,6 +2937,170 @@ pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
 	}
 }
 
+struct pnfs_deviceid_ref_args {
+	const struct pnfs_layoutdriver_type *ld;
+	const struct nfs4_deviceid *devid;
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
+		if (NFS_I(inode)->layout == lo && pnfs_layout_is_valid(lo) &&
+		    args->ld->layout_references_deviceid(lo, args->devid))
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
+ * @clp's servers using @ld still reference deviceid @devid?
+ */
+bool
+pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *devid)
+{
+	struct pnfs_deviceid_ref_args args = {
+		.ld = ld,
+		.devid = devid,
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
+	struct nfs4_deviceid_ref *ref, *tmp;
+	struct pnfs_layout_hdr *lo;
+	struct inode *inode;
+	LIST_HEAD(putme);
+	bool matched;
+	int ret = 0;
+
+	if (server->pnfs_curr_ld != args->ld)
+		return 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
+		inode = lo->plh_inode;
+		if (!inode)
+			continue;
+
+		spin_lock(&inode->i_lock);
+		matched = NFS_I(inode)->layout == lo &&
+			  pnfs_layout_is_valid(lo) &&
+			  args->ld->layout_references_deviceid(lo, args->devid);
+		if (!matched) {
+			spin_unlock(&inode->i_lock);
+			continue;
+		}
+		ref = kzalloc_obj(*ref, GFP_ATOMIC);
+		if (!ref) {
+			spin_unlock(&inode->i_lock);
+			ret = -ENOMEM;
+			break;
+		}
+		/* NFS_I()->layout == lo under i_lock means the refcount has
+		 * not reached zero: pnfs_put_layout_hdr() decrements to zero
+		 * and detaches in the same critical section.
+		 */
+		pnfs_get_layout_hdr(lo);
+		ref->lo = lo;
+		nfs4_stateid_copy(&ref->stateid, &lo->plh_stateid);
+		ref->cred = get_cred(lo->plh_lc_cred);
+		spin_unlock(&inode->i_lock);
+
+		/* the pinned hdr does not hold the inode: grab it (and
+		 * keep the superblock active) for use across RPCs
+		 */
+		ref->inode = nfs_igrab_and_active(inode);
+		if (!ref->inode) {
+			/* The layout may still name the deviceID, so report a
+			 * partial list rather than silently shortening it.
+			 * Defer the put: it can layoutreturn and sleep.
+			 */
+			list_add(&ref->node, &putme);
+			ret = -EAGAIN;
+			break;
+		}
+		list_add_tail(&ref->node, args->result);
+	}
+	rcu_read_unlock();
+
+	list_for_each_entry_safe(ref, tmp, &putme, node) {
+		list_del(&ref->node);
+		pnfs_put_layout_hdr(ref->lo);
+		put_cred(ref->cred);
+		kfree(ref);
+	}
+	return ret;
+}
+
+/*
+ * Collect @clp's layouts referencing @devid onto @result as entries usable
+ * across sleeping RPCs; release with pnfs_layout_put_deviceid_refs().
+ * A negative return means @result is only a partial set.
+ */
+int
+pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *devid,
+				struct list_head *result)
+{
+	struct pnfs_deviceid_ref_args args = {
+		.ld = ld,
+		.devid = devid,
+		.result = result,
+	};
+
+	if (!ld->layout_references_deviceid)
+		return 0;
+
+	return nfs_client_for_each_server(clp,
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
index 9a5b8070f595..8dd892d875e3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -184,6 +184,12 @@ struct pnfs_layoutdriver_type {
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
 
@@ -371,6 +377,29 @@ void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
 				const struct pnfs_layoutdriver_type *ld,
 				const struct nfs4_deviceid *devid,
 				bool immediate);
+bool pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *devid);
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
+int pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *devid,
+				struct list_head *result);
+void pnfs_layout_put_deviceid_refs(struct list_head *result);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
-- 
2.53.0

