Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793302468;
	b=lMS+ApfN2tL+nFlJgGMepJilFJ2GTuiKDay/cz2A2kf5Fx+hHx9henoOVBwfY2jhHqq2
	 dsq9kWNrdp02YMw6aEn83xZzOnwhOveCfgrkZiZXWj/4ekAKOUoJE5O+u2olpceEN2JVV
	 p0NCTc8QAEX2alaopk34aeWrdO5t6vHBN36H2jA+jGEYiKK/vTzqZh7mckVePPDy7H0/z
	 ZK/+rivl+nhMKGsJOGzVKd9gAW9ipdak5/13REMmyy7ueEfporWhIpKe2V1n8n8zFHxhj
	 63/+3GcwPBVp79CZnraxVFckhAq/8KcULuQGbB9LPc+aMK/9VpZnh5M7N/HySTuDcmQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793302468;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=PuLVebBATEeqqyn/PldQ4dGyEDIrLVXFLW5fCfzk680=;
	b=D3SrzerVCupA0roRieyqqcbsqtyl6Fo55w2rBOm1x2GiDij9kVcLq1gzdDMdE7LLl/2D
	 MsvjOUvro76/gmkpsx+Lop/9R47xbuteetzQZFVJOPgGjmpFkRkdwVr0NZp4HXdWddT2T
	 Ii7+cKB30LVI+r6ncPn2KAS/vvr4ZH2KESp4LgawFJ3jxOED6jJRWbactKgmkTABU60bX
	 7zCl2YnFwyWjoXi+Jek51fkADJqftonNPO+qWtF59k04qJDVDzjlTmoyMZq8/KKqO7HVU
	 6LfZ2PG5Z17Oo9905MrfGhR5R9e5R6xXSQykQxqMh20XsbY6CjFnEdSqe17e/Eet2pw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ZrzhcgSQ;
	arc=none smtp.remote-ip=209.85.210.45
Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FBA4606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 19:34:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4FBA4606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ZrzhcgSQ
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-85d363fb73cso15446a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:34:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793302467; x=1793907267; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=PuLVebBATEeqqyn/PldQ4dGyEDIrLVXFLW5fCfzk680=;
        b=ZrzhcgSQygD274THC+YgR0ETYxRxxDuMXEEgdEkH9GGU8Atz8X8LERap+44pyynuRB
         rfspesTVWpd7OTG2O5D7zRHGcxkTJko3pHywU4F67goYYHDlHjtzGJL3looKRWyMp81O
         KkBcmn6N/ADjeEWMaigTciTTIbiar8ACavqNw3tVHDVgr0IKe7fH85Fe1Ef2udwFDgYa
         fRUD2U9xZA3mBUlMDHqLG6taJe2xgwsATPpy1MV0/gojXQmpSMqSFh4OthalDX/Ps3kv
         oR7G15PxE32f07xOtUA+poXU+7GXy5o2OYP+/baqLjXUrA80FFYygFcHUx3IICcBVBh4
         exbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793302467; x=1793907267;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=PuLVebBATEeqqyn/PldQ4dGyEDIrLVXFLW5fCfzk680=;
        b=Pltx9ZeNKAl4MWpn8R3js1n5R6/Iv0oe1f1lRUU1iK/karKWZLlLDu0zAe+5N7k5Pd
         OsQW0EiNXieiCNlgjwLAS1Ff2l2ZcLUfvpgK5aXqyCbS/Jp/0Rg93RmCAHmXcFXCHOan
         xcP1HNKEHOWJMOL+peGCRamIh65LHJ/0xI+hmMCWGX2c84HeeQ7azEvvcxzEDGGFb2jS
         qz5oNYldS2JoqLFpSNHyTLnA8zpaaTYDd8ul+3nXlpP+NWH0ClgYHDADnM3SZFGh0UWg
         a/2/irzOAg5Z5ydud51PLOJ1KS2wgQX/3gQwTzGHXBpt0B8I4T6glzKNczsI+0mnEiBp
         c6rQ==
