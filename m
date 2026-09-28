Received: from mail-dl2-f39.google.com (mail-dl2-f39.google.com [74.125.229.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAF6B3859EC
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:27:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790620077; cv=none; b=pdL+uEDTCAqKrvrhAq4Axi/v8bZP6wCBXUCD7Btub7W8fMUPqtsDVtRchIHYp2ruE9RxNd3s7bjGNVk6ata8Hgl1m0anvy9cSS0tT7Kw/l506JtRk9vCt1Hkd66X0fqG4FwgTKoI51KqWMjY5znCn2Kf+qEhWSVLeOWA7Wr9jVM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790620077; c=relaxed/simple;
	bh=lA+/qeQ/7Zd4GsOWrL7T4sQMQ721MJmAVOQwV+tc/4c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UWrJDt7vyPNAcF1vDl1RdxUBhQt7vWSZOTU/IVOVELyUrgAwwwVlVPBVXVrotHppflByTLRXgbON3kvlZtj/Oi+4qJOh3xWID/Z8ZPNYjSXM/KF+GU9PhJ2cJP98ND5eH+YxCC8cyxD7Zd9zVHCZEqfyLIgAh9eoXCY0c0I9Q/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ae5BSqPT; arc=none smtp.client-ip=74.125.229.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ae5BSqPT"
Received: by mail-dl2-f39.google.com with SMTP id a92af1059eb24-1438cb9b3a3so2108446c88.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 11:27:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790620075; x=1791224875; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=nZ+HoXc0R+NK0c3dnqJSfpL5GoUL8PlgcOM7DYKwAo8=;
        b=ae5BSqPTIhZvyq0+XUTt+qfxQKZIfAQV6ruuLOrEd5WzP3Eww21WNpOu7SRGSKLAoD
         8TdiW1HJIild+XDs4uCrvImrlcAgU6Ibvc2NO5jDu292ubL/OBIULGHSpaY+i7hPt+y9
         ApxoMjxxnxzLmgdfCJW4hWeL2/2Dpkd6ItzCEjIM7rE7SvC3AN56BdV7k7s0ubxEYQuo
         S6+uDnYxhtl90tilLBpLpNUtptjjoFM7kNTqut7uGJMfeoshR4rWAJI3VWOBpLss+7Ek
         jsnKcmeiR7aIaI9SmO/2AdoLyVILgo/220ILDaBtZjExHJtp45tTHCffzhkHnQdHxhFV
         R2zA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790620075; x=1791224875;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=nZ+HoXc0R+NK0c3dnqJSfpL5GoUL8PlgcOM7DYKwAo8=;
        b=Y1hJ4YNb/4n5n/DHmgCxd0vZNtxt6EkC1m63lfYbMWfl2A/sOS+wiqvmAB/Ia2koQY
         mopYhP2qA+IMVaUgDWucd3qN8Kms2qOa33lhJQd9BUQl5pfi/6XqL1AFnjf/6zxGasyW
         Dpgiv7rIdXzOEfTL6H1AhQboxlEwS08asU+IQ5PTR2v7ZCW3lIxRq/DdV9O9MbbGsSSy
         Y4bC5dkKwZXnI+QQVlnp7N2AdRI/AGJ371PLde2058CtEEqcbHvxMUPrGK8jlFxEzK0B
         JNG7HAkOWntKoDiBnTrktRczqf0Sbo4yhgFe/9XPmYwyvwEDSKzHqQGc73DplOuqJadr
         Qqkg==
X-Gm-Message-State: AFuF++lLC+WJNxM2BRD6tWG/4BrpdC5H7SvHE9r3qV0rVoZ6jtiqUWqc
	BPK4qEF65amWwEhK7p815b37k+N8uDMd/TDPsdQcyGhn38xDtVs9TmQ2+zzikCLlMVw4AQ==
X-Gm-Gg: AYBFou2+k3S05kZOzOilWDfqAabXSfq2dvfvj+RUmX5JjlxsnXA1FdNyFjYDz5QtilR
	zbgTp1acYnbDRSP8na3chJVG1Wz+pl3drfs+h3KBmDfutscMF02qPgVPyOyIdZJzOcPxVNoboLj
	rCPEAYgSkgmYXMdif20cdzsf6OoLtmi8evLJf3thTt0CsLPANaEipjBMTFhLGILZg/pdD0KewLz
	xCOKKPR0sJupe/YXrwOVBY8IgdA2b3ixSmTwXPAGh6H6d6iBMZBFkXl7IQyUYy0pdWxsoVkDh6X
	k1kqarK2dWCv1K6WEsgK+bWkqOsWoAz+KIWtVK+9wGmnfc2yWrTONdfsWLbTCmjIEaMkucaIr5E
	9SOo7jFjlmOrsNN1VX1H6DSj7oTOjBAHf6eylCq/w3SdAHN/zhFc+SpjUfb4NA3WtBMwJ73mBG5
	U6Wr/WYZBCfBL9dFumG/uDDNVHAUdMLKPtEMPL76cgSnhZuMIDxnX6PwVKUEd+bG4auA==
X-Received: by 2002:a05:7022:ff43:b0:13e:68c0:9d7c with SMTP id a92af1059eb24-146ce7780e7mr12379480c88.12.1790620073743;
        Mon, 28 Sep 2026 11:27:53 -0700 (PDT)
Received: from localhost ([8.219.239.189])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-145acc45f03sm25484014c88.7.2026.09.28.11.27.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 11:27:53 -0700 (PDT)
From: Dairui Zhang <zhangdairui@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Dairui Zhang <zhangdairui@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH v2] nfsd: fix READ payload landing one page ahead of the XDR accounting
Date: Tue, 29 Sep 2026 02:27:49 +0800
Message-ID: <20260928182749.1835924-1-zhangdairui@gmail.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260927094535.1745224-1-zhangdairui@gmail.com>
References: <20260927094535.1745224-1-zhangdairui@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

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

Fixes: ed4a567a179e ("NFSD: Update rq_next_page between COMPOUND operations")
Suggested-by: Chuck Lever <cel@kernel.org>
Reported-by: Dairui Zhang <zhangdairui@gmail.com>
Assisted-by: LLM
Cc: stable@vger.kernel.org
Signed-off-by: Dairui Zhang <zhangdairui@gmail.com>
---
v1 -> v2:
- Use buf->pages[page_len >> PAGE_SHIFT] for rq_next_page instead of
  page_ptr with an if (base) guard, per Chuck Lever's review: the
  guard only covered the mid-page case, while at an exact page
  boundary page_ptr is the empty page after the last full one and
  page_ptr + 1 is already two pages past it. The new form matches
  the accounting xdr_reserve_space_vec() extends.
- v1: https://lore.kernel.org/linux-nfs/20260927094535.1745224-1-zhangdairui@gmail.com/

From code reading only - I haven't runtime-tested it, and this is
my first patch to this list. If I've misread the flow somewhere,
please tell me.
---
 fs/nfsd/nfs4xdr.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6a0a97d..e4b8285 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4933,6 +4933,14 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
+	/*
+	 * The payload accounting continues at
+	 * pages[page_len >> PAGE_SHIFT]; write the data there, not one
+	 * page ahead.
+	 */
+	resp->rqstp->rq_next_page = xdr->buf->pages +
+				    (xdr->buf->page_len >> PAGE_SHIFT);
+
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
 				read->rd_offset, &maxcount, base,
 				&read->rd_eof);
-- 
2.53.0

