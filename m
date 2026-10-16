Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DCE030AAD8
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:36:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792150608; cv=none; b=h5T3I4hNd4MfPd1a4S9KSNPBTV5CrVSYJADeYgiHefQBIiJgUD9wbVvcAq6sE0kHdMdo0ygCjl7T9ZrBr6DyZtm7QZQMNMFI70TZhXYEXbZtSMjrkit9JErFvJKTljl4bS0kfro5HFcUb/OmkrWLJ0AfNHfdRJ9ddCk3X0rigV8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792150608; c=relaxed/simple;
	bh=8dB1z6+i7eM+hOJfCwS2uV7IG3Wg4WO+eR9pXIKVRAA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=o4fLiK+zNe4v1J2i8dtn9Us5d5IIo/IYFY7t3yMxQN3AFX7PRGxSEYQP2ohPNqoDyM00nAblrdstq+Ib/chC8EftEAH0JySy2vroj7CJwZExKq+Pb053+GZLiFhnrqZOEzUy4gdY3aYTBmnl9uSA1nXKybV3sIjy5yqFfQCWCLE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=OG5cCduo; arc=none smtp.client-ip=209.85.167.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OG5cCduo"
Received: by mail-oi1-f179.google.com with SMTP id 5614622812f47-4f6dcc0e8ccso678508b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 04:36:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792150606; x=1792755406; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BNqmqOYbKDdujZdJgtRUm1Ba/c3Ldk9/W9JJW+zlJXU=;
        b=OG5cCduoH2yRCWdJy1jwjc3dfyvVU47PFjvRXymY//fS15oATbaMDICYydpGCP8D9B
         HeuqqRxHT2JxxGCbAvD0blf5TCXhXWW80LccpEN4se2otK1hYT6+CxrDWA/gfJo1M6uY
         gDzDzHfbrNU6YVLJxctDiOfL73N/ataLJN7O1UW0NgffJSgsFDXT5dwiH3BDEtn2iSQJ
         tcpy8cspaasp6Ucf8CxLIVLkt1ddXp0fxRofP/hjk7hu1uAVY3o0M859JnfjdITYQyHz
         dUgd+pY5b9EMMSdR288K0RuUlLPYdYlwOxjMLbMPJ08mLNrMVDqB52E+UpzlGvtxQDAj
         Ushg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792150606; x=1792755406;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=BNqmqOYbKDdujZdJgtRUm1Ba/c3Ldk9/W9JJW+zlJXU=;
        b=C9s2UZms4mCbIEfuO+9OjGbb8ra/ito2pg6G3bAB45SMtdghgQsFtnYYkj/bvdjEnI
         EEydHJyzeBiGgl5wcOrgQBokdRLMAChGSARPhVABpUek1EiAqKdGLhMEP+gDR4FrZGM6
         0NrfoB/XwR4YIyZx0zMOlIA+TF+D1sc+IkV59H1mgIy8bfZwJgDIzWBCcT3+rCztV8Cc
         XVR4lXeru3H4VJ+NZQf328ev4fM/vjC0oW2MxrQlRNIn5VwTEwR1YHKOZbzykBqm/238
         2O4/5JCNXEPopa87hK0M0PLz7f60kTFrga/a/t5mz19kLyJyEcYx7s1/1Ci0BzToZM5S
         ArAQ==
X-Gm-Message-State: AFq9FYLDKpGWOBAhJKt3vC2KvrLiqhvJw6eHs3bnlmj7kJHiGdLL4eoE
	rQMylIc3kPfgT3/YExZithmKdJxgyjqZ7Vp+Y3qOp8RGoyy7xmoxPYJNNuQAPZ9JGfWUqpHCyb7
	gqDnb
X-Gm-Gg: AYBFou3UzxORd7EugT0Gx3wXIohRh8+NJ5v9aLZOySEPbEfopUGo+oSNOZ/IPO+TEG2
	FXZWmKmDVvyjayAWrFs1h0u3v+jMutw+081tWl+80R60xjqnstgxHs8XyY6v83Ev3TxljK8+7VB
	SU4/+oNGNbTSv/NhK5t/k7MBcPFQOoRXdM/KHEC9tvBQ8qyvFrptqbe95TruTBzIjOobZeRkJXC
	whpSL+vqK0YsFdw/BuWoCVKbVQ2WIktw9yJWhhrmexCee3KlAKnPymFze+pwCRS6Wj67odq1M0q
	CZ39zeWpbE+Mv6jJLfnrOVArfo0CscrnuvaqnBFulwIFamNwQqrPEiSsSQ80HSA5tgXE9VkAoT9
	Kb016zoIdsu8wBC2EZu8x9ONO6eww0tvKxKYwJ22Dvw2vCCjf5iiOzirdsBgJe2OeCiHcfPH2lK
	povXGcZr+2AQNZUv0GvtT56PT6+vZfXzJAHj4V4xHJySNsowul41vTdLPWdin7vyoeS9Xp8SzjC
	0rWBpbXeQl46Qe4hwumAxuEOM8SNGo7flfhRbzbJQ==
