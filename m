Received: from mail-pz2-f39.google.com (mail-pz2-f39.google.com [74.125.228.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 821FF51D525
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 16:27:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790699278; cv=none; b=VkE/EOxG9K+GBOVfvttbiD/td1NR6ysQRlJjCUGR/QPTQQEp8Jb45MYfwZffIoMxUD4zwurSqwN/FiQ6dMXVUIQKxPftyQAQMPWXmRJz+wqu/ctFNLInAtWKW3VSB2bVAOa1DoXYdBBeB+ZyR6bjodV/KTNgCNsP9Vt2k/Qe2L4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790699278; c=relaxed/simple;
	bh=gq9sRaDwfOSOR9U05J47ThC+bJA+gjzx/O2KwmU30p0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=U7z597W4P+59QrGMwnon3afgPQZJGJ2A/xdpVfp642u4RuUq+B0F3uF82KRjJJ7TV3iS06L8b5dmlwkdATRehDucievx1iAcQECucXTYYEQhZ0pZjhyFX07A61NzsuGrLYjTdVyamfAcivFiz+1Qfl+X5EFkZSAgehwMkrgzmcY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Blqr3WTv; arc=none smtp.client-ip=74.125.228.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Blqr3WTv"
Received: by mail-pz2-f39.google.com with SMTP id 41be03b00d2f7-cc7979d1dadso2243936a12.0
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 09:27:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790699277; x=1791304077; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=nMLJtBtu1McmX8NW+POn2C9MT++VFKrT899CQzM8ZpQ=;
        b=Blqr3WTv1VnJUzfjEe0EGRc76RYO+EoxuO5/+fmfudHKlAjdCc5ROsBt/lYbRaN39O
         oSYSyJAKTecA0Eo1Obz0I+vOO67axZaJ7mFLMXLTouSU3ULyggKq1CwtU1AQXwwt2GI8
         DhwYUIeCNbFrte1d15s84O8ixkB3bKqrPOvSEu/ciLnbr5lFykkx8axFku/MOmUHiga8
         RIIg6aBcmeBx1CB43Sf9Hz4hcZS49eO++DjmQTr5yJq3kYq1ndH0K2V7HWxLd58UJsck
         6rw9ID0MVeEzUjOULd+Sr5OYN5fT4GZi+PBf9XfrZHoy8GwxarTb+uTWnI5Q9z3KCZmx
         bqJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790699277; x=1791304077;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=nMLJtBtu1McmX8NW+POn2C9MT++VFKrT899CQzM8ZpQ=;
        b=d19kB8WvVmK8kwsEpPgHSKYhpFk9Zb00ZsAErJIXoPdpCYpFCwpkI+WIg+NS6x6DX3
         uTW2hOvoWIKsQdv3RKicuwxaJWdvhOCP8gl7FHkWZQ738Gg9258+5+kfA6FD5IYDeL87
         8753heqivK/0FO6xq6NMpq6RjZRt0iWh5/jmvMXh1/l2012IzKcz5pMc2qg1bragd3p9
         AcwJXCRkh6wQMVGHrTWD6Fk1WxZly+pRxyZ0AA5PNm4G6nxRLuCRiRikirFAZNWZ5cLJ
         QRKJAR37MNwjpKpKYGnYPt0gUQ8/EqxVEwHGPJSTFaX5klpf41pFjpyMIVxN7BlRBffc
         dvKQ==
X-Gm-Message-State: AFuF++k6f2Kfr+/m7LTIiLUEas742i8PWyFp4KVv1oAjxJRBwN+t/JIi
	bxh7eszgsg6dNWJXjD/67iEf9jV0jxkBTEUJU5uxp2Wud3dlTx/Whgua
X-Gm-Gg: AYBFou0+SxdXiAWbuWGXNqPwiOWT6TlE0cnFlmIjDO6shNPnpxkaE6UccLocxcU7S72
	wjdN0NOm53OfrNYD26MvCprmuJ/GCwMUJTzo0aXUTd1MDGxpX798tCyqJTePuh5/T9ndZFzgSHx
	VcdvNFbzLnKONniDvQ/1Jtu1mAKLAJenrWYHIllYtdRh8vffj76pK1roMGSWbuW1AbI+Amlfbnv
	oszG+bysJo1PD339m21mf3ewT47yscO8GS+4zucr+5NBZhDdfOJZXSr1ezaOODNONARYvRuPZQA
	HTmm9fS2o09+zDOWyU8gJ2zeuPhpjtd8LLtotbUA5aIu6DLm8tjf8SpZEIZnzcH6nmJjqBmo+7N
	z/dFxwxuCbq56vljTdHB9EyIXz9L4W6ApB+GsLxIP8NeoaaN/n8oNJgXAMvrUZD19N6qlSIuuyC
	X6pInLe5ANvhoZ9/qnoyOYV3pvoV9jXW2pd0rQQ93drYaV+NWMuKrL8B66pe7RRJtcfjM=
X-Received: by 2002:a05:6300:6ccc:10b0:3de:456a:6e02 with SMTP id adf61e73a8af0-3de456a73bfmr5446096637.47.1790699276636;
        Tue, 29 Sep 2026 09:27:56 -0700 (PDT)
Received: from localhost ([8.219.235.175])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cc7d2b2974asm113238a12.11.2026.09.29.09.27.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 09:27:56 -0700 (PDT)
From: Dairui Zhang <zhangdairui@gmail.com>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	stable@vger.kernel.org,
	Dairui Zhang <zhangdairui@gmail.com>
Subject: [PATCH v3] nfsd: fix READ payload landing one page ahead of the XDR accounting
Date: Wed, 30 Sep 2026 00:27:52 +0800
Message-ID: <20260929162752.1895270-1-zhangdairui@gmail.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260928182749.1835924-1-zhangdairui@gmail.com>
References: 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From a4eb1e6b98f6246af5f37ba5bf48b8f8a1a54224 Mon Sep 17 00:00:00 2001
From: Dairui Zhang <zhangdairui@gmail.com>
Date: Tue, 29 Sep 2026 03:14:22 +0800
Subject: [PATCH v3] nfsd: fix READ payload landing one page ahead of the XDR
 accounting

nfsd4_encode_readv() computes the in-page offset
base = page_len & ~PAGE_MASK and passes it to nfsd_iter_read(),
which writes the file data at that offset into *rq_next_page.
After each operation rq_next_page is set to page_ptr + 1, so when
the reply stream is mid-page the data lands one page ahead of where
the payload accounting continues (in the current page at base).
The client is then sent the stale tail of the current page -
previous RPC payloads, since reply pages are reused without
zeroing - instead of the file data: an info leak and corrupted
READ results.

Trigger: any compound where a READ follows an op that left the
stream mid-page, e.g. [PUTFH, READ(100), READ(N)] or READDIR+READ.

Place the data in the page the accounting is filling,
buf->pages[page_len >> PAGE_SHIFT], instead of one page ahead. At
an exact page boundary page_ptr is the empty page after the last
full one and page_ptr + 1 is one page too far, so this covers that
case too.

Fixes: 0d32a6bbb8e7bf ("NFSD: Fix zero NFSv4 READ results when RQ_SPLICE_OK is not set")
Suggested-by: Chuck Lever <cel@kernel.org>
Reported-by: Dairui Zhang <zhangdairui@gmail.com>
Assisted-by: LLM
Cc: stable@vger.kernel.org
Signed-off-by: Dairui Zhang <zhangdairui@gmail.com>
---
v1 -> v2:
- Use buf->pages[page_len >> PAGE_SHIFT] for rq_next_page instead of
  page_ptr + 1, per Chuck Lever's review. The if (base) guard in v1
  only covered the mid-page case.
- v1: https://lore.kernel.org/linux-nfs/20260927094535.1745224-1-zhangdairui@gmail.com/

v2 -> v3:
- Drop the comment above the new assignment, per Chuck Lever's
  review. No functional change from v2.
- Correct the Fixes tag: the bug in this form starts with
  0d32a6bbb8e7bf (v6.6), when base was hoisted before the
  reserve. The earlier rq_vec form is not affected.

Tested on 7.2.6 in a QEMU guest. The test file tags every 4K page
with its index. A raw COMPOUND{PUTFH, READ(0,100), READ(4096,4096)}
forces the readv path (readcount=2); ftrace confirmed
nfsd_iter_read for both READs.

Unpatched, the second READ returns stale page contents instead of
the file data (heap bytes in one run, zeros in another). The first
READ only looked correct because the stale page happened to hold
the same page-0 content. Patched, both READs return the expected
bytes. A localhost v4.1 mount with 128K/1M dd reads (splice path)
gives identical md5 before and after.
- v2: https://lore.kernel.org/linux-nfs/20260928182749.1835924-1-zhangdairui@gmail.com/
---
 fs/nfsd/nfs4xdr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4933,6 +4933,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
+	resp->rqstp->rq_next_page = xdr->buf->pages +
+				    (xdr->buf->page_len >> PAGE_SHIFT);
+
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
 				read->rd_offset, &maxcount, base,
 				&read->rd_eof);
-- 
2.53.0

