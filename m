Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374234;
	b=BMSh6FH5sxEKDSqh3/Doz2fP8B95d8Clr8J8dhsNlYrWnuH8NJ+Jp7VddN7MggSNPlXc
	 bKfwfjqaulYAQFjR4IuvLLUlIUtTQaFKJ5u69cDG1e2c0+xE+ChBGHtaquSYaBqKFj8DL
	 JT84NeLJPIE/3HWss1XVJgtMwJjb9EWrWSEmrCTvIn2goFagWR0XeeoueUJH6F21+RFxU
	 gRywBVaM4sYxVssiVetMpjxmruzBvd0zb7DzWRA7o5buFs5BEtr4+cyqAXsqNx3O9Km/Z
	 OfQ8iuy+1bNzWkmzM8Y6Y9ZnUoSgxVycGiIbJdUEM4n6c/6C115kwNGx+cnQmzJ34VA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374234;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=sS2XK6x44s2LZ5cw7jz9/RsCVGClFMSfZGP0rtBAbDI=;
	b=g+pjqfluWI7EXGJGEQhEmbIQTImjxKMpp5Pzg9BtO2s7TrYb/WCOLTal6mefQjJrR8ot
	 f5P0jjBDhK3m6/tZuSq+2fvjS86QU7V9KgUYHrh/ds6q0Y6Kk8+C0T+lpOS0NWfLtow7C
	 ZrTL9tjR5U8zBs0I7IdYgZc9amJXfcF93P6On2UGyd3jk0SdEUVFJBn/Pa84fC0Eksrg2
	 oT4NZddoLNpRAKmLhHSBEhpV0Jh7FaLnyweDKrzx7sRNPz4T51DDlF+Mza9oij/Z65hfd
	 yDAVPPjBVrq25Xz6eQg+YvYsnz0g7LsoTGT2um2Sa0B0T50sLRtw1KLG/fAqApI5csA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=BQFvwNWz;
	arc=none smtp.remote-ip=209.85.167.180
