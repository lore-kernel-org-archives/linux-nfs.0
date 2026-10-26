Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793057275;
	b=baLNhWyGQOYOUPTmQxNXOiMHrZvtRVV8ZFyeTvFTM2pQARMn6hUpxBEWab+VL2VShVlb
	 h8hAyKDy8eVhDfuKX6hbu2vVwPZWAz71F79rCBoZ8/sZv+bEgqRgE6IkRXkepKdLsnoCE
	 isccwim0Op/OL+NPO5UVaHG0SErGkRrb/G1/FcJ2Afh6KeqywRhbtT6q+nOu+61SMccaf
	 O3rR5hTlvitiwWktQZhwUnfHNVUeHMIiBFtEv52UwfeO/SSFnTahHqrsb7sN7kSOKFoZj
	 oGDdmVr4Y+9NlufzOmMPlnFdrPbJazNb8Pu3cIcRiWKQc/Ij8oH4aH9ZhYBCZLE9GVQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793057275;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=+0mRATtv2GF77n3k6u9zm025rOyp8Pav4XcpqOtjcp8=;
	b=OwKSelONsej8xM8Xu1JkBBwm9XM4GoNVzFlDMfh36x55dyLWRfC6wXbYEx500tzGFPKT
	 6IS5JzPnQMaw/th8FVtXiPIfPj7uz35ADyQS8dFuTk6hz+RUax07kr2nRJdyhpiFXMfUx
	 lkQFi6oDR3x0+4WYTkyb9RfhMBtgTvibNrxP2aDHuz47CGhYj6GwlhZHxPhiPOsar1x/4
	 GDeRYx8FMHu70FRtSzDPCkBi+zUDT5+k+ddW0lCMHXmLqzq4eL4JS76xRjsOQaIuzTwFx
	 Us/xS1Cl0/vlhga3R97Gm/MGMmbuGI+/8/zMWPRGdYDdioUbQUZ1nOqosb5q8xEDW8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=CsIhSNlo;
	arc=none smtp.remote-ip=209.85.210.48
Received: from mail-ot1-f48.google.com (mail-ot1-f48.google.com [209.85.210.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 262DE606A32F
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 23:27:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 262DE606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=CsIhSNlo
Received: by mail-ot1-f48.google.com with SMTP id 46e09a7af769-846566246e8so368860a34.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 16:27:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793057274; x=1793662074; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+0mRATtv2GF77n3k6u9zm025rOyp8Pav4XcpqOtjcp8=;
        b=CsIhSNloQY5uPgyi/wFC7jSSS4zkKTa2DITkAk289B3QUOxHu2F6ZoqlJEZdjLdhfM
         G3y4Gp0eBKV+a8ZbWxqYmp5VV8VH/W6fdqteoYcjsFvgFaYyGgb9HNNfq/qXf5dxoSbJ
         BcsVz2ILw/UrKr0qHDgTqPD70TDBXFcyHlAbL5B6kPrCZRCAc4DTZJQyT+cTLGAUi/r2
         7cgn8ejaDAhiu2jdkcmtSMVTtjgwOLWlTDHRjX3T5RtQRZeNOUAmZqZConxPq31/N7M4
         IZnd9Ax8/SHLnIs7P4VrXHB3zv9Vr9TWQ0t3aFvXc4Fq+wg1tJ+KzdElA1kfDBo4J5g+
         KSdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793057274; x=1793662074;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=+0mRATtv2GF77n3k6u9zm025rOyp8Pav4XcpqOtjcp8=;
        b=LAU0LfCX5eQz7xR7IkCbzve+2HjUlZga7KyRyzQ2wD/D0KeyXAukU0dkLVpkDCATGg
         egRMpD1lP274+Q9MVy4KFMsX2AXnBaTDk2pqTTUD1JsWAIXK73psw1pbDTNop3Kv0yP8
         e/Z4nxx8eVqMxjMWWoYjjV3K8t7hKcrrAPhwRd8aGRrYwnDnyd+GkwuY99YhktT10Ogp
         A9b3ILCoAQSnsbwZn0pm3GNHMiW7fd3Gj22tG13MrmgDO5QxFSU3vkwW5rxVcAC5wati
         4qUrXnsYBcKBj0WbFODI1ZOm0Dm1Dv63WSwjsXbhHrXmvKrgFo/xnVaAOA0qUEPjhg3/
         RJLA==
X-Gm-Message-State: AFq9FYI31oz5QT4Jn+p0goki1+kMl29mYgq9YKMfF+wBoG4OhOZqXsnt
	6aDi04fzNNLuepy06RumwgwBVDYXEEfP0lSOST8er+b7HKqXslLGUVupPea26068k4A=
X-Gm-Gg: AYBFou0pS7/F1Bvq0tn7tF5/F85+Sfxl1urud8bROrthWGYLM5o8syW9NbT1amBGEEs
	hmunOugGW0KQFq0Ebps0neOJ/Kk2BHcqcx1O3rp8kY8k3Jowq8x8Eq2z9E5pSJof1U8xfAjVU0O
	rQQxITuCqwzK3SJZ/oz6P3m+LNQK+hOFej0meBLwX1oHKk5ZhUPpoRtc6CwoFnf0gl/s1j7rKzE
	wI8ZTwz3wmG/n+iAOyeO9cEgwhSjk30OrNSf59t4V/s1AGV6OeDJuTaaxKL7UpD02xaeIzjGOcz
	i7ftjffwm5bCQT9K8INLgB9S+jIQO67JMIYMd83KMVXYgGtLlTl+UpsOoRV2ca5dSpA33mj/LOc
	k0SDGCBb9/ETESRWJB/+5x0Wd9rEvDILb+LVpPeJ/lJO55r+hNn3vroPxuD4RhDTr6qL3tHzhXQ
	VCkResUWvyyVygCeC51QQ7qHFbwkQzqNP5BKCaSL1CDS1/hmRUH5wx7tzD1Nks6Le1X65CxWYI9
	MWbx305PZWVIfZopXxvS/MlOdwUSiIFzBmuuSkEzVmy7Kkxf/47TY76hQy+Wi7AFUvLZg6YtFXL
	3pfcyRhL9EGNvLAm3YAdPEnk2so=
X-Received: by 2002:a05:6830:410b:b0:845:8a38:c786 with SMTP id 46e09a7af769-859421cf96cmr780978a34.16.1793057273902;
        Mon, 26 Oct 2026 16:27:53 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-850fc002444sm9060774a34.23.2026.10.26.16.27.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 16:27:53 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v2 2/2] pnfs/blocklayout: report data lost to a failed LAYOUTCOMMIT
Date: Mon, 26 Oct 2026 19:27:49 -0400
Message-ID: <f1a9f1337cbbb4039a29fb5808d8c2944b9a112c.1792157092.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1792157092.git.bcodding@hammerspace.com>
References: <cover.1792157092.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
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
mapping's writeback error and the superblock's, and have the block and
SCSI ->sync return an error recorded during its LAYOUTCOMMIT.  ->sync
also runs from inode revalidation, so compare against the raw errseq
value rather than a sample, which would return an older unseen error
from every stat().  The block and SCSI layouts are the only users of
pnfs_generic_sync(), so replace it with bl_sync() in the block layout
driver.  The files and flexfiles layouts, whose LAYOUTCOMMIT does not
decide what a read of the file returns, are unchanged.

Fixes: b2be7811dd94 ("pnfsblock: cleanup_layoutcommit")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/blocklayout.c | 17 +++++++++++++++--
 fs/nfs/blocklayout/extent_tree.c | 14 +++++++++++---
 fs/nfs/pnfs.c                    |  7 -------
 fs/nfs/pnfs.h                    |  1 -
 4 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index aafcb8e30057..b41fc7a6f65c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -798,6 +798,19 @@ bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
 				lcdata->res.status ?: lcdata->task.tk_status);
 }
 
