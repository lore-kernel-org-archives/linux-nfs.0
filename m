Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0627B493635
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329779; cv=none; b=fX1P0/zXZzlaa+rRfj0Xee5/aSgZl6h9mvdPSum/pSBlRHRpHP3eMM6JGWFsY8r7iD5N9TbHS0qvFaWDFu85WX0MDnZFcy2i0TNglQo8lYfKK1DCRNuf00zy8/ttAXWhcBG39r/h/Tr3VxRbnUEWNP+JNs1r890NvAjKBYX6Ye4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329779; c=relaxed/simple;
	bh=vmu0tEb4qcyOrlu5kXJnOphkT0IlZRFzSiAPB6rAtRM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=o+PtBM/eGHstOWq3HEO2PXo4uWZTKn3VIpJaKLr9a7djYKI7mgTiRKIr4DkP2tpe6RuW27OFIZeTTgNyXJ9ibtabEImKq0JvnauEOkCTgEDB1H71twxy9lh7ZfAzgfSfjEndwdYT0rtobH+/DahCkj+g6FsL9t5OzUQwV3VjQA0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=QOKiHlgE; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="QOKiHlgE"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4a40bcc8d69so1024822b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329777; x=1787934577; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=3eUQYEOqt4TQ9JlCh7GuqokMETaZtrWfS4n+rNm3FyA=;
        b=QOKiHlgEOPfQ2Iv8eXFHloI7bNMlm52u7nP1rNz4yL9rhl8Za6OSJnpzes6z2HmhIb
         lsldsK40vz4XoMbK23N/ad35E0qb3BmixiOX9pwP8eftil+cXLxPKCzcU1c5qWNuOyXk
         kUZjYmh4m2CxnhGV59YH/MlcXfFzhq2N9P/DUxUfDZ0Xv+R60lTBpxSKP+X9cdiV9BiO
         wSs7jzRa5/p0OQlg8qC5hnWMGnxhiAUQ3sP9PqeNRkd+ydMVKzLAN3EzVC/t8T4Dns49
         5FiFVu2JxQKQCU5BUizVfDeEVH9WuocSJZZ4LqAt8w9uGmBaLJpSLeWo16M5J+v4sp5G
         9jZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329777; x=1787934577;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=3eUQYEOqt4TQ9JlCh7GuqokMETaZtrWfS4n+rNm3FyA=;
        b=fowWawIpbxlemVtUOkRGWXdv/doASTlZboKhEJakDBnJfF3Oiy8aoNUtpOJHn3xlXc
         +TRrCGJWdZue5TTOZ1eMNuqalRhmlgHc0LlTssumWlqLUQg4vYm5GbJkPcWvCFrz7rNr
         T21/FjKQJZDkiQg5OTduUOBzel4C8wDYpQCGVI7ec07BnPzlaQ1OSHVqYN36rE3L+9Fk
         tmDfTMzV2MMSzMItGXhglO87a8U6p0UNCbuzAre7ebcbZbdLLUH8SgqJyJcah3CbvulN
         ndPvCrC0UOjCGLkoaiJDQ4GQ24CsiZFsXp1nhBRHU0QhMkfJ+N0uCaQwvHOlkmOeigs8
         N59w==
X-Gm-Message-State: AOJu0Yy1/oGRNkFOx/p10S+GV6qkV0Ueyksi4ayiqQYpJe3Bu3lQQ0h1
	0N0UmxBLV4WxwHYMiT47ByIlKQPKWYVHZx3AObL+GomlRysRWvBUmrzVlig3umsr/NU=
X-Gm-Gg: AR+sD10lRt//hLRSDUpiNp+rgtxCs03xV66XPQyeCI1j5qTfmm4lMz5PqnxwhIQ5A1k
	bpheExJl4oKXvk9typXYuwyYgaJLu5A43BOmYt2wJj9jDm48Np+s84ZDyMfNpSf+8Sx20H7f4iP
	QXWEgm7ZZAknLjVaJMU/a9CK4uRiuq267S/KA5aLbdcoVfmd+c029bT85HikWSydC01WUEAl+fU
	LGFbH5fD9lwE6sbog85HXcEzlATR0RrNjPSIZ7dMxcWNnh0CQf6zc/lqv0O0brqi5+SV5wBTo4J
	OV50GodD7nadpy1KF9LBHZGSO9UmXb9CbQMOJ8evk+VgI3P3LuYyXChFeX6p8bdHmfbR8mazlVf
	h8K6MS+umdkHYuu+gUp8nAtSyZkhCFCzaCYG4dMABKpCfeL7vm3El90dzw4ea0+Mok8wJE9/++m
	SXTW3DROakYRBLxnXdsx3YQYVbcS1ZF/gwQCcCFKwrjR0CSbW5qo5P/U7raV+V6VbUmE/Hxi61B
	fz9L2Rql8RwFm5Wm81OemLe
X-Received: by 2002:a05:6808:524c:b0:4b2:5529:ed3c with SMTP id 5614622812f47-4b2ef23b082mr8728852b6e.7.1787329776684;
        Fri, 21 Aug 2026 09:29:36 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:35 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 05/23] NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
Date: Fri, 21 Aug 2026 12:29:09 -0400
Message-ID: <cdb5e053bb296b467d1890b6ddccd3664486bcc0.1787327939.git.bcodding@hammerspace.com>
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

ff_layout_pg_test() was copied from the files layout, which partitions
data servers relative to pattern_offset and bounds coalescing with a
segment-relative offset.  Flexfiles has no pattern_offset:
nfs4_ff_layout_calc_dss_id() partitions on the absolute file offset
(RFC 8435 Section 6).  So when a layout segment's offset is not
stripe-unit-aligned, the segment-relative coalescing window is shifted
off the absolute stripe grid and a coalesced I/O can straddle a stripe
boundary, sending the bytes past it to the wrong data server.

Bound coalescing on the absolute offset to match calc_dss_id().  Aligned
segments, including all whole-file layouts, are unchanged.

Fixes: 4934ccbeaed3 ("NFSv4/flexfiles: Read path updates for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 6db8de2b1fb3..46f9b528eb5d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -999,7 +999,6 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	unsigned int size;
 	u64 p_stripe, r_stripe;
 	u32 stripe_offset;
-	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
 	u32 stripe_unit = FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
@@ -1011,8 +1010,8 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 
 	/* see if req and prev are in the same stripe */
 	if (prev) {
-		p_stripe = (u64)req_offset(prev) - segment_offset;
-		r_stripe = (u64)req_offset(req) - segment_offset;
+		p_stripe = (u64)req_offset(prev);
+		r_stripe = (u64)req_offset(req);
 		do_div(p_stripe, stripe_unit);
 		do_div(r_stripe, stripe_unit);
 
@@ -1021,7 +1020,7 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	div_u64_rem((u64)req_offset(req) - segment_offset,
+	div_u64_rem((u64)req_offset(req),
 			stripe_unit,
 			&stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
-- 
2.53.0

