Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795109108;
	b=CBWsQTUZXjz5SVg/q2YlFHmZVt2zuhdKdjhyhK157ARENqts5wWP/HWGpAnYdSyJa7/l
	 eVOx4VP7j4s8RlzDo6v4rFnhIqYX/6bVX+Y9jVNIkn4ev/v8KY13EN5c377ENxXGEYY4f
	 8yHPMEweop98JptCUFO3N18nWnsG0Z7KE7aicQ+o3cr8VT+7XA9NqyMQzgj8Eju5yyEv8
	 bQfBN/s0KgRQjNbeeJJZtVVzS2uKgNZKu7ngHqEtLEW9bmm0eFbdUu406bg/mfZAtIi8P
	 aHAgEiLKVXGFt5TSBkMZsIeqOUYWUH3VV3J3UOHcnMurziyxMGPkh/26ck58HQ2vcXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795109108;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=1rcHE5CHzsVMtMuDdojH02EloAWT+8I+vlusNK/i0ns=;
	b=Yo1KkWyvR+iYptiJDrVtulGN81IOD2Fcw3ecfllaxFte+0vapRjFSdmk3eGw3S3sEPhE
	 y93eIpSOq1Kd/g2VJ/tx9AtmOGGtq3NYDWaj3ULKDzN/PLqMz/ANcuVwnZCfnq2a465Zz
	 ZwkKCB7Rc3ONXlNmjEXrk8vJGWbTgby5bRiB8PTGuVmqonIyvyAQjyvo/Oq+2Y0JNFpE2
	 fmaOS+dHE88D35Z5Eeup7kBIhYjJE/Or9srvKN3kYeVP2e+S/nQRXtYExeiySqU8A5aEv
	 ZBm7oOJrBBueCwSIguCax6E+3DfdYBg1nMCNm14CWGa0k5jSooK9pADeVI1n942wyFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=EzYmHSQH;
	arc=none smtp.remote-ip=209.85.161.51
