Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516199;
	b=b9EUrl2XMqnNcYZE9E6EZ07/yyw95AlP2t6m/jJ90It/OKHdQPi7XrPHf3erRcwdjLpg
	 hvj5bwX0u/EddTdY1W/2S1nSAz+qacdQck6AYCkaOb6AYLIvBWWJ10Borlc7LbS8bbrBx
	 z7fKtebf+J2XY2N67pkWIuRql7+oOYYWODFY9zRIBzKG7y+d4+wT/8ri0l7fgDHkaUVCj
	 ayF9Rne1WNjyROXCzOcKQogNyo4UJkJagXXEQK/ZnWEYnmm61vL7rmMf0sft2CI3gPt5K
	 /syzn3HSdZrdabv8yt2gNuY04VCp6PVBLpn6YS8UlyhYn4Sqrf5VZNJ05sFRh97Yncw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516199;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fyENN5sIEy1TZoroVNNyOGrZpCVFOUAK6ZbDhUks68s=;
	b=cHpUQDr4F6K4qod1D0psB/cy28IoKREz98mn9AZZkN319gRBC6mBSsfI6yKL4SoB1rhA
	 mj5UbnuoCm3eL/WV7XEC/HvrTGd9ZxMDV1lgNXmMJv9rJbt0dcSkuiWIIacSS+EiHZQeu
	 uHt0WEhpL3toLbU4uJBpBqD+o6ZlLcgVE1GMk185xHyKs2vZIzYxK56ZAtUSgPQoaCGOI
	 DxQXofLCyO/fg5LICRWPxqgQeh5SvolgQlvUX0QR8209ZJqW3A1rUpbPF9j+xGoTfTKHN
	 Dwy7W9kbak7kchcEc8/he3HqbmRL6cj5A6P3vQg52Q+cKfwzrLFth+l2oJDajdpnSdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WPkMnfz3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51CB4606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WPkMnfz3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3BE871F000C7;
	Thu, 12 Nov 2026 20:43:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516199;
	bh=fyENN5sIEy1TZoroVNNyOGrZpCVFOUAK6ZbDhUks68s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WPkMnfz31Vcw2ZrMVVDyrbxkVTRT1CFp0u+GILs2+WPxXRbI+y0kjf+jaCc17ZgRD
	 GcBAum9IkL40kIpyaHBvwR/8fM4zBTh9pmPSrUQSJyUqkrf9IY9SKvfZJ/rGxp86sI
	 uDx1IyZCJzgyYe5DpNkv1K1oitkd+0zET8262kVBwWIw7xZVK9boRPzRJmrjywRbHs
	 KUsp5wQWbn59eHDjaidlC7XpfLhleDDN1V2e6FZnsfhRsuReHeSaaFzzv61lcpF3aI
	 3s7QXrLVhgI8r7bmsJ9EfDzsIlJwIqPl716dXKH9nyNJCt7xcQZIEQVz9dpsMd8FrV
	 zuFj2T4rog6SQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:05 -0500
Subject: [PATCH v3 5/7] NFSD: Apply the entered export's credentials after
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
Message-Id: <20261112-verofess-2-v3-5-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4423; i=cel@kernel.org;
 h=from:subject:message-id; bh=5ESIFHd6aCuI3B2hE6FhZhIpaSxS4lu9ijVvHcF3Osw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTe0QZgjqx64Zr29zv15EEmVTkefmEp4m1LJ
 PqECSLs4QWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 lxNbD/4mAupyy6E9txxtdfv7PQFO4JXs0isXAYsJ8B1ovtvgz6vDcuoYXQg2W0q8pAuLVjREVBo
 JM5bqmE4oasTvpmzq0ZE4QHrWgRYYfXex03xQ1G3aiIleImj0ZliHMPGNDXxJMfKrwaof0DZ7Rk
 EokCkLe5gUh9MPnDsJLQtvssrhCZ12+Iajf9PdChhtBfTBgzWst0LGstBRxuVO4LLr9O2qp/c7K
 I8vMKL7b2rZzo1q1F7GnkxLB82GU0JHy/gONxCXhnPmiTUSGgaxLGmtRmT5lpBMNeebW3c/UAZN
 WAFgAEzEPSbA689a+O6aWC7dDmZniN07tqnBbUA5oMyNy7siD9ppcDfnoNPzH+5o1C4t3n5YARd
 44oaM5jEwgFAMmeFB6VM7e3PEJ9iQcaT2Pldc37LnSYE5PChhyihtWAHPcYOfKpiLlsTIZHysxZ
 XiTe9P3/DeFMEKEDXSKZYJb5Uov4oE+2UzPuyCf1X9qZ+8iK6SQzog8MvGo5IRXELRPBLUMfzYs
 VOKCSAgT+AjgCbHeT8XaWxcPnSNIxtqsopdhkeHRaaUt7UdWxSkhSdjOZHgbpb761fikbaUGuzB
 wivEEXkiY5et7QueZVCDwi5ZQHTglZMYWURE4swABTj7fFIsNWc8MuCPRO0VZbAnQGzDoX02NNI
 jWjDxW5xOPecZZg==
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
index 85bbb0073874..5121e7e80db1 100644
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

