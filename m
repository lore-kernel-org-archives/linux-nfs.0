Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06C913B774F;
	Mon,  3 Aug 2026 14:49:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785768585; cv=none; b=j6nPRXozHQutwk+BC/NeP+d6dtX2HosgzCAjcid+IHv86pmqUhdoBaz2BKceartDXEn1vY7ywXyHHSEiJR7pToN9Jq6yRVdQCetMiq9Dea9vSN1LEYmCZ5MEAf28HB8A4GrAmK7pXt0udGuNYRSVQLNT97oesAcDr30vALLUNf0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785768585; c=relaxed/simple;
	bh=000qLjhFfY8t5uphrRUHp2XXS77Xpjci3Rb8DbEgLiU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ewQHMNaEiwdZD+ecVwu7HsoP3e7SeVYOcJ6rgd+8Mv4iVZuB3Qm+LE0+5GmNPYLZzz1ufjA7oVaDyh4UDLCoxNO1d5L8nfJGWCRt+wCcpT8sSxkfbV/pulyRWnkg8zgSaPZuIs9z4TXrpnyjsqvA5fQF7kO/5RxpUh96+VBOiGU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d3ja4ae/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d3ja4ae/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 159041F00A3D;
	Mon,  3 Aug 2026 14:49:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785768583;
	bh=61HqsWs4WViN6j6FlSMsLvv/uPKYGpyaC//E9oV9veI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=d3ja4ae/DR4F+6N6bj3hm+XoAXx17nmAOyf9dkAAdAFGOSXd4tzv54Ve8FPhAjAJK
	 6rzMW+2z+x9OM/Se4REAYKaLqV+qK1nmIIKB9F2pA1UTPpgn3fAOjvjv8cXucFBn0z
	 N/r4yTm45oBgR/NpoEeVusmv20KuPuqAjP4+0I5CwQZg5rb6aWnPqWeSSSVyNyFzDh
	 K5gdQtKjTXAC6l9ajHXcZY4Kk3HUuZv2FE3qWLYQwThSkj+ouD51bSUzkhgAdDkBTC
	 8MCpwV7eqSnUnY2fXjSqqf2gkzvRij5BotjqZp28wHGTvCDs7u7rV6/CoKlO7wbalB
	 BhCqx859+XFmw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 03 Aug 2026 10:49:27 -0400
Subject: [PATCH 1/2] nfsd: fix type mismatch and explain host-endian xdr
 buffer usage
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260803-dir-deleg-v1-1-51be76861821@kernel.org>
References: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
In-Reply-To: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>, kernel test robot <lkp@intel.com>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1367; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=000qLjhFfY8t5uphrRUHp2XXS77Xpjci3Rb8DbEgLiU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqcKqFIR8heAKC1nVhUQlnyRiv5Q/NpjUYfXmrs
 NkqgFvvPdSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanCqhQAKCRAADmhBGVaC
 FQZmEACZ/fQEgwE43+1WQkg7B8v1hIZ69LH3J26hP9ZRD2+wrvUJxbR6K0kDnUz8E0Rz0IIGCPU
 yBK1lFpHAGskQgzTzXNMFWx/BYDeThCovqIqeV1o0/koBtoXNJtqOztWNUQstOoYGpslTwV2yep
 sXAxMidq+JcJLCUqLLL96P9QjLXQ0AWpPvsjbF/h5dSxpquKvtneUo0dDiMOTBASN4r/cexY5rg
 SXrEjLRz3eyU5wnJsGm3X+byhaNIX5wNGOVT0X9deKU/yLVVxxcARVdC4zqeEXmla9fGA0ViXz2
 vcuTzQfcIaFVo+LKkja1Rz05Y7A4chfwTq8H1UxXQXD+PbXvNZSwWAwWNEBkiro3+TfjWFotqHj
 4OOT/rCjZJkNZc8lxkqk7oZx7AGuq2aECzgNtT7+KV6QQLRjbFvbV+qci5u/VpXcTef6j4nRjMC
 r3WCM93TEsud8kNq5aeBv80bsscLc+zvhs3K9u9hZLrnpIx4upZ4iUaTvpVbyW7BYjTfpBKjZHz
 wAhf4rWQ8fleK1awo4f9rhoBw7miyKzmeDS4FUIWuSyEgGerIpdWtf/aJnWmOBkd4FJIoa5gRd2
 g7SMHJkKX6Q5EwB7mZsn/exAeN2jNuIQFuuJ4XY7GSt/0aEjj3pq7z75lxAzMq4slNrbsliymWj
 8CmiEm6IQkSY8XQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

sparse flagged this type mismatch. Also the xdr buffer usage is a bit
non-standard, so explain what we're doing and why.

Fixes: 4b64b811f368 ("nfsd: add notification handlers for dir events")
Reported-by: kernel test robot <lkp@intel.com>
Closes: https://lore.kernel.org/oe-kbuild-all/202607310455.AT0GoC5j-lkp@intel.com/
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a47eb544b99f..5cbb4a415384 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4383,13 +4383,18 @@ nfsd4_setup_notify_entry4(struct notify_entry4 *ne, struct xdr_stream *xdr,
 	struct path path = nf->nf_file->f_path;
 	struct nfsd4_fattr_args args = { };
 	const u32 *reqmask;
-	uint32_t *attrmask;
+	u32 *attrmask;
 	__be32 status;
 	bool parent;
 	int ret;
 
-	/* Reserve space for attrmask */
-	attrmask = xdr_reserve_space(xdr, 3 * sizeof(uint32_t));
+	/*
+	 * attrmask is the host-order bmval[3] that nfsd4_encode_attr_vals()
+	 * consumes and that ne_attrs.attrmask.element points at. It must
+	 * outlive this call, so steal a few words from the xdr stream to hold
+	 * it.
+	 */
+	attrmask = (u32 *)xdr_reserve_space(xdr, 3 * sizeof(*attrmask));
 	if (!attrmask)
 		return false;
 

-- 
2.55.0

