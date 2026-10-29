Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299326;
	b=wfxerlATVPXkKuHx3hSaXMHePiceBM4ZEzg9jYzaWsdE016kBB27MdRK5gzDznok+new
	 /UgijUwH1Vu2b9vp45yTZ+0GOH1pEovBdV/Zc9f6L9Uig3qUw6FaYD0KEkyQ+Urh2GUQg
	 BSNg6Jk0wv6BZq88r1+fVvROmFalL6uowRWdanirRHmj3dIQEqYLuC3qLPZWCSNynBj41
	 rAbXQE1laiRey08XAeeIxU/pXrfRlW2Uwb07MVdxZqi/ds7UR3u5+wGqeuyTciezhXsgI
	 euYz5DUmXQjJgp27lkw+6rh1HD4ARyCBYbyVeJ5hX1B6v5dMeY+Mo5Aik503fFE+OZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299326;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=YP5POTH957Ok72zkzvdfxY9vFeDTk8mx2hSjr4M8ywM=;
	b=bsqtTJwDKEmgyDZEzXpQE4N50st5HUke1zrfzm4q6SturI2eDQn1saqwwjrqzJsYTQ/3
	 Rfishfx9E/RSmcnLvVFcyuHn+5RCxpiY/SA5VHq1irClL/yRu6pA7cKeiggF0Ud5qJDb+
	 H0XsOs++xuyb8ZxbMmFkEf5EKzh/SqDNHc7W/FbebNbZWSkexvVBZQA1sKTdJ4Kmp15BM
	 BfU6Sk0LqxHW8gyROvtUlYRTSSXq8WHsC/KtGaJkchwf9bkuZspVTBtPC0dT/RLVjdOCL
	 Y5eh7aCqBIDc0VY8cmqWQmBC4BDIKZkEfbCQy8SqtLi1dm37dwLRwrBBXor8nWHQF0w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=oNz628fy;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98432606A320
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:42:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 98432606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=oNz628fy
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-84d5e56f876so1746510a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:42:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299324; x=1793904124; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=YP5POTH957Ok72zkzvdfxY9vFeDTk8mx2hSjr4M8ywM=;
        b=oNz628fywp6ZbFxgyqKa04pW6w8KivU9fOUDLGAkrtKmeq10TCnzsDntq0pWGw55F0
         k9j5BqJJKBD76Z/8SamYjz6+JpqAryw5WKV4NU7o7Kdp2DsdTlF0/dBY9H+w4VtGd7b4
         xWxAlAY75oWgcIQ5M3cZNG2olS/hfND+eueNFIbeJh/hhVD9JcpV26+12B+JdfwhHUCV
         Z1jl6wwOECFDQvq5lWOULo+sseOUdfm3lRM09D6RSTvO3dxuAkZ/3ACgYHeA7htlEEbe
         qgTQWyloEvUifUi2nb5237mDWIBk7zS5s75ajNspYKqz1tQCVrsyWmbFl2370iatNhGZ
         XImQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299324; x=1793904124;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=YP5POTH957Ok72zkzvdfxY9vFeDTk8mx2hSjr4M8ywM=;
        b=CHbuvFnq2Eb3YwjNa4z6PzmEzlrYdOl++H6SVfYgqiPGnrfj8Xg5xtfGO34HP33i1e
         /1H3K1dPajvzBsioftQjGiaLkGUHMsXPLjWNI87RkL/LYu8BXGwKHBUU4jSeyvv35QOO
         KNwzUgjwTl5WAYu3KelBXv5mPm4Pp4RQtPclzbqGwOrsOjcW4T2Ljug/R2EohHHy4j20
         WFOYoKqMhX3vvi4C3TF6iLQ+UZAg86797UCeCmBMhX1MO6a3Avx2NgGYgC31WGyMthdn
         Y9yexj8/3BFgub3Aje3BGEajKZo629+u04VsKiOUyReEGzPZpmGESM7Ynm4o83wEcWt3
         al6g==
X-Gm-Message-State: AFq9FYLS9P9vgBuD9XayGCaPKqjiJ5/YXH3Ffb76ul1YEF32h/BGroyH
	/5+xsKxwaZAirIqrNdY4mMUoDW5Cnc1s/P8opN+uSlTquGcXOqNNlW12K6c4uuYuMjY=
X-Gm-Gg: AYBFou0anhtmqCIdU1pSkvgkclON60Wc9d8bA3kfejCa8EpZ/OFOwN6hrqFoFACu0xs
	V+at8Xq2fLvdYKoVN9sKCrx1zqCHMS0Ivbvrm7GomjuoJLLa2bT85UeYyqoGE6x8YZhV2hWH6ZX
	Cxx+O9yuOU6sx0qAG3f+FxhPwy5PuVkXCM5XfWEYYAvpBei1V0/iOC/lZNf6kR+gtUWKcAAd/ON
	hOIeJh/UrHyBqyPcnkMRJuapYy3QDD+m5d5oOLLj++sYeB+4H81e1s6Xil7y2OafCv4LQTPTwNL
	jC3QBPgq3mKVRuvasVx1jFhxK8U4XseFC3iy6ig0fWiiny+QcwTaTna9iWeYAFQwYpaDdtYd3m/
	H9joOM6VKr4kGf151LGwu7NHWqX6hlQnodQhQiFhN5IJRVeEPyzTHtYmMykZyUS8L3h6Ho19l17
	sg1B6Y7fmuSc1mVE1I6fYOXwlKHrA0G+ByGCpfjTfmAaSIjeNqmIQH1CwlN4FoarmpD/Xjwk9AL
	PqYBRpUh/UVYGqrhAbXKBv2cEvVdYpSJga+AAkPRPEl8tiYP/brDh6Y3ZRn4MyUaM8n3xcK4VF9
	WNoj3q/IdmZaE3umbVDWSc7NiDOFJxOEzqp/ISvcc3L6VmX94O7KbFEeliGBNWb3CAp2l38MkDq
	P6p1rTVZnvWVrZ4XN20n3Nw==
X-Received: by 2002:a05:6808:5390:b0:4b9:e65b:8c31 with SMTP id 5614622812f47-5640ddbdcb9mr62678b6e.31.1793299324074;
        Thu, 29 Oct 2026 11:42:04 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.42.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:42:03 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] pNFS/flexfiles: write through the MDS while a recalled layout drains
Date: Thu, 29 Oct 2026 14:41:54 -0400
Message-ID: <5e0eda7713c22a6646a387a98106e8de437a4bd9.1793298149.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793298149.git.bcodding@hammerspace.com>
References: <cover.1793298149.git.bcodding@hammerspace.com>
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
index 27322b6f0d0a..a0f424893b66 100644
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

