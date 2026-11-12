Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516200;
	b=rehtOWqQU744osXRGZBnlxVOsCZikIHHA/TSPHraAS5RYu6OEAstzTzTvG74J0/crzeE
	 Nds//LVLFmRjdHmJymjj0xWvaWXgCpdQZmZcc2SSjftAyRw4XQpzXIdq+PUCiueLc6io9
	 v4Q8I0k88bi2SbwzHSlKp7DP8ESPYNpLtugmrPyXKj+ocxhlNzK/tXJG+lM/GrILdHwOt
	 cV/P1zrF8WIoXpEENN2NWIEycXkbRL+dGYlm4sPOrf1rqouJaI51tq0LBw8k3IEiFibkb
	 iQKjaiUD8148Kp95aegf+YPsGVpS108fvG6yF02yn6W7krsJEDFcl7dWJYnWInzW3MA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516200;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=NDj23KQxeoDtJgA51KD6zzW3wMiCa9uxKpl3tEGub84=;
	b=29pnduzKv3UncrUblQdtRPO6qXtaVa/qv10Uqwivh77ji4jzxGw0rsFF/0sdUuy/Rrub
	 wbd8BzZxOy7Yh2gjIsfCNzTPj4ZPDmRZ31SbbU2DlEHQ9x7aHSYZ/HEUuohZ/3o0zjo2A
	 0C8LTp9t/GYFMbkVIgHmhxoPy7BueS2+fmN8/3XiDvIbLsCmjXEW0WOf+xLDsctZ7BFg9
	 QHiO1CNtDvtfZiFyAXOF5LOsD3zTWNZxQwnCFU0BycFwl6pvbNd0bpWk++p4gXPNT0XTD
	 c+NbtiTFVBWRtIG0lWgUFDX6lLggx3An0Yi1DQrqh8ax8OWf6wzk/alLLmHET302x6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Dn3RerT7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85C37606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Dn3RerT7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F5071F000CB;
	Thu, 12 Nov 2026 20:43:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516200;
	bh=NDj23KQxeoDtJgA51KD6zzW3wMiCa9uxKpl3tEGub84=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Dn3RerT7s2iDjK2QdZOthS9Qdhn4mYOKC1SiZRpee4PLJlAnz/rv3MQ1fFw33RlEb
	 Xz2+QxClBk1tLUr/uhJkDsSm/TuQeXxVg7kA+QHvTc1QqcPAUvYc77u3Vv6vLaEUnc
	 zF80ivz1BcmX5WRCFhcROjJ3e+rSxi+mLnTTgBNsRDtNzEIBLxikPE6wanfDs3742/
	 rHtQK66mcTfGD9HeQGqF1bbb/zd/xNEGqccB0P/W6I480Mg94jgI0yKUwneHKflN9F
	 r4HuxUdw870m9CJd1oopk1s/dlczF3aZJsH0PbCDMCpqi+i/PT3Owfbh+Nvgu5Xe0Y
	 2x/lM4XIgcm6Q==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:06 -0500
