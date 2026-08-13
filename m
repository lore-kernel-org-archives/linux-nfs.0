Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9071C40F72F
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653815; cv=none; b=TGGIdO6DENWT39NCPm1Y3qMnKyBCs//686KZ5i8AVUNzZRz6kV7viYeRuy8v1BxEpj+x2wwLG0WfINWTmFNXMUlSzUe9DJHD4075GZo94asUao0O8p5l2SB9tA2+dYmEoHXfhWeuiER7o6fcyX7dHDtoFk6eVpFY0BXWnvSry34=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653815; c=relaxed/simple;
	bh=T4MoVyMboR+GprMt6LYTDh3XyspRwKUDXYvckQYZiP4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jj5+J9OBt4wbd8mZTr2+9ftyCKlybVnJ0r/vrE+v6EBMSSXpTF5gGzLTCNV5505mVN43GL4s0d1eERSrZH+OymWTmME1FK4gna9CBUVEkkLrpvzjzuEDgGWxg0ji3x3CUPLZI0b1T7TXWvbWkEKy4m6JnZygqLsAL3z2kpxP9YQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=eX+Rm5ip; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="eX+Rm5ip"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-499f6e0bbabso152247b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653812; x=1787258612; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Fq16wacff7rtTCYFynK5lem5GHv8KTUgRwB2mijyBEw=;
        b=eX+Rm5ipIannw7tBTnbFs9iTEU1yRRzDr9Vnpa8lBlPaA6tVwBqvlBe5wj1twUA8jJ
         ij4emfqB8fza+gI7UKPa1lssIFYzC6xhbs3Gar+tY0tN4Yv+02sKrWaVTyur8A5t3k82
         HUxvDywJV0sGJEiZ6G6Dhl44sNy6Nt98rMXsQRLENlwn6IuyxdiI82KkUgxthyVak0QE
         e8MdAWY03J1iVL4hsxGcrPnr6NsfPlhwun7OY3kNjC+VhUPm6pa5KSuBoWeKZKdUmRWq
         Hz4Vu7Vrxu3rYvgcGP1HrzkjGeSEP6PK3AXZpv0TEEcLCjiyyAa+MB+EAQsdOIIPfY9n
         aRKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653812; x=1787258612;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Fq16wacff7rtTCYFynK5lem5GHv8KTUgRwB2mijyBEw=;
        b=m13Xp6MsIS6gqGg3CVnRyDDuV0monowUPnV39Qy6SOpJBhwM8Mv+6T5J/cCkdGPq9X
         4vupo7uRp2RmT64mvn1fTYbUpCI+OOJF6eI8QhhpymAhlhPxYaya/VrNubhMJmcr6xJE
         mQh04i7KFxiJN43qAPBGHxdpXD19Ry+pegbFqWRAEBB29gWgf0WidyDDya1VL5KajjEk
         XN79woD85XiJr6rEFml+rMeca79mXIuYQOqP1IL9d/GlI64yFMHnBDGGXyi0nL9QrmkE
         p5rt04T0BxpM1F4KFx5UAYml5MoO+E+JN6R9cv9bFQ4vyelgsBIcxnAlkBqa2IPTipce
         pX/Q==
X-Gm-Message-State: AOJu0Yz7nI953UyN62svsoZZ+oqXiGtMmNzKrFnEWraCVAvwlhJoI7sF
	Wpowi9zAYmT5PRUf0NRRlx1nGwglcU9Wr3LlZhyot2KBeJE0T9VKMisdHYfV5NXUtf4=
X-Gm-Gg: AR+sD11Zgtq3fmeSyJBk328dUAv1TCZ5NA3GyccIA8F/ST83wtvd9TTRLlp4vlPws/u
	rfELmV9AG2GOUVbCH3QoA47Vd+LxJn4YaPMbBPRCQjOMGE2JUDG5XhxB6rCaN0yRdkNjoHh5BMv
	oS5YYpcP1SdTPesUOYYHc44Z7DOOfOJiZ9RGsHl5Bx6uAsz6rB+L0CxHK4ViTlGzZVyxR7s4CeP
	WhL02tl635Qek8L1PmCcDr5k2zEtKIukeZHOhHlZd2W7N0XJxurflvM6d8OWYie1pJrvL3Ad3X0
	jch0VZYFYk+3rPK9WJMfC7Lte8u222kMDrL+4neeAF29IHHx0kf2/P4EK5p+SMTLWF5x/tWFrPS
	YM+PAcfXfTUfqpm2jcLuLCtigL1JH6s/BwoEhq5968KzbKmZkCgc6H0oqz2+P6kQHh+T7sgC79+
	5Qfi+InQh8Nla2PhPHdR8R4lxKdnfuS+Um3b+HjNgSqdCKQU7j8b+gEYY8aOvReO2el31c3nE+A
	PZOVJYdu56g5rJBOirmo4T1
