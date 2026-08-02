Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 545663B8930
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690292; cv=none; b=id9/P5STIkGAewx/UTU0AweykWWCChKxS/SIIfx9D0UeO/txh/RIYjk1xCzModMom5krBxFvcbJwaqTzFopn50ceMRLd9i4nUylpqKrIV9IyJWe57ICnzf50aQzMdGRCRibfIIulClmtJPvwrFDzoZZh/4sytlWqTItm3Zj8lY8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690292; c=relaxed/simple;
	bh=VFrPyv3iSOoLVFbdM8c+3GTVqPoqDGp3AgaGc7AS2TA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=hZgV7cDNIn7Cnp9CkuIIvByZO2v7J6018G2uoLvaCtTgmnLEgnDHG2GneMBpIHxvQgGS2H8UVHGOqEt7UeipVwm6f71Ls8NSjGZdTU5m5N8PhJbSOB0bN/+PCAsuFSiAS7Lb0Dr+hAK9+AC0TgujXslb9RpeAs5LdPXM1qApAQw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nsT4if3f; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nsT4if3f"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C16C1F00AC4;
	Sun,  2 Aug 2026 17:04:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690287;
	bh=f3Lq+cZuZ2aRy/xXJloy/6yDZRLBIPpBE4RVQXIKUKE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nsT4if3fh0gAFTEmphHm/qM0nhV7YNgCesU93cd0OVnCrtQwXnER3R/OrmvxyedWg
	 4DXg0TD8jF45vvc233eGXUofzfw0klYuqW4AbY3q4OYdYFrC4t8wbh3wWqNYlb4NY3
	 TR37p1UH0DZbtJYIvjTpXnbDz+9axkEWsVTM68hLlBLW0P8NuxwzttCEAxtxfmufqL
	 uEiizJAjLRrLKt2sRgprFaEsSsWE2ItARsaEj9q78jlCctLPkBHBM1LEuzICZ9dkXO
	 lanTf7qtBHpDce8L4Ca5UOh4xEpYGlEMoczKEEHy9B4ggfXEc9IQRvNeW9eXJwtDYb
	 yieCImEyzyetA==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:33 -0400
Subject: [PATCH 6/9] NFSD: Budget the CB_RECALL_ANY opcode
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-6-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=993; i=cel@kernel.org;
 h=from:subject:message-id; bh=VFrPyv3iSOoLVFbdM8c+3GTVqPoqDGp3AgaGc7AS2TA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iqlZ1R6zGJw2QglUMNv2VxIyPg6r6K30gmn
 kp9nG/r87WJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 l7I3D/9c8Nd+5LUDuNYXnGIC8W0KSm8cRMOpBk9madsYJIh5NL4soo5HbFzXY8NLRDcvXX4Wrjd
 JKOaIFbeFtI5N5hf3CxlyD3ZqeSk90EU62qrZ2M+HyvExu+X44zL4gkmntM6ffxFAdTM3ZF0xvM
 wCvZqTBLUtFVyrFsDUXZoLMQBwMN+hxEXGqsPqB5n5xnK+5rWeNqTS9JOnDZ55c018wiTie8I1S
 aojXjSFtvKB8xyPgj8Jfw44X64ajtMZ80G0quEp94nSegQ7CxyHf2EqdoVeS/O9ifS9j/uUe4Ft
 q88rgeIiL8ZrJipqdROdyms722PwmddvntULa/enHebddDV6f5YZNGRG6uJ7wrc1eLTCDeteqDq
 WFH/2gaBPFUU+2rjHzdTVgdZrZywBE19duhnBHYDlYCZi4eNbXW31SoPLUNnYIbuW+oFLaWUWvb
 UQZ/UxjQf6GLonAfwFBGYH8cBRK4yrLBqjlvPOe7YTCyXsbAVJHIB0S8CN2xeW/oFm4iugUkB6n
 kd2+TiaJShw3uAie8jVr1WsOjppAch9nwrGJ73d0286lRGKaESRDIHV4VZLImSYlGJc6ieMWVdU
 KyvvV8+RT1q/UHv/hrCb3GjFOwYs7ypmDP/TC93I4maozk1+4HkagTmcwF/5Cgk517R0jXQ6kR/
 cAa9maXlN/0B1vw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFS4_enc_cb_recall_any_sz counts the objects-to-keep field, the
bitmap array length, and the bitmap word. encode_cb_recallany4args()
emits an opcode ahead of all three, so the macro falls one XDR word
short.

This macro sizes p_arglen and nothing else. rq_callsize pads that
with two credential slacks, so the shortfall has never reached
the send buffer. No backport is needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr4cb.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index 01bb54f03d25..838f8629821f 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -67,7 +67,7 @@
 					op_dec_sz)
 #define NFS4_enc_cb_recall_any_sz	(cb_compound_enc_hdr_sz +       \
 					cb_sequence_enc_sz +            \
-					1 + 1 + 1)
+					op_enc_sz + 1 + 1 + 1)
 #define NFS4_dec_cb_recall_any_sz	(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \
 					op_dec_sz)

-- 
2.54.0

