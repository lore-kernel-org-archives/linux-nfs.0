Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1219A488D91;
	Thu, 10 Sep 2026 12:52:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789044735; cv=none; b=enZrYHswaCZBfpzRlZ2JgeMKkPGRD7VViyhDq8Ao3IsQ5O+CVtdug3kNne1Y5Ldh6u39zn8czIX/onR9xi9FYye43tvV0wsHWIVUCLJkoKVOnpkAbh2FO4tCdu4PMFG5XXnH099G+3mXzbTET+xbtAoXEyDbc74YMONQRF5QAtc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789044735; c=relaxed/simple;
	bh=Ezn8F+nhVCikENYJLwij9ukuuBoM6PdN4QdRtdvgb0M=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=Qn5u0/i5PkyWUAhdJchBOs2kwb2zTRy44+Yk+LJDKOkmX6lH8O9cFjUbXTvV5tXamtkbwtCfvmvaBZ0Y30ZTr6tIpNGZ9gjTvVv2/HYWfTiRKWBT3b+RxrEtEj7E1nfnJzQEMxkdza+hwRD+KnOTEgv6TIKvNS0RPL7TufiSCCQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=MKyAnVA+; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="MKyAnVA+"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=72zdgAReQQ3eTBRpuedEj0C50a+TNwS2vo4+fbBTZd8=; b=MKyAnVA+yGwjdtJULveA5holtL
	iRXxKfDpVyTzIhiKkS5BcRVxq1rCaN6VkTPXWcpkN+L2cdLAnIauAOAjtvb282gIaK+bTLCxQdy96
	tN7A3mGq31TQpNFGVcSpQPux2ur+7gpXkmAZ/E9Cu8JEqKxkMPCWwynEZIAUm5Pn2NPouUhD6UkFZ
	Is9UWTFiYK9l2n9ZfB8mrNSSlB8XUNGo7AUb8RIecsPh/RGE/NCjeaMl8uMOVxtirl4yx78p1CPG7
	i0hvNvxTZERlWAHpLTcIUPNjOW8MwdJudhRBin6KEeAwuPg+SIQBBdKYgb6Hcy6XV/O2IKoJxa7jn
	GiLNSVmA==;
Received: from [151.115.150.205] (port=50146 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.5)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1x4eG8-00000009e4t-1HUR;
	Thu, 10 Sep 2026 14:52:05 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Subject: [PATCH] SUNRPC: fix oversized GSS proxy token copy
Date: Thu, 10 Sep 2026 12:51:20 +0000
Message-ID: <20260910125120.3798995-1-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

gss_read_proxy_verf() allocates one page per token chunk, but it copies the
entire linear head of an RPC request into in_token->pages[0]. A UDP datagram
can leave more than PAGE_SIZE bytes in the linear head, so a large
RPCSEC_GSS INIT token overwrites following pages.

Copy the linear head in page-sized chunks before switching to the request
page array. The linear head itself can span multiple pages.

Fixes: 5866efa8cbfb ("SUNRPC: Fix svcauth_gss_proxy_init()")
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
Assisted-by: Codex:gpt-5
---
 net/sunrpc/auth_gss/svcauth_gss.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 967e9d5..ad1e178 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1085,10 +1085,11 @@ static int gss_read_proxy_verf(struct svc_rqst *rqstp,
 	}
 
 	length = min_t(unsigned int, inlen, (char *)xdr->end - (char *)xdr->p);
-	if (length)
-		memcpy(page_address(in_token->pages[0]), xdr->p, length);
+	for (to_offs = 0; to_offs < length; to_offs += PAGE_SIZE)
+		memcpy(page_address(in_token->pages[to_offs >> PAGE_SHIFT]),
+		       (char *)xdr->p + to_offs,
+		       min_t(unsigned int, length - to_offs, PAGE_SIZE));
 	inlen -= length;
-
 	to_offs = length;
 	from_offs = rqstp->rq_arg.page_base;
 	while (inlen) {
-- 
2.47.3

