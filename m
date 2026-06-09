Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 767F14D98F9;
	Tue,  9 Jun 2026 17:48:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781027284; cv=none; b=qGh0aWqDTqpDLHeEA3EihdUyCFWVEZZUANLnFsMuSN4MOxbsvH3oWRRKbLWDv0oolo6WQ9iG+t072vyFrdYp464CDq2I/bhM04a7jv0V9XoKvJIqY3QYl+sz2ToLgl5H1ziEhc5AWpifjYQ3dwnJjR05etkgUSfKq47gGeDZ/fY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781027284; c=relaxed/simple;
	bh=KVrLhX9lsnQb1vW4B3vqrncGKobnyg/dgPHZxa0IyTk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=j23sxxiX4rN8X167UEwqpTO2nDVbXSYq5UbolGU49CXUdjzfjxk6xnoC4kc0tXr+4jZzLNCo4ea2/p4Zohhi5bMkGctzISowSCZnZXq10Az82/8nwLNQzhymE5B5SeaNc4KfuLI7eqxnyQ/EW3o2fJMJVcz33tHDXjfUtDh2w8A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gCkfE2cD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gCkfE2cD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7A4911F00898;
	Tue,  9 Jun 2026 17:48:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781027283;
	bh=VGQgLYYOesAWY4AaR21R8wLs+Xwa63VsdpGz6sz3/hs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gCkfE2cDJ2ILmVjb4KUhgsXlzSh/hRwI5mpHIs/fbPiZI/+OS5Y6/jiGNe6uMt3ee
	 3llMqy3inQDc7RcVoqPdmRYq7o8zSygdItBjPk7gMuFRFBOqBAKH+cs90sZ4erdqXN
	 0ANnr8Dqiw+CGnPgmA0oU89NwFq/O+96zpsRi6OtoMyvMa9j8vKk14ZgESY+GkFMnx
	 cp4SSZcnA5GWd+EVQOj1NjEEGmnd3osVInTZPti1JZciET64IClA2XYCX7AGIKpoOp
	 zd8zo/+zy+xKdg2oNNYut92ctsJvIJN41kUR9ftoO2ROQMAUcF9AfLGMParzWzQicr
	 hc0NlkGUJg2Ew==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 09 Jun 2026 13:47:30 -0400
Subject: [PATCH 09/19] nfsd: remove premature NFS4_OO_CONFIRMED in
 CLAIM_PREVIOUS path
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260609-nfsd-testing-v1-9-e83acead2ae8@kernel.org>
References: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
In-Reply-To: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Christian Brauner <brauner@kernel.org>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Donald Hunter <donald.hunter@gmail.com>, 
 Lorenzo Bianconi <lorenzo@kernel.org>, Qi Zheng <qi.zheng@linux.dev>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1050; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=KVrLhX9lsnQb1vW4B3vqrncGKobnyg/dgPHZxa0IyTk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKFG7STSaX6KxdI5j88333BiJi5gyEyp3Jpqgt
 9CgpDfo0WuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaihRuwAKCRAADmhBGVaC
 FQQrD/9Y+/TFwm3Q9ENanUHkdGitNqSoHgyRH3x4YyBBmVFyX9tZollaGl0MPV29ehA+eRYwfF5
 QeRoSerlwataKeb8x2LnVb4NFczIbdCuPNK7G9QPJShxH0UPKKN1YkrxU+bLt8ilGblipKiZnto
 ctq4w0DfbpeOLOU+Og4sYM7Zy1vH6K+t5TQqBGu5hDvuXUtwNGA1+nNOgU0UkUcHcVywsKupvYy
 8kCEblui2y03XnSNRQ/apjT2jywwqZ7Mulppgxyt97jrPfl2FUtDggYPDItftG0F6aTQ8PplMtH
 PSiRTOek/Qf9aNXHr4VGlvY3jkSKzde025PFyDPMgt33q6GNdzAmHm9Qvm8wq/DJBA6phuB1IHh
 e1Kw82jU+uEExtjBQvNpq/kTyVUk9km6se9QYYmYlEYiBwJsj4c05+03Uo47yzApD4RqGoQCXQA
 U8VQwoYs8YZucpzQfr8JD0giYZjk+vfjEKu8sA8vu7Ii5lo8IjGmiLKBvyz+2DgEWP63aacSy5M
 xWdb/utf2CUmYMEwOhncAZ9S0VjYIX4qVzOP28DvJCn/7O5DCYigOrJXHzQLNWsbsf/Bto48+o/
 Nq9fr0iWxa01DB9JIRdb0hGxksOSw4xIpBIyhoLnuVVtm2B+3/9yNpyRHcFBvudSen0W1zCjoyT
 sqde/SMC4bKdlLw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_open() sets NFS4_OO_CONFIRMED on the openowner before calling
do_open_fhandle(), which can fail. If it fails, the openowner stays
permanently confirmed despite the OPEN failing. The correct
success-path setter already exists in init_open_stateid().

Remove the premature setter. NFSv4.1+ is unaffected as sessions
always confirm at creation time.

Fixes: a525825df152 ("[PATCH] nfsd4: handle replays of failed open reclaims")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 69fee481581d..4fe46996c8ed 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -643,7 +643,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_check_open_reclaim(cstate->clp);
 		if (status)
 			goto out;
-		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 		reclaim = true;
 		fallthrough;
 	case NFS4_OPEN_CLAIM_FH:

-- 
2.54.0

