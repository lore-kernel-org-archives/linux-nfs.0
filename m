Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627899;
	b=nTnhdYoqpzReGGWwNEiuxf8G6x9QbCSxNwiUidwmZ0+/eJJlPZnFTkCRcLeftP/uD7Jx
	 azgS9X3gVIbdWsKG57r7M3IBOEOGC3kOtJDCpTmzk2DH3XDcPb84/yox2Q0YNUylX9vst
	 uvY34f5bPrYD8BHLC3s2AMLdY0+3K9dCA3Y4KXcvcJE+9ZeKpgW3KsBcdsuNbJTMuReIU
	 N+/gNR7UEEKEhNHVbXlibOHL5DfW+EUc64BtSTvLNTGYM4kynHu3aR+g0PXi1LZx3mV1u
	 MqgCOtNvtw/j2bX1Nr4ZzdzNd1mel/M8EDZ5EwHovMrX2DAdT1GSsb8dL4NCagD8GMQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627899;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ege6OQwHTUhZgLJ/FEQoqPP2UKV5laRmVuwDbBNP3P4=;
	b=gSMrmASBw7x8nGvT8V6oOFnSW1Tmbykfjku+rMnY8nAO7HW6FPkBvT20ZfeExtt3vQFQ
	 V8hv8WPObq72EXsKItc7oIkbi7K9zl+Plsz62KpYWxgt99m7d4UCyVkEf491mvM+BwBk6
	 Ulu4L5+N87mIrszYYa3Gph2bms+4jR6aGXhsNudU/AjSMLpMq+NdBRL0qu5o+H98Q2WVW
	 6Z/ZUpSYpOu41jRz9IbZbYY2qvUoStmu0akvQRpgU5tlHbwT+rOHwM2Wf4G1kNdTuA9a+
	 f5lBLKycEzKuW6AJn8A/f4DOT9xCYkYocmY3dpwlh86fmB/3Q5zkigORTFQwnaCtwGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BMuVBH9e;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5FD760A2616
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:58:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BMuVBH9e
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ABC8E1F00A16;
	Mon,  2 Nov 2026 13:58:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793627898;
	bh=ege6OQwHTUhZgLJ/FEQoqPP2UKV5laRmVuwDbBNP3P4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BMuVBH9ef73VgbQElagcfazAwBA88U+k2NDOLfpinqXzjI1S74zUbmdTpS7ORP5gJ
	 LmU2lBSvzWQErTxy7rvJi/shCdCYHdXH7yxO2J/n7HCtv1n6wy3gAZJVFZRBeGB16n
	 24c7NoaG/gvdQ6F8Jf8JgReB3gbQyxeB6qRNJ3wp2al/BSnFgS2jGFIB0noBgg2qn1
	 lNVlp77MD0dzpdmheY/5RGnjeOEeRg+jG8FKehjSBke0Jc1GUgs6iHDV05I42qYI/c
	 WgIxpS3q29UvqmkZ8FEULmlSdadBmj69J/D7Cx8ckCKas1ugPYOj6NKc9QmIhW0a4h
	 VNmKAhY/dN/Pg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 02 Nov 2026 08:58:03 -0500
Subject: [PATCH v7 3/5] NFSD: Check the entered export on a mount crossing
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
Message-Id: <20261102-verofess-v7-3-d2cc0de4d44e@kernel.org>
References: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
In-Reply-To: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4583; i=cel@kernel.org;
 h=from:subject:message-id; bh=DMxwgBFvUUZqAA2Nkmj+Gt9xecvnmWYdmb5w3SjP4c8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6Jb1zgAKE9GHvcUEJIoDIqZfHrOlmOHzZV5ug
 q6kxJKqUEmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauiW9QAKCRAzarMzb2Z/
 l+fbD/9tfLPO8Q84uYFsr3pTNaZX0s1eiAxhwJtWRaaWxlk8N8Jc9BdSSt4UZ/0gtre4Jzp0ZjR
 GpcPFIIrKKXI+tFVTdHfDnnE2RfvoCP596xnWElbTC5DO2Bb+LoB3hcuulXSTBV0C92UK3Tyn7q
 0c/tq90KxpBKWJjbNoAnj3J1RlQh84dYPwgOlh4t2GMl+4EJzZKcF46GXffCJthjXswXhuUWfyN
 Vf5HyYt74In7XbfrCXpDxEdBnVuXF+sEa+3fcnn0k0F4KN/2q7HqNbs5cXitdwqoEuDmFYzydIs
 /3ZYjfGds6moYXCzTZ2ujbu+OtOpTiTUpuHLAjD3fwzPI0cRTjx2oiPrljRol8Otd07Lzja7RUK
 7ERJ8dNQ/82dJiXg5unP/CqXHnZb8vsdA4/m2zNA61y6rS6yvf3FJF4Dmt134yrrt35rTGU/FX1
 IsV69Z7BF0+BSkwNWC/n0UPXDHWGo+4oIj79DmZ7S3yZvkZ0C2SPPnIT6owmEfGqOXsD9apAuck
 I3SazYjygYUxjPl0OOhJkgIkx896NS/swMo/UqBDUyeeWfOcsMB9NHya3Yg/eA7ioi6cxtDp1RV
 /zdJrjEVHoER4OgiDP1YPAU6egZgUxkPEgJ1OEiFhFNkOVb9H5aNpgUheD3cOH+wZ2DtId05u37
 nkbyQpRlKpk9A9A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: VeroFess <coderzeng@gmail.com>

