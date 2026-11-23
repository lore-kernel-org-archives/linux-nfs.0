Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438765;
	b=z2GM6YF5s+Sf9hsgDrs/tm/bwMObbGv3ciHzIcslqbqzDKKlVjHNUeWDMRh36KjpW6oY
	 TyrqCiG2gktPqGRocUAwz4TuGYSHbuUQFdEhZpuWpYin/QeS/UXk37MEQK4SLv1topRG7
	 jfXdxq2E6Ol9gwzFuejUdAgBHRUm/zJxKaJAT5xnitNBjYohr9UzDlxgsrxm2FhS5Fr1Q
	 DitssJ42Eoeq4OSe2g2x5mXraG+mN3M83HQKRYAY+NoSNnXtdt/3xr87o+b7mavdtLXAb
	 xRDD2nms6VeyWXihq3axcPm2hqQWVpsxjZM5ftWtLZ1H9YV8Rb/v6K5q5+VE5LGZo0w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438765;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=3dcIJsldixuW5oIi/bQJmNzqprHHDcUhGFZj4Bm9sCA=;
	b=L15Bhv3tB0U9Lufoh5Tdj37rNKS+bbSFjHcKOA9jc0VmNlDK7k1ykQY9JjreT09TuNeq
	 33viw4ooyQ6Kph0p+TajavhyLM6R/g4xcj7klPtNX3+kO2t64PDY6FlJ5tquwtFmP+pr/
	 2OdlHBsAAYnTABUJw+JlGOPGRzXhplMJIM0Mo+RyqYvZYq32HEYzqzMUSCit4/ajjdg9v
	 phTvILgUfpGx8N0B9hRb7N0rg7RnP72+/RCRnUf11nRRWGbJCRlGDMXPaJRY7wbsRDS0y
	 pjV3DoJP7yEez70DDdBOMHo5I0LLaBxhe1ZNpszxKZzMYU25V4szRk5QQYjxO8w2a9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kmIf1nwP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F182E606A33B;
	Mon, 23 Nov 2026 12:59:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kmIf1nwP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8E171F000C6;
	Mon, 23 Nov 2026 12:59:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438764;
	bh=3dcIJsldixuW5oIi/bQJmNzqprHHDcUhGFZj4Bm9sCA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kmIf1nwPvx24uQlxoIToMDeF/hnkQbqo3CRBOdtEorLYw9fEp7j3k/1/xKVvUw8dl
	 F6/Dle+fGasgXl11a+J/bN4882m3DdApRDAlqT+20PjN4TPl2ytQA/tYzy3BGCTzWz
	 sdcjQbNHMfBWhJq3IY5Uaio4j0w+rd8AEsDgDNQ+BwoDFo5U3x7cAoBz9Q/nsT6We7
	 N431eITiDfEyhJlpPVKGee0wipmM+87Cs7jkAc9DKgd7JCw4Co7vFQPUeSXmxx02PS
	 69IFMqY0khbVAGo+PJmqYfnuDM9gyV5K5L3eBtutsOISvUAQ2go2hB93J8bJdkbyeZ
	 +SZU0jn7f++mw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:07 -0800
Subject: [PATCH v2 04/11] nfsd: don't grant write delegations to NFSv4.0
 clients on CLAIM_PREVIOUS
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
Message-Id: <20261123-delegts-fixes-v2-4-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1119; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=dCeBuyX4iAFjFAe6/Qhj51iL8hiks5cI+UbCd6LamnA=;
 b=kA0DAAoBAA5oQRlWghUByyZiAGsEOKSg/UxsbsZ8EUsV/wO7A7Orl0dXpdtERCYCZ0k/NrEI+
 YkCMwQAAQoAHRYhBEvA17JEcbKhhOr10wAOaEEZVoIVBQJrBDikAAoJEAAOaEEZVoIVGv8P/1TT
 Y8WZv9WpP3UFGajbYNtTDLrThh9uBnuYi4ZooHi28JqBWWKx/BhLdDPcxSVfngE1fDKza/rqxXE
 Z+A4LivM2VSf4JuAwW3BWGjlHl+8ZVbDEyy7cBKU7S4/QCBcljZrXF1orejNuZmfq8ezww3yykn
 hBA7DliOW6qqm67zBiFu+WY/YJf5F9dJYkOsDAXZnQwG+EpyPOKFPpFDlsJLRxRzFheeqya2zna
 wcUJRx3F3ILnCHRwjuY2G4I5sA22vy5xpjoeLn3YoR6nWXX9KwQ6/D3X8OyvJpSPG1VkCdP45CN
 bcxt/Lb4xOADvr5UIYvwQw4KUMbGh3kJFGTRcPj4dlssR8Sh9hHzTVoPIlgILJWWEd1hMKoMI40
 VvNjUAMDsYA6Qkb9aMwko4kt2YId+i9EP+PhWQG5jRjIxYWQwBHajFmWihbpwIjU584pETG+KAZ
 HVLCss4DV5PYK2KFIw6ZabkPW93WuovaMzfZ1daWdrfF3ZEWH15tRo+6pjXpVHiQsAMQ+NAcTnQ
 0Q+in24vYNnlOTQKN+8OFyDV84/+6ewPW1FQ8sVQ18sW4e3+9z53Ib37IuLSF7XbBmAEhIRoBWV
 CuClGmCZ4bE3gjiCMt5aD4XjSEK9AXC02Mrs7+GkM+cHfz8CLvg5ZDeu58JuGqm8cx9c/abqvwr
 gp8Iw
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_open_delegation() refuses delegations for NFSv4.0 write opens on
CLAIM_NULL and CLAIM_FH, as its comment explains, but CLAIM_PREVIOUS
skips the check. An NFSv4.0 client reclaiming a write open during grace
can therefore get a write delegation, and NFSD can never complete a
GETATTR that the client sends before DELEGRETURN in the same compound.

Apply the same check to CLAIM_PREVIOUS.

Fixes: 1d3dd1d56ce8 ("NFSD: Enable write delegation support")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5c2151b329c4..4b28553efc8d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7533,6 +7533,9 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	open->op_recall = false;
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_PREVIOUS:
+			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE &&
+			    clp->cl_minorversion == 0)
+				goto out_no_deleg;
 			if (!cb_up)
 				open->op_recall = true;
 			break;

-- 
2.56.1