X-Received: by 2002:a05:6808:1a0d:b0:4b8:46e3:e223 with SMTP id 5614622812f47-536f451dd47mr1702143b6e.15.1792150606039;
        Fri, 16 Oct 2026 04:36:46 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5388f3eb6c1sm1269694b6e.15.2026.10.16.04.36.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 04:36:45 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/2] pnfs/blocklayout: report data lost to a failed LAYOUTCOMMIT
Date: Fri, 16 Oct 2026 07:36:39 -0400
Message-ID: <735df39cfa1873f3ed5b20702fb7d7a79cf49fba.1792097970.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1792097970.git.bcodding@hammerspace.com>
References: <cover.1792097970.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

Data written through a block or SCSI layout into PNFS_BLOCK_INVALID_DATA
extents stays unwritten on the server until a LAYOUTCOMMIT converts
those extents.  When the LAYOUTCOMMIT fails, ext_tree_mark_committed()
tags the extents written again so that a later LAYOUTCOMMIT can cover
them, and reports nothing.  nfs4_layoutcommit_done() also zeroes the
task status for NFS4ERR_BADLAYOUT, NFS4ERR_BADIOMODE,
NFS4ERR_DELEG_REVOKED and NFS4ERR_GRACE, so a synchronous LAYOUTCOMMIT
returns 0 for those.  A server that has revoked the layout answers
NFS4ERR_BADLAYOUT; once the client drops that layout its extent tree
goes with it, and fsync() and close() have returned 0 for data that
reads back as zeroes.

When ext_tree_mark_committed() puts extents back, record -EIO in the
mapping's writeback error and the superblock's, and have
pnfs_generic_sync(), which only the block and SCSI layouts use, return
an error recorded during its LAYOUTCOMMIT.  The files and flexfiles
layouts, whose LAYOUTCOMMIT does not decide what a read of the file
returns, are unchanged.

Fixes: b2be7811dd94 ("pnfsblock: cleanup_layoutcommit")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/extent_tree.c | 14 +++++++++++---
 fs/nfs/pnfs.c                    |  8 +++++++-
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 7393118c42a2..e408dba57401 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -696,6 +696,7 @@ ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status)
 	struct pnfs_block_layout *bl = BLK_LO2EXT(NFS_I(arg->inode)->layout);
 	struct rb_root *root = &bl->bl_ext_rw;
 	struct pnfs_block_extent *be;
+	bool uncommitted = false;
 
 	dprintk("%s status %d\n", __func__, status);
 
@@ -709,11 +710,13 @@ ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status)
 
 		if (status) {
 			/*
-			 * Mark as written and try again.
-			 *
-			 * XXX: some real error handling here wouldn't hurt..
+			 * The server may not have converted these blocks, so
+			 * what we wrote to them may not be part of the file.
+			 * Keep them for a later LAYOUTCOMMIT, but tell fsync
+			 * and close.
 			 */
 			be->be_tag = EXTENT_WRITTEN;
+			uncommitted = true;
 		} else {
 			be->be_state = PNFS_BLOCK_READWRITE_DATA;
 			be->be_tag = 0;
@@ -723,4 +726,9 @@ ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status)
 		be = ext_try_to_merge_right(root, be);
 	}
 	spin_unlock(&bl->bl_ext_lock);
+
+	if (uncommitted) {
+		filemap_set_wb_err(arg->inode->i_mapping, -EIO);
+		errseq_set(&arg->inode->i_sb->s_wb_err, -EIO);
+	}
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..b21ccba9fbab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3444,7 +3444,13 @@ EXPORT_SYMBOL_GPL(pnfs_layoutcommit_inode);
 int
 pnfs_generic_sync(struct inode *inode, bool datasync)
 {
-	return pnfs_layoutcommit_inode(inode, true);
+	errseq_t since = filemap_sample_wb_err(inode->i_mapping);
+	int ret;
+
+	ret = pnfs_layoutcommit_inode(inode, true);
+	if (ret)
+		return ret;
+	return filemap_check_wb_err(inode->i_mapping, since);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_sync);
 
-- 
2.53.0

