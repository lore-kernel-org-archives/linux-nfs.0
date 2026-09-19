Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 638F0345725;
	Sat, 19 Sep 2026 21:21:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789852892; cv=none; b=axbwCM8Cwmc1WioB4+uUO6o+1Xr49vZdR6sUxM6je3eGS9I7O7oR3fp1k9BUL5YycfwnXmZWdZHuzsMfD42HeMiDTdjud6/pGZ3PxEPek0QkfgipGPMi5KAR4r0VMHa1PEbuBKd2y9+K4EJKKVont0Q/ip1K7YzQPM0czKb5d64=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789852892; c=relaxed/simple;
	bh=/CFkfMpBF8fyzBHjid3b4/eX04QmMQDYl53ld049TOI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=W7mUKFYkqiAFMegH0gaSFAS6uMXt014HWf8yRcKyq91IpUSomyQWrazMEzpO9Q3TOnoWI7K1B5o6lwARz2s4aN5Z//OI4JVzf4NTXuc8UohWy9dHpO+RClAm7D3wzvflazJLS0uh6DmQBrOzTmenEhfVCizOCRvhKWzKIYSV+MA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=qgyEcQKt; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="qgyEcQKt"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Unsubscribe-Post:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=VGlVhVkMT0o9ZTra6qrIGvE2wdfs8kYNNB8oz6/+LZE=; b=qgyEcQKtBtUrqZxiTZfW53qNuY
	3ff5cmSuVpSuY/8+WS+TLvOH8gGg/jswlQWwCgB+alhndB9JfIiB2wm3wvDrbQxF+FudBwKV+v95S
	kDuZMBvI5h6vYvhtpQylpTcAdnIaZkp6gXOZmpjVNUPoW6xOKrhhGtCPbhuqw7WAQ1AgzfirnAbAi
	8x/WBCuGRhgvEGqCEayUnTAIgIFcN9SfqYMeMQnPPtWqQPlP/7Q9KgLts0q3Q8EfNNZjcGKdRoytq
	AhQMRInvCfipjuhJGl6PURz/9xiXb/p8pNdr6VXof34R7pZh1Xk6XMKVJKJSc8r2psbzOBwKZCoRp
	62Zw2hIA==;
Received: from [151.115.150.205] (port=49996 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.100)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1x82Uz-00000004vfW-3Go1;
	Sat, 19 Sep 2026 23:21:27 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: cel@kernel.org,
	jlayton@kernel.org,
	trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Subject: [PATCH] SUNRPC: restrict integrity replies to authenticated payload
Date: Sat, 19 Sep 2026 21:20:25 +0000
Message-ID: <20260919212024.2335794-2-Jeremy.Jean@oss.cyber.gouv.fr>
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
 net/sunrpc/auth_gss/auth_gss.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8ddc65e894da..bd0457abc5fe 100644
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
@@ -2038,6 +2037,12 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat != GSS_S_COMPLETE)
 		goto bad_mic;
+	if (xdr_stream_remaining(xdr) < len - XDR_UNIT)
+		goto unwrap_failed;
+
+	/* Expose only the authenticated payload to the decoder. */
+	xdr_truncate_decode(xdr, xdr_stream_remaining(xdr) -
+			    (len - XDR_UNIT));
 
 	gss_update_rslack(task, cred, 2, 2 + 1 + XDR_QUADLEN(mic.len));
 	ret = 0;
-- 
2.47.3