X-Gm-Message-State: AFq9FYIaV7aPECyRQeIgdIUVlOK7IVhpVw8jRB7yjwW1EAY/wuapRuyj
	K3GC/xc0yBs41EZluOHL/uD5UwwbJKdq2eKeZL80DfXMC7IFZiwfQLVww+sf0ehFYyIF9Y4JCMg
	AfNYd
X-Gm-Gg: AYBFou2AoZa13Sy5OcFFQueIHYmUiDJSrYZTMXLHK366rQLZ72R89631f9gDtvMRcw7
	sAQgjSMwRFtJFfaJSq4HBGX8ir3TnVbFempe8xwpYxqhD1aosVZ/vYj9Lg4UcjQ9Mon1HhjC/3C
	VXKWOzjylMpWQe8oDT0XwrZWdROS3NzEShfph/NqKxbE8i2FloRUtHT4t626wGIbsWASzcBETcE
	EDzst61Hcv+eZqLsrwgBhbbhIPpJnhmwYj8F5L+jUBZz8NbR6tkIgmwy0VY+fAXor9Ft6+Xcvtz
	2WB4jadxHI+pQF31Xb5qihpgf1oGNk4NaKMhE07tEvj23a2MGxIixTkhiEk6DIg2vm5TkuDHB2m
	Te+E/KNG10p8LiL3zv8NOuHieD/T+U1aS6XTGIKmo4N0c9ofaSZI9aafoPvnjJZ2VabqHcSlei5
	nEngykJA/jtZtbNPK6i272mhwzIeNnbob4CTWuDAoZoJboAxQ4ZRn8kwAnVKVxaH8CgcScnCvpW
	L0Qk82KTTivKOSfLTZjwb6xPkBBnXw8t9TvPWNJf3CN3tZ1V7fhz0ltLtOiyMzYiot/aAlt3PvB
	OiR5wfJrmzf4HvIPfOnMT1NWJ7O1EmTaa+qNXYZDcllZ1k0EkFJOZrQzxxn75I2cUSTVzQUdYiO
	x
X-Received: by 2002:a05:6808:1925:b0:4c3:4e34:c69e with SMTP id 5614622812f47-5640d919f60mr292478b6e.8.1793302467138;
        Thu, 29 Oct 2026 12:34:27 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e37d046sm107380b6e.15.2026.10.29.12.34.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 12:34:26 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v3 2/2] pnfs/blocklayout: report data lost to a failed LAYOUTCOMMIT
Date: Thu, 29 Oct 2026 15:34:21 -0400
Message-ID: <054f354ecaa596514da593698461206e356004ac.1793302358.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793302358.git.bcodding@hammerspace.com>
References: <cover.1793302358.git.bcodding@hammerspace.com>
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
mapping's writeback error and the superblock's.  close() already checks
the writeback error after nfs_wb_all(), but nfs_file_fsync() checks it
in nfs_file_fsync_commit(), before pnfs_sync_inode() sends the
LAYOUTCOMMIT, so check the file again after pnfs_sync_inode().

Fixes: b2be7811dd94 ("pnfsblock: cleanup_layoutcommit")
Suggested-by: Daejun Park <daejun7.park@samsung.com>
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/extent_tree.c | 14 +++++++++++---
 fs/nfs/file.c                    |  3 +++
 2 files changed, 14 insertions(+), 3 deletions(-)

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
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e1bdd10b35f1..59174ffed242 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -277,6 +277,9 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		if (ret != 0)
 			break;
 		ret = pnfs_sync_inode(inode, !!datasync);
+		if (ret != 0)
+			break;
+		ret = file_check_and_advance_wb_err(file);
 		if (ret != 0)
 			break;
 		nredirtied = atomic_long_read(&nfsi->redirtied_pages);
-- 
2.53.0

