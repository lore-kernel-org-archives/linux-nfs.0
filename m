Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793329284;
	b=tOsHhbj9yHovZYBhO8s/8Lz/R6VbfVRlgRHEbzDCEluJUwFP9k1ICgTE7LYCYNY+Q/MV
	 EYGjK7WCmyZHjcWbIQ5+J+3sLw3oMaSb+m8v9jvy1PAY6eHj2cjx/RNA4v/zzOR+5SKsH
	 2395XLXVf2mAKV/Z8UbgUGbfDJDA9tdx8r2dymTvD6vRXW9jVKfGj96pNfogeh9JwgNBv
	 tHPUIg2n6KNMtObQYCF0RQf6flFWz7jLCyUQnEZMeXEYTYq6IcrO8mbuUXuBH2zT/i2Qz
	 BbYAo5sAkuP5H+Mu0gTNvKg5XW/PsHRDlshNLIi/QuQ6dCrLzUX+yftst0HQW3KB97Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793329284;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ddXiyi97dIToZ3RY6tAnA21giJXFFXfiHSd5Wv5fL+E=;
	b=ne51iM4F352/8U7vCm7tEc7aQQ1gcn3P8AAx9Gn+j1Gj0Czo7uhJlJCz9TwWJ642FwgU
	 gfPoiD6VcvuI4GbHOwuPEPolI1ZpC5xndsbUNiIB2r4I8aM3XjkqOiEkStqzeAi6rZKHZ
	 ET43WuyiS9/QKznOalyWS476kkt09wRlA3JvtKYPEJqmW+LTIkfhwAD+xlbmKFGLEXwQZ
	 1h99usJxJh0ykVSU/+IveNWaAQUtj36jdSps5MDxHU6i5Omir9NUs2YlGBwghenaUncr/
	 zTOgRhvi2rBuYnR+w+kD+xBbEYWmpTHPKtcapp5eyyWNNUIRsDrqipLEKR4XG10luIw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MFJ47toe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE684606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 03:01:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MFJ47toe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0F751F000C1;
	Fri, 30 Oct 2026 03:01:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793329283;
	bh=ddXiyi97dIToZ3RY6tAnA21giJXFFXfiHSd5Wv5fL+E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MFJ47toeWXfViAUzmbIqce7+rqvFmZj88J/ujolZAUB7fVf0Ih48pk9gBuKfyuAnA
	 XUTdLAP9AOZfTxvJQkSme4hqgjmEWPw5UaipxEHOqLVftdQ6Kb1ehpDZlkWZu+iWOG
	 T+eE398lxg6km3X0DPpf8bTAfJwfcq585c9jfJQdyUXVzqhRyBnhvViTS1EHA8SFlZ
	 kcbkkPWNICwW1WH+HJ50JYb8oTGStMOWy+rvrtt8zgjwKMDKBryUpIffRCJVncoRGj
	 9lNvpSPiIW0dhLLxKqVxsq8cZbGm0IGdid/n2HZAwRkqgBhjYxSNyVWX6UEev26YTe
	 YVemb+xQchaZw==
From: Sasha Levin <sashal@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Tim Menninger <tmenninger@everpuredata.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [GIT PULL] Please Pull NFS Client Updates for Linux 7.4
Date: Thu, 29 Oct 2026 23:01:21 -0400
Message-ID: <20261030030121.3377197-1-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261023211150.485518-1-anna@kernel.org>
References: <20261023211150.485518-1-anna@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Fri, Oct 23, 2026 at 05:11:49PM -0400, Anna Schumaker wrote:
> * Various localio, flexfiles, xprtrdma, and TLS fixes

Hi Anna,

The rpc_rdma.c resolution in your merge of Trond's tree lost the buflen
part of 9ee534a75912 ("xprtrdma: trim head iovec when the payload
arrives via a Write chunk"). I think it needs this on top:

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c0d5042f3b660..69d4e35d49ef5 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1010,7 +1010,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len,
 	char *destp;
 	struct page **ppages;
 	int page_base;
-	int pad = writelist & 3;
+	int pad = xdr_pad_size(writelist);
 	unsigned int delta;
 
 	/* The head iovec is redirected to the RPC reply message
@@ -1267,14 +1267,9 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 		rpclen &= ~3;
 	if (unlikely(!rpclen))
 		return -EIO;
-	if (writelist && rpclen < rqst->rq_rcv_buf.head[0].iov_len) {
-		rqst->rq_rcv_buf.head[0].iov_len = rpclen;
-		rqst->rq_private_buf.head[0].iov_len = rpclen;
-	}
 
 	r_xprt->rx_stats.fixup_copy_count +=
-		rpcrdma_inline_fixup(rqst, base, rpclen,
-				     xdr_pad_size(writelist));
+		rpcrdma_inline_fixup(rqst, base, rpclen, writelist);
 
 	r_xprt->rx_stats.total_rdma_reply += writelist;
 	return rpclen + xdr_align_size(writelist);

I sent it earlier against -next, Tim tested it:
https://lore.kernel.org/r/20261020161346.3711926-1-sashal@kernel.org

-- 
Thanks,
Sasha
