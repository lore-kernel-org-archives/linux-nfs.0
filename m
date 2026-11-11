Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419044;
	b=SHUNNAtyPUW0f54FOz2usQhEXVZDyaU+71plk0KNa+JCNdzQmDX2fOd/Hi1tCQEX98h6
	 J893eaJo9hdsyL3rkPQUSP+5Bk5oy08aLz91XvUduc1iCgAMWesfGZJhHD7fw3cq258hw
	 +zbFACwZsUmFjQcKWmW6mYG0n3iAI5I9eJHSlMm7kZw0bs4WTVPZZm3YFUw8BZVZKzSj0
	 WFxBnBSMhq0s8bvI9l5nOWGeXvoVukT9hiQGg8ycVSLUwyu26bYToo3zYNsKn1ep7Cwed
	 1LO6ytyY2BIgXR9jbb9L4eFb2/OGMEHNaOZzYO2KEyRekY2iyFpwMVnqoy0IlQ+1vuQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419044;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=aEumcaVWaX3qPVpCpfZy85bv9j3atS9sqeBatCP9q58=;
	b=yZVwXKB5Tp2+/EU898RxHibr+9XSJ+LigSrg4uyhnjTwa6En7GQO/zTbqoFxc+BDFIJm
	 4sumy+rHpcujQ2PkH4WZVJWfTqd6YvAUb8OdXrQL7gn7oWX6mQigCSIO5MZ1GmaZRIYbh
	 TsrPJ18ulEJ1D0uBvdEYl6/kp+fBlXGVgv6hnT/S2/x0u2Hy6Jce2OYaA3fbVzwux01F1
	 TClRAmVRASt2mod5bztZYAocJ1rbQIIwFBGUhW1kzVHFuTlCIN2EQ5o+SkjWZ48wVrzxq
	 DRgjo0UzZbB2FRM5Ivm6RV6Edi/LK3VgLSVUcVWwWUSwy3xRIqjY3LlecgGasz0P6Zw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bx7NBvuj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C67F606A89D
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:44:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bx7NBvuj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 196FA1F00AD4;
	Wed, 11 Nov 2026 17:44:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419044;
	bh=aEumcaVWaX3qPVpCpfZy85bv9j3atS9sqeBatCP9q58=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bx7NBvujqq1ly5Rx32zK6pAzND4f7YP4TvI3SnhGHBlp2OTILs7i/Txjg/zwX1Hbp
	 kVH7xNFcaueosb6OifZEb/gY8CgJ2ChJ9cwuMi3l9g90tPUPd5JDfEnecZg4WCCmAd
	 uCGQcDjMkkjuY78Da9KwCOKK6Jkadq5I3rSJZ6g/9s63zM+U076fsdfh5vz/OjmkF7
	 OeN0LcAJTNMIc53i60anXBDGMllDoD4Nv329gGU7HBBbKgLnSYU52Y/mHhq9HK1IZZ
	 /UkO8PpZnzkqCCvTeLLoSgZNTLReZrwm9LrYWeavEqTXqL5FjE+pXzPbKxA5MhV3Oy
	 VYxEfynri3gCA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 11 Nov 2026 12:43:45 -0500
Subject: [PATCH v2 5/7] NFSD: Apply the entered export's credentials after
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
Message-Id: <20261111-verofess-2-v2-5-01596ca4d8b1@kernel.org>
References: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
In-Reply-To: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4423; i=cel@kernel.org;
 h=from:subject:message-id; bh=K1Qldh0R55Ca9R3N60ztwEjB+8QvcdXJ+15AYXqt8YY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9Klb42o6cW+dKWsOHSKOr397MffpkFxyXIIl6
 Iy71YbtceiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpWwAKCRAzarMzb2Z/
 lwToEACOglEPO+GGExe7pBcYCDe5qSmITH64B9IlYN2gchd/1+33WNQcRYKm2QJINmvjBHrftOr
 vyX7NCu9ckcBEAmw9DW8nK0Hk1yb+7jvYK0WtuH6j/xil5GvU5N5p5P9ehEFzQv/A1LzKjs+Ff3
 pV/70UHVIpuy1le1KNeWsspJwoJB2Sg0vl54VPI18LBJVm6ALEGqLAJBbhpBHrbSaItkeomj1nN
 c4g6vtovHBF9jxi1tcjIqixUnPfx0cT3AMqGJ5+qQc48TlA32VosAXkoPay0Tk1LbJM0AgtdxSo
 j3J5lDgyEJ6Ieu2HH3mZ03KlfGG98IdE6n/CJ7dBAGi0UkjeL0CD+udnftoQ8WTJPCpf/zYFune
 jKD6lAUyz3+TfHB9b5nm3IsETBlNBF4dDX6wLOMGUnTbWqH49SEhjgXvokBG/ZCtdY+RQ9tCE7L
 IAFUiWxxl+ccJCDgzufYBZ4EYCv1iQ8aTuNGuwXn/8J8HikAWde1C2oXFLdRXoWYFp5XbRvEX6x
 80monWUG0MrVYIKCh0GSCBzjr05fDhBPESTYTAjR4tMKEx7FJuSS/JYn1j8MObxMI+XKlbSofGq
 4agGVeh7jGfS8oeDipwe2jdu4kJDlVdvcFDs7XVmqecr+Jne4Z8SLx5333xTY9lnSyhREjiDNQD
 0xEk+fgoX47wi1Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

fh_verify() installs the credentials that an export's squash options
map a request to. When LOOKUP crosses into another export, RESTOREFH
restores a filehandle from another export, or PUTROOTFH sets the root
filehandle, nothing installs the new export's credentials. Operations
that use the current filehandle without calling fh_verify(), such as
READ with an OPEN stateid, then run with the previous export's mapping.
If the previous export does not squash root and the new export does,
READ runs as root. If the new export uses all_squash, READ can fail
even though the anonymous UID or GID would be granted access.

Call nfsd_setuser() for the entered export after a crossing in
__nfsd_lookup(), after RESTOREFH, and after PUTROOTFH and PUTPUBFH.
The crossing has already run check_nfsd_access() on that export, so a
full fh_verify() would repeat those checks on every LOOKUP that crosses
an export. RESTOREFH likewise calls only nfsd_setuser(), so its flavor
check stays deferred. NFSv2 and NFSv3 verify the filehandle on every
request, so only an NFSv4 LOOKUP installs the credentials. After this
change, every NFSv4 operation that sets the current filehandle installs
the credentials for its export, so RESTOREFH skips the call when the
saved filehandle is in the current export.

Reported-by: VeroFess <coderzeng@gmail.com>
Closes: https://patch.msgid.link/20261103013237.1174538-3-coderzeng@gmail.com
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 16 +++++++++++++++-
 fs/nfsd/vfs.c      |  9 +++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 10d3aeecea9b..d146ae405412 100644
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
@@ -859,23 +860,36 @@ static __be32
 nfsd4_putrootfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
 {
+	__be32 status;
+
 	fh_put(&cstate->current_fh);
 
-	return exp_pseudoroot(rqstp, &cstate->current_fh);
+	status = exp_pseudoroot(rqstp, &cstate->current_fh);
+	if (status)
+		return status;
+	/* RESTOREFH assumes the credentials for current_fh are installed. */
+	return nfserrno(nfsd_setuser(&rqstp->rq_cred,
+				     cstate->current_fh.fh_export));
 }
 
 static __be32
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
index b9d76a1a3e65..c227a3d3a805 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -40,6 +40,7 @@
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

