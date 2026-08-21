Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E87B493638
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329786; cv=none; b=EYonIVShvPwPinK5JCG5nFN1m7cbqCf/ApJM82YKMrB58za1Fmf78T3PHx/P/E+ysiOpnPqK81oGj9/CmPdbbgn0b5GQa+7qL5cpFOrLV3WwdG+KZ1eSTj+wDuU/TgTVZRO3N3qzBHEwNXUsYtBlTR0yvU1wQWG5L6RaK1k3+rM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329786; c=relaxed/simple;
	bh=2botJ9flCUpMYHPmS39VqUBccG0EYgN27601wpk9HTk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fwUIze3oDInvh8zpFm0ktUZaXG3J2OivmGt9sd1YCEJaH7yo58AitZhODYv4ZRj2Qyv5mhfQ1VxnOfdZyrWwotyb9Vu7oS9PTQ5yQ2crF/QeUmF/LIZFbcJc56KnuzNSbOkNvEPQEeeGUIdghQEQ3EUavdbZIPkvb/pRn5cCeWA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=RlpyW2sH; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="RlpyW2sH"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4a40bcc8d69so1024923b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329784; x=1787934584; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uyljV9HfCDfnyC5g4xW9QhBgzVlWRaIxVmyGckJrG4Y=;
        b=RlpyW2sHDbTBGYgbSyUwRddHI14/WzNxhlZfu9llEDx9WfGaepLzJJyeWObl+3bGuH
         N2OdbN4/mDNmIS47BHOGdVvqnZN3FX/ck2rnYDqFuhSjbKKzcOMtoxZ5H7nyy5zEQlJx
         kMAqhG98ISmBFJlcDjAU7If+Hfv2ER5RE+OsYecQVy3HbC1aMlHzpv15DQz2sYB/Vu5a
         DqiJgTDCmgROzvAtjqIVEGax696Zmq9qC4QmxNrpNsuEah5TedTjZF5e7c57qQS+Gbr2
         xXidMosvUD5vLPHZhD2EJucX5nRNKXN6NHVJwyfwKv12XhE6MLnDz4D3gAPn0tR8kVI5
         WpBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329784; x=1787934584;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=uyljV9HfCDfnyC5g4xW9QhBgzVlWRaIxVmyGckJrG4Y=;
        b=dvFoh/JF4sfl3FTHVUmBw99e3NPqN29FTrc+2Kvx/1LWulGrtaJugJisgf5hbmclqR
         erMHkbJlvpzsY8mLDitWNGe4LmVob+smioLTlCGCrmZqe32pdN07ZaqiKlPA6MJYERb9
         WHqzG9IMygl3HY5QRtFkmuOj8HqIUrGEigJZKyXrwiGIPRNdrDGZS9heT2JbAiEDwkvE
         PL8G/gNQrWriWXxfKaS02uwJQpleM/Q1NdJvhX5yxG3+Dj483v2wHyg7UU8aKu8z2ipL
         Y7U+j1qIIgp7/Thu1R4QbGop2sGBMLiih6d5bmBDupndSLjdbHZ0ch3xL4fAZdtXkHdd
         A41Q==
X-Gm-Message-State: AOJu0YzKOIfkW66yjM8zuiFruCB4Ee1+h9/k2BJR8g3kQqrq5gcStlaU
	2nTyfq4m42ZzttydonpDSO1S/cYUxv5uDKsv0ONo4vxFcVNB/Qk7ocN/xlXX2oI5fAU=
X-Gm-Gg: AR+sD12GpdeQKIJJxdQM0fpDzXytAHSE7XHKibcSB9rpKvgtiQZsJygxY132Y1hR0EA
	J2C3DrdPWv6ZT8QfwzZJ+dZiUcK/ljmQMUYQ9+Rjxxtg3KsUvbS8y1B9xtX306u3kijhfI1waPx
	fTlpl/AEIfFxFjuk+/5vpqaS6JOCozQDL2ySyVOCZ4bciBl5NC3Tvr44kQ1ahPT7oTwHicWHSqD
	OZ8HO/axk1gf4/4kJn9TzGoMqA9Si9XxJ2OTv0uiCO/OSd1NPEQRswVMRYMUPIZDH0dKCCt6WWc
	Z88kshqLD0l+eMI6Ts8rcBV/eUodJYH6wW+FkfyejT2P2QIi/1ovwXprtopWs6QKLbZYS+XcQHF
	+0OXngV1lNKW+nOot3gA0TgONSIyySwy3XAiGXWWGGcPYOrpmh/zI8kgHfPIPfMjVq7vE0klvOi
	LsLW2AHD49ykca+U60tcPnVf20K1Dq2gaLDz6jVr1nO7DgJJyi9y/zjFiepPTsdLTU9ufX38fZO
	W6WuPbjLhXnUZ/OxaeQH8Nk7q/5bGkEoNw=
X-Received: by 2002:a05:6808:199c:b0:497:da47:df5f with SMTP id 5614622812f47-4b2ef42ce04mr8356939b6e.17.1787329783923;
        Fri, 21 Aug 2026 09:29:43 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 11/23] pNFS: Add a reresolve_deviceid layout driver hook
Date: Fri, 21 Aug 2026 12:29:15 -0400
Message-ID: <ea1fec6367ed99afae7bd6870033f7c9324cd698.1787327939.git.bcodding@hammerspace.com>
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
index a21128321c0a..6769671addd7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2876,6 +2876,68 @@ pnfs_layout_return_unused_byclid(struct nfs_client *clp,
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
index bdce7f930c6a..9627da034d94 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -170,6 +170,19 @@ struct pnfs_layoutdriver_type {
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
 
@@ -353,6 +366,10 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 				       struct pnfs_layout_segment *lseg);
 void pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 				      enum pnfs_iomode iomode);
+void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id,
+				bool immediate);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
@@ -375,6 +392,14 @@ struct nfs4_deviceid_node {
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

