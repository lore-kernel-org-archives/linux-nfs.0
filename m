Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793735581;
	b=hMT0crgL4UuGzvuC07ilWtw8qpjRO8vs7z72oFi11ZO0d6KV04b5eRy2hx+0SFDobtTj
	 FPkaSuEPNqHzCYAvpScZqumJFmPyKWjvlerpAvfcBsQxBeTo/NjneePn+n6OR0DnCpVuD
	 /nVzD9tTqwuQm5Uq7vfk/+6jbSQiFwqhY4YGb14yq19Cie0thF36caUESAY8u2BdfCJhG
	 sAnHIw0zS0bSaXWujFi7112KC9wPbYGzSw6SSvqzwBCCmY1tpHsocokYveYX5NqvLNxNr
	 kOLT/G3YGeXil3u97rWhKh7flv7lUt7/aKaitWvfH7UggCz7FrcKgJHZ9ZHiHtRJ4LA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793735581;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JWyEZLcT3KJgQp5WwYpRdvzvebBkCEVSNg42WrNK3vU=;
	b=LYKLg3if5gzNmUqcv9iF+/VrDGpSgOsG47kklN+RAs2R/y41UHg/I0r8Ks0cRKRxqoFQ
	 KmUT6qtCxegejUK+4xs2ABy+hGtp3MnVVoyZLXwAJ8HuDmwnkHO6rKXUUkoI5Oa+qf27y
	 xmEDt7q7XoXMFrqsr6bDK3aF2l4BB1tnyKv1341w1NkixrIJuGS8c5ToVlezMCC6spjnG
	 UKblRP+N8OtI+zmiospCbdqNT0/bGF3ECl+TNGp+Q6ME8uWgLtFWA8rzvHg0YIiGl1G0u
	 TbRceiErOa/vy7CXPLLfF8TvWpz7+uuw4mwnmdAvKAGuT4pf3ClADfQepKqq9/SesEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="gj/lxgBV";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB4BF606A33B
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 19:53:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gj/lxgBV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0EB5F1F00919;
	Tue,  3 Nov 2026 19:52:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793735580;
	bh=JWyEZLcT3KJgQp5WwYpRdvzvebBkCEVSNg42WrNK3vU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gj/lxgBVIflu6hwlX3KFx4Iq4Bc6wxZxTTzXNP1HJriWmjAbQ7xBeGtZzxX/sYSS+
	 DdbbJcEArTC79T9veENqhSpo6iqjqqBv7Lglm71zM5pulSEpQ06B0svb/80hjHjtC5
	 cslxEDui/uuL1/ESXihBpjHTkC3VNwmVcTCoXlqRYfifnDkKSnk+GxCd90eI8fNoP+
	 Tf1Nbn3numC3ItrA4L6ijILQ6g4Uw5amEsTLknv9WR8tFhcNo0XnOsvNERR97zgO1O
	 8FlOaU2dfxWmPvuEcv7a6lxZlkLDHCix94N2cmZ4xFoa+vsJ+mtsrHY+987oWpiHW/
	 HYlp79Pq815sQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 03 Nov 2026 14:52:40 -0500
Subject: [PATCH 5/5] NFSD: Use each export's credentials for the COPY and
 CLONE stateids
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
Message-Id: <20261103-verofess-2-v1-5-9e6568221beb@kernel.org>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
In-Reply-To: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2730; i=cel@kernel.org;
 h=from:subject:message-id; bh=kSK+ZVJRX1ZcZSE8bG3Wl89PK7MrVp8goGptkgw08Lc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6juWtuF/TM1AvVk2gtipfaosBZN1u1nJYELxI
 cSmBNwUdPiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauo7lgAKCRAzarMzb2Z/
 l1HcD/wN1TtmyhbztJXkPKXs0cBVcrvoLpQiViKNQd5yqeNxNYdKJp3i7paXY0G3JemLoauSeve
 vCj1f6H8R7hvygxUdadhHQwcbrpz/GbNG2Dxu/k9eADZtemb9ByJ99LTadHEOR15PXYBX2+r2qG
 OtchsoVpAwHBeYIi/I7ct/yhWbt0ICMgNlhiZZC4ifHLDnIJrSkMZK+3GCgVN/Oeit8aw3aVbOR
 Q+gUgKvLSxDEsfhRnWwRW2aPmT9tScUMM+14c7h9NlUOLRAF03ghoh2gH73ZlZ7Dv3SoVQjSyT7
 vDHaHnJYh9xwtDWK7bTGeArElMVJ+Jqp40zGyZJALDQ9Hox/3PVT6kV5drcQiPZFXssfIAEYrLk
 ldv3ef4WZCwGcQhzF7o1DygBllkkh0infCte7inneW7FGQZm+gdYM+zmCb99T+MmXzp1WhIh8fS
 TVN5WkRyhyQ3yDllAYMhgoX7xO76nqtGJQAkSOQ3JaR4/Vb22t/l0wzk4o6hC8qVJeevlnbz8qj
 a+dYIx4LZTM9dF677XzsBMBSIJ3nWeq/TIEsyY8xTOKoU2Co7Im7+wnJQe5LjBVlYAeuhVTBJTN
 L6xZOWj2L/U0nwN501V38idO5QSAU1qnyUe0hgPGVRQzaQhR1wuxeNJY2nZ1yj3u6IDaF5O5MMH
 y6fPBVCR/L/aSfQ==
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
 fs/nfsd/nfs4proc.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8c7b81f62125..03ea955f1fe9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1515,6 +1515,7 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  stateid_t *src_stateid, struct nfsd_file **src,
 		  stateid_t *dst_stateid, struct nfsd_file **dst)
 {
+	bool crossed;
 	__be32 status;
 
 	if (!cstate->save_fh.fh_dentry)
@@ -1524,12 +1525,27 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

