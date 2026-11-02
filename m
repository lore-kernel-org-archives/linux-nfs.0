Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627898;
	b=LMNN/rZsuAx85CVge1HefF3LeM00HZrpixtgodBCYhf6mf/ydcrWHcM2yvljy96MSXb3
	 3S577nEh37f5FOSj3ebisg/uCfObTfSYO8cGpJk7MNWINaqfPZNw36puA9fg7/6gGxeqR
	 hQ8ET3gbipAz97/CTmt/0IH9HnLYwlTqTGUpqTJotmTsLay280y0/PCyYl55MZ/8+dGzZ
	 fEWLz7GFwG0n/I1nUuRC75dooBhPseL7e2bnTt8JT3JDDIy9vT/L+lh/2rf8D8maqNEIu
	 Zk2IkG8woIkm2eNdHE/KHnaCsbTtEPaGRZIvcJKUaKKHCKfMewqABZgqk6p2QVTVCjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627898;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WegNEmpKRRWSzxLhvfvUhla5z4ld8cstexY8Ei6KrLI=;
	b=XbuYtii9udjEo5soaoCTyN1JEzyVjt0fvKd/r1qO5R9y9btxyiE/eRjmy4WeXk26MDt4
	 3BcMjvx9G1Y4PJX6MAxTEici9FGhbdxZ3GehjNLdWtuaY+51l2sURKOy+WY7vk0Q2CcYf
	 6j8J0iQfWcmXzRAwfATneqOycGhwXq3RgW3Lih1GJO/uxXJtdhl42mIUtAzzbbJ+xyykI
	 UaDk3qZJpMyJbC7c8V1ZTkWBjjpCkgnAxabYBGHQGIAq+mra4Pn34ADnRWI5Rn0ui3Ffd
	 k7/3O3+dkY4+Fv8df0NgwzkbJ1r4yWLfxDrhjoVoj13EUQYNUmkDdhH4cEhAGEUDGDw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=emaHUTdW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE92660A2600
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:58:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=emaHUTdW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A91981F00A1B;
	Mon,  2 Nov 2026 13:58:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793627897;
	bh=WegNEmpKRRWSzxLhvfvUhla5z4ld8cstexY8Ei6KrLI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=emaHUTdWQUDEpQ8fttl5nsM72t6KMQiEvMgcwneWO7hB+9Y6RExkOOOUOaX5r4YSR
	 4HJ7P8Moml4gAc7vJHNrem6lU3iINSag/a3sNKrwmeUZzx7gr3kCtblptr9WTx1im8
	 cicTvHHjQZyN2FPtnmwCTyrhxHhYJaREV+IzFqt72jR56+hMrAASFrORkokNtxlko2
	 BnBH8fbV+dLBLqKqWm09TEvY4Cjg2KYRI7hCt7YdI6ITHqM1kdvSH1aJXl/AEUVyg7
	 DPbrCkPXc2dnozp6Qlc7HckdCchVgtmjEcCXPH9GVdR4FP/DyNLX8IhmNiDyDdmrs3
	 oxO76p/oOGSnA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 02 Nov 2026 08:58:02 -0500
Subject: [PATCH v7 2/5] NFSD: Check export security on the COPY and CLONE
 source
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
Message-Id: <20261102-verofess-v7-2-d2cc0de4d44e@kernel.org>
References: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
In-Reply-To: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1665; i=cel@kernel.org;
 h=from:subject:message-id; bh=/MA2K/qSMxYhyaDV8bIgIo1is7pBkgoZl6gCVy67SGY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6Jb1X3pzt9qghO+dGFZs4KT5npH0FBCZj2E1s
 h2sc8lFr82JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauiW9QAKCRAzarMzb2Z/
 l7T/EAClqRUhbF9UB7RB7vImMKGU+mzUKY7itJorxjfLAOUZXHuasntCCxu28fXAp4+6H36bukP
 d/ZkOqG9+nugQ3mp6FUgkekmITPbWPaOwvR2mxyKxY57HUhk4AypB6Ce4jCF6DWDsY1JP264OeO
 0o3Pn80XPJxdh7/x/z0we3ujxhfnmhMPrygxwOsNoK5/M1MjUBjQ2gN2ClqW0HFDQPnIWv4+rR7
 bZJ1RmhessZGaaRu0m/nsmp+H75cyRk7G+oTM+LP1ud64QHBu3h3RHAlw+NWupT/2vqinYvuhm6
 +inauJ/wD5QHPcxq7PajGV6GQn+0ig+wf01aTyTzSHl4aAkDcavpaD3DCp/pECpJj28U9x2jRjW
 RXegDqo8JDn2p1CS9rC3LNeUylULSwRGUDP+iQkw8tmV7dSuBZk8Cm8oHxOa4N+flJEIG1V2zEq
 Ju6AQKG9INYOMNoVPgIeAvS/1nRvt73FiK8zoWoN+o8iP6Oz3SwEHi6RYXY8d0U13ONbaqOEhwk
 migG8O1dpdB66RnYXctgfEi0PB5i4f9PuB/gbof2LigmfVtOvKY0t0NNqpNp2d6tDuzFfq4d+1S
 N6ldGifgyYXnBFuvTCnNpJgP/bNovQts8rslnxtLZSQfoF3zCbFadN3oJJ+TTzbfsfPRiNlXauq
 /nixH2Z3BurBfqg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: VeroFess <coderzeng@gmail.com>

RFC 8881 Section 2.6.3.1.1 forbids PUTFH from returning
NFS4ERR_WRONGSEC when another PUTFH follows, so in PUTFH; SAVEFH;
PUTFH; COPY the source handle reaches nfsd4_verify_copy() with its
export's security flavor unchecked. The source stateid then finds a
cached nfsd_file and the copy proceeds.

On a kernel with only the need_wrongsec_check() fix, an AUTH_SYS
READ of a sec=krb5p source returned NFS4ERR_WRONGSEC, but PUTFH;
SAVEFH; PUTFH; COPY of the same file completed and wrote the source
bytes to the destination.

Check the saved export with check_nfsd_access() before using the
source stateid. Map NFS4ERR_WRONGSEC to NFS4ERR_ACCESS, since
neither COPY nor CLONE permits NFS4ERR_WRONGSEC.

Fixes: 29ae7f9dc21a ("NFSD: Implement the COPY call")
Signed-off-by: VeroFess <coderzeng@gmail.com>
Tested-by: VeroFess <coderzeng@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 50f38d6e147b..b6dcb889b5eb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1491,6 +1491,11 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!cstate->save_fh.fh_dentry)
 		return nfserr_nofilehandle;
 
+	/* A cached open stateid does not authorize the saved source export. */
+	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp);
+	if (status)
+		return status == nfserr_wrongsec ? nfserr_acces : status;
+
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
 					    src_stateid, RD_STATE, src, NULL);
 	if (status)

-- 
2.56.0

