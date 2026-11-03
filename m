Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793735580;
	b=h5nurIlHkTznhL9XhTdGbItY+Ze7etGZjV9J1inPioDqhN18qzTv8xcYlRK5av+58aHq
	 WEA/cjW4TGEVLbZxv0wYL7MwFlBalgawCtsC5YlJqffiBwDwScyNc2+h/FcNujlsq1Lqw
	 86K/1JXJFScTH90FfAoPSQhxlnsn7/1pfmYpzqfr/FzK0J9wCgxCr7M6k9VUbSvauEXt3
	 yMoM/o9AFNi87F0KvyBwwVFmKyEdxlnJdlsEBIxCTDtERkUMTcyTNgJfHthO6JI9n2Hmj
	 9CX29C4+zRFjy+XhfEibYRfWfRNGjnY4YJYckcLtJezIC3G3UZpZMOqaiUvs7ny083w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793735580;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=OfFYL30PYx5VuX0GuKBUrhg5U+I57tDG+1vv4wurPOE=;
	b=DKP6OfDEXG5EOKhVvFfhTSdD7ekgKvqinync8Oh8MLVkA5bBGqrE+T7AKUUOFLT9AtVn
	 kntQv/UaHyb5D+czKyHVaIVhuvIwXCmtFRRF2ULW/QKVc/lcqEq8UC5xmmouxO7JwcCDP
	 rvAOqydgEED1UbxXQSAu1uamO2uiInsZnGbhb3q4AaitTgR3P5Qn6bri7SZNJZcn03YKi
	 lYfqG6tIo3PVCONpTLpAYJOWXzxOiE9xZ6Pbf6PfhnlulSo+VmJYE8TvSmwdUR3hybo21
	 Qij8Yr6jWs0UmpaLgmaFa7tqwswABCoo/zT0Vc0h9hBQIeuU3HySndf+k7RCwp8vJMQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G4uD7nDx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB7E6606D808
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 19:52:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G4uD7nDx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E78F1F000C1;
	Tue,  3 Nov 2026 19:52:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793735579;
	bh=OfFYL30PYx5VuX0GuKBUrhg5U+I57tDG+1vv4wurPOE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=G4uD7nDxg5AfjcH1EtjCaB+UMoLJZ2LSR6adG4CRDcMUk0g9JrRLQ7w4Zt6hxLboS
	 uHqc3KTc9hcnjKJO01jMGCsmyZBGR/eBlPyMzVmQniWtmMC6uZI7F/m9yJ6QBeZQ0o
	 MkGfDieKU+l3VNXkhhUJ7+X8v6DXR7GqJ6boEOgS5FUG14/wijZI2yTc7SpkidEdst
	 8aMiZtERLMh5g8wurcMQAqcagZH+6iC05/PnUFr2kTt5kaGmSCz5KYDpddf9KZElgy
	 /FXN9S9F1o/iHCHfiREBUwS9anLuAN29vA5AlgDrTCW2UGQCEjioyamdFIgGtzrziy
	 SSnugSCpViU0g==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 03 Nov 2026 14:52:39 -0500
Subject: [PATCH 4/5] NFSD: Apply the entered export's credentials after
 LOOKUP and RESTOREFH
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
Message-Id: <20261103-verofess-2-v1-4-9e6568221beb@kernel.org>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
In-Reply-To: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3718; i=cel@kernel.org;
 h=from:subject:message-id; bh=jSkLTRw6lSLN72n8PBe5jbJadux4btP/d+OIT+Tezpk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6juWJenA1UEnRyWnwOoyqlbdMuTEFA5oR7rpq
 Lc7tbzzHomJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauo7lgAKCRAzarMzb2Z/
 l4xwD/45SCiIMdL0WZ/glyzPGyE73rFmUjDJKCMkQTjplUqZCXuZ9MTAK1Qbo8eoCFlfXzvgjGQ
 jpwFyFFGUynhlLqtiZEkYeQiN9znRiW6nzgak23B/BnKuMlf01qAivy6iK4V4CaVyp+bLx68nkA
 cR7OA+14SBl+fiWopOcz31pV25zYYCbbHecxt/a0WouQGsI+5eKlR4gKghgQJ9iyERnbzf60+3L
 zytsJgYd/C0uK9CUCtIeoeFaaLb/0Bky0jhJr4GF3skFJ3Ax+J4P8BtaiV7yUVAtFqdLrUat4Hz
 e8PCUjUMFxzVyKYqrYe3fjh05FBfDeJzvhdXORyzdFdQmdgJBSf3hGsMRZXr2bOfRq36H0lqpJT
 uxAqf3fVQQWp+B04II87g9vSFEAj4mUHoSLGwU76Rwu1U5fMaPnEjUnmFYKQiQeIH+/XGfksL/R
 b88ut5efzTNJlSY0wdAt48f3rxCv2VXRQJozR4puCYJ3Ry9CM2dHSTWz/ZcVfSkogTc+hjnXwBk
 xQFWVZJiGmwmGYlwx7amH3KnVjuit7YlBsafzPLr3EaiP3ACetCGgPfScnhjbX6cETidWZWcITm
 0Q5MjQd1jhWir1p/AnbYIfXLe3mrZGubwBhtceNVdH1lZJoOkwtYjChhtPW9r9GWTFLfrlD7Pdl
 DCdhzn+KmYcngyA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

