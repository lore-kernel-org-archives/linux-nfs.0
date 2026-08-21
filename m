Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AAF8493640
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329792; cv=none; b=QVTLCPLHbJVCaRYImfPQlJF/wL7dpbczSFtZ01WwFvz3yN0UcByB37FDYtbTnJz39Zaqe81l9UaPXDab/4MZJumibx82MyANYo94JvWRx3c+ym4s+CKvh8oJkq9VikHzvm+hzzYn09J8XoE6+KIbWAVa/lOEY/Eq05ct8LOmAr0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329792; c=relaxed/simple;
	bh=AEagcS10rgXu6OdxfUrI0+oay6oGcvBESa3gM2UIBI8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=M9d6NQ1lAnqCHKeUAiHvzp81do3YGre8f4Dwk9WZu3e3iIWsVbulI3ojtPF/GoKlfXLLhL+3bX7eBw7glME6GUO4hvjBIRm2SsNGO+qwUaKRUTyQGp1Q1bk/uqvaj7PU49TiTwSAd0m94O5F2fpx+/ro0MQn5FoxSeqYQL2etv8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ngwLcKpL; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ngwLcKpL"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4b190cdc9feso1020252b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329790; x=1787934590; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iUwGOH/iBwqKGXK5dC2RBRefCdLkgHpGdVnZ9hBeluk=;
        b=ngwLcKpLEIflboZP4ghHcduKKvRgoAG8JruiqTDd+G2Q8PMToDGVg7ihSn1jSczLi0
         YNLib/tx29g7unDIk21f5dY3pbXH8is/ldbvZOiqICbxe1xIk52dOXaPgIb0JEaJ6uLD
         uieR7PIlqbpG3EIU0liCKuKZ8R1mfVhqIO2mpy/8TxLaNWkROAo2TT1kM9uiF+O+58ql
         7i5hPxV1T3RQpJMhe+iWeaxk14NKmRqIkGU4Lpp3GGOu8hLdgv62I8lV2SWoe29UHnmm
         a6rTOGw9A0c/umFPh/P691FsM8XTw8MGK1r+SgcaMznHXmN9HJvAL9VKYXy9xP5VNnXB
         RehA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329790; x=1787934590;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=iUwGOH/iBwqKGXK5dC2RBRefCdLkgHpGdVnZ9hBeluk=;
        b=Te4+BLu0g00EMhRmsTpfE9vEEhXOdIwV0SEmxMEBGlcvxFlGNPMu2fBDjodhkSieEM
         ZBV/y5dbhaJG4atrbOIm2AiCBVibjOgelDYTkqXexgSiFeB63zEP8nYBJXPRKPF9Xi93
         7RpPdQB3X73KUbmif8mgZE5Bd7pqPcndNLwai1cymoRteRAEhtv+A2XkUW53yCq4k5um
         QQu7loePsP4grsUxa9v/JXKydMnmKlhRqQ5B4GQIaF0fIGsSs3SFtj2FjRZdGMQ1Yjs0
         i3dTJTz4D8ewqK9lvu4j+EX4ch+jY+qHT8O/nE4KJEaxbPFdUEUF18mgN6vhJWxA5mmm
         218Q==
X-Gm-Message-State: AOJu0YzcqLIVJJyBw0G1B3g6uPYU82rIWg1UP/OtUIuhWquaSvWLPTag
	IJXXgZsfI3DQ3l/SIIZ4wHo6P3IhqOdHjRC6D2ADrR9dXlvumpl1Q6C5MgY+QBoq5LI3VLwCBR4
	PPzM9
X-Gm-Gg: AR+sD13uva1AdG5Fro23VpWKyIGK/IAlyHJbnm75d/lmDcn+ZGsOplvm8W2aI33Nd79
	BUIDZKb5FWu7pIc5dzNybqaDjDN/Q8Cgxj6Q/VPJ6nXaKx2N3tmERTUVLZLUnnmyucqsb0xROS+
	keMk5kB6dBx7OBHqMwbQ21KM9N34BxrE9PuSku6DgGBj0+827FQ7pXNo8iG8uIHJNPXbckNAbFv
	GD/6L//jeIvBMwXfInYc9rqxKkQbx7nE9dRlACD+6y0MUN9TcZ5iNeNPVTncbNWbSbI/y0QidoY
	x+9VPH6KRwBXvx5QULpQM6gOzopOGs6bNYiUgOjGgh+rM7vprj2jReM4HcRA0x472RrV/6GgnIv
	neSe13Sh2oP2FyS8DwIvnewz/txU+QX5cBmyAbeF365O8TnoIS+nPaQ2mz+ix+ljWkV2jfYmDI8
	STq+1Tzb4gFdpBXFZzrjIkz3tFYqj3IHJTKo65/E6yWtx57MAJF4zlMbOscm2CeiQYFoS3vxyOt
	pQZEG906xD31dhF1I4e3f9sTAtR3nUjGPU=
X-Received: by 2002:a05:6808:5087:b0:4b2:8e21:622e with SMTP id 5614622812f47-4b2ef1bc216mr7919031b6e.1.1787329789592;
        Fri, 21 Aug 2026 09:29:49 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:49 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 16/23] pNFS: Add deviceid reference query and collection walkers
Date: Fri, 21 Aug 2026 12:29:20 -0400
Message-ID: <8ca7c1beca17f412e9ca4454372a80f4d146a90b.1787327939.git.bcodding@hammerspace.com>
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
 fs/nfs/pnfs.c                          | 165 +++++++++++++++++++++++++
 fs/nfs/pnfs.h                          |  29 +++++
 3 files changed, 211 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ebb19a919f9d..7923088f1a69 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2508,6 +2508,22 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
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
@@ -3137,6 +3153,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deviceid_node,
 	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
+	.layout_references_deviceid = ff_layout_references_deviceid,
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6769671addd7..c44f5a109021 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2938,6 +2938,171 @@ pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
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
+		if (!inode ||
+		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags))
+			continue;
+
+		spin_lock(&inode->i_lock);
+		matched = NFS_I(inode)->layout == lo &&
+			  pnfs_layout_is_valid(lo) &&
+			  args->ld->layout_references_deviceid(lo, args->id);
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
+ * Collect @clp's layouts referencing @id onto @result as entries usable
+ * across sleeping RPCs; release with pnfs_layout_put_deviceid_refs().
+ * A negative return means @result is only a partial set.
+ */
+int
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
index bf0b012a49a9..5a8c1ffee784 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -183,6 +183,12 @@ struct pnfs_layoutdriver_type {
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
 
@@ -370,6 +376,29 @@ void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
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
+int pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id,
+				struct list_head *result);
+void pnfs_layout_put_deviceid_refs(struct list_head *result);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
-- 
2.53.0