X-Received: by 2002:a05:6808:f07:b0:495:da3c:1aa with SMTP id 5614622812f47-4b241e16cbfmr711907b6e.16.1786653812508;
        Thu, 13 Aug 2026 13:43:32 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:31 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 09/21] pNFS: Add a reresolve_deviceid layout driver hook
Date: Thu, 13 Aug 2026 16:43:05 -0400
Message-ID: <84ed176fdf6b301e87e45fab837683f8683cbe40.1786653063.git.bcodding@hammerspace.com>
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

RFC 8881 Section 12.2.10 lets a server change a deviceid's mapping under
live layouts by sending CB_NOTIFY_DEVICEID CHANGE instead of recalling
the layouts, but the client's only response today is to unhash the
cached device, which never reaches references pinned inside a layout
driver's segments.

Add a reresolve_deviceid hook to pnfs_layoutdriver_type and a generic
driver, pnfs_layout_reresolve_deviceid_byclid(), that walks every layout
on every server of the client and invokes the hook under the layout
inode's i_lock.  Because the final put of a device node can sleep (it
may tear down the DS nfs_client), the hook must not drop references
itself: it collects the nodes it un-pins on a list through the new
nfs4_deviceid_node.put_list member, and the generic driver puts them
once all locks are dropped.

No driver implements the hook yet, and nothing calls the walker: no
behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h | 19 ++++++++++++++
 2 files changed, 87 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a21128321c0a..3020eee50918 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2876,6 +2876,74 @@ pnfs_layout_return_unused_byclid(struct nfs_client *clp,
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
+		if (lo->plh_inode == inode && pnfs_layout_is_valid(lo))
+			args->ld->reresolve_deviceid(lo, args->id,
+						     args->immediate,
+						     &args->put_list);
+		spin_unlock(&inode->i_lock);
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
+/*
+ * pnfs_layout_reresolve_deviceid_byclid - re-point live layouts at a
+ * changed deviceid mapping (CB_NOTIFY_DEVICEID CHANGE)
+ *
+ * Walk every layout of @clp's servers using @ld and invoke the driver's
+ * reresolve_deviceid hook for @id.  The hook runs under each layout
+ * inode's i_lock and defers its device node puts to the put_list, which
+ * is drained here once all locks are dropped (the final put can sleep).
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
+	struct nfs4_deviceid_node *node, *tmp;
+
+	if (!ld->reresolve_deviceid)
+		return;
+
+	nfs_client_for_each_server(clp,
+			pnfs_layout_reresolve_deviceid_byserver, &args);
+
+	list_for_each_entry_safe(node, tmp, &args.put_list, put_list) {
+		list_del(&node->put_list);
+		nfs4_put_deviceid_node(node);
+	}
+}
+
 /* Check if we have we have a valid layout but if there isn't an intersection
  * between the request and the pgio->pg_lseg, put this pgio->pg_lseg away.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bdce7f930c6a..9ec0ffebe3c4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -170,6 +170,17 @@ struct pnfs_layoutdriver_type {
 	struct nfs4_deviceid_node * (*alloc_deviceid_node)
 			(struct nfs_server *server, struct pnfs_device *pdev,
 			gfp_t gfp_flags);
+	/*
+	 * Re-resolve any of @lo's references to the changed deviceid @id
+	 * (CB_NOTIFY_DEVICEID CHANGE).  Called under @lo's inode i_lock;
+	 * must not sleep.  Device node references given up here must be
+	 * collected on @put_list (via node->put_list) for the caller to
+	 * put once all locks are dropped.
+	 */
+	void (*reresolve_deviceid)(struct pnfs_layout_hdr *lo,
+				   const struct nfs4_deviceid *id,
+				   bool immediate,
+				   struct list_head *put_list);
 
 	int (*prepare_layoutreturn) (struct nfs4_layoutreturn_args *);
 
@@ -353,6 +364,10 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 				       struct pnfs_layout_segment *lseg);
 void pnfs_layout_return_unused_byclid(struct nfs_client *clp,
 				      enum pnfs_iomode iomode);
+void pnfs_layout_reresolve_deviceid_byclid(struct nfs_client *clp,
+				const struct pnfs_layoutdriver_type *ld,
+				const struct nfs4_deviceid *id,
+				bool immediate);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
@@ -373,6 +388,10 @@ struct nfs4_deviceid_node {
 	struct nfs4_deviceid		deviceid;
 	struct rcu_head			rcu;
 	atomic_t			ref;
+	/* deferred-put linkage for in-place re-resolve; owned by whoever
+	 * exchanged this node out of its pinning pointer
+	 */
+	struct list_head		put_list;
 };
 
 struct nfs4_deviceid_node *
-- 
2.53.0

