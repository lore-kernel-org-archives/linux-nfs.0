Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254019;
	b=0GavSKuZxF7W0VPTLrokFHdWOGh0hTRYBV5+62cAsYp1E4As9jT22Z9ylXmaFgdf6ofN
	 9QRPaWqnevQngI59qln65ScOPHkzqX5jy/xag058w+Zwiwy7GSL91WPMYOQD3P4Xvei+m
	 s59p405aSbEvEfBnJCC/0+Ap9RhDlJ8uex3iq8VPevPXsxsTxapt4phkWFKvX13l69gSj
	 U1s3NTCovywtp8vBuW0NkIeAoTz8bOJlbJluYdCN8m8Kr/Ng/sWxMb1pDwevl4pME5AYO
	 fOTuZfx3hwGeKOa24pXB5MTHj8zOH4GzuC7iIgoRLlPcenYfDAXoN+cmIaHyoRu6FAg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254019;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=I0HwuxBTP6DxjiOfEuTrFdUzSZE6qxUu5qpZaPKcLC0=;
	b=CwW2/wbee07FCN3FJf/r0xEx5iSUAeX689ctInGSIZkEe/6uTy9moN3E2IlJAFX8MA/v
	 GecvmiWEhsOns25MAAlimsSgwSjxYbOtmR7DThRLq7jDp7Qony4RfPsrNFFeT6/PQM2z2
	 6WmyKssuBxuNFmE2Kd02ym4QVcAixUTduYmFAzbQRlKMQHTljTf7A+p+EBrJaNwAQrQzo
	 cLcGEqJNcJpJiNT24ux+PvUpbU/wQyrquYlDPTkL133gj2kCkY+3Qh+k2xYAnObdQ8zxM
	 ipYtfw5nhkUxXmqTp2T9/JZGp+c44cbf5yCkrdW0QFvCYfdk+nIMO2nAusDWqLiqkKA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fhY8URrO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B90A160A380F
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fhY8URrO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EF83B1F008AB;
	Mon,  9 Nov 2026 19:53:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254018;
	bh=I0HwuxBTP6DxjiOfEuTrFdUzSZE6qxUu5qpZaPKcLC0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fhY8URrOzJJA6bw3LAULTReTt/sGNSlo4pVtAODj7F0T6Z9mLgyGjIdLNuMMyse0/
	 7gyBhLOfP6w3SzuR9IbZSHjJl0SCfYMVvMFgJ6HSv1Pq01B+by/mZYIxLerQ/c+ADj
	 Cx+7ackP9HPpkjJvDz8XrwyITxWBmYneKSs2yy7V75rQY9gAVx6XCJxJ0B2Dh7dvBw
	 0hHcRTCgV8UjWePoXDSkp+wbaijliHTg29ptFbT1aWUdS9YLWx6B+3OdgUUT2NmaLT
	 60H0R0HY9D03iN4+EMhE0cmFYsb1/NAVYZHa/kOAbou2WpBRfxqS1uiipmkfIDlsS2
	 mmdqedFvnq5ew==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:26 -0500
Subject: [PATCH 10/13] NFSD: Round the session's reply limit down to a word
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
Content-Transfer-Encoding: 7bit
Message-Id: <20261109-xdr-page-base-v1-10-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1236; i=cel@kernel.org;
 h=from:subject:message-id; bh=pS+oAQHtOTmk3PgCJuC0NaR3Qxi3+/pRfKUFBx4cj+Q=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS4VsB2zJvSek8iYYDMihtBufSXmXy/0qDhO
 ca2FSXZMLKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 lyEeD/0QJs6zg3b+OjW6JPbvOO45kMT1Tag0G/GkEvmb/IylNKxXrEMwUpZ3Bbb0hDW26SUIA/e
 sQTua0avWzHyPtrdqT2byMfSYXIBtdeq6d+18FdYRubuSqBKFj3iOzZuYK4pGEXzQOIoqSj6ZiD
 X6KH0tS3UhnAyWhZ2ESHGdlGDYUfSMVJQpjSqZQDdvuSAxtccPg7hS8UXUbESN7JVUs17mZAY4P
 V/96KUZHkUxNEx4pV14xa/Mg4aBBgKBICT/ksKmZUpWwArIoa7lF7Oej0jlxh3VtHIHo31JfG7E
 4xUV4xHFXoTPQPMIXXv/EPFbeniMFHCWbdd3BoB+eylZRUkSaeTeld1Gpso5o5ItKxp63UQ4QjV
 6H1roG4Ga8C5d2Nlf3wv5AnGWNplcoCq6gXLC4g2v129Q5ryCWtpbR+121oPu8UHDuNIdPJYAG2
 Mam3uc6y5CtI1MTgeRYGa6yPPYC+HDY74cm50WEcOJVEGIYHrkDi+bwsaYH4UkiggC6i5ac0tfQ
 OQGaDP3ohC0L4bpJTo5Yhlk+v+O2qX6ljMInkmmAvr7tiR9JHGxgPEd8vYIbJoN4HcHayHVJZ80
 6hpDQwW83w7ewEHYbnfu1xmW369f6egczCICbgyoaYroRlLbkaLr0GCBbyoVsDqMxKw7X5GIp17
 hJkhPooozPROlHg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Under a session, rq_res.buflen is the session's maxresp_sz, or
maxresp_cached, less the auth slack, and neither need be a word
multiple. nfsd4_encode_read() caps a READ's count at buflen - len, so
a READ sized to fill an unaligned remainder reserves one more word
than the buffer holds and the client gets NFS4ERR_REP_TOO_BIG instead
of a short READ.

Round the limit down to a word in nfsd4_sequence(). Every other
buflen source is already a word multiple, and a reply never uses the
dropped bytes.

Fixes: b04209806384 ("nfsd4: allow exotic read compounds")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a7df801212bb..864f0b1ec176 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5315,7 +5315,7 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				    nfserr_rep_too_big;
 	if (buflen < rqstp->rq_auth_slack)
 		goto out_put_session;
-	maxlen = buflen - rqstp->rq_auth_slack;
+	maxlen = round_down(buflen - rqstp->rq_auth_slack, XDR_UNIT);
 
 	/*
 	 * A SEQUENCE result too large for maxlen never reaches

-- 
2.56.0

