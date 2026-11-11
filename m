Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419046;
	b=OMIZRvke3fia8e/70PzfPnB4T2fNzPjsL5PwfDu8qVIwwmK9noD52TP+oCSW7Kzlkh0u
	 pmETHRo6565HsXL7m38MC6ajTBg9fzu0gkUEKC2/NarFhSkY/CMms7/tp4uJTkqjqb7x1
	 KpnUZ1aTSvifR3bzNEVmBQZrTQNi7hAmFjh87lWNrkE5f8p7nhaq2t/ppZZuUQo/YzIs8
	 QIP3wCWs+ROYtEKXYf3UAm4/JhBe9L8UBLdZs+Unw/ROQmsADkAXSr0a5JJjFPo/ySjzI
	 z2XiL0/IM5BES30tHeK9cttaezhH7npoiJ0xRKeX1s2ySjiEEihfbDAP2Nw2ZiDa75A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419046;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=aOOUqrsVemmbro3m2lkmVhMap0QS+leWPc2y6HwQ+jY=;
	b=fQWa+CrvglLvpRdW/v2cPh7nBVOPHlktjkMQwzCpKPJ+5oviQv9eOmCnGj6lH8oFRIMT
	 gnWKL+s/I3hBn/WPSiiZk4+Mz3O3dWUBN8yD2219pBqnhNL/Zm1ZI8wRgN1MHNLMta9BO
	 xFPMNNy3qMoRu/VmVyU23w0DcvXZ4bpkcvCc7VVI0a24YnZV3jOJqFdVWTcaS/2bxa1vQ
	 5gxW22/WxTmrfICOAKsXvM7dtTEr7kN+H2UM3FyqTsdeKr1TX6XxstEewn06lvfJAhatd
	 ocKN1rhphDdMa8Vny8vyVVSx4nFLOvEDtnBkhkMYjvDfwGfBm6wQvQfK101+sVKe1Gw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mefOa6MF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71783606A8A4
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:44:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mefOa6MF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 57FE41F00A05;
	Wed, 11 Nov 2026 17:44:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419046;
	bh=aOOUqrsVemmbro3m2lkmVhMap0QS+leWPc2y6HwQ+jY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mefOa6MFmu+bb+QEScwRhv8JoYDx337UKCPaEOPvdBsNOaWBBAcxD5qJwrJtWQOwI
	 Z7ARoCTZQ9r5bNNTYA8yjGiTVUjcOADCtojyYtT7A8MQguPN5GtJInQrdRos4603vU
	 XS/GmRGHYyLSiRRuNqYKQg2Xbpvg6Wjn4nqyBfm/ERlxlmSCjGl1BBs/3a0qR3qiHk
	 vrMg13sfysC7QSYbGFkwu5dKSFYVXB+AihgadUg/5vCn6+tDm6+HooFHInE6zxMsjq
	 AYjR/0d/UNtqmJlRNCjO5WAnO6efufVRjFavGt75IqjrbpdecdZFxlVeix7GUQMTd5
	 IQ3NN+4ork3uw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 11 Nov 2026 12:43:47 -0500
Subject: [PATCH v2 7/7] NFSD: Apply the current export's credentials after
 a cross-export LINK
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
Message-Id: <20261111-verofess-2-v2-7-01596ca4d8b1@kernel.org>
References: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
In-Reply-To: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1939; i=cel@kernel.org;
 h=from:subject:message-id; bh=G4t3hy0tsX9tl/yEP3AAbrwl4wpHCj8zLFHyJ30E9Jw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9KlbH+R3oosFXzTzZe+sSEWgT5YiiDgbxDPHi
 dYetOVAKCeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpWwAKCRAzarMzb2Z/
 l2BeD/0cwkZWyDFxwU9KQWTL5ROGmE6+nhZzWBPdidLuph268yTSy9mJ+6/oCwUfihIyZVJTwbF
 1/xUqQWmr2plcaTAHMhAA22Obd4qhi2/xW98UxOwjmJDJslSdtjH3L89bsb27ejEHkRe0gYJCbS
 5gmVaWlZcjuH/p+Tx/+VUSsocOdoNKojFlBFhD2Do75/V/AXFUwHzp34SDe8cPmmnE672l8faww
 1nUi58pyrxYluZRJJAqFxi0DlJZ5+d/dDeg9ZbrO7NpWES4qqv9ZbrT5upnSA2eNewIbxzx/B2L
 vedYxMOIfzdxm1P3S/iGAOAqvxLHy5avz6hY3MLaIrBpMJUo+RhGj18DIbkGqDTOcQ4f48bOKU5
 BnlWzsiPHlo9+EpEcQvmLUwnn9MMHTaG3U5lYRxIgNFfw9l63vJLgwjN1R6ZbPDbzUuexP0E0Li
 20OwAMw71/fAZ97uQ844Bg04ScPAATO6rLLQj53OIHMF1u9ybab4Z+/wuLIs+0QP05ZhmQ83PTx
 mLAFuwR9Okb3ggR42IiNRJdAtlOvWS1o/o/aQeOjZv/SzE6juULYLAoG64m6/ToMWbuT71Xy5UI
 +w9miIuczycc4/aHCdnKS5ye0cFiEG4arPIQdeIWXcCEMISsKXwTTsjnfgPu2RQZdoAehjTS7Qm
 ktBxxAeOQ/UvpCw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_link() verifies the target directory first and the source file
last. When the saved filehandle is in another export, the second
fh_verify() installs the source export's credentials and leaves them
in place while the current filehandle stays in the target export.
Operations that follow in the same compound without calling
fh_verify(), such as READ with an OPEN stateid, then run on the
target export with the source export's squash mapping. RENAME verifies
the two filehandles in the opposite order, so it is not affected.

Call nfsd_setuser() for the current filehandle's export after LINK
when the two filehandles are in different exports.

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20261103-verofess-2-v1-0-9e6568221beb@kernel.org?part=4
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 280743e309af..454a6c4671b5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1106,9 +1106,19 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfsd_link(rqstp, &cstate->current_fh,
 			   link->li_name, link->li_namelen, &cstate->save_fh);
-	if (!status)
-		set_change_info(&link->li_cinfo, &cstate->current_fh);
-	return status;
+	if (status)
+		return status;
+	set_change_info(&link->li_cinfo, &cstate->current_fh);
+
+	/*
+	 * nfsd_link() leaves the credentials of the saved filehandle's export
+	 * installed. NFS4ERR_DELAY would have the client retry a LINK that has
+	 * already succeeded.
+	 */
+	if (cstate->save_fh.fh_export != cstate->current_fh.fh_export &&
+	    nfsd_setuser(&rqstp->rq_cred, cstate->current_fh.fh_export))
+		return nfserr_serverfault;
+	return nfs_ok;
 }
 
 /*

-- 
2.56.0