fh_verify() installs the credentials that an export's squash options
map a request to. When LOOKUP crosses into another export, or
RESTOREFH restores a filehandle from another export, nothing installs
the new export's credentials. Operations that use the current
filehandle without calling fh_verify(), such as READ with an OPEN
stateid, then run with the previous export's mapping. If the previous
export does not squash root and the new export does, READ runs as
root. If the new export uses all_squash, READ can fail even though the
anonymous UID or GID would be granted access.

Call nfsd_setuser() for the entered export after a crossing in
__nfsd_lookup() and after RESTOREFH. The crossing has already run
check_nfsd_access() on that export, so a full fh_verify() would repeat
those checks on every LOOKUP that crosses an export. RESTOREFH
likewise calls only nfsd_setuser(), so its flavor check stays
deferred. NFSv2 and NFSv3 verify the filehandle on every request, so
only an NFSv4 LOOKUP installs the credentials, and RESTOREFH skips
the call when the saved filehandle is in the current export.

Reported-by: VeroFess <coderzeng@gmail.com>
Closes: https://patch.msgid.link/20261103013237.1174538-3-coderzeng@gmail.com
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 7 +++++++
 fs/nfsd/vfs.c      | 9 +++++++++
 2 files changed, 16 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9762a56d30ad..8c7b81f62125 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -49,6 +49,7 @@
 #include "xdr4.h"
 #include "nfs4ctl.h"
 #include "vfs.h"
+#include "auth.h"
 #include "current_stateid.h"
 #include "netns.h"
 #include "acl.h"
@@ -852,14 +853,20 @@ static __be32
 nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
 {
+	bool crossed;
+
 	if (!cstate->save_fh.fh_dentry)
 		return nfserr_restorefh;
 
+	crossed = cstate->current_fh.fh_export != cstate->save_fh.fh_export;
 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
 	if (HAS_CSTATE_FLAG(cstate, SAVED_STATE_ID_FLAG)) {
 		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid_t));
 		SET_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG);
 	}
+	/* RFC 8881 Section 18.27.3 does not permit NFS4ERR_DELAY here. */
+	if (crossed && nfsd_setuser(&rqstp->rq_cred, cstate->current_fh.fh_export))
+		return nfserr_serverfault;
 	return nfs_ok;
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6332341a8fba..02df2ff02d60 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -41,6 +41,7 @@
 #endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
+#include "auth.h"
 #include "nfserr.h"
 #include "nfs4ctl.h"
 #include "netns.h"
@@ -338,6 +339,7 @@ __nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 {
 	struct svc_export	*exp;
 	struct dentry		*dentry;
+	bool crossed;
 	__be32 err;
 
 	err = fh_verify(rqstp, fhp, S_IFDIR, access);
@@ -350,9 +352,16 @@ __nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
 	 */
+	crossed = exp != fhp->fh_export;
 	err = fh_compose(resfh, exp, dentry, fhp);
 	if (!err && d_really_is_negative(dentry))
 		err = nfserr_noent;
+	/*
+	 * The crossing checked exp but did not install exp's creds, and
+	 * an NFSv4 stateid op uses the new filehandle without fh_verify().
+	 */
+	if (!err && crossed && nfsd_v4client(rqstp))
+		err = nfserrno(nfsd_setuser(&rqstp->rq_cred, exp));
 
 	dput(dentry);
 	exp_put(exp);

-- 
2.56.0

