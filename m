Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627901;
	b=BRM6mvQUh71mZ6P9Xdq49VxC9wCZKOzXyNfNSyuTh0eaNJie/MpXWfF7iaJFEKLCF9Yk
	 Tzo7EAGifI1KiuL0mK5RZbFjsm12rXnD2n/Cj8c4JlViB6QN8cBz1ldKD7k5nr+ZYl94S
	 zHn80HFDJFuhGnxMiksd0Gx7aeMNqBaGkv5iZWc4CQll6M40W+biRwqmLXzLnUucAvRZT
	 v0QXVTbB9GB2egNrLNLAvpYMWi/lzUCkwsAv4dz09KZvIWASGz/snniaaA68II3bvn+C8
	 LsLo9L3g5BpoLzShV+Sbp/lmpWuAFuLZ6nP8qPrUE8tI0a1thX/OV2j80kn7YdvBl9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627901;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=92pciX5e0XOpcOKn0KPC1KN+u9eFBOYlC0y/F1tTbhE=;
	b=pR6+3sa5z/CVPcY5lfoOB85e3BGlpOMj7AuwcQEL9sX69WpODM7Al2Kk9pgFmnWCILMK
	 PsMT7nUmqfKFjcnk9AmZ3LtrfEVKGvg1hySXLfJz9sWlYI0LnLMjx4PLXIx5tbnLn+4wy
	 IWhftv9jg2JWXpgRrI671ad0iQqFShO8No0BxFGkE45GG2rqGa/kP3PaquKTPxfiW6Aao
	 KJ7YLnhYWP5ER/iACr9S4cYmQoA9B4/Md8bWiw/Y/UcjzqzLAt8R45w3unqXFkuXEDKIx
	 YyjNhoHmgg9lmCkEK4Tb+/BL+1kYtUttaKGEjjMJPWAycEpL27aRGD5+YtT5Sl+07sQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="LA7e/FhK";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4004960A2600
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:58:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LA7e/FhK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D21451F00A1F;
	Mon,  2 Nov 2026 13:58:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793627900;
	bh=92pciX5e0XOpcOKn0KPC1KN+u9eFBOYlC0y/F1tTbhE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LA7e/FhKnJ5U3B9408lJ1SrA2Fvl3B8DWiUk1A1ktPhx+vsxjRd7SB8vDPHVUz3FK
	 NIXlT4wJYOQo9ENdZ+IwHK2jg7nBtH9+NPji+IqC2DZuOMTRtCHrTZUOg388ZQ6yWr
	 B0CFW+oW5uSH+X3qQ7MJcIsSzeq3kiTlmi0XEhPXUZG4Q5MqoebrKZx3Zbc9kNAakB
	 tBvDu69VP3tjhjNlZncwnNtQtQkJBEhiZsGIOfaDM2g3DlqXVda+v66P3D+fTQgA28
	 bHwp4e61bH2Xr6ExCXiZwEmCaZF8For0SQ3qyxggt+Ncyhw+KyUZPdl+jTOEjjzLHd
	 ntsDy/vrjqF5Q==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 02 Nov 2026 08:58:05 -0500
