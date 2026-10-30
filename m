Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793395670;
	b=fIQU/BtPHBBFBeu0HCXhTNAg5LSld1nYKQntvMB8RHpOF8utY6ZVgDBWxNu875GQEqNd
	 4IiHRIQj42djTjUnoTswoRi1LQ2BgAOWAAB7n5IUUeWkYy5lSlknPPzYdnnkbkL/bz/Op
	 evZ/ojasZBUzyIdrCWlNpkyQCMfHWhGu+vJCnNEEAAzWFNwdXBF1riNvmxji89ugc7xkD
	 hrk2VfWLLdwvhUd33zulJSiZGSNnn0fmAN2LiaNfD2S/VDCZRCTlRde/GME2WzbWJ+Tyh
	 ccO1YrZXt1W1Kb4GCBZyOl+scapYO763CjjadX1Vlg4eQf848Ty99t0Jw0esm5aGfJQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793395670;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jjlhlA4KpOs7g+hcXM1I68Uw+hLtiWDWF7KKvq1fTDE=;
	b=Zq/UdNYKl3LkSK9tP1NFFFAec98NXGSrvrJs4OCbHKiUjjrSgxo8d3DvLDNkZCa4lDPU
	 UQpDoi2O89iD/zy+4D3qDfNiCumwNk7NPdX4lexPM8oyC/xepY7k/lxod9OOJF5HR14V6
	 akRrayp0yJ+9r82mNoRSh52OF7h0p/06lJ4Lw1XBRsuan1FrGQjfhlZ2/91m6bu10c/NO
	 nGcs70GeQHR+MxJO6k1uRcSOqOu+GON2k7d39AhiaAgC1ZznEo6JicH2FHQycRYzGQH5f
	 t/8/PIHaAz7vOUBpQftlwEhtAD/luQf9S5oaCSus0s0wKz668MXpzPgfkQiXn9EW+oA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eo91bPVU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A08D260A260C
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 21:27:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eo91bPVU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D97B1F00A15;
	Fri, 30 Oct 2026 21:27:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793395670;
	bh=jjlhlA4KpOs7g+hcXM1I68Uw+hLtiWDWF7KKvq1fTDE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eo91bPVUApHxLARh10LSgIUuf4tBfMYbKFnNKqw/0s+lUbnTR70TeQuFLcMvS3iNO
	 GRywvBUbARvczPMmawwNHZuvxFSIalTH3wxsvumKkeCyif1hOjya25ffELoikKIoR7
	 IGVRYLi8uB8es5HLSE1de1ZTK6tAnEmS4KzFMzPgelKpFI/ZK/BoOlpUX4klFP+zU2
	 FkGKOfOeQmBakA1ypowrxxfSmvZxoViD7gGmWkr9K5Dtnqmof0tEfZnTylLIjKunzq
	 r9oNLxn/63QzAj2LSThubwDHZcgNq8sHsYGIrxq/ZSxvKdcQw3cGXWJFWK8Ov+aqPL
	 B8xJI4xZf5xRw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 30 Oct 2026 17:27:36 -0400
Subject: [PATCH v5 2/3] NFSD: Check export security on the COPY and CLONE
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
Message-Id: <20261030-verofess-v5-2-242eea2991f3@kernel.org>
References: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
In-Reply-To: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1698; i=cel@kernel.org;
 h=from:subject:message-id; bh=0/hXnoB2UqTTc4ebIjIjdNCYeA3yfMGZL0PKye8ZGhQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq5QvSFDDBWIzwsWftytPrIQdlxU/oWhX2KqAii
 phj7crnG5mJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauUL0gAKCRAzarMzb2Z/
 l4KKEACE5Fi6DmEqZklyA1zTaS5xhpVJPktD5PDpyOPkZc8UnvmuO2hIPht1U5M7Z+xBHf+SSLH
 MjOUtfpYYYEOB8/cAwnHeNSVlB9lZ1axx2Bes36pJzzPNeVJGy4Q0++CFO3ZBqbuKFDs7R62js7
 4nAXvsNIiHvLDZDPDI89pPjmtWSu00KgPNF3cy54/ghX9eww5or3awg7mpr7wKcnHkmCPDD0X46
 AXqyR4gC8WGFaArjSdiMH7W96vZ25/wH8GZgaQzEG79VYfnOJtwSudH/rMvH/RK1pgFEh1gutuR
 UHCo2pHYDcDFBqAfBNkRo+9qo3ia2vrGZVOo8A45midEah+npWZZDxywmV8LW38gCA5XkdLFZsk
 pxsNMuP+J8c9q6jpdg8VUjTSGH02oLmJfutop4ubSl1T1Hzou4oyw3zcR4ZpiSmmbpEsiepjbdd
 oKI36lZZXqLIpEw4ev+n0MDZwVieGJzuXnKsWF/N+bUFnxTaIWG7HgUsuoccPkImfrtGDP+C0ie
 +tq1tVB/BLS6RXuDSvQRNBi3ZxNpGKcitPCuMdd+FepR6zQz+pxj4ZjuXE6ulixNtjBhqF7lcOp
 NmGPzARiowq2spmujKocDbfrzueaQ+Ul+hkUOIlyyqHmIMAoUN9iPSZ/b5Ahdi+aRdUyb6Hijz9
 KCdf7OuPTD3p2fQ==
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
Link: https://patch.msgid.link/20261029063917.138184-1-coderzeng@gmail.com
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

