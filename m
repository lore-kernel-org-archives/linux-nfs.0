Received: from fhigh-a1-smtp.messagingengine.com (fhigh-a1-smtp.messagingengine.com [103.168.172.152])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C02C13AB48F;
	Wed, 19 Aug 2026 13:27:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.152
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787146065; cv=none; b=I699LToqTpsubb9/Zuptdb0T5vgpNZoWsf+Dx82CiBlv26GA38ZVxz0FltoM1VLxhnBHZ/lEwVmwqOuxdNiURDUM/q065MHzXO2CPClvA4WazIIsrO6qwFde/rtRiNf3FxX1pCIj/4jMSncLH86FS/cxAvuPk6N0N9IffXEfUNU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787146065; c=relaxed/simple;
	bh=oolcBPMtoHs3bC5tU/crdeyoDqPcoP1GjBaiTIwBaXo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=IGVNx7VeP25l2yluvbUE2rBrBOdbjveTYtsODKJD6019KNkCgAFfJoEPwlpiSVfL4Me4skpdv7U01XDkYL730JF/xrDSY/H+fw7UjBs+xBsRpcbernLFD/RrfSaT5P1nNTNPbyvZrb4GjyaFIZ6Q+v6wWyPr1J7PdD1yhbcY3f8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=kroah.com; spf=pass smtp.mailfrom=kroah.com; dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b=BcUqFW0q; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=DLUU6e6L; arc=none smtp.client-ip=103.168.172.152
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=kroah.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kroah.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="BcUqFW0q";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="DLUU6e6L"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 625F014001CE;
	Wed, 19 Aug 2026 09:27:39 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Wed, 19 Aug 2026 09:27:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:message-id:mime-version:reply-to
	:subject:subject:to:to; s=fm3; t=1787146059; x=1787232459; bh=5s
	BRXvXxfQv9ufNmQC42o8v+aBqJNVE0Dj4HxcqWrZI=; b=BcUqFW0qCoLoz3MN+A
	f52pNwW1jmaYn0dSmnaeGplI0CVvrQXHaiCeTlPL87w2tAXcBzSM3S9C5hPe7jgh
	zg4iFqwq17EyE1ckxkBFyGts+xP1gqoTQhBeSgKw5DJXLm2+EtN35NKTxsybNzks
	6y1mG2ZL75W6VszU3DBt2Auylk9w9VkGg8WxLdJv6+kIqdoU9EfW+iE+i1trXFZh
	FVPlc7TtBmfUYgQlUPtIs3+DgvSNSlNFXfN73abTyuaoUUP9XRZh7dEi/CsODrGf
	i5ch28UYxh5a57cMa/ZlP03QiB4/5gDscNOrJHvBBZTnXoRn3uItsza670WgA6Sn
	9nfA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:message-id:mime-version:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm3; t=1787146059; x=1787232459; bh=5sBRXvXxfQv9ufNmQC42o8v+aBqJ
	NVE0Dj4HxcqWrZI=; b=DLUU6e6LIjQw5KxH4WJAWawVkBmd0g/0ondFZ7VkcIPW
	S/89jsu6B2ZYcHfiQ2k606z6fXJtQL3cIKGMyEesxnqWkWog9rRHKUU3U1b4BgcY
	oLtVGZ8QsA3VTHWqVNh8FZv6h686khxI4e2EOdj89qWDciMKRZsvQG2aajDr3Lnv
	9xxGsIe4E/CXj4e1Smmjte55QIMhIglPHWdFRUC+CLEIqdm+CDUHPKbv65GACPJf
	k0qn7kV3zCB6+bM3g+/zcPcELUgzLHRZeC3rIdbFsJ0lREOvSdJjjgEF+KYgE335
	xvBp+uFOLtXi/gtWP125AUExqyLSoL8WeHVJT4hlPQ==
X-ME-Sender: <xms:S6-Fau9QteEQjXOj-MVmjZsIg4IrWppguWWx1AP8F_N1s8_r7xkV_Q>
    <xme:S6-FagNa32R9_Sn-wCmYWlVOBJGF6iyz0rcj-Dz2YppurlLovb-qsHs2wKo3bvR4X
    gPVaNrPJlDvQZL5ck1uGntVP-nJR2tQtePToHiPnTdndtxJIgQ>
