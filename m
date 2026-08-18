Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com [115.124.30.132])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EA623AB285
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 16:23:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.132
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787070215; cv=none; b=YLMcMCCj66iaC2tvB9VvSburtx+Pcd3kblO2uLyXYKNKMaZxqpSMaKPOhMtNwDtgJnQcsDHi+EAPGED7jO6aiktDBG9n56mya18OUEHn+XdUmg7QwvaVBjn069xqsjZnLedns46lg/Cq7a4QJl53ESEIq1blXAYjhn+1jgYmjYo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787070215; c=relaxed/simple;
	bh=XJ3JukLOODdcYqucgccJPMwKat+YXN2a59KANMKUdwk=;
	h=From:To:Cc:Subject:Content-Type:MIME-Version; b=hfdUGvF2YgbZ6W3Vf5utseHlFPN0WVvIgMNdB1SbFSdvxAW1QKz/tLl4386WdGCPJVowfVdwAMlw7JrnWZPHkzPKpMi9Tg3lqvUsYK0AjJxMNZEFIoR9f2tUTBEX3+1qwN4womBBEQ16ZQaFloZLvRqmXgdTipkNga03OqZWZa0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=MaWbaW+E; arc=none smtp.client-ip=115.124.30.132
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="MaWbaW+E"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1787070205; h=From:To:Subject:Content-Type:MIME-Version;
	bh=6IEkNaH0ciub/47O06ArMDzgQxtaNWmKmbXhIT9VBNI=;
	b=MaWbaW+EuygriZ/wOzPJfyZIY1F7ocpppuf4ks/npGtxHBynqYgdXIGoveVIEbBhMzasCh1O10tUbV8MBdjXeYNCSSjb4pqFFtkJwYJessNy5ee4t4htLFeGEC6ieLtMG1Usw4KSdVuVF+t8+VoIIOijfO7WWv+yLM3TJJkRrbc=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam011083073210;MF=chuyf26@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0X9E5Av4_1787070204;
Received: from x31j07255.sqa.na131(mailfrom:Chuyf26@linux.alibaba.com fp:SMTPD_---0X9E5Av4_1787070204 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 19 Aug 2026 00:23:25 +0800
From: Chuyf26 <Chuyf26@linux.alibaba.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker<anna@kernel.org>, linux-nfs@vger.kernel.org
Subject:
 [PATCH] NFSv4: fix out-of-bounds read when decoding many pNFS layout types
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Message-ID: <20260818162332.Z32qq4QUMQSjH5g-YvgOUsu882RBUL3Qgv3pfhxxEUg@z>

decode_pnfs_layout_types() passes nlayouttypes * 4 to a single
xdr_inline_decode() call.  nlayouttypes comes from the server and the
multiplication can wrap around to a small value, so the bounds check
only covers a few bytes while the following loop reads up to
NFS_MAX_LAYOUT_TYPES words from the resulting pointer.  A malicious
NFS server can trigger an out-of-bounds read in the client at mount
time by announcing a huge number of layout types.

The path is: the client issues FSINFO (for instance during mount or
statfs), and the reply is decoded by nfs4_xdr_dec_fsinfo() ->
decode_fsinfo() -> decode_pnfs_layout_types().  With a wrapped
nlayouttypes * 4 the pointer returned by xdr_inline_decode() sits at
the very end of the receive buffer, and the loop then reads up to
NFS_MAX_LAYOUT_TYPES words past it.  The XDR receive buffer is built
from pages, not slab objects, so KASAN does not instrument these reads
and the following memory is normally still mapped: the access silently
produces garbage layout type values instead of failing the decode.

Cap the number of layout types before reading them and decode each
layout type word individually so every read is bounds checked.

Fixes: 3132e49ecef9 ("pnfs: track multiple layout types in fsinfo structure")
Reported-by: Abaci <abaci@linux.alibaba.com>
Assisted-by: abaci:qwen3.8-max
Signed-off-by: Chuyf26 <Chuyf26@linux.alibaba.com>
---
 fs/nfs/nfs4xdr.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a9d57fcdf9b4..c8e073ef1d37 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4816,11 +4816,6 @@ static int decode_pnfs_layout_types(struct xdr_stream =
*xdr,
 	if (fsinfo->nlayouttypes =3D=3D 0)
 		return 0;
=20
-	/* Decode and set first layout type, move xdr->p past unused types */
-	p =3D xdr_inline_decode(xdr, fsinfo->nlayouttypes * 4);
-	if (unlikely(!p))
-		return -EIO;
-
 	/* If we get too many, then just cap it at the max */
 	if (fsinfo->nlayouttypes > NFS_MAX_LAYOUT_TYPES) {
 		printk(KERN_INFO "NFS: %s: Warning: Too many (%u) pNFS layout types\n",
@@ -4828,8 +4823,16 @@ static int decode_pnfs_layout_types(struct xdr_stream =
*xdr,
 		fsinfo->nlayouttypes =3D NFS_MAX_LAYOUT_TYPES;
 	}
=20
-	for(i =3D 0; i < fsinfo->nlayouttypes; ++i)
-		fsinfo->layouttype[i] =3D be32_to_cpup(p++);
+	/* Decode and set the first layout types, moving xdr->p past all
+	 * announced words one at a time: a single xdr_inline_decode() of
+	 * nlayouttypes * 4 bytes can wrap around for huge values.
+	 */
+	for (i =3D 0; i < fsinfo->nlayouttypes; ++i) {
+		p =3D xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
+		fsinfo->layouttype[i] =3D be32_to_cpup(p);
+	}
 	return 0;
 }
=20
--=20
2.43.5
