Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BB453B9D81
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474966; cv=none; b=c6ZpukIErDjjxTJbb+mVFaqaJXxSLN4Rqt+SsugBekbD18I2v5gFISXz/7g1xSIcZsdfAI+PtNowqczpx1z7APM1MqjspGD/tL2jqHQyk8nUIfTuYmz5M00ykbJf52alIQlMs+0ZoyB22fVPXqtTSgweqBA53Z8tt5SbB+RnGVs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474966; c=relaxed/simple;
	bh=+6qHMDnLae2+f9zNz2L2GiGtFP1Hw0/oudROPufXEGM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=J1qjE0IDOBXab0KJXRgnL0wRJwfo3gVj9M6EFIZuBMVkUEs2UFbOsAu5oGi8ZouJTacDGRYN4XfMR1tOhuwDJfRx/j/9S2lNt7xXp7hRHllVjiSb/0wTvzFkU0uVR5oI3eS1zEtEfckh36hv0NtGRFC34kfSPXlg/0golsAsG14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=XaH3Cu56; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XaH3Cu56"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c4bf3dedf3so105590b6e.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474964; x=1790079764; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=c1U7MyY+vOvX5QakHbnCRXfOaWIhWEne/NdglU/3f/w=;
        b=XaH3Cu56TCJBV7QuLtpC55K3kMPF2rSRjwiWE8g82VWHTpyzcC7V9on0Mn9vfl8i13
         +CUx6Z4/1QZdYelXX+lNLYa3gOc/HmC2B3+pbGJsWcL/FYFesu/tPFeZ02xeHGeqAO4+
         GItrcwItlWpUjbtOvyOIZlTjYowOb0aCHBWXQLVCBO+yBuyaQU+HLXMG56Xq54oFxSRW
         2tm5XUHqx3OcbWc/A8RG1wsVwwPzDE5fUbLHxPCTU/JGhtI9EffBDAX2z9rBTwalz+MY
         bGbAzmQnaW8zmKpisLaW5bloMrPTtGR85w5icgaaCdOLAMdiiplDo+VXmLoKQxMSZ60y
         5NFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474964; x=1790079764;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=c1U7MyY+vOvX5QakHbnCRXfOaWIhWEne/NdglU/3f/w=;
        b=RdXuYYoKkhoyOUBaD0a6aN5xwnjHw+y6PWutorZlF7j0sK1/o9jl8tAv7V89Up7Tg7
         XP/B6XcQQEghrmvKMj6nHUdYQuaDFlu818oTySs42JR4JeMnedNVVtJuVIkdfIVj6ypn
         WdaW9Dp796nh/6ibexq6speXLIv2wTvkm8TClQxKfU4vZ2SpRioArXfBREdXWUwVW8c0
         kcqP2hg7zdsas/X64lM7BpeovP24YuK5tpp0ikaKKdkKX3jag2xPnF5SC/GLZOug7xjJ
         upJv4r+gJBjRTru2Euea1HWiXqTnD32To/+BI4ch6p8doQcWq/6VhkmoqHMcSoun3Pq/
         /GdA==
X-Gm-Message-State: AFuF++n8CMz9Mpz7gh3yaYR3hXVb65yQMZTv20x/0/VaLgEnymyh1yMg
	gi6TfA0D/aVQfU+jpXUmx4yvpOYF3iaUPbkOf/ob8pPeyCkGEsi058Kc68ncZXsq4lA=
X-Gm-Gg: AYBFou0+vaG7Mkr9CkFqEqh8AvwKe2JO+A1DWy14aUPuD3zS08/NK9sY5KP1Up+hsWw
	6qydLvJXCrhjt2U7hzfd1bHbASquFKOaHuC6V7w4B9Wgbv0c2euV3zYqX0ZqAkkVJJ7DpOdjbnL
	wD8WgMKA2z5XtMPOjsQ9YY7pkKnO/dnN9Vp2nSpNcc5e/OqusFKW4A4+74t7J61qsy2PAQ8HrZ1
	dp3rzc0PatFZa8thyYD/xzFcO52iW4GZhIOCcg6CeHxoFP3EgD54ziXG50CM7aEKRPowoyQe1cz
	4RJpFDRybTdCn6a2CvLQmZvNmEdMalGnbwfpb5jKSZRRX7SBjPR13koyY5EZouyQAw2Mi1+AhJv
	4qZDPeRl8cZ1f4yDlNAfsTaVZGPqtNXM67cee5SlS2PpeT5Ompf/0uZYfQDx6mZ3VCH7jo7BGBJ
	nZ1aJaOF4ECjaYqZuu869H9yKPKxf+2KiPLpnDKLSWTysk6LxNLh7Mu6P8OGnIg2T1QLIsOUT9c
	zMC0c/uKLyo9lkWCRLTb61NEHxnNaIeIpQ=
X-Received: by 2002:a05:6808:4f07:b0:4b9:e6ab:d079 with SMTP id 5614622812f47-4c9aa7af178mr433503b6e.25.1789474963988;
        Tue, 15 Sep 2026 05:22:43 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 12/24] pNFS: Add a reresolve_deviceid layout driver hook
Date: Tue, 15 Sep 2026 08:22:14 -0400
Message-ID: <08f30713f0223524d480f915796ad6417645b55c.1789474702.git.bcodding@hammerspace.com>
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

RFC 8881 Section 12.2.10 lets a server change a deviceid's mapping under
live layouts by sending CB_NOTIFY_DEVICEID CHANGE instead of recalling
the layouts, but the client's only response today is to unhash the
cached device, which never reaches references pinned inside a layout
driver's segments.

