Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAFEF4EE84F
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:18:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483523; cv=none; b=HBFQx683sYSudEoJMkasBkymhER8nVBt2G7D26x7XQKC9bl1YZbiy1oXaCeDyWyPYxci0Ygtb6cVQGfAmsm3dJoJXE3wy0ezCpxi4FEkW2ZHKlQvCFrptRPzL7sQIG1UKuCbkgech48lvrzd3tOdFnfB8iJpEmk4sHZ+qkv+/zo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483523; c=relaxed/simple;
	bh=VRNfJUSlaSQ+pp525mLecYt1crjhJp8xvG2j8fk2Z2s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=j22rv+6xnmp/xXDMOFtUsr14Hu75uh47S459WXmDWVcOuG4FqRW2bUERihNaM5j2ZKvUw0dVEhvICtC5kzIlCcLMjKAS7YNQLjCadQpcDOi1hLiIbRJ9ZUvJHRHF3fDfHaIHxXtNXmL0ZZabGEvTyCcKN5wJ/OEnJ/bGgv2TGwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BGtKCHjf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BGtKCHjf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A6931F000FF;
	Thu,  8 Oct 2026 18:18:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483522;
	bh=lzt47+ti+hgb05tJKlgzCBAcsu6JWZ5NLW0bOrxUur8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BGtKCHjf79YF78sQONkqMNAfh1I/PVWPGgvBofFs5CHQ3mPra1vfBj3XLMF9ugsaP
	 gQmQz2vHel2BH4t2zNAG7rzcXbcAn7MHTebVH4s+vXsUWF1U4ISZzkPaTowvom6g+8
	 vgt8ZJAYyOYNXV8WhzPS44k42Qd2JtKq3K92aRjtnnFG74wYIZ3vF0Gk3agK8LXIch
	 RS/9r/j87dhk25uOLkAingyWoaaA/TZtNCNms0i3y4h3e7fu/P4Ah3tU6OSZpFcUPZ
	 LKgfLae6GoJVUzpk/Wd66cvy2RVmaKvqeuHTvnWEMH5KwvGL+jLBaoerKpMoUSC11D
	 wF+mZ2xiGMKIg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 08 Oct 2026 14:18:29 -0400
Subject: [PATCH 3/5] NFSD: Report WND4_CONTENTION for a recently recalled
 file
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261008-want-read-v1-3-e372262857c8@kernel.org>
References: <20261008-want-read-v1-0-e372262857c8@kernel.org>
In-Reply-To: <20261008-want-read-v1-0-e372262857c8@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2530; i=cel@kernel.org;
 h=from:subject:message-id; bh=VRNfJUSlaSQ+pp525mLecYt1crjhJp8xvG2j8fk2Z2s=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqx95/h1j77X9qIpKkX2M3aWf1vjJtXqfvVuREv
 dyBCMVT6dOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasfefwAKCRAzarMzb2Z/
 lycjD/4jASGR1pVWTE2KDHjp/HR/IXGjD9mjdaXqSZ6c0BkwlaFhr2xXZRWDVQr0RfSlQ5yTRs/
 i3NLQwJRMHHWBxA9zSyPI6Kn8U8RClBM9McDTnyHwidLHNZWls2Dv2x1hGMV408Ze9hphqJk3IF
 Lrzs2Y1whYf281nHMvCKzjdx6Y0+ihGZyBj54/JK03i4oScXKb0CFGhIhtihvM6XeSCeGUx146N
 H9vNk6UmyZMX2La8y7C1aOLg2Q1nIKeZWgHnVJ1pK0w+8T+3srGhbu0VD3v2CshJ36/h/R0cRCY
 ESTPMzppMoym+oFy3WEMuozWoMB1XsYW++qY3suFIFSDhO7ZHl1MBj6ylmfGDwsSddx9zWAy7bC
 AsxXCBV8pjO7MtH8PP46qGZJNZY86AtiOFbojetSYxhd+KzSquFuiAti8aG7I/jHNeqLxyIBqrH
 oHheGQBLrM/zSrqpkyWgLFooFiJhm1GwUPAmMTRJdjTCDv9W5fTJto/Kq4TMxYlrByH2qpC5Gu6
 Ek7xthgoCYUnNhOSIBLtOm2iyitkwy9FxgbOQ3zO2yoqwVur532rMt8yX4MwNC/k5/qg/OB8lEd
 MIGFwzwSLwAEMIJLBxzAjmL0wj734ThrgJnqf21OpROVnQG+q2su3qLYHNnzBrcUbHpdXmoTSue
 7Dgeb1+dckM+FdQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD grants no delegation on a file for 30 to 60 seconds after
recalling one. __alloc_init_deleg() enforces that by returning NULL
when delegation_blocked() finds the filehandle, the same result it
gives when NFSD is at max_delegations or out of memory.
nfs4_set_delegation() reports all three as -ENOMEM, and the reply
carries WND4_RESOURCE.

Return ERR_PTR(-EAGAIN) from __alloc_init_deleg() for a blocked
filehandle and ERR_PTR(-ENOMEM) for the other failures. Pass that
errno up through nfs4_set_delegation() so that
nfsd4_open_deleg_none_ext() reports WND4_CONTENTION.
alloc_init_dir_deleg() continues to return NULL for every failure,
so directory delegations are unaffected.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 46e7343e050a..6ed53864c9be 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1263,7 +1263,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 	long n;
 
 	if (delegation_blocked(&fp->fi_fhandle))
-		return NULL;
+		return ERR_PTR(-EAGAIN);
 
 	n = atomic_long_inc_return(&num_delegations);
 	atomic_long_inc(&nn->nfsd_delegations);
@@ -1300,7 +1300,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 out_dec:
 	atomic_long_dec(&num_delegations);
 	atomic_long_dec(&nn->nfsd_delegations);
-	return NULL;
+	return ERR_PTR(-ENOMEM);
 }
 
 static struct nfs4_delegation *
@@ -1310,8 +1310,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 	struct nfs4_delegation *dp;
 
 	dp = __alloc_init_deleg(clp, fp, odstate, dl_type, nfs4_free_deleg);
-	if (!dp)
-		return NULL;
+	if (IS_ERR(dp))
+		return dp;
 
 	nfsd4_init_cb(&dp->dl_cb_fattr.ncf_getattr, dp->dl_stid.sc_client,
 			&nfsd4_cb_getattr_ops, NFSPROC4_CLNT_CB_GETATTR);
@@ -1345,7 +1345,7 @@ alloc_init_dir_deleg(struct nfs4_client *clp, struct nfs4_file *fp)
 	int npages;
 
 	dp = __alloc_init_deleg(clp, fp, NULL, NFS4_OPEN_DELEGATE_READ, nfs4_free_dir_deleg);
-	if (!dp)
+	if (IS_ERR(dp))
 		return NULL;
 
 	ncn = &dp->dl_cb_notify;
@@ -7088,8 +7088,10 @@ nfs4_set_delegation(struct nfsd4_open *open,
 
 	status = -ENOMEM;
 	dp = alloc_init_deleg(clp, fp, odstate, dl_type);
-	if (!dp)
+	if (IS_ERR(dp)) {
+		status = PTR_ERR(dp);
 		goto out_delegees;
+	}
 
 	/*
 	 * Record the granting slot before kernel_setlease() makes @dp

-- 
2.55.0

