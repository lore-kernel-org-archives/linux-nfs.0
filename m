Received: from mail-vs2-f42.google.com (mail-vs2-f42.google.com [74.125.227.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 868EA3A1D01
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 16:00:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789488038; cv=none; b=I3zvmCN0iUWA0OWcpuUjtBg19/3Y3D0gkeTXBj+qLSAVCqDjbJ59+Dq6yWqz4Blm8N4phOufSEjQgNzH/wjTG0AO4lHnFK2/XVg++ql7eG3aB6yAA9lebLDh+by/6jhzgFwiAaM3G+yuRlzf/DNbLzHrLTDfku7S5VCn5CFunuM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789488038; c=relaxed/simple;
	bh=yfFk5AxqlgLH6I0x387ApOK8n1uXyoBrfJ8SxXsFVWA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FM+c3S2xVohkHYI26MwSaBFwWjhGu6CnPnJfBcts0gBoCX8vsr4GCC6EIhnP6latWznJZdvc68izHWLJkL+lKyUKGi9IVHE+leIkP8/DaSOpFl4WWc4NZB+ayrytj2sc4ns0oI0TR8QhJtTSL0MphUSRJbdo3pvF9kZlANX7RJY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=V778B1OD; arc=none smtp.client-ip=74.125.227.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V778B1OD"
Received: by mail-vs2-f42.google.com with SMTP id 71dfb90a1353d-5c98dc46a95so357215e0c.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 09:00:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789488035; x=1790092835; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=GUDKgi5BjwUlGqTDW5BhogeZ2whULHpHZjtGCCfq9RU=;
        b=V778B1ODwI61E6aMAqmTiLs8Ib1DHBkTN+zCMxc2VH0ukbB8PxBIMjF6I5UX3Hv8iP
         +T3mMtZO/6Su/iXOaAGRYor7RhusIWSNFgCm8jRnYJ+qE0O0UWpCfMVOHNwxj5VBdt/0
         sQxyQdfLJVsXwD3wGVxb7XalIjMwmO29npEmmwkh8TGfbQyFSs8+V4b/9L6UmdLLgGLu
         EP4R9pwGEe+vk/cL04CSNkBwWDxETr/cS0bOMt1Tql23kTOZ8M7iC5rQFQuUP45+Fb4H
         IxYwFvZJcDsUnin/x8uuv2O7C1djgMsI/sRaNwsazQ5lvRiKIKgG25C7vhNy8yUg3pzH
         dutQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789488035; x=1790092835;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GUDKgi5BjwUlGqTDW5BhogeZ2whULHpHZjtGCCfq9RU=;
        b=WRa1DAqby7M7RAU41bjqDm+8RHnUBzbyhAlC+AYNjaMLcke3XJ5hU6vGlzmGEyYROy
         FXRjnlpnqrvWRpaSZRknb0euMB2pUdy5HtSmUcE7wjScDHjZscX4rdWICdvmZeD1+URk
         cVOdCvB7h3a6dhCT074mkwDzk3avBwj1p8Bvt5hWnQZBKXp9y0t/y4H2WvoVm1iIP51/
         dsrTS3aY4rkcO6Fn6RNJlV0ZhQHH4WgpIU83WF2JCl1yt7qFrwgmMevLsnShbibqIit8
         u6Zzsf1Nxy+PKJcS8LY7S3BRaMv/aRV4H/VIZRzXQJe/ecqk1A7PGfYdWFLllBD7l5Tl
         crMA==
X-Gm-Message-State: AFuF++kfK7lBQ6dMd2Niqlad2UVl+7ILEIRmSBNgipk6dmF6dk/r/2jx
	rMejbaUeNNmCHtu+S56DTsp3iRx69WcFDNATJzFlqyLlgcIuh/PATOD8
X-Gm-Gg: AYBFou2uZm7YDKkikpXGwRpkoYVYpNIFFtDEvWc1XHl0r1g6wplqRJ7meMcP/iGPs5y
	rNNnAxOpOEUNsDZVn6gOXCM9qmTz0ab+3KEIYr30TeYZ6Xpxkso3vCDPqsjGRF/KuVSXHxMhP83
	/xAaofQgDk6B/LGEF+5FlQqnzhbCB/4m5YXXcbNlXTk1kQmRanD7xo/48salRmurOxFTvbps2Hi
	YfOMhWvJhDtMjEAz+hJ+TgE4kHHgzc3nPDUS3IsnGdlPR1f5Cwi0QTcR03BlYysnDJCnl9hnWn8
	7EnvTuyQ3hmU+QgRGJZkmfGZ5fHnvzvrSYBgIyAJrWPOZZU5omIOk6eqIh7LBua/akiSDZOKMsY
	tBf2UUzid5xKOcv7Oab6rRTrWrXPL90rj/Bmy/MVewHnyQV8yRTWxkLFWQ54u8LT5nBI27Ajceu
	8jkCNn1On4VzI1wALuvz2tZHFhmZlSBNLGVDANjvIfTHOO9KE6+lUhTFoFjvDEZxiezcU8QiJnk
	4+/
X-Received: by 2002:a05:6122:488c:b0:5c7:d204:db7b with SMTP id 71dfb90a1353d-5c993c0c81dmr3441065e0c.3.1789488035334;
        Tue, 15 Sep 2026 09:00:35 -0700 (PDT)
Received: from beelink.. ([187.13.206.89])
        by smtp.gmail.com with ESMTPSA id a1e0cc1a2514c-982ba1789b8sm14883192241.13.2026.09.15.09.00.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 09:00:35 -0700 (PDT)
From: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Subject: [PATCH] NFSD: copy SETXATTR data from all XDR buffer segments
Date: Tue, 15 Sep 2026 13:00:22 -0300
Message-ID: <20260915160022.3105295-1-qwe.aldo@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_vbuf_from_vector() manually copies the head followed by whole
pages starting at offset zero. This assumes that all remaining data
starts at the beginning of the page array and that no data is stored
in the tail.

However, nfsd4_decode_setxattr() passes an xdr_buf returned by
xdr_stream_subsegment(). Such a sub-buffer can have a nonzero
page_base and can span its page and tail segments. Ignoring that
layout can copy the wrong bytes into the value passed to
vfs_setxattr().

Use read_bytes_from_xdr_buf(), which observes the complete xdr_buf
layout.

Fixes: c1346a1216ab ("NFSD: Replace the internals of the READ_BUF() macro")
Cc: stable@vger.kernel.org
Signed-off-by: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e17488a911..0f9f926cbd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2288,10 +2288,8 @@ static __be32
 nfsd4_vbuf_from_vector(struct nfsd4_compoundargs *argp, struct xdr_buf *xdr,
 		       char **bufp, size_t buflen)
 {
-	struct page **pages = xdr->pages;
 	struct kvec *head = xdr->head;
-	char *tmp, *dp;
-	u32 len;
+	char *tmp;
 
 	if (buflen <= head->iov_len) {
 		/*
@@ -2306,19 +2304,8 @@ nfsd4_vbuf_from_vector(struct nfsd4_compoundargs *argp, struct xdr_buf *xdr,
 	if (tmp == NULL)
 		return nfserr_jukebox;
 
-	dp = tmp;
-	memcpy(dp, head->iov_base, head->iov_len);
-	buflen -= head->iov_len;
-	dp += head->iov_len;
-
-	while (buflen > 0) {
-		len = min_t(u32, buflen, PAGE_SIZE);
-		memcpy(dp, page_address(*pages), len);
-
-		buflen -= len;
-		dp += len;
-		pages++;
-	}
+	if (read_bytes_from_xdr_buf(xdr, 0, tmp, buflen))
+		return nfserr_bad_xdr;
 
 	*bufp = tmp;
 	return 0;
-- 
2.43.0

