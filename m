Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549758;
	b=AF24C1jE/LtMNGDJCbLOe17zAksHWsWDnnbKDiY+flMAcNxclKxxKJEQxQxbfZ1ptGwo
	 V6F899n5NE3FI8291Lr8zDTN7gMemNmRPM1OsoAlsGqIXkt7C9gjNnEw36fI9EOyk8Nz7
	 q48aYzNUP8Ijs1JesR9Pla5sc/1spGxjVhmeUfInKUAwv23DFhN+wsoj2GKnR7XgYH/DJ
	 8ct1KZydSg2GWyuB1DbcpMRuabAmdUFwN/aUyACCNXnXHG2kn7g6U7cwYUeNlPvC6kbeh
	 LkSIItTPwNLSNKDXT2fLMzJVx+IjRG/DVO4+7WwOQYPVzx6zcDuROKwIijBG0C62RRQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549758;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jg7hs5jvVNR8OXpAtrVOefW43N9tndHzcXsUvzGGrOU=;
	b=JG0iSB9KHSqUWNbuZ6+N8+dBN6K3ZsbL6yI/oQ9l0BbkxNylKsANDDMG98b8vFsJX1yl
	 kVILIaoWz46nX+p07lvh/VnhMBllRQJKf1TQSZ+BABwBfeZCP7VcaaZUza63ImTC0eCJS
	 +WMBBu2lM9W2xzYHjlxMNPyyI9Pa0aeC7RvkbvS/wGPHx/oLJmcwbwpVsRMkmct8nDN92
	 jXox6PcQhq+flE6iM0q3I+74zoek+4cojxSjo7x6nD/xs6Ze/kAQB9E41bKaPOAOhgihK
	 EhnV6Jser4ZvcYLJxaYAr9bGs7GVjnJuLfTAtyg5uu5PWLBm9ask3JxPndL/5rcLubQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f1BPlSS7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A22C9606A69D;
	Tue, 24 Nov 2026 19:49:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f1BPlSS7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C2F031F000D3;
	Tue, 24 Nov 2026 19:49:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549758;
	bh=jg7hs5jvVNR8OXpAtrVOefW43N9tndHzcXsUvzGGrOU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=f1BPlSS7VMhhK2R8b6LZVjC8wUUCGF70j1to25Uqrcazaz4zq6MqdBxXPeZFa6lz3
	 qm+ibNHdRk07phm76dTUP0vcHWSZ57WFgQjIOFIKxMF8EbR75S+3RknoUlwp5Epy6C
	 qKIdKwWE9xr8iVwQ38UwqKUL0qVdCHtjByQBXRZhGZUMNzv0z5iW2pWUzsvl2NqpvZ
	 wK0kRhC+y5WikACE0QArjdhkAzGYHKGAf3eSQ70AADzq2mZLXLqt5lP8ljDomFv6tZ
	 abku4tAmXsW5aQNumwwT0EQmEIrSAduzl8GgxzNKmsDFDkLQbZQUJ6tCkx9KbgChGz
	 f8/hW+NhcwiNw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:43 -0500
Subject: [PATCH v3 04/12] nfsd: don't grant write delegations to NFSv4.0
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
Content-Transfer-Encoding: 8bit
Message-Id: <20261124-delegts-fixes-v3-4-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1184; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=xsEZJZSCLjMO6DFVXUr2huRjfVNFltsxOviGz78on5k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo1CLyT90lof86UGCerB6qwNpBw1Y3T0fRAk
 dZ20g67kFWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNQAKCRAADmhBGVaC
 FaWmEACFBciiNVSdWwwiAvaP+U0CxeGOBV9Vk/t/0gdh4sOglOLNClMNmPBewtcXrdYdMlPrwR5
 vBjDrVbZX5PaZr78bkpGvv3FziqtMO6LFw4X9Q7oG/2gEhqjSIOjGMbSjFcFP7TNjsJVQUKBCpI
 Ma5qlYjF3UyEHvSjUNUPfigneM5oR0F9RrNbe+zMdsehj2fa+1cGPXXh9fAowZwoA4xX+659JCF
 6K9Bxu80Xrp3/zp+sKJ7hnYDolyqaYlqq64g8HHTEdnV5dMhyKxVhq8fUB1QsgkNVYhX7TgjhwQ
 GnQefNZ91lM4ThR9yrKJHz4mRnd9KosXSmsJFfDFg8osJAuy8+Y/12Jo63BQwoZoi5siJg3940w
 TdaOJvYFxZRJ7/EVA06rvq+O2yzS3bN50PTgkSIIdagfsNR4ZvHiab7gNXiu/2KTgwgSndu6tnd
 7KypykzUX6x6AoBqqjy67lBvN05qHDU3rwJoL9GMVZoyZtwK2y9hp+fc8sUfvxhB1Gh+SPuFmVj
 kwetvJZBUHcJfuzWwr5xvtWKyq690cEcz3Ag6ooygnkLdHgrYLAlVLzxe664aihByVyygLDHY5n
 2BRUJUrQ/eNVkCw9memZJQ1oYrW+ptnOqAw0bJvu5MK5PEs3XEMSNRpGSdHs72a1YoA1NQJYT1H
 3m5ygMzbyPoH0wQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_open_delegation() refuses delegations for NFSv4.0 write opens on
CLAIM_NULL and CLAIM_FH, as its comment explains, but CLAIM_PREVIOUS
skips the check. An NFSv4.0 client reclaiming a write open during grace
can therefore get a write delegation, and NFSD can never complete a
GETATTR that the client sends before DELEGRETURN in the same compound.

Apply the same check to CLAIM_PREVIOUS.

Fixes: 1d3dd1d56ce8 ("NFSD: Enable write delegation support")
Reviewed-by: Aurélien Couderc <aurelien.couderc2002@gmail.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c2c082006d81..f865548c297b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7542,6 +7542,9 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
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

