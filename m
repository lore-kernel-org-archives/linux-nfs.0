Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795657534;
	b=GD9OsO5oBn1XR6h9TBkEj9ohf2jOfk57tnzNUfC8pRZOdidQF2mDYcVA5VRjc8II0lAh
	 nhH74CEFyULasL06+/YmaP5hqWCrqZAvUX+qIEI6Pu0xnN7AIV7lLi7xbe9Y/3gN7d3Du
	 z5kY/RemSPVtrKkoY6I3aenj+KWLbqbrUT/4M0SE9IOQJFgpJT8ErfG1JxxCGpgjQzVB5
	 EROm1IuKgi0/AfHLlArCecDk4ZIRTHzJhE7QyaTToi3LLlZkVMkEcYKaOkdzF7XObyNW5
	 YX53VcOuY4y5FhMgwOucDyz9YJbTD36/OgCdWxW4BVYy8KfY1t5sbWQzYpZzS4XLvWQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795657534;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:X-B4-Tracking:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=mqtT1NBF6kkEhZlIdXJqIac3O6MblaqJpKIS6Lamh2Q=;
	b=Liyfmw1pO973HjLLJVPKfMs1zAXsGbAE9HEFl0Qq4HaqqtgrvKMsHaAVWFY5dbBANLDw
	 h3tDOCtkmsd8fctHdFObEwJaNYH5EyGQBMLo4wyhFwd468KjZ/UwhjzcjQBc6PA8P+AD1
	 Lk51XnQNXSmIRkV9t+vYn2OWCCRZEUN/xdhsNQEWzw+GB9nKfjbKiqBcqtbokZzdWe8VI
	 1D8nAAHAK73J2OXHqScoOfCgoOAwsVOQSDHH6m1NDymo5pGwljtpbsSH85JrkXL5Kb1bC
	 au7vunet4zfS3JVDJpuKG+dwVEtfb4TTUVIAt4RHLU20Q+ETGAM5SMbkMsFHC4WceGw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gJs1PQRu;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 542CE606A321
	for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 01:45:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gJs1PQRu
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1795657534;
	b=lLqmRm9bLQucy/qTKSK4YK8GO3fqJyhucT4U3BZdr1oI9R/YjzRf+9aeAZZOwrxSD2cG
	 ggcNwWlfwcDg5wLOxV+MNdskDTlkd+MeQ479BI3jBsVBDh+xoDmakUiBxfhz5cPd6s9nA
	 lvo2PGRJLhG7A88GVXc4xGBSZuw0R9JvK/oQJSZUQyd7ININ59NgN7cfWM878g7eNEsWX
	 iL/0p0Rl+LZy9CDyeBy6U2u19YD/nR3R/onpxZBmi2IBWe2NBi4O4TAWObDmrJDISvZqK
	 P7ZunkqDj3MMWWowAUClhAiZe2Zta8r4M5xkl9t119HKhNDkhyOxFFMpo/f5AlBtLKQ==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1795657534;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:X-B4-Tracking:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key:X-Endpoint-Received:X-Original-From:Reply-To:
	 Content-Transfer-Encoding;
	bh=mqtT1NBF6kkEhZlIdXJqIac3O6MblaqJpKIS6Lamh2Q=;
	b=UpqLL0A77a+bduUZ+knEYO1qFikGAQ+u0XqkZBg2xyAOnvO63mAmaqijRVb95EQvbZsO
	 i9MxuyUe07wladpy9Kp4SFPh6n9dOEN1YjFMoVTpiKfr6XcPQzH3R9cq0il74TmHOaLOn
	 scU++7CAf+Zu/PcVb6S5C5IEncNTxfS08MVdZYdhLk4CWRqNovm3qEXREsSSeJgyW/wfK
	 mcm1Aura/ZBkvrP1ulB2Sjrt85pyC7wlwKC592lA2UZqEZWe5UUDcxwiYDyarT1WYWbBR
	 1l1vVKLsUQKIaNZydIzXQTGuxypzFfX3BAoMsPasluzkpuciipN3PmretvCLUkEZN/A==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 9D5191F000CA;
	Thu, 26 Nov 2026 01:45:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795657534;
	bh=mqtT1NBF6kkEhZlIdXJqIac3O6MblaqJpKIS6Lamh2Q=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=gJs1PQRuj0DWCnVT3zBdG/uvSU2Wh9S7ZDRtOkp6gfUAdbPq4xIJiAaupiBi+/J86
	 +uGdH5qUATgbzJqv+cNnxPvTps82JdHXYqFehqOTd1jpbZqaGMRGF8sjukUQEj+Znm
	 fmLPihu0w9Y7C19vc2XxtIgjeHPB8x6L1QakwKNP7loAryg5vOwMKeO9uhTPyhslao
	 DznvZqBXHF8qSN1AVSN3dRiZ6BL06x5F6qciHNvdm6xvamPW4ooKkIsQhrgBArQh3a
	 nwCR0jiQtZd6WgM3Wk8VoUjLMJAOGZfUIBBwEy/vn+0ghEwH5R1b6xK+jW1FzFkfSK
	 6jlLr3MqKHdFQ==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id F2A7F4D14B;
	Thu, 26 Nov 2026 01:45:23 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Thu, 26 Nov 2026 10:45:24 +0900
