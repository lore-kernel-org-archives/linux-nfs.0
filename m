Received: from mail-oa1-f51.google.com (mail-oa1-f51.google.com [209.85.160.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6AB4493635
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329777; cv=none; b=T2wWvBrhdYaZ+fL4HejriErt28uSpVHTSZBG2hypB/MP2026KHMiTwbQtnMhH3AHW7RCPVYiK9kmPiw4sjXzjF29PNlSIODhM0XeXltXtXd3JSyx3p3DYGHM7huU3iXCzyzqYJAbNcVYN2/TUuLL9yxojqF5QgEwlKwXAjq7zsU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329777; c=relaxed/simple;
	bh=KBbtLLgU3AZo+dzvnywDsYYQaYy6I6RsmT32NTkJcWI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QyfkSJQwSXiJwwWZniVOZb7TqgMWWuCmkFywjD9YJ0VA1SghDBCtBXviVgfnyUeIXk0pCNfbMeB7FQoq6AJ2G/khpDQB3de8xQe/oJPpFoTGfVBGV7ydbdJwEvoDmJpnKrTdSPp6lPEZ5Rgk/HgYdp3gbqJEaRlRDvqMsyy1Bqc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=GZW8fXKn; arc=none smtp.client-ip=209.85.160.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="GZW8fXKn"
Received: by mail-oa1-f51.google.com with SMTP id 586e51a60fabf-45eb688c891so513173fac.2
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329775; x=1787934575; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AQaWp2+1+CFEq8AEXUDjc1i2hB9ZIa/GtEH9nR1NkJc=;
        b=GZW8fXKn85m3j0ZJEeJa2wNgacjSfFWd75+sNk8l/u/UD6AMEPVrIKZqLc3hinQKEU
         NQQUHxousqY4HA4+2LW41cYF3g9ncoQK/ppG3cMG/d3/sG6cz5XJ1zpePE4jSb/Ax4Au
         Hhs+mIFaeJfZtPCManvzVKmOsgfhCgxwfTqMBwou0T02mBYfGLLtUJSDouJTw31kE8C+
         Fc4oeBozxVazNHSLGSKE4Mnzf52Py3yfzvtdX84Nm/7qrpuBleLb170VAuYEKIQCp5T2
         Rsp4c2PFGGwN6TzhFpKuYhsolG/afENA/4YZp1fjNZGWGm1skZMrnjCTi03Yjmp0xWDz
         490A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329775; x=1787934575;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=AQaWp2+1+CFEq8AEXUDjc1i2hB9ZIa/GtEH9nR1NkJc=;
        b=qXQdRCCqM64zXOm8hte1x4MdxlQE5sO+5auP6PAGZesRBjs6tLwC5r1Lf0gRvxU+hu
         0OOnVw9bzkd+fjoN9sEMNPsn0PvfIr/S8FGld+1b4B5v+uLI/Yx0QmMpvx/Ex5/QRUg/
         SPKvN669TLd6Cb4kdhhaCrnQPQ5/HTnBamIG6V1vgjEKd0ey5iIYWnpvKczFK/BnZtZR
         7Z/nlKiNvFotJEYGz6lzxsqzUVNErSCO3EBU8H/0/A+u08envCuDuDMJXkou2/wNus+d
         W3zWGu+QA3zXjedIhtP4RR0Aq/ns9OxFw9rTmrb0qAmrULPnTh8vOUJpxDIDNqfC+yQm
         Lpsg==
X-Gm-Message-State: AOJu0YzKs2ok85L3e+OkRcNSCUeyz3K1LkcM/P0bb835Ef/iimGd2O0R
	oFzCZytK+GrJBVoNdg6rW6eQaj+58LKyIvV63U1M8HXZsg128lqjhAP/jIREKQYJ2tQ=
X-Gm-Gg: AR+sD1362RNNsFIipZRTZrNj1ALBx1qys2BSoknPekyJbNxOaxzvrbNVPHUklRkBgHh
	7Vd0VdvZKnSwm99xy4+3RteyJRMPushbknz3EhRyyqT0TpzZoK0niXKPKpaPxv6tKRt4e2ikBxW
	5OIe2DPpVjD0ou43JHVmcV8DQtVbpCzeWQS7W8EGIf+ZocghhcHTPAc1RtWa7I37oVyi8yfy7hs
	FxnglH+Tu9dbQOZsRWuTQRTVYTTqfkYR4B9JlGASp0PqWzDFHlJfRTLPvO2lDjwimXiy6LlQKFF
	bijexHl2Cqujq04RNsc8/lst9nG0a+irkJJ1gUvHM1JUBxZuSeMyMNZAPHSPwyEgenbRdLbyej4
	eKVAKyhErKg40ZFHct9us+nJLVpruMxz4C2xUIBZAOD5d49KjBP17HtclIMRyQCvd5b2rEfaosT
	NfPNUalPGY9C1Y55Ya+715CbRRduS89p7FPwhL04AqvqOjyZIuGnOeiT3VP3CacmqepIIHllPhW
	Le9unSRSqh0xWxKV6ZtyEtO
X-Received: by 2002:a05:6808:1185:b0:497:df42:1dff with SMTP id 5614622812f47-4b2ef1bda24mr7013719b6e.1.1787329774643;
        Fri, 21 Aug 2026 09:29:34 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:34 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 04/23] NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
Date: Fri, 21 Aug 2026 12:29:08 -0400
Message-ID: <75516b92b17c77cf269772bc4e2537c079edb799.1787327939.git.bcodding@hammerspace.com>
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

The read data-server selection helpers declare their offset parameter
as u32, truncating the file offset before nfs4_ff_layout_calc_dss_id()
computes the stripe index.  The write path already passes the full
offset; make the read path match.

Fixes: 4934ccbeaed3 ("NFSv4/flexfiles: Read path updates for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 74b75d061c6f..6db8de2b1fb3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -881,7 +881,7 @@ ff_layout_mark_ds_reachable(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_i
 static struct nfs4_pnfs_ds *
 ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			     u32 start_idx, u32 *best_idx,
-			     u32 offset, u32 *dss_id,
+			     u64 offset, u32 *dss_id,
 			     bool check_device)
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
@@ -917,7 +917,7 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 				 u32 start_idx, u32 *best_idx,
-				 u32 offset, u32 *dss_id)
+				 u64 offset, u32 *dss_id)
 {
 	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx,
 					    offset, dss_id, false);
@@ -926,7 +926,7 @@ ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 				   u32 start_idx, u32 *best_idx,
-				   u32 offset, u32 *dss_id)
+				   u64 offset, u32 *dss_id)
 {
 	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx,
 					    offset, dss_id, true);
@@ -935,7 +935,7 @@ ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 				  u32 start_idx, u32 *best_idx,
-				  u32 offset, u32 *dss_id)
+				  u64 offset, u32 *dss_id)
 {
 	struct nfs4_pnfs_ds *ds;
 
@@ -950,7 +950,7 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_get_ds_for_read(struct nfs_pageio_descriptor *pgio,
 			  u32 *best_idx,
-			  u32 offset,
+			  u64 offset,
 			  u32 *dss_id)
 {
 	struct pnfs_layout_segment *lseg = pgio->pg_lseg;
-- 
2.53.0

