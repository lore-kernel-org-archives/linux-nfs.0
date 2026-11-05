Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=51.159.188.251
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793912171;
	b=dE1rnmQxblL4Xcv4lgVBqlgwQMwfWzy67jy+SPAsCXvpEsFxY5/Q+VVrbEA+NgDjVTs+
	 hbdhpBMouav/MrijrpTDfmh4UDIPWkXgkTwM9nYshroD579Uop+R/R9cE/NNATSwbZYii
	 jT2wLBVYfF6Dxkq3L0nL92100RRweAqJN7Za2iE6Vxb81F6BACxgKHIFYVBwHJsVo2rnU
	 l/EX0npQCrxEOP0bXKg4CiM1ck1P7dU96BOgPZgVhuOTsK4Rh4mU0qrdsAjBTdB1Foeoa
	 rSm09BgEtyJGL4LFrsMok0QsmosicK1YEngn8IYI6G6jsv+44Lk5EJlbvtffnJ178Hg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793912171;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-AntiAbuse:X-AntiAbuse:X-AntiAbuse:
	 X-AntiAbuse:X-AntiAbuse:X-Get-Message-Sender-Via:
	 X-Authenticated-Sender:X-Source:X-Source-Args:X-Source-Dir;
	bh=4vkCF+GeDl/arZVLp4QCimt9/Wq5wID7Smb6j+U+Awg=;
	b=jPwIIgX3PSkLkLxq8S5ke2ltMhgExCLFsb/0BkcFZfl875SS56Z/lskwtGJP+J0pGQ2A
	 //8hWTR5xuP3UUU7qBsB0e5lfg4enxdNskeHWMn7gCJL/MP/dzhNo67iOHZsDEyR/caAv
	 aFKZ5kq8/A8l7p7xyWnqG6C2ZYsDdksKpEvsNrLZxn2Pk59w4wGguYbiSuDGvWcww9Qvg
	 UzEfQsw3WzQx9Ye4K/RQHNLT4MKRxF8fBa5TPOHvdyCGpkDAD6MpbUmqtLvBrWGJKu/rs
	 MSfyhoDxH4cIRyGBpYqaWXS1qoRHj8gunsdUemQPfrKuD4E1PyW4x39+kJMCMlm2Bag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=oss.cyber.gouv.fr;
	spf=pass smtp.mailfrom=oss.cyber.gouv.fr;
	dkim=pass header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.a=rsa-sha256 header.s=default header.b="Qf/i1ALW";
	arc=none smtp.remote-ip=51.159.188.251
Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63BAB606A328;
	Thu,  5 Nov 2026 20:56:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 63BAB606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.a=rsa-sha256 header.s=default header.b=Qf/i1ALW
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Reply-To:Sender:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References;
	bh=4vkCF+GeDl/arZVLp4QCimt9/Wq5wID7Smb6j+U+Awg=; b=Qf/i1ALWVP8Gb7tSyOpoZd5w3s
	mK71KqrFyUN+wItq2zpzHWPrSwB1snHbCkAVoL1BJgDIJkLIZILkHJbcf9hHe5rVx8Q+84RrGqt3e
	Ysn9v6tRuDiWn6u9lRA+HyMLS8EmuP1XBYBZNBS4C0YMWk8VeHb3W1jWgVcd3gmW5c7bPU+APHFxH
	JmpzxTHHPSTA4PsaiK5TwVY/BOXJz8Wf5hymsGxwTl9vELmXHnf6B3XEISJpIH2bStIkoXO18JEDO
	3sjaN68+aqnTE7X4dLAuN/L5/MD0YWZ+sA3iYupu6HadZT4MarD/C/5oDq3rGGlXog1eD2gT0Pn4z
	+UToT3IQ==;
Received: from [151.115.150.205] (port=55576 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.100.1)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1xP4VG-0000000B44E-2eHJ;
	Thu, 05 Nov 2026 21:56:08 +0100
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
	stable@vger.kernel.org
Subject: [PATCH RESEND] NFS: blocklayout: reject oversized SCSI designators
Date: Thu,  5 Nov 2026 20:55:36 +0000
Message-ID: <20261105205536.250173-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

A SCSI GETDEVICEINFO reply can encode designator_len as 0xffffffff.
The signed field turns that into -1, so the size check is bypassed
and the value is converted to SIZE_MAX for xdr_inline_decode() and
memcpy().

KASAN reports:

  BUG: KASAN: out-of-bounds in bl_alloc_deviceid_node+0x616/0x1110
  Read of size 18446744073709551615 at addr ffff88800262c014 by task trigger/50
  ...
  __asan_memcpy+0x23/0x60
  bl_alloc_deviceid_node+0x616/0x1110
  nfs4_find_get_deviceid+0x565/0x810
  bl_alloc_lseg+0x638/0x12d0
  pnfs_layout_process+0x2b6/0xcf0
  nfs4_proc_layoutget+0x4b3/0xd30

Store the length as u32 and reject oversized values before decoding.

Fixes: d9186c039765 ("nfs/blocklayout: add SCSI layout support")
Cc: stable@vger.kernel.org
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
 fs/nfs/blocklayout/blocklayout.h | 2 +-
 fs/nfs/blocklayout/dev.c         | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index e242b1d5b4bda..8a0b4e0d7cd3d 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -84,7 +84,7 @@ struct pnfs_block_volume {
 		struct {
 			enum scsi_code_set		code_set;
 			enum scsi_designator_type	designator_type;
-			int				designator_len;
+			u32				designator_len;
 			u8				designator[256];
 			u64				pr_key;
 		} scsi;
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 00462e6affb12..e085e1b7e0555 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -216,11 +216,11 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		b->scsi.code_set = be32_to_cpup(p++);
 		b->scsi.designator_type = be32_to_cpup(p++);
 		b->scsi.designator_len = be32_to_cpup(p++);
+		if (b->scsi.designator_len > sizeof(b->scsi.designator))
+			return -EIO;
 		p = xdr_inline_decode(xdr, b->scsi.designator_len);
 		if (!p)
 			return -EIO;
-		if (b->scsi.designator_len > 256)
-			return -EIO;
 		memcpy(&b->scsi.designator, p, b->scsi.designator_len);
 		p = xdr_inline_decode(xdr, 8);
 		if (!p)
@@ -368,14 +368,14 @@ bl_validate_designator(struct pnfs_block_volume *v)
 	case PS_DESIGNATOR_T10:
 	case PS_DESIGNATOR_NAME:
 		pr_err("pNFS: unsupported designator "
-			"(code set %d, type %d, len %d.\n",
+			"(code set %d, type %d, len %u.\n",
 			v->scsi.code_set,
 			v->scsi.designator_type,
 			v->scsi.designator_len);
 		return false;
 	default:
 		pr_err("pNFS: invalid designator "
-			"(code set %d, type %d, len %d.\n",
+			"(code set %d, type %d, len %u.\n",
 			v->scsi.code_set,
 			v->scsi.designator_type,
 			v->scsi.designator_len);
-- 
2.47.3