Subject: [PATCH v7 5/5] NFSD: Defer the PUTFH export security flavor check
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
Message-Id: <20261102-verofess-v7-5-d2cc0de4d44e@kernel.org>
References: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
In-Reply-To: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2839; i=cel@kernel.org;
 h=from:subject:message-id; bh=DrpKyJCC1BuqBgJD+T7ZVOJM5S/alwdWQWsqgg6bJrY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6Jb1kBGkyLRqkKDJZgiFlEPlMivBePdxJmD0J
 1gA0zJJpCyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauiW9QAKCRAzarMzb2Z/
 l8xiD/sFDMwO1g5kkLR/1Z1O6W7OdWuuloYTra8hOjokzIo4lXu2hcqkBacWnx8K6KlMImYTHUe
 rYWPN4GAS3aqbNiMErT2VbBHJp7eXkhGUomIgIz15AcA2aP9hYsNjfk9Sm7F9URAHRR+BwiW/Jn
 buvtnOgpFnZJzEC2v5cVp18Zj1f+ALqZ9F0R64ydKPfdCPf7VlgV01nGatT/OktS3mvURr8gkHV
 uPvT05zF4bN9jv7rq2KBpXtWxUHcdNkTIxY+bnqX4Du4TrkQCFtOoCk+g/MOtJ8EOo7KClgPQie
 EoguqFv1TehKgyBdK2+JixCCa+B5tA+2ORe+727r58gMvN9PvSz6AiOrSPqxhreACfpJKQc1z4f
 xO/T8WGqZbZGip7ktfCb+LTrXxNY82YlIWRm6aqxNY1CyUBC0Xc/bo+zqR79ALaifkwLLEfxyno
 xFMhEl2UyqBu6q1yuwYdy78I9tPsxEUrqxWZoQKKb9HD53VrHevEjYTMFfPjJek57frlTcEDV0w
 cJamBbApxnfNFBjhR0c0UR5fK9rHqCAQYkTRMCHx485PSggiyfGmRYbJM6EgwDMgIJQwky9316k
 JVx1TTC0vv2gqLumFOnxngNnsiYfbPS2P/nvajkHXMbJjHC1AtP8PfaTEyvR+2jmJtL8T80qZX3
 rMUlQm3Iz5Z3j4g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An NFSv4.1 client learns an export's security policy by sending
PUTFH; SECINFO under whatever flavor it already holds. nfsd4_putfh()
verifies the filehandle with NFSD_MAY_BYPASS_GSS, which waives the
export's flavor check only for AUTH_NULL and AUTH_SYS, so a krb5 or
krb5i request against a sec=krb5p export gets NFS4ERR_WRONGSEC from
PUTFH and SECINFO never runs. RFC 8881 Section 2.6.3.1.1.5 forbids
NFS4ERR_WRONGSEC from a put-filehandle operation that SECINFO or
SECINFO_NO_NAME follows, and Sections 2.6.3.1.1.2 through 2.6.3.1.1.4
forbid it when another put-filehandle operation, LOOKUP, LOOKUPP, or
OPEN by component name follows. Commit bb4f07f2409c ("nfsd: Fix
NFSD_MAY_BYPASS_GSS and NFSD_MAY_BYPASS_GSS_ON_ROOT") narrowed the
flag from skipping the check to waiving it for the two unauthenticated
flavors. That is right for the NFSv2 and NFSv3 mount-time callers, but
it also closed the path that let a GSS-authenticated PUTFH precede
those operations.

Skip the flavor check in PUTFH for every flavor. fh_verify() has
resolved the filehandle before the flavor check runs, and
need_wrongsec_check() already decides, from the operation that
follows, whether PUTFH reports NFS4ERR_WRONGSEC itself. The operations
that may follow without that check verify the current filehandle on
their own: LOOKUP, LOOKUPP, and OPEN by name through fh_verify() on
the directory, OPEN by filehandle through do_open_permission(), and
SECINFO and SECINFO_NO_NAME with NFSD_MAY_BYPASS_FLAVOR. PUTROOTFH and
RESTOREFH already rely on the deferred check alone. A v4.0 PUTFH that
SECINFO follows keeps its check, where RFC 7530 permits the error. The
transport policy check stays in PUTFH.

Fixes: bb4f07f2409c ("nfsd: Fix NFSD_MAY_BYPASS_GSS and NFSD_MAY_BYPASS_GSS_ON_ROOT")
Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20261101-verofess-v6-0-4d70097db7d3@kernel.org?part=3
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6ff59fac9094..2c653027d578 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -827,7 +827,8 @@ nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
 	memcpy(&cstate->current_fh.fh_handle.fh_raw, putfh->pf_fhval,
 	       putfh->pf_fhlen);
-	ret = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
+	/* need_wrongsec_check() decides whether the flavor check applies. */
+	ret = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_FLAVOR);
 #ifdef CONFIG_NFSD_V4_2_INTER_SSC
 	if (ret == nfserr_stale && putfh->no_verify) {
 		SET_FH_FLAG(&cstate->current_fh, NFSD4_FH_FOREIGN);

-- 
2.56.0

