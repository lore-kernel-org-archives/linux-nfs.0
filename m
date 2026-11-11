Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419045;
	b=vwASSmQVlAIFh0sFRedih6ahWPr4jLICHEzDvBRe3Y6LrJYqZWuUkZG7phvxkxe0DtXd
	 zylcFDEJ/48hpskSd9wqRpcdn6cK71TYH+47wUOROeN4JiljvFVqU7JtfvvCQzIlptC0n
	 Ab4y5AvtxCCT6ofnzW9MJ/gZCAzH6zxh/xfUdSm+HKBBhn4N1t7i6zG1MXk5uvhqilc/v
	 IO/sK+XdUIgLr3CpWWw/S+yP12pYJqsRGEhKISA16/Pcoz5Is2tSBZ32SRxMwVHfaNw4n
	 OU2ao4oWVeHJLhcoJa1rDGcpi3xLr1XbcrVsMNa3vFiRDvedVBBB18CbQ06+03auuHg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419045;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jSH0wWNBZa4KDDzuBg/KKm28TviJioPlBPpvOnhCT6Y=;
	b=o+ZGRZQwwAlikaFFNCEhna99DwAx6Ze35XJz3QSSlGU/58kqPdyDUylwtsqBEyVnpyB+
	 6lrgkpZ6imBjXUwBUnBLqQvhP68E3qvv672rFFlREmOpRUs7hzand+ffTYiQmts1S22G6
	 fFA3O02j8r9ws6sgaKbxXJttWj7G+A80YrVEMX+oHeqC9Vtu9GPPwwbTFtzuycD83kOTl
	 ywFhba7Cvq/aX/jhtRKAEdjirE6seW/XHS/lhFAFUdZT8aOwnr8eDGZzs3/ev57gAYABU
	 EXrQ3IDtKOXqpVfNxLBmWWOstVej1R5b/0Y86WHWZjBZzH+GSWiHQtAz05+i8HNYmjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ATcGADgd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F6D6606A89D
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:44:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ATcGADgd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 511C21F00A13;
	Wed, 11 Nov 2026 17:44:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419045;
	bh=jSH0wWNBZa4KDDzuBg/KKm28TviJioPlBPpvOnhCT6Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ATcGADgdWZjavKslMuxMlLXhNUu+wy+bBs4ow6XOnqVRfIT62mKZ7I8nQ19MMk4/P
	 hqvuRxOuOc9H7eWLeYwI5GCH3YXxlCHjRH87/WeWepCDJZbkTovLMHqa24ev3Ln4iu
	 ZU2fsxMb3t4jFunKfQ+CQU97bkVmI0B28M1xtiQo79Lnp7S3BetbWzlGaPp7NsIthl
	 HrC4puRQ/2CSJm88xmdqIbpZwKiQ/l/V2NWBkZlObEqepyXcp6npSdFxJDwCTcRmSS
	 Hyl+/DCtlcC40xxxnws5465pFr9/SRHcMtOrgU13pmhrO3ldteKZ2Marf/PQb0Qi8V
	 afHZgtJ7G32nQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 11 Nov 2026 12:43:46 -0500
Subject: [PATCH v2 6/7] NFSD: Use each export's credentials for the COPY
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
Message-Id: <20261111-verofess-2-v2-6-01596ca4d8b1@kernel.org>
References: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
In-Reply-To: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3179; i=cel@kernel.org;
 h=from:subject:message-id; bh=tGJkCueFOJgOsZO40svoXSsYvOtxesM28VNeixnsplA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9KlbetbcPGJFZ5UUp1kJqzHcmDeMKOBJ5yW6k
 SdX2qyZJgSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpWwAKCRAzarMzb2Z/
 l2brD/wJWeyfP8VZbKgJI6TwowdCw5Y1fIa6YNxmEftCJzw0Uw4jQcNa+Jza62moqU0fe240zGJ
 zmdIi5ceMJkb+MxnZmqxDICdiCSopZgWK2RLhCg0E+m8NN5SVyaPzMXVCi6SK7mUbc+eDcpX5Jm
 8xMmIZD1tTW74zU26USS41PgTaBuB6uLafEL9yYz1qu1wSyu/Ig9eYYPK83qNR7GSyTVdP4CR1s
 2unx348BiXpXauEFa2NYIoi1e7jbguCdQzZx9Cvl9ZtlE0PMN7XGh+uvg5TtRa9/UtBku8NBOgR
 /+g5zD2Jnm+NBNSA0WoVaWcy3ceB3vSB63kCWIIYLo6Pdd1K20NaBDIzOIyQbgZ/YJxmjJCFoCP
 OjaGjpJSZLK1SPpHnHP+kXR2enx+KqToo1pCNjAw24xnL1ARudsIVRL4ZJmSVRsTsdDEtOna5Yz
 j9IjHR20AcE4azMi4aXi9bHakeTi1jHpC6ukb9jjqPFYD4MpH77r7bY8y7R8qtiGuaZmWVxJP/t
 qd5ooe/2EoVOOD4Imk4Hndrkg7KG9Fqzww+wZYJsJDBbE0yiyvFxxYgpRZnOWguyJVqbgz/kIes
 YLjS/8v3JDzYUIF1nT351GBMq+kaMU7pKEqDg8yQFWpgoIGuN+e+aqpFMrSUj/RTf3qCw3JgsVk
 Zb+uIJ5Z3qhAzww==
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
index d146ae405412..280743e309af 100644
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

