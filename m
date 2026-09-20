Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEE563E1CE8;
	Sun, 20 Sep 2026 21:08:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789938502; cv=none; b=HOJlPNeXSVeq/76ojTskQP7PACenppBESDDsym0CQUP0vijma8xDqrG//0frGwfgMB8rH3HhWkl/epwEKTbNv4Q7KGvOZLyS05ULgzAaEpz35AuwyrSSDfc/rnW7X3+2dYCTBHRaJb5H+iXjMgFdqcoBCqIMr+fV8TH2uzy9F2I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789938502; c=relaxed/simple;
	bh=cZ/k0SPV8Z1+FIzSdsidjYgouD4ZG+cgSoKVCgnJg5M=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=r9yV/4NhUtDj819Ri3mcrYhH26zJVAdkvMs+ZvlWnUk0YU629O2eAQiY69pBSjCoTCYO3sWaAYzc8W/XNdHj5CmDt5sQwola6gw0aRibv9t+V/nfwjh0E9aFPkfdeIQA7Xy5Eop1AeNt4AN2lzZtm7+TQlEd82gPFVx4BAxUVo4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=ZYbIq9ai; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="ZYbIq9ai"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Unsubscribe-Post:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=JRFenQY4HXAGvTuXVdoqTmgRFpr4frNjwqD1UnLAff0=; b=ZYbIq9aiD4WUGVRPecNrMTdkAe
	6Fwz/WdAjAeLW2oVSb9zNUGpSnHpliO1Ryvpz/p9qcQiuqZ/E2144VEK+kUOF/ygTeS28ALlj6tlF
	lhGJmEXY36/HS14IxQUX1eIejJZrpEjARfVjgeu+v+cntZmwlPNKKf5f+RFyKAT3t+YbL1lquvTdP
	Rpg/gh3WaT/EBC4zQDpMNmOX87KLAEi2YKGizK3jvxPmZlsjihynWGpRjB6tBisI4KBMwovAv3Oy4
	FRsnE0En2vzPWtnupin+/j40AUO5bnd9GBIkfPv/8TZazpVKsxA/wGjp9MvLugQjWobSkfM3hjL93
	NP1rc5IQ==;
Received: from [151.115.150.205] (port=48948 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.100)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1x8Olm-0000000C8rS-3hOK;
	Sun, 20 Sep 2026 23:08:18 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: cel@kernel.org,
	jlayton@kernel.org,
	trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Subject: [PATCH v2] SUNRPC: restrict integrity replies to authenticated payload
Date: Sun, 20 Sep 2026 21:07:13 +0000
Message-ID: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
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

gss_unwrap_resp_integ() authenticates only databody_integ. The checksum
object and any bytes after it are not covered by the integrity check, but
remain visible to the XDR decoder.

This makes RPCSEC_GSS reply payloads malleable by bypassing crypto
integrity. A modified reply can contain only the RPCSEC_GSS sequence
number in databody_integ, reuse the reply verifier MIC as the body MIC,
and append bytes that the decoder consumes without invalidating the MIC.

Decode the checksum length into mic.len and truncate the decode stream
after MIC verification so only the authenticated payload remains visible.
Reject bodies shorter than the mandatory sequence number before using the
body length.

Fixes: 1da177e4c3f41 ("Linux-2.6.12-rc2")
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
Changes in v2:
- Drop the redundant xdr_stream_remaining() guard before truncation.

v1: https://lore.kernel.org/all/20260919212024.2335794-2-Jeremy.Jean@oss.cyber.gouv.fr/

 net/sunrpc/auth_gss/auth_gss.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8ddc65e894da..b4911b6e69cc 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2001,7 +2001,7 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 	/* opaque databody_integ<>; */
 	if (xdr_stream_decode_u32(xdr, &len))
 		goto unwrap_failed;
-	if (len & 3)
+	if (len < XDR_UNIT || len & 3)
 		goto unwrap_failed;
 	offset = rcv_buf->len - xdr_stream_remaining(xdr);
 	if (xdr_stream_decode_u32(xdr, &seqno))
@@ -2021,13 +2021,12 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 
 	/* opaque checksum<>; */
 	offset += len;
-	if (xdr_decode_word(rcv_buf, offset, &len))
+	if (xdr_decode_word(rcv_buf, offset, &mic.len))
 		goto unwrap_failed;
 	offset += sizeof(__be32);
-	if (offset + len > rcv_buf->len)
+	if (offset + mic.len > rcv_buf->len)
 		goto unwrap_failed;
-	mic.len = len;
-	mic.data = kmalloc(len, GFP_KERNEL);
+	mic.data = kmalloc(mic.len, GFP_KERNEL);
 	if (ZERO_OR_NULL_PTR(mic.data))
 		goto unwrap_failed;
 	if (read_bytes_from_xdr_buf(rcv_buf, offset, mic.data, mic.len))
@@ -2039,6 +2038,10 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 	if (maj_stat != GSS_S_COMPLETE)
 		goto bad_mic;
 
+	/* Expose only the authenticated payload to the decoder. */
+	xdr_truncate_decode(xdr, xdr_stream_remaining(xdr) -
+			    (len - XDR_UNIT));
+
 	gss_update_rslack(task, cred, 2, 2 + 1 + XDR_QUADLEN(mic.len));
 	ret = 0;
 
-- 
2.47.3
