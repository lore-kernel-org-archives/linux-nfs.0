Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8B783C6600
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690287; cv=none; b=drMGA5Bw4j7aOR24m+hnKbkIRV4EhsvSVIiVRUPrIJuNMW5iyX/9xY6boltc1Gf70+8+Sdty8ne3CKrdr9d+ZvW1fgrxAggD+uLdRBq/01vs27usM/V8+Ug+4XLxPrJtG/K+iRWI1uSr4y9HjLv/D1Nh1uI/boF5OUSNwZyIO6o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690287; c=relaxed/simple;
	bh=MjTjse/4prfak9stb4djqCHJFpS4RkbtKgxtjxoY1fA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=RnlskopOWgPx6w5QFFi/fd4VjyJRtCd7r0VdqB9o9PxN7xdZUMEjedBAPOi5BKhaPlg/gPJl6mLskgbxOV/DQdHLu3dl4e0IxXom/K59G/bSCfeGU8DIwYJf9d7qsi6Fg28AOgIiWSJyODMbNf2Z23ION7IJzhKNXuAQXir9gmg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MQuH4B1T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MQuH4B1T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 23B271F00A3A;
	Sun,  2 Aug 2026 17:04:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690285;
	bh=EUscUx/LHUC6qU6YQBJls+H8NWoQvsHPDDmtKWBvz7U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MQuH4B1TGz16ghHJoVXp9fOMPHAKa+klQ+0bx+bjfyUy5slLY6OzvHRVl0Et2WZp6
	 6t1n3dTmeFE5A4ECx30GFYaw/VNolPvvVZQ2pC9lxsUtqhe9QsYvskpMG3xrbW++vl
	 NiPXXZxYNaMYGIp85g9zKNAOZpOxkdDC27/CWq3uxper/kkkM6XtTgHtXEZfvxZJDl
	 /yLVudEF56tkwFzpYKHX1B16oydm20SpIGp1DWH0hN/WzhkuA7upGsYhPQWOFu6KFw
	 13jQgfAy67YuOSAi2Z8YprTPsrjZ1Finq48f96C8FNsn/v38slS376MKcgGazmDz7a
	 UDUr8HHHuFbuw==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:30 -0400
Subject: [PATCH 3/9] NFSD: Budget the CB_LAYOUTRECALL recall stateid
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-3-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1158; i=cel@kernel.org;
 h=from:subject:message-id; bh=MjTjse/4prfak9stb4djqCHJFpS4RkbtKgxtjxoY1fA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iq2l4sqVq125Bq33F9u5zpLXpVDyS5vuXE7
 LjNRd3h56OJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 l9AsEACilbA8EfaFnssJ7dftERSfpuZcgk56ET2f/T9WdXpQRkvVPVvQ4QcBDI2yMGC9Igf6KU3
 sEczMw/RMvcYAIpIkxmllN0Vh8Xjy8dpeEoQ9nmmlc8RMfNvwlwjSHQNvv60ai5ztcKkwRLsI4U
 Gh+KZPKYIkmwgsDDNxG3m0Nuewu6PtSCRg6bwwjut/8hcHAD4UZSayFsmScxNKx4fndM5gU3y55
 gS47nUqE7Oj/EPumRvUiUf3r6FowgAUHoxd50ojCSVEZqxAMhb0zTyR+9Ntx1SX+buJz+bw6Ucf
 D44D8Edr0QziJQV5YvoPtOdQxX+rAf2D+y36rApJdPXoDv7W4pXXfgm/Zyt9RQyr7UWpS4NVGHz
 r3maHLb99eG7Lve080LzSRinOKCPe1FOkUDdDYDCWYKIcYGgW0CR00LL+wGIAnYIZjgpHdNwfbm
 nNiyukUrx2nr+gLkWYQsdv3KGQPZVgKUTeH1CUlfUtV/uOCSRXTnvbXHjgUezIobnkJ2juj3N1u
 CnP9ErlxYcMwRh253tr+xsoPDOTqcNyRaDhxrPHXGx0HbWe0WfzPWFufSvCjS2Ie2zDyJyfpWLL
 1tLtKf+jBhu+ccXO5NSL5fxQmyxcAleodK38D2ZygDR5vD1Zk3UaK1mKSGwtPwQSwXIUpdA5bbv
 lJ65rV0AfzWmhNA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFS4_enc_cb_layout_sz counts the opcode, the three scalar fields,
the file handle, and the offset and length hypers.
encode_cb_layout4args() also emits the layoutrecall4 discriminator
and the recall stateid, so the macro falls five XDR words short.

This macro sizes p_arglen and nothing else. rq_callsize pads that
with two credential slacks, so the shortfall has never reached
the send buffer. No backport is needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr4cb.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index a7c8dc355d1a..5285934b3a54 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -27,8 +27,9 @@
 					op_dec_sz)
 #define NFS4_enc_cb_layout_sz		(cb_compound_enc_hdr_sz +       \
 					cb_sequence_enc_sz +            \
-					1 + 3 +                         \
-					enc_nfs4_fh_sz + 4)
+					op_enc_sz + 3 + 1 +             \
+					enc_nfs4_fh_sz + 4 +            \
+					enc_stateid_sz)
 #define NFS4_dec_cb_layout_sz		(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \
 					op_dec_sz)

-- 
2.54.0