Add a reresolve_deviceid hook to pnfs_layoutdriver_type and a generic
driver, pnfs_layout_reresolve_deviceid_byclid(), that walks every layout
on every server of the client using that driver and invokes the hook
under the layout inode's i_lock.  Because the final put of a device node
can sleep (it may tear down the DS nfs_client), the hook must not drop
references itself: for each node it un-pins it allocates an
nfs4_deviceid_put entry and queues it on a list, and the generic driver
puts the node and frees the entry once all locks are dropped.  A
deviceid node is a shared, refcounted object, so one re-resolve pass can
unpin the same node more than once (multiple stripes, or multiple
layouts over a common data server); a per-reference entry expresses
that, where a single list_head embedded in the node could not.

The walk is deliberately not gated on pnfs_layout_is_valid().  A header
with NFS_LAYOUT_INVALID_STID set can still carry lsegs whose mirrors pin
the stale node -- pnfs_mark_layout_stateid_invalid() sets the bit and
reports whether segments were left behind -- and by the time the walk
runs the cached device has already been unhashed, so nothing would
re-resolve that pin later.  Worse, a subsequent LAYOUTGET on the same
header can pick the surviving mirror back up (the driver dedups mirrors
by deviceid and filehandle) and carry the old mapping into a fresh
layout.  Un-pinning a device node does not touch the layout stateid, so
the hook has no need of a valid one; it walks only the driver's mirror
list, which i_lock protects, and the header cannot be freed under the
walk because the driver frees it with kfree_rcu().

Note this differs from the reference-collection walker added later in
the series, which does take a layout header reference and therefore
does depend on the validity check for its refcount argument.

No driver implements the hook yet, and nothing calls the walker: no
behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h | 25 +++++++++++++++++++++
 2 files changed, 87 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b44274ab8b09..d9a181ed1eae 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2875,6 +2875,68 @@ pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 			&range);
 }
 
+struct pnfs_reresolve_deviceid_args {
+	const struct pnfs_layoutdriver_type *ld;
+	const struct nfs4_deviceid *devid;
+	bool immediate;
+	struct list_head put_list;
+};
+
+static int pnfs_layout_reresolve_deviceid_byserver(struct nfs_server *server,
+						   void *data)
+{
+	struct pnfs_reresolve_deviceid_args *args = data;
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
+		args->ld->reresolve_deviceid(lo, args->devid, args->immediate,
+					     &args->put_list);
+		spin_unlock(&inode->i_lock);
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
+/*
+ * Invoke @ld's reresolve_deviceid hook for @devid on every layout of @clp's
+ * servers, then drain the put_list once the locks are dropped.
+ */
+void
+pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
+				      const struct pnfs_layoutdriver_type *ld,
+				      const struct nfs4_deviceid *devid,
+				      bool immediate)
+{
+	struct pnfs_reresolve_deviceid_args args = {
+		.ld = ld,
+		.devid = devid,
+		.immediate = immediate,
+		.put_list = LIST_HEAD_INIT(args.put_list),
+	};
+	struct nfs4_deviceid_put *put, *tmp;
+
+	if (!ld->reresolve_deviceid)
+		return;
+
+	nfs_client_for_each_server(clp,
+			pnfs_layout_reresolve_deviceid_byserver, &args);
+
+	list_for_each_entry_safe(put, tmp, &args.put_list, node) {
+		list_del(&put->node);
+		nfs4_put_deviceid_node(put->dev);
+		kfree(put);
+	}
+}
+
 /* Check if we have we have a valid layout but if there isn't an intersection
  * between the request and the pgio->pg_lseg, put this pgio->pg_lseg away.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a2c70573dda5..bb1ca7ba0221 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -171,6 +171,19 @@ struct pnfs_layoutdriver_type {
 	struct nfs4_deviceid_node * (*alloc_deviceid_node)
 			(struct nfs_server *server, struct pnfs_device *pdev,
 			gfp_t gfp_flags);
+	/*
+	 * Re-resolve @lo's references to the changed deviceid @id.  Called
+	 * under @lo's inode i_lock inside an RCU read-side critical section:
+	 * must not sleep, allocations are GFP_ATOMIC.  Rather than put the
+	 * references it gives up (the final put can sleep), the hook
+	 * allocates an nfs4_deviceid_put per reference and queues it on
+	 * @put_list for the caller to put and free.  On allocation failure
+	 * it must leave the reference in place.
+	 */
+	void (*reresolve_deviceid)(struct pnfs_layout_hdr *lo,
+				   const struct nfs4_deviceid *id,
+				   bool immediate,
+				   struct list_head *put_list);
 
 	int (*prepare_layoutreturn) (struct nfs4_layoutreturn_args *);
 
@@ -354,6 +367,10 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 				       struct pnfs_layout_segment *lseg);
 void pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 				      enum pnfs_iomode iomode);
+void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *devid,
+				bool immediate);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
@@ -376,6 +393,14 @@ struct nfs4_deviceid_node {
 	atomic_t			ref;
 };
 
+/* One reference given up by reresolve_deviceid; nodes are shared, so a
+ * single pass can unpin the same node more than once.
+ */
+struct nfs4_deviceid_put {
+	struct list_head		node;
+	struct nfs4_deviceid_node	*dev;
+};
+
 struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(struct nfs_server *server,
 		const struct nfs4_deviceid *id, const struct cred *cred,
-- 
2.53.0