Received: from mail-oi1-f180.google.com (mail-oi1-f180.google.com [209.85.167.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6053A606A32E
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6053A606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=BQFvwNWz
Received: by mail-oi1-f180.google.com with SMTP id 5614622812f47-53c156ba662so445696b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374233; x=1793979033; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=sS2XK6x44s2LZ5cw7jz9/RsCVGClFMSfZGP0rtBAbDI=;
        b=BQFvwNWz/JlqFxWCXSvu5mhmAepwNkwlsqLPjlc5rfMkaa7RICvYcuqhsa3aWDx2ia
         xnKZNxDApINCeMI/YCYxkc2c/Z84vqt5Gy8WHGz2diJRgylFQJJR/i/WQDzayFN2PcTL
         sEpE6za4dW3xROLwCNtiZl7sHYdXOFic6Yf2rQa9Yvv593pkP2gdFeonbA2J0p+m+JC9
         TEppqfgYocGDZ3fCtRr6RdHawOiW9J3zJJbSyN8dFQOgWJzR8JgfV5V3QiUCNZY2KLqU
         LvFy/sR6ni82r1bPmPpz6mz5Xqizp9cDdwCV4UEfmcGA8tc1WOW1DzHmzqL+vkmXB0yq
         jIAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374233; x=1793979033;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sS2XK6x44s2LZ5cw7jz9/RsCVGClFMSfZGP0rtBAbDI=;
        b=roaedc/mkRuEU6aGcZoVWSo8ZlG1DzznaKAVFftLvpGv9htAXax3fhGfn8SUDHugcx
         0vUcZiejY8dzwEHhRPuamNzkzPDc7JKn0EYUgxHyx1nhpoBHdWEMkL3Y5LtOk0oIR/Es
         JZwBL7orD+mEIZ4jILiBILk1ZUVCZJXREOiqU2iUqsvQ+2O4rlqVR3yUaNuZPXA5nSiG
         VTJo2wqo5vU4+gFMWnp2985mK8u4Nu38UP/qtSMv3gn0ZqmR7ycWNR7Ljge9OQIkxw32
         n7MGxrbbtl0L5uRjmkSaSoG5rOj9dzIBLOKN9yRQuVz5KHyIAatt39LfqXTumbZEGzDS
         BTzg==
X-Gm-Message-State: AFq9FYLyzNMPEyeLKGOf2vKw+mUwnID8j41TwyAXOgPDGbOLqwSQwivk
	tKDGunUCzdpkiUq57vyQuz1UYQsn5ZtarTPMFF6Im7LuiQyz3MSoWiVsiL7yZXRa2es=
X-Gm-Gg: AYBFou0zXmM91gN+XeKcuszn8CHCU4eWqu8aMKsI2qc89SZmUj+OLzvUaArJ5VYkZ+d
	G9SCydTMAdKppIoe/3DTBgDKnd6LEa3Kf4B3QF5WCW6c/nmkb4HdaGbCsJVESEQEqb54yo/k2BP
	+x9O4HRWsLV/uwW6k9PxgfZQKZ73Lj3PADE5ZFOXIudWkDR0jZHmvKXLIJzfj9DRnbTn3K3D4tU
	S46smZKJ7Gq9Aswosu/v6KJMmLNZak/uINpRj/7EgYu58IMlLPyiq617oUojx8Qbeju82hRXjdj
	Vi7lKY+dJwr4m5PAzNV2xXNtTfvnrO2LT85hOLW1vdvF3fKEOh5o2Sm/4f7rnoJe6q0oqldNfQp
	UXeXJ7prfMy2LfvIJT3KwX0SKVGzezyfPzdUZjqzC9h55pIBUby26cKXriHDc5R2QsYoBkqEE7t
	OLjbWVuZ4AXWndrrm2ddSNYodHhQ/RZAtJQnAjI3EFk8tf3eRkfiVdbHS2Efw64OgrXcUQCLkZh
	sbDa5tqgNgtagvFgyDJANsFa/NlX/2eGwZKSjT8qWT423cU2RHsHTSAqR3PAW/46WVIJJttjYR/
	dksgjz2XQylHz2fbwCtclIYiCBK8hx1SBgO2X7ZS0AVslTzMZfAFhU+EjqwaXrA2Ld78TcAUKyH
	7YDL9H6IyKpRYE/DqhRGPYLvf5w7GXwc=
X-Received: by 2002:a05:6808:c40a:b0:4e8:721f:2824 with SMTP id 5614622812f47-5640df45e10mr1741736b6e.60.1793374232954;
        Fri, 30 Oct 2026 08:30:32 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:32 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/6] pNFS/flexfiles: write through the MDS while a recalled layout drains
Date: Fri, 30 Oct 2026 11:30:22 -0400
Message-ID: <19211fc88f00f39a513bb1380e4675c066611bf8.1793373378.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com>
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

When a layout carries FF_FLAGS_NO_IO_THRU_MDS and pnfs_update_layout()
returns no layout, ff_layout_pg_get_mirror_count_write() returns -EAGAIN,
and nfs_writepages() and the O_DIRECT reschedule path retry the write at
once.  pnfs_update_layout() returns no layout while NFS_LAYOUT_BULK_RECALL
is set, which lasts until the I/O on a recalled layout completes, so
writers spin for as long as that takes.

FF_FLAGS_NO_IO_THRU_MDS is a hint (RFC 8435, section 5.1.2), so while a
recall is draining, write through the MDS instead.

Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 ++++-
 fs/nfs/pnfs.c                          | 19 +++++++++++++++++++
 fs/nfs/pnfs.h                          |  1 +
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9492d6bc1d1a..9777c83645ad 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1222,11 +1222,14 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 			NFS_I(pgio->pg_inode)->layout,
 			pgio->pg_lseg);
 	if (NFS_I(pgio->pg_inode)->layout &&
-	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
+	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout) &&
+	    !pnfs_layout_recall_draining(pgio->pg_inode)) {
 		/*
 		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
 		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
 		 * retries rather than silently issuing the WRITE via MDS.
+		 * The flag is a hint (RFC 8435 5.1.2), so don't wait for a
+		 * draining recall.
 		 */
 		pgio->pg_error = -EAGAIN;
 		goto out;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b0bdd40de4dd..ea87e95f1083 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -593,6 +593,25 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 }
 
+/**
+ * pnfs_layout_recall_draining - check for a recalled layout still in use
+ * @inode: inode to check
+ *
+ * Returns true while I/O on a recalled layout keeps LAYOUTGET blocked.
+ */
+bool pnfs_layout_recall_draining(struct inode *inode)
+{
+	struct pnfs_layout_hdr *lo;
+	bool ret;
+
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	ret = lo && test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(pnfs_layout_recall_draining);
+
 static bool
 pnfs_cache_lseg_for_layoutreturn(struct pnfs_layout_hdr *lo,
 		struct pnfs_layout_segment *lseg)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0fb3c7fd8a27..2a4a1d7699f1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -310,6 +310,7 @@ bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 		struct pnfs_layout_range *dst_range,
 		struct inode *inode);
 void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
+bool pnfs_layout_recall_draining(struct inode *inode);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
 			     const struct cred *cred,
-- 
2.53.0

