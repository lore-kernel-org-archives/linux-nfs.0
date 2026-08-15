Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CC992D77E6;
	Sat, 15 Aug 2026 04:28:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768132; cv=none; b=XqD4K6m1ywT4EVQGF7RfrjjXUawtFA9kYSDEotJuRiqYqEw3gZ9apV2h6ZAr1FHLZm2jns0Vm4NiRPXOWSY/LHFTeJdJmfZ26OIAPfXg6solsm9jdxqmmFgwzfKx0EmVEXOEufFMX0INHHXslWkCknd/z6c4NvVnuTCimZCPkBo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768132; c=relaxed/simple;
	bh=A0UhbREzQ2b96qESdEBPrmUcdJUGNNPBEmk7drrg2k8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rPrkE0hQY7C5LIAlTT6qLdrd/JCPbADkxDmisi9SaWhh7vp4SSPUxLvILeflCwX9b5H4exyzytEybzlgqvPe3+CMp9c+A8xLVJA/VZFZtdKbjqF3G6NeKoqtZcAcSCxxP2M3ynACJcqdvCea/kn5Pcgkuj6yfTexdJFhOzZImQE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=lOahxFdw; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=cJ6X2n1R; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="lOahxFdw";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="cJ6X2n1R"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id 8F78B1380411;
	Sat, 15 Aug 2026 00:28:50 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:28:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768130;
	 x=1786775330; bh=30+fT77CWVQvZZk/s/T4uRUE7JQPMDkgqcoKGgJMCL4=; b=
	lOahxFdw5kiEJD3ro7+HnvkIfFp6IFS0D3Y9hf9CKLjS5a4i2lYuspEiyH77bVte
	F+qfxD8Fi5uIgDI4t4ypjMgptiOd2GvivbiNeYoaszLd63HQGyJmWLTSI7+PsNno
	8j09X89T5iP6ejjDLbjlkgMTcXEuXJpBL54VmRM509SNTUcmcD/LjIGevmGdfW6B
	TbChej1XfhcvHNjEy4t9U1akatocIW9BWsO1alH3w7zqYv2auG89j3mRebz/GI41
	XHNTpjNOp0xvfG1eQBc72GOzH2oGsJZZqRBIyncpSkXKcdOpSiKTiUOXnCvNvzF5
	aL7VopMLJli6a4B1OKJSPA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768130; x=1786775330; bh=3
	0+fT77CWVQvZZk/s/T4uRUE7JQPMDkgqcoKGgJMCL4=; b=cJ6X2n1RAYP7oAWgn
	/ObSjbGj6FRaVViEenB9BjQV773032oNlR/V0cG+tMNrf1nP3Woyx0/q/LDmTIXX
	h98ICIs4mQsrPdLcRw/jm+ZaixejutDYYI04o9UvdUMwYsOrICgXWVmVDYNbJ2Oy
	K5/65BdNXZGlwo9/CQmR559BpS/hx0sK8ZKG8T/qwIuIvEnssK12ZZiVu05lxiso
	ACA30j2x+2c7mETCmM82b1SupAXBK8JdCrmSYAobb7q9ISuoPK5EGiAxUwhxgbcc
	qDriYPx4+VO+W0qvetafCzVgTYs39g7i4RbkICieZc1cqlRtsLORy9aLsMA9Xv1g
	9p5tg==
X-ME-Sender: <xms:Aut_asvyogwmcq9VXMc_8niMTG4IGtXbuPUe6hjtuq9Z8iVjSdJBJg>
    <xme:Aut_akfTgxaT-x0ZtU_-vxLfq8eGY2aUqtAkuGQ21ko3EQDXqAWVFmr4qNo2Yg-HO
    pQyhgQ2TMRhJl6HgH0knl1hhhgDxJjasUWDQhTYtJT0HyViiw>
X-ME-Received: <xmr:Aut_auYRLyyohoEDqLhrH57rvBCMrFKX5KZrRkirnRPsv28pWKNZNol1Vlt7jx1pPleT-Zmf1Ut5N2vcpqJNVBuJcNN4upU>
X-ME-Proxy-Cause: dmFkZTGxKCIJg189DggFiXo5ZJL4dIjbhm46neB2Vqz0yysnTK2EEvZfyUO+W+5VylOmxA
    MXt5kdik9jz+bmdCUGG9zhM/yC7XCFdf6P2fYdm8xoYAkS4lmA5u96Kjpq2TeGn/dPFbKL
    mULzfOuDXcNtV/w8ss/fVr14WSq3NSOCPLhEhjAPC143exYjC0qGmAPeJSTejsuElTX1t+
    XC5iq/pm2rahqBTv8qgJG6LygUrvIIzUau+lgT4YNtEUmALkB88s8XvdfVuXa0aHqANFgm
    TtvBEfNb5mRkIrhcsMJtSzP4V6xOiTZaNgnWWaBZgJzE/9cocWzpzl5kcQPsd0HyLX0eAk
    cBD4+I3j0niSMzcI0GyaYcha+Lf4GpfMAm9iR2rEXYmbXHvJeQ9IVi8f7BSRKLoOcrvsyo
    anTjeg9VMQ1pKhx1onwV0VxFHyGWIqcN7uFNZAHLvSMSTCBTBiEWkO2aRVW4inH0eqHzjL
    3dg5VAuGtIk5NYJvMY49lfX7fuc1vFkYLsM8eUiS75J4Zqzwuev33owc/MvGoaEKAUBFuc
    LcnULLM/E40FQhZHCOxc1EkY3NYXRkGmeQL5nJ+TMXPO0+Ws4W71oLiO/yFloAEt980ZPg
    cX3Iv7KO42sPvTMG7Y6AqrhbsXtVDxwBZjE7iWp+5RJykrXQziB45IWBBtlQ
X-ME-Proxy: <xmx:Aut_as1UcA0t1_mcG_ISEnTHWpT8Kx-A466GEHwye5834bpqhgrgFQ>
    <xmx:Aut_anpv8edDwF-CmURKhX-uxMfycsFPWa1XrZRUZFk0fYf1nYsZ8g>
    <xmx:Aut_atxBDpU25nztN3Jr4fpJp0x-YN509QESvHJexY59JSOxU6N2Zg>
    <xmx:Aut_agD_V-3bIWNutr0ktJEhQQq6WJHqpy6SNxBKyo_K9HsLVSZBAw>
    <xmx:Aut_ap1lHMZ2Gm5Gx1MtQKJDz45wrYsTqeDp5bCXu5wb5agbbm4SIBYU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:28:44 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/18] nfs: separate locked regions in nfs_clear_verifier_directory()
Date: Sat, 15 Aug 2026 14:21:21 +1000
Message-ID: <20260815042707.2535717-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfs_clear_verifier_directory() locks the dir to call
  nfs_unset_verifier_delegated()
and also to walk the d_children list.
These are two separate needs and they don't need to both
be in the same locked region.

Subsequent patches will use a helper for walking the d_children list and
that helper may drop the lock temporarily.  To simplify this transition,
split the locked range by dropping and retaking the lock between to make
two separate locked regions.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c7caffb31935..bba5d996413c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1492,6 +1492,9 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 
 	spin_lock(&this_parent->d_lock);
 	nfs_unset_verifier_delegated(&this_parent->d_time);
+	spin_unlock(&this_parent->d_lock);
+
+	spin_lock(&this_parent->d_lock);
 	dentry = d_first_child(this_parent);
 	hlist_for_each_entry_from(dentry, d_sib) {
 		if (unlikely(dentry->d_flags & DCACHE_DENTRY_CURSOR))
-- 
2.50.0.107.gf914562f5916.dirty

