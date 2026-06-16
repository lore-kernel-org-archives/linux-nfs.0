Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF45D43DA50;
	Tue, 16 Jun 2026 11:59:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781611151; cv=none; b=tG5EcODqz62KFGclj12mW0NDJlQUVRtziKAZ29Ei1gAtVKFgV3zusBbErmdGZarXGR1iQxT0iLlE20K6c+OMkf1eBKI5aTUKGT5X+m+j4CGg+sQY6/3L7VS69crAJl1Wazpj/mXP5Aaui9FN9kVD5/VxxMYy1wbjStgErYR2lJA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781611151; c=relaxed/simple;
	bh=5G4Qh690yS06R7Wqa6FTAPRJfvVNC6FMD0/xoR83hNc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=cLKeWnIVwYhJ8JXqZsES798ICt72lHsW4aJat4Oeb0cowMBSiET+2ow2n+2AZdHvy/5K1tbyGxcw4/v/lxGUHIEoEXlBBdyo31VsBR5BS97ubav9X6r5lB1+nuk8MemgA7/nh1Ku/GrYEJasvtlW+B9OFO8vnO//4lJkobTZlIk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=etQb9Q46; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="etQb9Q46"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E7B821F00A3A;
	Tue, 16 Jun 2026 11:59:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781611148;
	bh=lKnw5hs6MO98rW4Imnk91d8pWCs2bWfCql6duxkapWU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=etQb9Q46NT8TBxcJZ/8Us7cvJk54izqcsPqP8/fxVXEiuFDMuOXXeGp5d/CKaAE7z
	 shaVVa4y2IdXBIhSnVSisVOBMOMvjDjAy42xJVStrhxEpscWG2+M0IFqk4KWgckPFs
	 YW0BbvJTxCWRoc+c27RjfITrt2TVaeuV4KFfyyal8xn+2vLWzVtxLZ3bNDJ6WDxS76
	 9kb287x5VLnNkrQWvJYlBiEweCCPiMqnmYxYvbXZvoq37JfKRyBKWJxOb0phldApNz
	 8A+FgtwkNibgem+W43Bp2aQ9xwRCIQ5on7menMPqbaA9NxfxD0bxsR0d2Uk01dR6ep
	 oUm0DsDf72TFA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 16 Jun 2026 07:58:44 -0400
Subject: [PATCH v7 01/20] nfsd: check fl_lmops in nfsd_breaker_owns_lease()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260616-dir-deleg-v7-1-6cbc7eac0ade@kernel.org>
References: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
In-Reply-To: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1106; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=5G4Qh690yS06R7Wqa6FTAPRJfvVNC6FMD0/xoR83hNc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqMTqELrd5tzdzArdDbXikypgWP//Rj1DQjM55p
 kHuVFjD6rSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajE6hAAKCRAADmhBGVaC
 FVavD/9yhzQYnSJPI4HIeHxVcrE/iC9bg7qf+ncQO44JCoF/fENVkneVQntlW47tuP2uZFX7s1L
 dMbf4/uOyEzNt33eV9LKZ4zRDlGIkeqG98QdLepuvI94zQC6NdHGJ0OHFY60ODoffODpRt24074
 JBSQ2l5XWf6X4NgaqJ9JtlsREAqFVJvpH3y6bt6+Mat7JLU7vepdO9ssLfO3cebnpo4h0rGZjyG
 1oQXEiH/BXa4GJ+M8623jkV9GN1D14YKFre6NeLhMF93OtrjDS538r2Aow6W8YkrfUtJ4FM0C5R
 hJXNOPuzkFFzJyXZONW4mTzm8DjsksMJ+lKpYQSWzBHKFYDTrmeIlud1JFyVazaU4BVZUs6hVWq
 wHsL+peiAmptnYJDgkvu9UhWvI+Ny9VO0LK0cK1jLamOITrAoAP/Ze5nk+ES8oRISO5+amtl6rL
 ZRWgliWNsn3UHuQK/sMCkQgg4MSAz4zcafx6dMbyhP8IQnkXflLQCKOupvYgWv8YxxdVzZ35U97
 4vu70gWnP28lIfLUF40SPzek/g/NU1Yn2nalEsUMpUX2a9RoQm/vFMT+p0lOgiT5lCDdoawlkwU
 jBFzpJMvcOuzDhliQdZIOdnznZXHB0nFDOndxlTHxvoMSc7P8yGVISyKaTf38c5OxNNXDdS7UDu
 eWEZXGW8nmr94Cw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Any lease created by nfsd will have its fl_lmops set to
nfsd_lease_mng_ops. Do a quick check for that first when testing whether
the lease breaker owns the lease.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2a6a0c9ef65f..e18f6efbeb95 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -91,6 +91,8 @@ static void _free_cpntf_state_locked(struct nfsd_net *nn, struct nfs4_cpntf_stat
 static void nfsd4_file_hash_remove(struct nfs4_file *fi);
 static void deleg_reaper(struct nfsd_net *nn);
 
+static const struct lease_manager_operations nfsd_lease_mng_ops;
+
 /* Locking: */
 
 enum nfsd4_st_mutex_lock_subclass {
@@ -5748,6 +5750,10 @@ static bool nfsd_breaker_owns_lease(struct file_lease *fl)
 	struct svc_rqst *rqst;
 	struct nfs4_client *clp;
 
+	/* Only nfsd leases */
+	if (fl->fl_lmops != &nfsd_lease_mng_ops)
+		return false;
+
 	rqst = nfsd_current_rqst();
 	if (!nfsd_v4client(rqst))
 		return false;

-- 
2.54.0