X-ME-Received: <xmr:S6-FakHC0Wc6cpwWB9T6cK2jCWXLD8F8P2107Lkrw2F1pz0UcwZRHlsc0Dh8xb1yzTUnAmidEelZAap571CIQUhuqu6RXh0axDoLHZb9ez7BE3IGYE8>
X-ME-Proxy-Cause: dmFkZTE6/3E+2ZMSRsZ2E6+Z9B2yASB9qJp7tBdCLKDT+TMPnqCumcFFFMWAzKRCA/NrJZ
    zieGosRKuQKcVMgM9kUloN+hAGMX4t6By9nOT842F8PKJZhrKX9akurw3VkvTUUWZKIEG5
    syEcXNl4tkqi2kEdhijpGacPiPL5Msn/57rgDFyMTITP2T3oPGLv+EfKL/2i42rXv591xM
    RFsyYAe+PmqQDEccTj1SK2+j6LEwaqmxWwtQc1qvR240mU1T6SWfSIbLlUxjTsV8HxQIOW
    UgSjjnnNuWKG0XT1f5Kktxua4Wc1msxh7AEmA6Mbs+PhdOIA7ZUGjiCg180Kk0gD+wSnt4
    eLW9awDDlClxPCn7cI4e/Hsm49T+dNLVuC+nx5WbLpOK2ILXxBnhnA1G5Ty7+zMa59N7A4
    j+j8Njd8EF1FUOyj/e8zAGkcIBGYacyB/2hFynmPHgjPps8WpxE/FKY7gDcwtrpc3j7ivL
    4V/Jle9reXZ/lC3CHUFdODAOooaMXElaSj2++e8Hs772Rber9RvX1MbKHDUcMihm5lbLiG
    1hseR6G/kh5vxR+IBTZRxI7+7lzxv4cIOHyfxXuFzxsrMGo4R4HOW7JsvR/JcRkE8BeNNT
    iSz3h68uN9fJbX9VdVRDiinUM9CQuw6jzq10n8dpCp5JqDeShWSr2yrhfMXw
X-ME-Proxy: <xmx:S6-FamR1vh6AIwrdTNouceOSBdom2ppF-Zo0qN_VyrI-ALh2gSNHRA>
    <xmx:S6-Fapsb-XrVYhsbrT3AKomrF1O9Kxry3gnmfE1MmVVilXAXqX5Bdg>
    <xmx:S6-FamJEM__78lFr6SeWHunNYZ7s-KAEJ_-KARtNievA91yl-Yx4hA>
    <xmx:S6-FammEXweuWtjMO8-IqmVIoJFC-l7RXGUPxXjFVkUyGP3LH1VIig>
    <xmx:S6-FamVo8N9ZT_q5OePoZa7yqV5ux19EmNkJjwZr0l4bE1Qusl4a1EwW>
Feedback-ID: i1d2843be:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 19 Aug 2026 09:27:38 -0400 (EDT)
From: Griffin Kroah-Hartman <griffin@kroah.com>
Date: Wed, 19 Aug 2026 15:27:32 +0200
Subject: [PATCH] NFSv4: Add size check to avoid 32bit overwrap for
 xdr_inline_decode()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-nfsv4_u32_size_patch-v1-1-d5eae3f6cce9@kroah.com>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yXMQQ6CMBBG4auQWduEtkjUqxjS1PZHxkUlHSBGw
 t0tuPwW760kyAyhW7VSxsLC71SgTxWFwacnFMdiMrVp64u+qtTL0rjZGif8hRv9FAblg44NzhH
 WtlTSMaPnz7G9d3/L/HghTPuLtu0HKOnF8XgAAAA=
X-Change-ID: 20260819-nfsv4_u32_size_patch-ac1d4e5de336
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Griffin Kroah-Hartman <griffin@kroah.com>
X-Mailer: b4 0.15.2
X-Developer-Signature: v=1; a=ed25519-sha256; t=1787146057; l=1418;
 i=griffin@kroah.com; s=20260706; h=from:subject:message-id;
 bh=oolcBPMtoHs3bC5tU/crdeyoDqPcoP1GjBaiTIwBaXo=;
 b=YrIMwNpq5fko96DBB7xWRaqMgpDyk+z/DoNiUvTez5dbroq4Klurhk+PQGi2wy6JAq82EUsvq
 rC8YlGzCW9WCTI+T+F+uk/7Ew14tllda2PjGvmj5wV+6IRuU7A9FR9/
X-Developer-Key: i=griffin@kroah.com; a=ed25519;
 pk=Hy1TuVHERdQhLAWwjmxLFNtGj7eEEjaZWPXehAlic5M=

Add a size check before xdr_inline_decode() is called in
decode_pnfs_layout_types() and decode_getdeviceinfo() where the length
parameter is multiplied by 4.

This check ensures that the parameter passed will not overwrap when
using 32 bit variables, avoiding incorrect size input to
xdr_inline_decode().

Assisted-by: gkh_clanker_t1000
Signed-off-by: Griffin Kroah-Hartman <griffin@kroah.com>
---
 fs/nfs/nfs4xdr.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c23c2eee1b5c..5c80dfd07bba 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4902,6 +4902,8 @@ static int decode_pnfs_layout_types(struct xdr_stream *xdr,
 	/* pNFS is not supported by the underlying file system */
 	if (fsinfo->nlayouttypes == 0)
 		return 0;
+	if (fsinfo->nlayouttypes > U32_MAX / 4)
+		return -EIO;
 
 	/* Decode and set first layout type, move xdr->p past unused types */
 	p = xdr_inline_decode(xdr, fsinfo->nlayouttypes * 4);
@@ -6089,6 +6091,8 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 	if (len) {
 		uint32_t i;
 
+		if (len > U32_MAX / 4)
+			return -EIO;
 		p = xdr_inline_decode(xdr, 4 * len);
 		if (unlikely(!p))
 			return -EIO;

---
base-commit: 8d3ae59288f1e7d58d76558a6ee96d533bc5019f
change-id: 20260819-nfsv4_u32_size_patch-ac1d4e5de336

Best regards,
--  
Griffin Kroah-Hartman <griffin@kroah.com>

