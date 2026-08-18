Received: from out30-124.freemail.mail.aliyun.com (out30-124.freemail.mail.aliyun.com [115.124.30.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12FA842903C
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 16:24:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787070272; cv=none; b=jZNbkIF7QEL63QMaPvTtA3BU/xMWiO2JdWb4j8lODQCPL8zpJVE+/UHhyWgdoiujYKhq5GeReyw3JjypOoCzfYxdQnT8aT/BJu++lU18JdQjtiCNim2un1c2Vp0fP8vLMJyqqSJaLcDlyAw4DRaV237ILk+hOQaP0sU4OQx9bYQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787070272; c=relaxed/simple;
	bh=yob/TGJ7MWWZkW3U3OHDywSTckgK8h5J5OeZfq7WiP0=;
	h=From:To:Cc:Subject:Content-Type:MIME-Version; b=hjTqXBRy0NAYKIgc+VVRMpr7/r3ZQJ1sUXC/+1zlpB7VIZTkvB6Vi1YK34sbRHK3xpfNZqoP33UoW348Dy16NJ8v8gjf+RKY52FYSyhDEwWhxo2BNI6GUb2TiIC7IbKj7lg9NMTAjSOUd3gB5ESihFvpDl9jltMGx43IeRG+IJo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=koRDf8c/; arc=none smtp.client-ip=115.124.30.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="koRDf8c/"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1787070262; h=From:To:Subject:Content-Type:MIME-Version;
	bh=ApoxDo5UFpl6Vo4WAq/xNlmsnQnFJ6waSoV7ttiz60A=;
	b=koRDf8c/MxUq6RVIxk+WxzpusTT1N0RmAYn5N6R5EAZTzVCuTS6xpg3lh7xxUCEf5wN1BO4L0AxUu79XthU10KTOvyK+nlF2sTRQUfT1y5n02m/dgSXcPgFfZeoUFBQhg0RlJnMsLnI1KQb1NKPIv+5rpkmjcz7XpbD+wLwit9Y=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033032089153;MF=chuyf26@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0X9E5B7G_1787070261;
Received: from x31j07255.sqa.na131(mailfrom:Chuyf26@linux.alibaba.com fp:SMTPD_---0X9E5B7G_1787070261 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 19 Aug 2026 00:24:22 +0800
From: Chuyf26 <Chuyf26@linux.alibaba.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker<anna@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: fix out-of-bounds read decoding GETDEVICEINFO
 notification bitmap
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Message-ID: <20260818162429.hRkBfHzaSOJtsemwF3XqknX_wBRwf6WfB8WnVDvY5Rg@z>

decode_getdeviceinfo() passes 4 * len to a single xdr_inline_decode()
call, where len is the word count of the notification bitmap supplied
by the server.  The multiplication can wrap around to a small value,
so the bounds check only covers a few bytes while the following loop
reads len words from the resulting pointer.  A malicious NFS server
can trigger a large out-of-bounds read in the client by replying to
GETDEVICEINFO with a huge bitmap word count.

The path is: a pNFS client issues GETDEVICEINFO while discovering a
layout, and the reply is decoded by nfs4_xdr_dec_getdeviceinfo() ->
decode_getdeviceinfo().  With a wrapped 4 * len the pointer returned
by xdr_inline_decode() sits at the very end of the receive buffer, and
the loop then reads up to nearly a gigabyte of words past it.  The XDR
receive buffer is built from pages, not slab objects, so KASAN does
not instrument these reads; depending on what follows in memory the
loop either consumes garbage notification bits or walks into unmapped
memory.

Decode the bitmap one word at a time so every read is bounds checked.

Fixes: 4e59080397fa ("NFSv4.1: Allow getdeviceinfo to return notification inf=
o back to caller")
Reported-by: Abaci <abaci@linux.alibaba.com>
Assisted-by: abaci:qwen3.8-max
Signed-off-by: Chuyf26 <Chuyf26@linux.alibaba.com>
---
 fs/nfs/nfs4xdr.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c8e073ef1d37..582f571689dc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5958,13 +5958,13 @@ static int decode_getdeviceinfo(struct xdr_stream *xd=
r,
 	if (len) {
 		uint32_t i;
=20
-		p =3D xdr_inline_decode(xdr, 4 * len);
-		if (unlikely(!p))
-			return -EIO;
-
-		res->notification =3D be32_to_cpup(p++);
-		for (i =3D 1; i < len; i++) {
-			if (be32_to_cpup(p++)) {
+		for (i =3D 0; i < len; i++) {
+			p =3D xdr_inline_decode(xdr, 4);
+			if (unlikely(!p))
+				return -EIO;
+			if (i =3D=3D 0)
+				res->notification =3D be32_to_cpup(p);
+			else if (be32_to_cpup(p)) {
 				dprintk("%s: unsupported notification\n",
 					__func__);
 				return -EIO;
--=20
2.43.5