Subject: [PATCH v3 6/7] NFSD: Use each export's credentials for the COPY
 and CLONE stateids
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
Message-Id: <20261112-verofess-2-v3-6-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3179; i=cel@kernel.org;
 h=from:subject:message-id; bh=qSCb2kFlDPUjU8snLIDsbEsUJAov2PTqTta11hbQEdk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTe6ujRCXV4zNGpV4lEc+CRbMhpHtb8K8GJ8
 6cI9IinD0uJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 lwi9D/9M7CriipCciAaVoAvUatZdmeJbs45sv+WRzH10f3HFaT222bAHAmnoLPe7RSzVbTwebZA
 aCi7lGv6vjfg1lvRNlbmaDjZT/PK2/rmuSXCVa7sKzc+07srsx3LGfM/4A2THitTsMojjgOBsLD
 /DZk4oGNDuwleG9Y2eKzkci8zjNJOdwff1lwYX8zXIIyvOJe5kFDnDJM0PM/B+sY2hYez/iOevp
 FRNpktKWj3u6H9H53Gnyv/2s2tnUKdbI652bGTQiTjv93QY4zMNhMlfx6jOZnSFfaokhaqXUUnb
 gotI6z6Vd1CjjeMGHNtWmPGXz1vISNjz5X/4dML5SHkKTzTZiWv6WwMRbH+LrI2Tx0Uunp5tgQr
 XQA5VyakSaDUbygEBrq3xvzkIYXrsKZctX+C4Vw0d5g+Teb4d74RcAWEJFO9yP67vIMhe5f1av3
 Jy5l94fpG6nyoRIEmgkFEiEprcMIG0OaRNiNq3roECjFUudh+QpCFTeP02AB1PJSt7U86TgqKtA
 ljuFX28tNyEH6LVLnPh62PwdrPfcANKDpT1sEAcIk8VF8i7mlsoxbaxY3o3zlDHxcZKDFJW6ygD
 92FdgxdsyFpP5EqYQ/0dHRXJq18Qxp3VKw6arB2gunSqhLzRAdiDXnOlvRkPy45Tg9mMupta5FZ
 VJSAf4xCsTMRxPA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_verify_copy() checks the source export with check_nfsd_access()
but resolves the source stateid under the credentials that PUTFH of
the destination installed. For an OPEN stateid, nfsd_permission()
then checks the source file with the destination export's squash
mapping. When the source export squashes root and the destination
export does not, the source file is checked as root. When the source
export uses all_squash, nfsd_permission() runs as the caller instead of
the anonymous UID and GID, and can reject a request the source export
permits.

Install the source export's credentials before resolving the source
stateid, and restore the destination export's credentials before
resolving the destination stateid. Both exports have already passed
their security checks, so neither filehandle needs a full fh_verify().
When the source and destination share an export, the credentials
PUTFH installed already apply, so skip both calls.

Reported-by: VeroFess <coderzeng@gmail.com>
Closes: https://patch.msgid.link/20261103013237.1174538-4-coderzeng@gmail.com
Fixes: ffa0160a1039 ("nfsd: implement the NFSv4.2 CLONE operation")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5121e7e80db1..702fa3e99c67 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -867,7 +867,7 @@ nfsd4_putrootfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = exp_pseudoroot(rqstp, &cstate->current_fh);
 	if (status)
 		return status;
-	/* RESTOREFH assumes the credentials for current_fh are installed. */
+	/* RESTOREFH and COPY assume current_fh's credentials are installed. */
 	return nfserrno(nfsd_setuser(&rqstp->rq_cred,
 				     cstate->current_fh.fh_export));
 }
@@ -1538,6 +1538,7 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  stateid_t *src_stateid, struct nfsd_file **src,
 		  stateid_t *dst_stateid, struct nfsd_file **dst)
 {
+	bool crossed;
 	__be32 status;
 
 	if (!cstate->save_fh.fh_dentry)
@@ -1547,12 +1548,27 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp, 0);
 	if (status)
 		return status == nfserr_wrongsec ? nfserr_acces : status;
+	crossed = cstate->save_fh.fh_export != cstate->current_fh.fh_export;
+	if (crossed) {
+		status = nfserrno(nfsd_setuser(&rqstp->rq_cred,
+					       cstate->save_fh.fh_export));
+		if (status)
+			return status;
+	}
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
 					    src_stateid, RD_STATE, src, NULL);
 	if (status)
 		goto out;
 
+	/* The destination export was checked when current_fh was set. */
+	if (crossed) {
+		status = nfserrno(nfsd_setuser(&rqstp->rq_cred,
+					       cstate->current_fh.fh_export));
+		if (status)
+			goto out_put_src;
+	}
+
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    dst_stateid, WR_STATE, dst, NULL);
 	if (status)

-- 
2.56.0

