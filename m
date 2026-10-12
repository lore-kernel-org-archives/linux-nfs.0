Received: from out28-123.mail.aliyun.com (out28-123.mail.aliyun.com [115.124.28.123])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65FE721D00A;
	Mon, 12 Oct 2026 09:08:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.28.123
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791796120; cv=none; b=mygkcxgrQlNbbtFlCoj96/q1pnRjBAGxTBdQCdRHnSb73ufzLIi5Bfz3y7BZqwFCk8kg0eFb+nd0Y9mNG8QOZFogYCNujK4qm9xKOQ/dVcUiUM7xr7HSggLLDBAnI0B/TRT+jg1yJA9Bw3pcKfqSiGy1mpqsyfwNn7qEdtrzkeU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791796120; c=relaxed/simple;
	bh=MaOtwmXSzQetw/GC1jtFEpyfaEqNpUZoYdI9UQryYpY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=TiTyrbPoSbNHBaE7j2K9CXz0FtERBnChwHCoMxpwRG+E5iYpv9cDzdfuQ27UURZUEOaL+NzFHaHqeKCDP49GEJMniz4giSwMWrqsAA+pU8FUgB8O0O5QPbS6eeknIocau2kp2NHZEA4PMfbAH8Un+h0y1kY1iQPWa8nN2yAqDJY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=xiaopeng.com; spf=pass smtp.mailfrom=xiaopeng.com; dkim=pass (1024-bit key) header.d=xiaopeng.com header.i=@xiaopeng.com header.b=UNSJ0/vC; arc=none smtp.client-ip=115.124.28.123
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=xiaopeng.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xiaopeng.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=xiaopeng.com header.i=@xiaopeng.com header.b="UNSJ0/vC"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xiaopeng.com; s=default;
	t=1791796115; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=MG/7cNd6lBR1DZ0PeYAxMraG9cwX8AGNJsr6BTnFceI=;
	b=UNSJ0/vCYFhIB2X+4COzG4FtbriM/mnb2YiDqpc0YySUhmx87lhkqBkepCz9Q3y14ylk9VBps5NyJQ99ijzkXj/m0CQ7iYk2dYpfz4iMaOzZjVfe2ZKM4p0MO11q8H8sBzWtJviGDFHuNeB8svbuPqo8pD2CtuR2QgneNCzMpbM=
X-Alimail-AntiSpam:AC=CONTINUE;BC=0.09176327|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_system_inform|0.00505407-0.000686733-0.994259;FP=15373143721677379251|0|0|0|0|-1|-1|-1;HT=maildocker-contentspam033045213054;MF=zhugl3@xiaopeng.com;NM=1;PH=DS;RN=5;RT=5;SR=0;TI=SMTPD_---.jZykkhh_1791796114;
Received: from DESKTOP-UL5U09E.xiaopeng.local(mailfrom:zhugl3@xiaopeng.com fp:SMTPD_---.jZykkhh_1791796114 cluster:ay29)
          by smtp.aliyun-inc.com;
          Mon, 12 Oct 2026 17:08:34 +0800
From: Guanglei Zhu <zhugl3@xiaopeng.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	liuwb@xiaopeng.com
Subject: [PATCH] NFSv4: fix bitmap length check in decode_bitmap()
Date: Mon, 12 Oct 2026 17:08:34 +0800
Message-ID: <20261012090834.920912-1-zhugl3@xiaopeng.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

decode_bitmap() reads attrlen from the callback message and passes
attrlen << 2 to xdr_inline_decode() as the number of bytes to
consume.  The shift is done in 32-bit arithmetic, so an attrlen of
0x40000000 wraps to zero, the bounds check in
__xdr_inline_decode() passes, and the subsequent reads of
bitmap[0..2] walk up to 12 bytes past the end of the received
buffer.

Reject attrlen values larger than 3, the size of the bitmap array.

Signed-off-by: Guanglei Zhu <zhugl3@xiaopeng.com>
---
Verified with an ASAN build of an exact user-space replica of
decode_bitmap() and __xdr_inline_decode(): attrlen=0x40000000 with
the message ending right after the attrlen word results in a
heap-buffer-overflow READ of size 4, 0 bytes after the allocation.

 fs/nfs/callback_xdr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 88e1af0fd..bea967e0c 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -109,6 +109,9 @@ static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	attrlen = ntohl(*p);
+	/* bitmap[] has only 3 words; also stops attrlen<<2 from wrapping */
+	if (unlikely(attrlen > 3))
+		return htonl(NFS4ERR_BADXDR);
 	p = xdr_inline_decode(xdr, attrlen << 2);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
-- 
2.43.0