+static int
+bl_sync(struct inode *inode, bool datasync)
+{
+	/* An error nobody has seen yet is not this LAYOUTCOMMIT's to return */
+	errseq_t since = READ_ONCE(inode->i_mapping->wb_err);
+	int ret;
+
+	ret = pnfs_layoutcommit_inode(inode, true);
+	if (ret)
+		return ret;
+	return filemap_check_wb_err(inode->i_mapping, since);
+}
+
 static int
 bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 {
@@ -976,7 +989,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.free_deviceid_node		= bl_free_deviceid_node,
 	.pg_read_ops			= &bl_pg_read_ops,
 	.pg_write_ops			= &bl_pg_write_ops,
-	.sync				= pnfs_generic_sync,
+	.sync				= bl_sync,
 };
 
 static struct pnfs_layoutdriver_type scsilayout_type = {
@@ -1000,7 +1013,7 @@ static struct pnfs_layoutdriver_type scsilayout_type = {
 	.free_deviceid_node		= bl_free_deviceid_node,
 	.pg_read_ops			= &bl_pg_read_ops,
 	.pg_write_ops			= &bl_pg_write_ops,
-	.sync				= pnfs_generic_sync,
+	.sync				= bl_sync,
 };
 
 
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
index 4f9c0f639014..99e33a69c087 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3441,13 +3441,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 }
 EXPORT_SYMBOL_GPL(pnfs_layoutcommit_inode);
 
-int
-pnfs_generic_sync(struct inode *inode, bool datasync)
-{
-	return pnfs_layoutcommit_inode(inode, true);
-}
-EXPORT_SYMBOL_GPL(pnfs_generic_sync);
-
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 {
 	struct nfs4_threshold *thp;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 70d20f779678..85b2ba557b11 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -316,7 +316,6 @@ bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task);
 void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
-int pnfs_generic_sync(struct inode *inode, bool datasync);
 int pnfs_nfs_generic_sync(struct inode *inode, bool datasync);
 int _pnfs_return_layout(struct inode *);
 int pnfs_commit_and_return_layout(struct inode *);
-- 
2.53.0