Subject: [PATCH] nfsd: stop a block layout at the maximum file size
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Message-Id: <20261126-nfsd-block-maxbytes-v1-1-1869942523f9@samsung.com>
X-B4-Tracking: v=1; b=H4sIADOPB2sC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzNDQyMz3by04hTdpJz85Gzd3MSKpMqS1GJdI9M0c3NT05QkY4NEJaDOgqL
 UtMwKsKnRsbW1ADkIto9lAAAA
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Christoph Hellwig <hch@lst.de>, Sergey Bashirov <sergeybashirov@gmail.com>, 
 linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1795657523; l=1992;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=NszbfrGTuRyaQObY/OY6rQ5VCgbAPzgwgkSXEuIR8lY=;
 b=13UcwiZpfABYvEKSs3/K7KnvvOT5MTk6vV+4Z0WbZ8B4cz7NB7xvfKFFpkmO9q0mhNaPdoa9p
 UqaUecEXjJoAi/bmHFbaJS1MrFk3+m0CEbkHINIXwqXKkGsmN6P5kl5
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

nfsd4_block_proc_layoutget() calls ->map_blocks again for the rest of
the range after each extent. If the range runs past the maximum file
size, an extent from XFS reaches that size. The next call then asks
for an offset at or past it. Since commit 29f3c1be4e55 ("xfs: clamp
the pNFS layout range to the maximum file size"), xfs_fs_map_blocks()
rejects such an offset with -EINVAL. The LAYOUTGET then fails with
NFS4ERR_INVAL. pynfs GETLAYOUT1, a READ for NFS4_UINT64_MAX, fails
this way.

Stop the loop at an extent that reaches the maximum file size.

Fixes: cc6c40e09d7b ("NFSD/blocklayout: Support multiple extents per LAYOUTGET")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
pynfs GETLAYOUT1 and a READ for NFS4_UINT64_MAX at offset 4096 of a
64 KiB file now get a layout up to 2^63. fstests generic/075, 091 and
263 over the block and SCSI layouts, and the pynfs block tests over
the block layout, give the same results as on nfsd-testing (generic/075
fails with fsx errors on both).

7.4 and 7.3.y (with the backport of 29f3c1be4e55) return the
NFS4ERR_INVAL, so they may want this in stable. Older LTS kernels map
one extent per LAYOUTGET.
---
 fs/nfsd/blocklayout.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 23f2365787e..c8942191b5f 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -182,7 +182,9 @@ nfsd4_block_proc_layoutget(struct svc_rqst *rqstp, struct inode *inode,
 		}
 
 		bex_length = bex->len - (offset - bex->foff);
-		if (bex_length >= length) {
+		/* There is nothing to map past the maximum file size. */
+		if (bex_length >= length ||
+		    bex->foff + bex->len >= inode->i_sb->s_maxbytes) {
 			bl->nr_extents = i + 1;
 			break;
 		}

---
base-commit: 6f174a0eca19e69a14c34b0ed56b60d484f22fd6
change-id: 20261126-nfsd-block-maxbytes-25f7755db30a

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


