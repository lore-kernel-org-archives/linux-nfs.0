Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997652;
	b=236fASGoExX/YvGicZ3po/LKRL9lsMnE8MSe0YHAyO5HzDwR3Mt8ll8mPcvezXld7O2r
	 1kMwV4qYvDNEeQSCyr5G4apkbtdzN06NpDXOwOJcHXzEenC196RS7Gizpjakbic8/+TMz
	 stfcD+U1FmOXkxxJYrTeeJAkhsCi6XdR5x9grRk15k5Kd2ESzWlBdMjU0HZyg6E9YtbwK
	 7r4rnMj2h/bKKsenaDNgc6anymT4G551ADjlgpnJc9IFYlHVfdfeNWuhJXT5NlZcm8QrD
	 9E1mnb/q5LVNy/XCjeHhblc9Eaz1qvqHFDn17vPcXEwXFxau2f1gdiDYmk0Nrw0iTUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997652;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=kew4vr9D/lX65hyEZonw0fC/8LUorIYJxt0gwq9n5sA=;
	b=LUxerYi3/gqrrVZ4maP7oXig9NQ9FfltTDhksb0by8hkof5VfpYKo2DqmYOUwVzHWDgr
	 T2CosaA/WenNhdA78HaUhxiYXY6iOe4gXGNhTFBU10wBXgNI05Cg7yzO6rHlX5Ie20zMa
	 3V+SmWFR1kwKM3ZVMyfaScOGh9IO/QaC2gtpIgPbDhv/ETJkz8nQ/SM4JcL8okvjW7OLg
	 Dv31x37fcdI6FSBmq8nfNx0bWK47xt/bPnW5bhZhxVqGkJOg/q+6NXNq+r3yHm7/iVdVZ
	 QO8Tff2BSxFPjaB0rUruYg7PgPDo6eaozfFAGh1FyJ9WxugPxncPJz6G7YE70BycIlg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Sc+5DKhr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40ED3606A326;
	Fri,  6 Nov 2026 20:40:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Sc+5DKhr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 304171F008A3;
	Fri,  6 Nov 2026 20:40:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793997651;
	bh=kew4vr9D/lX65hyEZonw0fC/8LUorIYJxt0gwq9n5sA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Sc+5DKhrEGxQ8PVCNss6z8vNbMZT2SqxCo7f9PHChsDmIJ/T91DbX6w9v6NrrsJSb
	 xBNUrHov8e9TTWSgagYZwqNWmbLnOzIAKAkIer1QIsZdgwkVP5cELDlD/1g1V0pLGD
	 tJ5xYnu96mcE14+m7LdUcfsS2r08BKJXg25jGmxLUokQS/tUvus4GP4lLnC925W6cx
	 kelE/z+cJAYSEN5diBEJbia9TJhCCO5+hGvIvOM+YCbwG9N2mJFb1hYcdbs6G96q1c
	 mLY8gAOm+3eUtUNFzbFVPUBdiitEFQbaXn6ZCwoBxt6y5BzPcebtl26h5Za9Cp5tFN
	 1945f+TK3f7kQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:40:27 -0500
Subject: [PATCH v2 1/5] nfsd: Report vetted delegated timestamps in GETATTR
 replies
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
Message-Id: <20261106-deleg-cb-getattr-times-v2-1-8433618ab9a1@kernel.org>
References: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
In-Reply-To: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1486; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=63CvdnJ3D30Wf4u4qYlU9zOOUTNaBtg7jPVJhlMIX/w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7jtRl6V5r5f4lpgNxbL29iA/ztdyZCw4VT90K
 6UIqzYJNNmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau47UQAKCRAADmhBGVaC
 FexOEADTznPkDfrf+9e0aJ18BU/BcC8KbPt0gOWig0xHqhq9HfkFPwdfhHe2AtESZ18fQvs/xIo
 OrqBpOrnoPC/OUyQ3FPOnssdbzTDCP58/GAJwYPcje1/P3fRqnJkGP90KaAuKIkzU9oqBtid1KG
 0j52WKNy76R4eP/fdHG/nYkzJOE+aT9oK4cjTzGlFGyX4XK7fC7/+qc/moLSNnuWoT7ywpt0IYI
 PMNHJiPoV8LSvOSJ3WJfVpfiyiBdmtpVmmEN4nLKyCNwnJ+gs7MvNdOpk8d1SsPd/cPZaWCSIpi
 3ounDy5JK6q6LTonNWlEmQvT+OhfNuoyFA5V4C9H2pGrEv4vu007U0LPCBjVZzugMVzz/t0iPm9
 FwKfjQFRpgmjBi2QAgAedVawaFfVouOy7k4IECeQok9OMwqg1BpIIafBum7bDnhb6TguFK61xEe
 AptpIfPl+mxBOttP6YOnRdWbH3wS+HIMYGiVK1xPW6dKFoMzpNacu6/tKvDBsb3lisvR7i5h+nx
 upN1FLVqlg4w87vcnP/ixKNHVBfOa/dYOBsLNyocvoaD2dqwTtyNjNbz2/0cIQqpQ/Qn6R+vet8
 xFYN+CslNenEOAnk62nBEYdtLhlL0MVvcWNIZM+pkCwHU/XTAAlCBx7UOPLuHtlauuSxRSKCVAJ
 KlejGvUtM+dy/rA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When a CB_GETATTR reply shows the file modified, nfsd4_encode_fattr4()
overrides atime and mtime with the raw time_deleg_access and
time_deleg_modify values from the reply. cb_getattr_update_times() has
already vetted those values per RFC 9754 section 5 and written the
result to the inode, so the override undoes that vetting:

- a time older than at delegation grant, which the server ignores, is
  still reported to the querying client
- a time in the future is reported unclamped

vfs_getattr() runs after the update and already returns the vetted
times. Drop the override.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 90b44163f886..434b6cfc5741 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4098,14 +4098,8 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		if (ncf->ncf_file_modified) {
 			++ncf->ncf_initial_cinfo;
 			args.stat.size = ncf->ncf_cur_fsize;
-			if (!timespec64_is_epoch(&ncf->ncf_cb_mtime))
-				args.stat.mtime = ncf->ncf_cb_mtime;
 		}
 		args.change_attr = ncf->ncf_initial_cinfo;
-
-		if (!timespec64_is_epoch(&ncf->ncf_cb_atime))
-			args.stat.atime = ncf->ncf_cb_atime;
-
 		nfs4_put_stid(&dp->dl_stid);
 	} else {
 		args.change_attr = nfsd4_change_attribute(&args.stat);

-- 
2.56.0

