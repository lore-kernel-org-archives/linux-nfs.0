Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 093FD50AC12
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540818; cv=none; b=IMjvdpZwJ9kiyiXKX8plQ/jvw7xDojAE1Z5lxTE9Whr7k+lHIyIDNIaXkykhR+pexjxX6g2FUnRnpXWvqI3Vev+V7FAQ1i3LthK5dyiumx3qAc0urzUD8HJmIyiQbSFJwEAMJFNgnSSaWF16G+hR9aqhvXB/GUF+tEkpU4BdzRE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540818; c=relaxed/simple;
	bh=kEUmTlsKTvfl7wSbME4wWVmiDOZ8JE5CBH/sKIMw6yk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ClcrpofAskU0uGP20Z0zfUjD1/Wk5Tk5fl1bUUk7gFEq80gVA+4kItjqntC/O04/O3BdXzlMyraPL9/GmgbI5qpSN0oSGBABJNq08mFWg2w+3SH+djbCz1PY/hMxDmvWL28RDDt+mbmW8yMqzi0vw2V7OOB5u5tFsOMN0z3B7X4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=c2Xrptfx; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="c2Xrptfx"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-9384cb251fbso65403385a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540816; x=1789145616; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=o8vYkKqN6vX5IL0ZtdCLhmLm+BL+Rlm8gtt/Bd8Koq4=;
        b=c2Xrptfx4p8PAbT2aPHHW3NasG+UiZMNCpa/5UxYE7wVYkGPPtg7rjQjLZwM17xDV7
         Nl9buy/VNqUY1BvIuq54FrzDMuLd62KuNWFN17PSLj7B7bDfIRrSyfCQWXu6p/dXd7VY
         P5Tvy1sCHwclX4hvWkQ79IqV/gXGdcsnY+6H/ZZJXhn3BYJJprnMW3Ao2uMMtZzHloZ5
         bu7B6Inpfsb+PYyB7H1J38Ckft/LIOTt90E0sJql8UOqxNO7CkcPe3s1CHxcp/OJJ2Gq
         6nydfymr9umOemXW7yHMl0E1SVxfg7io3jStkbFbZRo3Dr8Lqi71juZzipml+8XdSHVH
         nMsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540816; x=1789145616;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=o8vYkKqN6vX5IL0ZtdCLhmLm+BL+Rlm8gtt/Bd8Koq4=;
        b=HIU9ZeY0sCfKZSgJ7Om1FV+rYUW463dM2azPuMK9iQKvNnppmLa0q+7FxusbRMiZ+q
         tV4uTuBy4zjk+66tCe0vhlALOt196Bi/N73t961t1ukaVwGGIPE8W3Of/qZGOP9OCS+e
         eBl9XHWPgLzK7NeU3WmGj0mer5ZEh4v2SOzqUNhasugpfEdivz+FetGVypV2U7wB8QzN
         TvDx0N1ElvSBx5lWH2LIzRFM9HyYInv9ZL9Ilfrl782+VS3yu89vt5ERzkxd3AbO6fOw
         +nFqc8h6uL61xU5cgbeqsKTOxU+PiLH6pg6vJ4pb0c7z9h9dI3b81y37gozUuky3DBWV
         fIaw==
X-Gm-Message-State: AFuF++mFRmhaQSv57H4egv+G844X2NygDUDI4bEXAG1Zng+BqvXD4lBR
	r3UKPpqT+ACkkY4Le07k5e93ncBqn+Vi4tEJNvw+WO40dUezxIAY1aqIUtDbOxZQeoI=
X-Gm-Gg: AYBFou1g7i7SF/EJ3UpiIMfJGsNmL4p3FXyd9gMuzwTAaWvR4vsMwWd3eiXyaabcWeZ
	R7qwICqIEteWMUDLM31LooivDfzLq7EfJORdsDHxL7gpH0DVfqESOoFOGcehzV5/KwyMKJI9ibs
	SJOzBFqRdL7Hv1+l+Hi40+OstehmwOYovFnwt4B2L8+1xd2g5JvC6rFBevTPG8d6rT+Sa2pkVM9
	09rxE9bahE6RmkldeJ7tCW6NUqzdxDXnMl2hI69BE83Y/9zvtFKLOvosjX5K0HTwsH/07JMnfPt
	h/guUTAdLTK9DwTe/iVlsVgCJ8L2q9H4M0cLO0IuqSIMuUfLlXVaJhLKvkxFKFHNT4xMZQ0qK4D
	/E0TOE9X1B8cMTV1v1BG6yvZkQ4WktXzok02HZ8RjQMz4TrtzGm/9KYhXX9ABDVhYheXUOsyMvo
	stapP0ptZ43aWJjFHSl530HgOWtZ7JjVmqqmt31mwAdmWUeT0KhlWpGlk1r+Cq/wQunu8EfJTOu
	gsnNfbwUj704lc2PV8dkrq6
X-Received: by 2002:a05:620a:6908:b0:937:58a2:45c6 with SMTP id af79cd13be357-939804ed8demr675633985a.31.1788540815233;
        Fri, 04 Sep 2026 09:53:35 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:34 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 12/24] pNFS: Add a reresolve_deviceid layout driver hook
Date: Fri,  4 Sep 2026 12:53:11 -0400
Message-ID: <a6a16d0157f471f5ae5254c3997d7b9b2ab21fb8.1788530385.git.bcodding@hammerspace.com>
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
index b44274ab8b09..2f54b22d0e21 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2875,6 +2875,68 @@ pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 			&range);
 }
 
+struct pnfs_reresolve_deviceid_args {
+	const struct pnfs_layoutdriver_type *ld;
+	const struct nfs4_deviceid *id;
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
+		args->ld->reresolve_deviceid(lo, args->id, args->immediate,
+					     &args->put_list);
+		spin_unlock(&inode->i_lock);
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
+/*
+ * Invoke @ld's reresolve_deviceid hook for @id on every layout of @clp's
+ * servers, then drain the put_list once the locks are dropped.
+ */
+void
+pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
+				      const struct pnfs_layoutdriver_type *ld,
+				      const struct nfs4_deviceid *id,
+				      bool immediate)
+{
+	struct pnfs_reresolve_deviceid_args args = {
+		.ld = ld,
+		.id = id,
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
index a2c70573dda5..08bea2c4186e 100644
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
+				const struct nfs4_deviceid *id,
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

