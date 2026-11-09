Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254012;
	b=oaIJQWVwrH1DyHuE83tRqKkIOEk4hVku/BbwxfqsOY6zESvHas3W/rEr0EpehEC7k0tp
	 gSNLtPAbJjwy2JtEq0Y8ryMdytj2rADNuRmQixYTRRJXnOs5AgGdue5TRgR5Dgw4YOkOy
	 AyhorwoXJ9jbhE0gusx2oW0IY1US2zEfjWfZrmOTEzvzeDVpe4QMx9khOqepSx/xaIN3t
	 rXNxAsRDWOMmig+2N6DQaLzBkC2vRXg2oJZPPGZ+CY4J/CfAhQ4x29HvVs9qt4Do3tfFm
	 Z2e8CeOsJLduHSxzaozSTV6c1guZeZMQXvP12ynKf7lKCTzxne2koBMTAfNGCMcTQjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254012;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=sgX/gcEuyjv97CpKMT2kbo6NTMJlRtHdKcmrN9Okz2E=;
	b=3/Lls8QDGmHOVRQ8wLOZzia1dSPB/bp6Mw+3Vd3f4YpimAtfow7GKFMtr6BiOmSGTQRh
	 8mUgC3yK2cgr8gPLuABY0boQ1klBlkyRnTaj4uQoqzjKCXsFPODHxrzMZreE5g+HTiwIN
	 gk43SEj2yK7xhyAtIyMUXLNXXB5AC2/troIvSRuK63vimAGPAPvVT9ybVj1BtHZ2R5vAP
	 ROB4HUFaLXdJ8iok7KcxH0h8FUcbpLAfT0ketQUP9EcINVISVexOxjisSfrReP6ml//Zn
	 0HnIpF35/qk7ouY1h/zm73SJk8oGfmwOTKaVNdgpq/069HtI2Bh24npA+sor35X/+6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kiHzHj6N;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3883B60A3815
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kiHzHj6N
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 457E51F008BF;
	Mon,  9 Nov 2026 19:53:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254011;
	bh=sgX/gcEuyjv97CpKMT2kbo6NTMJlRtHdKcmrN9Okz2E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kiHzHj6NZg3/nMGN56+qOe92xuBXJtDgrmfvrrydZ6YWJfMppK+grbykp/nQeZP7b
	 g4cW+fXwKKygIzfPUnrBAWgr11aEwfelpMOzQmzDuRq/ZKRK313uVxzjnKG1G9lqNf
	 vagtevl2ATOCgbsz0xQMhDpABYSJcUZoPWfk7qFe72+xKY1MwzzjPYv7pVTf9amX8S
	 4pOlsuiFNPftErDLiTFH21d4eOmTblmpB6LPdRktbJ16Sk+CBKtRnSdZ6RnC6vtPCC
	 KNyX/KAJxJh7m8E+8vfyVv1nNPaN0lrN7S/hgzVUU1fwN1XrOVpkNo2wBDYVCk6rb5
	 CvYN4dGdeB3iw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:18 -0500
Subject: [PATCH 02/13] NFSD: Pass the link text offset as the READLINK
 result payload
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
Message-Id: <20261109-xdr-page-base-v1-2-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1470; i=cel@kernel.org;
 h=from:subject:message-id; bh=NcxN32sBUE/UzHM9kZqLLcmEs1dABTogffvwMyIQAWE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS3JYIYbuOaCkim20XrDr4a0V/5U7AWqvhyG
 z3AwHKeAVOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIktwAKCRAzarMzb2Z/
 l4s+EACBZw/aMDQkteEOsfgWAReBlHRZmNMkAiG9g9CrRBX+qT5QuyuJ8QsC903ZWG9cySwr0Ig
 zpt4SvrA+3yfdVEDltWVzrfJhzHhGmCPL36P5lM0gfxEakSlCsbmiQY7kt1d3HQeB5mSUyC88w5
 h7uLj14ml0kxlbob55TtI1YdY7XMr3onR7+Nvr49ER9228n5ve6sREsoXyPIrY8r4xm5323Kk2n
 WEnHYIb99F5wxqHBFncLA/d0+xn0wDqueRW2wSW4X2CtMYpeh569+RH/pm8kHgU6mJMO5LtLJSd
 up/w1oIv8TsORkjzxwZwX4RW+Gr278EgyfOAsoxbmWEp5RNpyCvtjWl0bNQF5jLvXf85hI6bQmN
 byzhWQgbjUD3nsqNYYlaWbG8Yx+J92cz+sqLiH4K9uErf4Q9q7nsrLNME3bIwZx3MEpsnYhfOPr
 z95pzzadtKHPQY/0XSL3SjzMDmFDgjPAvmyiQnqpSxUy9da3fO/p3uJ5+CQMjUFdGUUVuYo/mMn
 oA8XmSwPzvXe6gv1L3En93QLvUfDeVOBRuiVTpdN1ugSJtou1MR6OIqtBOY3uCK7PTVDyAcv0gS
 7nI6PCHZ0MtALPKhuC9L0DnM7O8kQgIkghYzB+gp1H1h0SFrEf//tiNy6x2uQrvaS8DeibkE7OV
 0SEdwPV4MKs1GoQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_encode_result_payload() takes the byte offset of the payload
data in the reply. However, nfsd4_encode_readlink() incorrectly
passes length_offset, the position of the linktext4 count word, one
XDR word before the link text. On RPC/RDMA, svcrdma writes the Write
chunk from that position, so the chunk carries the count word and
all but the last four bytes of the link text, and the inline reply
omits the count word.

A client that offers a Write chunk for READLINK, which RFC 8267
Section 6.1 permits, decodes a corrupt reply. The Linux NFS client
always uses a Reply chunk for READLINK, never a plain Write chunk,
so it has never encountered this issue.

Fixes: 76e5492b161f ("NFSD: Invoke svc_encode_result_payload() in "read" NFSD encoders")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4a97db3dc7af..268f387ff30a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5414,8 +5414,8 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr,
 		nfserr = nfserr_inval;
 	if (nfserr)
 		goto out_err;
-	status = svc_encode_result_payload(readlink->rl_rqstp, length_offset,
-					   maxcount);
+	status = svc_encode_result_payload(readlink->rl_rqstp,
+					   length_offset + XDR_UNIT, maxcount);
 	if (status) {
 		nfserr = nfserrno(status);
 		goto out_err;

-- 
2.56.0