Received: from mail-oo1-f51.google.com (mail-oo1-f51.google.com [209.85.161.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 875A6606A325
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:25:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 875A6606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=EzYmHSQH
Received: by mail-oo1-f51.google.com with SMTP id 006d021491bc7-705cb6ceebaso2024262eaf.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 09:25:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795109105; x=1795713905; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=1rcHE5CHzsVMtMuDdojH02EloAWT+8I+vlusNK/i0ns=;
        b=EzYmHSQHDY1iEt1zOdKZ3BrnY3gJ+VBBlonPfCHMGgvLbX2V23a30Pu3tIfJSSwkuJ
         WurrGH6TTW7DMOAjJI6NJg7+R57Byz52z4yCS1dASxzATe05vWPnszMVS3zZLV1gt8Yk
         gBZQUEsQHRFPz1VCx1wX9QP8GDRkL1FJ6r82tyJjd1ePkG/QIufgCpPGVzkyvotTsgeV
         8gXlQ9xzuSoFsaiTqqlCxKo5FbdTFJ5pRJRsRIoY7DlXQmCA1eKDBD0vI7b20ByiOKA2
         j2B0LdAhIRYb3L4U2g8Us1aE0VNW4KXy6ITYIB4beMzxf6JYQbiQhCVdHR2azqQ0cVbb
         JQcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795109105; x=1795713905;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=1rcHE5CHzsVMtMuDdojH02EloAWT+8I+vlusNK/i0ns=;
        b=m1vPHutlgpH1n1CCRrn1BPhtNSACPxYtOOkHUaOoIqeCLRK7tGr2tngqi7u4ScnsOg
         68IA9eZ/LkDLstfzmhNGqFTuXRZw8z71zwc5YflcZUDgtvEBDyg8jXnf7DbwC/gnlcrS
         I1vVcD1M2MCKXMsty/bS94wFnsf2rW+FL4f6CqvInNxYfa5ZLxIq7uTt+HhS/swfuvVO
         U6tGg+DH4KZbkCLY3u36ToPJsJle6kBlcauHRXm1+cftrfBHUfNudF20zvT4fliwmkVf
         mv8m+Khgibqa2ht2vRN3KC2mt3aa80rF1Bw9yXD68EPQPSbl8haJ1rtLHLhjDx72Cy88
         sDaA==
X-Gm-Message-State: APuU4Z8FOQkKEYC4RjX4sFwH+BjjPgLJP1zuQBT2YdBSyDgEwingVC0x
	GUzNM36k//ktR+g+NlYOf+MrYB4kk+DabcyQLXuqQ9dGKB97CUB6jLLxl5SnIgYHe0SMsMVmCAM
	tqfMB
X-Gm-Gg: AYBFou2UxgqYhWZPHp3gmuW9BoKZe6l1U5tghXP+FjX/d8cpB61XwOZnwgF/uZXi7o7
	deAunE/m8+qr8O1calJScSn/NtTYNIxrJFHirEl1SmSYS/fENhqXYLQ0A4DZcG+4+/Z0BCdP77i
	dMkJe3N08uHBUX2E8liqOTU93VGF74jkH/dxWfYGe0XPxzubME8mDC0yLGm2oDIWLGeJJ+1JTEN
	4ijBHqOw9X0j8hxw/t0xBYj9qJrfyPxIauWxOqyc0DKEpkGiiR0d2Yw+80vn3lWFZoAQ4gM7A87
	Qs0EpHhBUP4OVBqaYAu7L2bH3dY45BOaJ7y5fwg67c8YY5Ajj8azUvLBv1qsNuUPMrdr86GbmDR
	bfIkG7sOe6x3VLKtLejeJiv7VUpuqP/oJ7f+Xcvw0Era9G5TtTX4LOV1chOWvdLU1zm9AoNq0Jk
	fwJKM2Rhi/W4hH4ME55847mxtjte7nJaVdGE8oYlIdiRYIxZsQNBHNbRS5Mx5LZtCO1h3i6PoXJ
	jQkAC4MqcmIPjfSfgC4L96PKzraqKSu2Ils0+8XzHqirA5f1MPWgxGwmY7oBoBDegcXgIWR/odh
	loGI+DeRJ0522aSy2bXIR2V06yMWP2FyJ86P2Z5aXFXwE9jMnzb1imdQEzx422AmIODRR3pUL2t
	B
X-Received: by 2002:a05:6820:a746:20b0:71a:ec65:1cbf with SMTP id 006d021491bc7-71b39447e69mr184894eaf.24.1795109105188;
        Thu, 19 Nov 2026 09:25:05 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b380bdff9sm401643eaf.11.2026.11.19.09.25.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 09:25:04 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: read the layout hdr under i_lock in pg_get_mirror_count_write
Date: Thu, 19 Nov 2026 12:25:02 -0500
Message-ID: <23435d398481f51ce2680053cd3a151fe673f91c.1795108831.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
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

When a write has no layout segment, ff_layout_pg_get_mirror_count_write()
reads NFS_I(inode)->layout twice to test the hdr's NO_IO_THRU_MDS bit,
without i_lock and without a reference.  No lseg pins the hdr at that
point, so pnfs_put_layout_hdr() can detach it under i_lock and free it
in between: the bit test then reads freed memory, or the second read
finds NULL and the bit test dereferences it.

Read the pointer once under i_lock and test the bit before dropping it.
The hdr is detached under i_lock before it is freed, so a pointer found
there is still valid.

Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Cc: stable@vger.kernel.org # v7.2+
Reported-by: Sashiko <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/bug/linux-712f3ebb-939d-4967-b9e6-09142f7b68b3
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5c289737366f..a797a2a8e688 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1211,6 +1211,10 @@ static unsigned int
 ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 				    struct nfs_page *req)
 {
+	struct inode *inode = pgio->pg_inode;
+	struct pnfs_layout_hdr *lo;
+	bool no_fallback;
+
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg =
 			pnfs_update_layout(pgio->pg_inode, nfs_req_openctx(req),
@@ -1229,8 +1233,13 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 			0, NFS4_MAX_UINT64, IOMODE_RW,
 			NFS_I(pgio->pg_inode)->layout,
 			pgio->pg_lseg);
-	if (NFS_I(pgio->pg_inode)->layout &&
-	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
+
+	/* No lseg pins the layout hdr, and it is detached under i_lock */
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	no_fallback = lo && ff_layout_hdr_no_fallback_to_mds(lo);
+	spin_unlock(&inode->i_lock);
+	if (no_fallback) {
 		/*
 		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
 		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
-- 
2.53.0