A bind-mounted regular file can have a stricter export than its
parent. nfsd_cross_mnt() checks the request's flavor against the
export being left, not the one being entered, so LOOKUP, READDIR, and
the NFSv2 and NFSv3 CREATE paths all hand out filehandles on the child
export without consulting its sec= list. Stepping up with ".." has the
same gap: nfsd_lookup_parent() switches to the parent export without
any check, so LOOKUPP from the root of a sec=sys export returns a
filehandle on a sec=krb5p parent. Every caller has already passed
fh_verify() on the export being left, so check only the export being
entered, in nfsd_cross_mnt() and in nfsd_lookup_parent().

READDIR crosses into child exports to fetch entry attributes, so the
new check also fires there. When the client requests rdattr_error,
report NFS4ERR_WRONGSEC in that attribute, as RFC 8881 Section 18.29.4
describes. Otherwise the whole READDIR fails, as Section 18.23.3
requires. NFS4ERR_WRONGSEC is not a READDIR status, so report
NFS4ERR_ACCESS. The Linux, FreeBSD, illumos, and Windows clients all
request rdattr_error on every READDIR. A client reading the pseudo-root
with a flavor that a child export excludes now receives rdattr_error
for that entry instead of the child's attributes.

Fixes: f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into nfsd_cross_mnt()")
Signed-off-by: VeroFess <coderzeng@gmail.com>
Tested-by: VeroFess <coderzeng@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c |  6 +++++-
 fs/nfsd/vfs.c     | 32 +++++++++++++++++++++-----------
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d4a88bef8444..a6651349bcc8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4775,8 +4775,12 @@ nfsd4_encode_entry4(void *ccdv, const char *name, int namlen,
 		 * then in accordance with the spec, we fail the
 		 * entire READDIR operation(!)
 		 */
-		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
+		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)) {
+			/* READDIR cannot return NFS4ERR_WRONGSEC itself. */
+			if (nfserr == nfserr_wrongsec)
+				nfserr = nfserr_acces;
 			goto fail;
+		}
 		if (nfsd4_encode_entry4_rdattr_error(xdr, nfserr)) {
 			nfserr = nfserr_toosmall;
 			goto fail;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a8cf41e4dfea..3486a2ee26ba 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -169,7 +169,7 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = check_nfsd_access(exp, rqstp);
+		nfserr = check_nfsd_access(exp2, rqstp);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -204,11 +204,13 @@ static void follow_to_parent(struct path *path)
 	path->dentry = dp;
 }
 
-static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, struct svc_export **exp, struct dentry **dentryp)
+static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
+				 struct svc_export **exp, struct dentry **dentryp)
 {
 	struct svc_export *exp2;
 	struct path path = {.mnt = mntget((*exp)->ex_path.mnt),
 			    .dentry = dget(dparent)};
+	__be32 nfserr = nfs_ok;
 
 	follow_to_parent(&path);
 
@@ -216,15 +218,19 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, st
 	if (PTR_ERR(exp2) == -ENOENT) {
 		*dentryp = dget(dparent);
 	} else if (IS_ERR(exp2)) {
-		path_put(&path);
-		return PTR_ERR(exp2);
+		nfserr = nfserrno(PTR_ERR(exp2));
 	} else {
-		*dentryp = dget(path.dentry);
-		exp_put(*exp);
-		*exp = exp2;
+		nfserr = check_nfsd_access(exp2, rqstp);
+		if (nfserr != nfs_ok) {
+			exp_put(exp2);
+		} else {
+			*dentryp = dget(path.dentry);
+			exp_put(*exp);
+			*exp = exp2;
+		}
 	}
 	path_put(&path);
-	return 0;
+	return nfserr;
 }
 
 /*
@@ -277,9 +283,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dentry = dget(dparent); /* .. == . just like at / */
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
-			host_err = nfsd_lookup_parent(rqstp, dparent, &exp, &dentry);
-			if (host_err)
-				goto out_nfserr;
+			__be32 nfserr = nfsd_lookup_parent(rqstp, dparent,
+							   &exp, &dentry);
+
+			if (nfserr) {
+				exp_put(exp);
+				return nfserr;
+			}
 		}
 	} else {
 		dentry = lookup_one_unlocked(&nop_mnt_idmap,

-- 
2.56.0

