Received: from mail-pz2-f39.google.com (mail-pz2-f39.google.com [74.125.228.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F9463D410C
	for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2026 09:45:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790502341; cv=none; b=oL+OxyxglStK/lRdqtjoS35OXPSBJ1BMc6Yzg5sZxHKvDFPJpislPwSBaNd/DiFoc37l/39jlLOlwE06KhD5qtdIeLd8OEFZEps/VWR70lp4b6EnHcV1GRFVOxCEX5GqKDRG+xfhxdnS7zG75lPJobqLjzRZkwfAjtG+gQlJna8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790502341; c=relaxed/simple;
	bh=tax8JMiviEXQQXZx8r3+hVtfjUs+GKtkWSm4PU5xCJo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bg3Ljyj7hBYSYxN4ue2GdNwRuwGmbkD4UdzfTWuiHPVEHMatQJnwt2/phHKM5aip5+2SgEOUSXMN2CG1/OHwykp2lGMKJtj4VOoPuF2qLf7cgs9B+TrN+Jx4OBNZwojSCqNcMGDAxTQ95Bu4CDJsMpvWmcR6boSWC4XVzcc2Kt4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=YaPiCJAN; arc=none smtp.client-ip=74.125.228.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YaPiCJAN"
Received: by mail-pz2-f39.google.com with SMTP id d2e1a72fcca58-88103e47f72so1044589b3a.2
        for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2026 02:45:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790502339; x=1791107139; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=WW03v5grmvf8mOWn+UC1EtDiLQQpdA7r8LHu21l4O94=;
        b=YaPiCJANHqirSJ6pn0t3fsx59mZ2lfQeMrtEiFgu9OtYc8v1Sm4Pwnf+NICNfAYhCH
         3LUcpVC8EcPRr+AQYC/ADdJe4TVEbrBoptYuINucgFgLMDaXQwarvSSi1Gc+diuaYHNa
         X6MzcAFdpUxDMG6fzEEH6lm6WtnIJr+PaHtvAIajYI43cW4GbtCbqITtMe3AHgIfSxat
         iCR11Om4Ue1uiP7R10qpG4TtDQzSCdf76ikuPQMZK91YTuuK/gZZZtc2m2A0jul0pDcX
         RGoBQEz+aCmyizt/M1Srl0lOIWNYKkl48iX04O94yYsJc7u/5y8XYb02Ve6sHNrQcitK
         cl0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790502339; x=1791107139;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WW03v5grmvf8mOWn+UC1EtDiLQQpdA7r8LHu21l4O94=;
        b=oQMswLHklBEClpsRiec2/G46AXmeFsiR/vEt1X6lmTZF4M26LlJUrUiFqgOfutKFkk
         GERuMByQhlX+XbLTwz9EZLIBbP8JLCjE0T6FBxRRDOxY6/xq4+l7x4NYvF/NjLhNdOLY
         XCkSy5ex+Ee6cQ8WuBTqyoSXmWjSzizvD/giH6YvFMjjuWDBvHswK6QkjN2TF+Fnn1AP
         lns9iofodndgJ/EKvllD288eLIoLz33cOfSqgznW0ER18e9qKyWy/kzxFToj/QJSWyac
         cWpgk50KN6ueNhB4V+oyaEVn10FmmKGUsn6zp+8VJIq5Eoi6w73ImCEUTGm4rh5Tphky
         Nhmg==
X-Gm-Message-State: AFuF++kTrB9EWeKUnTN86wdKzu4Q/+me656KlCj7jX6EqJTJSoSf0JYc
	F4NcuO1qr92PzDicLco9e9JTLdGKDP0qs0EYhghte9+RQ0L9obgHE8PU5CmAZ3TEw9v1s0bj
X-Gm-Gg: AYBFou1KUErt4ZAJNVBeBEZ6PzRTz0b1S11LGGo3r20C9UBCXz03+xayqozyAIkgAix
	7RopHn+OhHDh9FObULKgYUdhm801hPVGxkMA8nwIJS6FEHzAyxEc3ukOYIfk7DDtY5KdtfpEOl+
	vdfNOY5bXwtjqmQOzSP8eN5TpP8mWK8EBZXI65HM7zVsv4eV3I7azlqrkHr3kIAz06Dwy4B51Kf
	huvJoVUJvTUvEukSEcUjJxNuitmk2voinO6e67RsncJXXN9FNKnIMirOzkG4ZXxLRzcl4nE+Pa1
	xktSEDEZmA/8bZq/+GbP3nB0ZQdlJamd96MqHkhpcRCRnpoL3POgzpCVzyuaiZfkpyUC78AAG6a
	H5iKRMK0EnLlm1+QmxxLnyX1IVYuroHexgewlFCd5e6BgKaTsY7ubd+f4QfCKayqRDBCqh32wR2
	CeP//L3TshvAx0HVsps88h+uiVVU9+F9EUxOju2UwczvC5UslqGA98Mp4S0EYLWyH0UA==
X-Received: by 2002:a05:6a00:9298:b0:874:706d:856c with SMTP id d2e1a72fcca58-87e9b3b9e0bmr9164617b3a.29.1790502338655;
        Sun, 27 Sep 2026 02:45:38 -0700 (PDT)
Received: from localhost ([8.219.235.175])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-882ad656fdcsm501918b3a.18.2026.09.27.02.45.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 27 Sep 2026 02:45:38 -0700 (PDT)
From: Dairui Zhang <zhangdairui@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Dairui Zhang <zhangdairui@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH] nfsd: fix READ payload landing one page ahead of the XDR accounting
Date: Sun, 27 Sep 2026 17:45:35 +0800
Message-ID: <20260927094535.1745224-1-zhangdairui@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_encode_readv() passes the in-page offset
base = page_len & ~PAGE_MASK to nfsd_iter_read(), which writes the
file data at that offset into *rq_next_page. After each operation
rq_next_page is set to page_ptr + 1, so when the reply stream is
mid-page the data lands one page ahead of where the payload
accounting continues (which stays in the current page at base).
The wire then carries the stale tail of the current page (previous
RPC payloads, since reply pages are reallocated nonzeroed) instead
of the file data: a remote kernel info leak to an authenticated
client, plus silently corrupted READ results.

Trigger: any compound where a READ follows an op that left the
stream mid-page, e.g. [PUTFH, READ(100), READ(N)] or READDIR+READ.

When base is nonzero, place the data in the page the accounting is
filling (page_ptr) instead of one page ahead.

Fixes: ed4a567a179e ("NFSD: Update rq_next_page between COMPOUND operations")
Reported-by: Dairui Zhang <zhangdairui@gmail.com>
Assisted-by: LLM
Cc: stable@vger.kernel.org
Signed-off-by: Dairui Zhang <zhangdairui@gmail.com>
---

From code reading only - no runtime test yet; the trigger compound
is in the commit message. First patch to this list, so if I've
misread the flow somewhere, please tell me.

 fs/nfsd/nfs4xdr.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6a0a97d..17aff48 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4933,6 +4933,15 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
+	/*
+	 * rq_next_page only tracks full pages. When the reply stream is
+	 * mid-page, the payload accounting continues in the current page
+	 * at base, so the data must be placed there instead of one page
+	 * ahead.
+	 */
+	if (base)
+		resp->rqstp->rq_next_page = xdr->page_ptr;
+
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
 				read->rd_offset, &maxcount, base,
 				&read->rd_eof);
-- 
2.53.0

