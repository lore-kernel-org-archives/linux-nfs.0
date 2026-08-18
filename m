Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B8912BEFFD
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 00:57:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787014646; cv=none; b=XkJ5Ghq1dv147gJJwVcTHSphq1c6GjrgQLyEOMRq1MQCneyOZHlXWu5QGNiFDG0by8q5uo2q+4DR7HACP+7M1GFbxe8OYhg745MXCSMB4mP0LVYDYcEF9P2MLJ4M+fp5X9103Vqv4JTc27WWLeq/NDmW+8PpqzGLON7QjDv7pDI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787014646; c=relaxed/simple;
	bh=1IT2RoqEG/PNmehgzeH9EttL5Y81QZYxXMB8/F5vNas=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=BNy2ZXwqv2AJGAcpMijJI9mpGiQsMygTc/iRnrYeHa4Jse19yJCfyRTrsayf4oXEYrj4JMn1DG7kWdlszE/Nh3HmPCbzcBEWQIYlwTYoQUm6m8YBaFzoBjLnwfpwRoVOsZnZneNunbk+OJ/4sDGitOtje/XpbGqmBFQrzFFakm4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Y93QOvN0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y93QOvN0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C9AA21F00A3F;
	Tue, 18 Aug 2026 00:57:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787014645;
	bh=CTrsmWG6zgmZyNX5loDgumuEzbnjONav24MJ2HqVTHo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Y93QOvN0i24zYvfF3lbBjFbGIwVtxMtY+ndA8GZeEwb1gaExXFjHDK00GxTIPr6uS
	 tj3PAFaxc9SW8cp+wbBNQX+Fd1VvE86EqZytf0KT75gewRzG6aRE0E5L7t49Y6Ymw5
	 +66+s2PdiB9PdU8VLf3wSwv+C5MwLgSnXEsCbP9Y5u+Prqq0TrmH5BQRisYY50Hc3u
	 RVVP9vN5PpaxXXIwUIhsGbJJGzSuIGFOtBeJvZYtz7j22e5Q32K+5z+TxXOPraVZhk
	 9+mE3grBaGF9b7y4UCsmyXilIRGWPEiDNd/UF5eB84jxjfURem3fFy/R4MjStSOAF3
	 rJEq5eUKqSjQw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 20:57:15 -0400
Subject: [PATCH 2/2] nfsd: set op->status when an operation's header cannot
 be encoded
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-jean-v1-2-9e356596ab85@kernel.org>
References: <20260817-jean-v1-0-9e356596ab85@kernel.org>
In-Reply-To: <20260817-jean-v1-0-9e356596ab85@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1892; i=cel@kernel.org;
 h=from:subject:message-id; bh=1IT2RoqEG/PNmehgzeH9EttL5Y81QZYxXMB8/F5vNas=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg63zStvmq7aqztHMpQEtyGXB2DucsvhnX1jx8
 pOPk5LZaRWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOt8wAKCRAzarMzb2Z/
 l1OqD/9Ugcs64F1q82kynhllpob35hZwDwUuvg3omlGcFrjCPv9CJN5FmGeGVOr6AsE/DlES6Fd
 oa6t2tZjWCm70wsN5YcclewrD5Hk09W5eGrWqSB+p+JbKdNv4tuq0x9U5vqJHF24ksB3ZLOsO17
 Z/LTeEAGYSBIxiPqvoNTHOdkuPdE6R5ThIYu8XxRkhypvIg9lKj7RAE4msJmsRFGOGNubnpeJsz
 nJynGMhylwxTUGh0BpHv7PJkpipYErz2X3njFuNqOtaOBsOQZjek2/3s0dnceF1tRKuWqKdUslw
 4iSi2IhaXy1iPux0uYpbGuzA+FKt+zy3fWBuplWpp7iatPZT7DQofL6EOKlLOdTGni5bzUyDETk
 J1eeDYQb85tZN7yzDjvVpnRctAZ0omW7Q6L5EQcRjjaxxe6yIFLTtDKK4ZIWXlxXgUL1vJDi9VB
 y7uO2n+r0wwFkeAeeYnextzfRL9oIVe7gSpqByg4b+4/Wm0XbXIPu/TTdGlcYPo/bTMIYewAqqb
 YNjeY5tH5QyRVAV7eFQwqbt+40Q98vPoS/16gErlbrewSUOiJb4LFrjV2cownIJ8G506zW9m2Vw
 TLmmPAsgiKADYTlqA0bognmj8H46rGenlb/LYu5yaglSd7oSaiCF0PHrQsN0IfX1eCFGMyQ8tb1
 nAqZ97rm7oAvEFg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_encode_operation() leaves op->status alone when the reply
buffer has no room for the operation's opcode and status word.
nfsd4_proc_compound() reads the unchanged nfs_ok as success and
goes on to the next operation, so the reply counts an operation
whose result was never encoded.

Report the failure through nfsd4_check_resp_size(), which the rest
of the function already uses. It returns NFS4ERR_REP_TOO_BIG, or
NFS4ERR_REP_TOO_BIG_TO_CACHE on a session, and the COMPOUND ends
at that operation.

Two paths narrow the reply buffer: nfsd4_sequence(), which rejects
a SEQUENCE result that does not fit, and nfsd4_encode_splice_read(),
which can leave a single XDR word in the head page. Whether a
COMPOUND reaches that boundary is unproven, so this is a guard
rather than a fix.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7d1b2d6f57f2..a154b02d82b3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6723,11 +6723,20 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	unsigned int op_status_offset;
 	nfsd4_enc encoder;
 
-	if (xdr_stream_encode_u32(xdr, op->opnum) != XDR_UNIT)
+	/*
+	 * nfsd4_proc_compound() stops the COMPOUND early only
+	 * when op->status is set, so a header that cannot be
+	 * encoded has to report the failure here.
+	 */
+	if (xdr_stream_encode_u32(xdr, op->opnum) != XDR_UNIT) {
+		op->status = nfsd4_check_resp_size(resp, XDR_UNIT * 2);
 		goto release;
+	}
 	op_status_offset = xdr->buf->len;
-	if (!xdr_reserve_space(xdr, XDR_UNIT))
+	if (!xdr_reserve_space(xdr, XDR_UNIT)) {
+		op->status = nfsd4_check_resp_size(resp, XDR_UNIT);
 		goto release;
+	}
 
 	if (op->opnum == OP_ILLEGAL)
 		goto status;

-- 
2.54.0

