Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599051;
	b=KzNEVzUDHTma24EXayH7Dm+uYUiVfZQBRdhpQbw3dFULNkoNffxFxUxXpZ7ClHxzaFE9
	 qTN1146/Q5VraR9E2ky8y+eTvSd8BFo0RayH+LAuroLH/yJkBP4hXTI3NWgomcK5DR7hl
	 a+Q8dkH0+BnJCo047pRwgAkovZzX/dqtwa7qF+QOtgeFOl+9hA1XrQTdrWm6e2mrdy5fd
	 Ow/LbTbFCoFPicoFHr09J/1XXPOOWYaegU0eZ81ETeRIP1WWzudpjIIJbhSb5deR4qRdQ
	 rxG82x6Yivppz+o42vcp4I/DuR0NijElqlLpd1R08fyJNtuvnHpXyqI9XLAF0M/PDDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599051;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=UEDzFosUVk1wWC2uM0T0N8+N9TEbp28HAC5rK2+NCwI=;
	b=LSlQfMibsODj8dMLRnUSkgPBOHMFEGUnkE0CRixfplyeUyfDJk/zs3CPFL6O5Da5nhOR
	 DP6PNmbKtQJYJ/wyYcIVqKBqHPRxA+HeCctCCTp89tLx9e0WWG4waStkaAfFP7xNu3NeB
	 CNYkYAWNoTv401SZlC1KJNT2EuE8nvCcElAhdut6pttkze/nM3ypQIWKMignhmVnZ3Ee6
	 2mEO39pZo9JQgm+uhDOxQ2p8jsz4CNcFffynZk9aArkR7CJTME2EmpU8/nUvXe0FQimZy
	 3Nq9+lwLkv5rV1s/MTvcift2nI4xiw9ikXE/672ag3qzm4EJ7O68qbxjrJwz9JwwoEQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gNnszGJz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AFBD6606A32D
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gNnszGJz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9FACB1F000C7;
	Fri, 13 Nov 2026 19:44:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599051;
	bh=UEDzFosUVk1wWC2uM0T0N8+N9TEbp28HAC5rK2+NCwI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gNnszGJz9nq8pq8O2yswnJIf8FqjR0E36B4lSquDKeXNHL3CgLdt0WX/Yhj0rwips
	 OY0DSaUOze8fMA7hp4vjrQaJw6joBd1qbUd8YpEAHF++MydQT8UUukWes/w//s4EUz
	 oFZlo5aNVkzRZp68mprew51cHAPOqqALtfpS+TYHv8Si1i+2qWiYxkCULKfQ32Kjir
	 38+M7UUOrQ+5MjSCDBlUj74kiNMUTZHDxxiGqLh7smBV+LacBqktCYHxeSJalRLOwI
	 cjY34wdDuE0C45hi2DBclRbPupC0/Tzq95E7KNPkgNKoIQh0VartLaUTErRd8qdRbT
	 F/4fS0nBAx2IA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:00 -0500
Subject: [PATCH 2/8] SUNRPC: Reserve a leading rq_bvec slot and add
 svc_rqst_res_to_bvec()
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
Message-Id: <20261113-svcsock-bvecs-v1-2-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3518; i=cel@kernel.org;
 h=from:subject:message-id; bh=aKj1UgODNq1TBNTN1sNEfiFEBdWkFbxG1wi7emIEzZ8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iHGCeJpPkoW7WIChdsPcMy4Gf5/O26wJRrz
 19pRYTfrWWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 lwZ7EACCB/BxbD3CaW02876ZIt/yyWKfqUNqO4ImqTdikOQV2ERW4r6zj94ingi3FlBLQV/Jmmp
 miL2jy5afnBo59JWjTrQ019N9owrLU3Iw3ym8SC+pCg8Le4jMP7ok4R+mnU7zyOEdL1Nmmhd0Ra
 qK6JwAaIwPAkMekKvmWmTz5lYXx1MBcyrsg6JuPLx+92Vb5jmRMCBvoY/vZmYtIYu8+CZrrm1Oy
 wRBjx2eHpZL2sAwljqJtHIL91rZ22jXn9/OA+BIUiMIFlI7ZmQkqe01KtrOrbcu9G17glbk37dy
 c4UUQ+5MD6J4R57BTh4eGZJbIU0SeGk/k0ekseia2olZs+yFgcsWggrv6TdmiCCqnVyyr35pfqi
 5g8sz8jzzMwc5xAg1DOPd//0jsxbdoqhhsA0kU+Y4R9lEovcaUga2SbfUaaSczx/cxQpCXm7Eu/
 fnm+hEV/gMDfoKvt6j0a02icC8aURWsASagzhIuw1FygJlhlWsCyTJn/zLESWmHdNVqaLMLeH07
 n1bALXOSxuoQ3ODk3nf0i3hxdxo8bf3MbZ9g/zpinWMClTm0BrwXr15L4qfxDfk/mxsb8fWJfgQ
 d/megohru/KqY5DZlWdFKA4hbmo+v2SkxL5TLFBTKHs74ZJoxlrwICpQJ2dDgHKJ/T5hAvY6Yst
 cJ62q/1fdFggpuA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The socket transports convert rq_res into a per-socket sk_bvec
inside their xpo_sendto methods. The conversion is meant to move
into svc_send() later, so that no transport walks the xdr_buf.
svc_send() is transport-independent and cannot reach an array
inside struct svc_sock, so the array svc_send() fills has to belong
to the svc_rqst.

Each svc_rqst already has an rq_bvec of rq_maxpages entries that
only the receive path and NFSD use. A TCP send through rq_bvec needs
one more entry for the record marker. An ITER_BVEC iterator covers
one flat array, so a single sendmsg() needs the marker and the Reply
in adjacent entries.

Allocate rq_bvec with rq_maxpages + RPCSVC_BVEC_HEADROOM entries and
add svc_rqst_res_to_bvec() so the transports share one
xdr_buf_to_bvec() call and its size arithmetic. Export the helper
for svcrdma. No behavior changes.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h |  5 +++++
 net/sunrpc/svc.c           | 21 ++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 042972163b87..497f56cdf7b5 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -136,6 +136,9 @@ enum {
 	RPCSVC_MAXPAYLOAD_UDP	= 32 * 1024,
 };
 
+/* rq_bvec entries a transport can fill ahead of the Reply message */
+#define RPCSVC_BVEC_HEADROOM	1
+
 extern u32 svc_max_payload(const struct svc_rqst *rqstp);
 
 /*
@@ -464,6 +467,8 @@ struct svc_serv *svc_create(struct svc_program *, unsigned int,
 bool		   svc_rqst_replace_page(struct svc_rqst *rqstp,
 					 struct page *page);
 void		   svc_rqst_release_pages(struct svc_rqst *rqstp);
+int		   svc_rqst_res_to_bvec(struct svc_rqst *rqstp,
+					unsigned int skip);
 int		   svc_new_thread(struct svc_serv *serv, struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *prog,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 920ae5aeef7e..b61edc49b253 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -656,7 +656,7 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
 	if (!svc_init_buffer(rqstp, serv, node))
 		goto out_enomem;
 
-	rqstp->rq_bvec = kcalloc_node(rqstp->rq_maxpages,
+	rqstp->rq_bvec = kcalloc_node(rqstp->rq_maxpages + RPCSVC_BVEC_HEADROOM,
 				      sizeof(struct bio_vec),
 				      GFP_KERNEL, node);
 	if (!rqstp->rq_bvec)
@@ -993,6 +993,25 @@ void svc_rqst_release_pages(struct svc_rqst *rqstp)
 		__folio_batch_release(&rqstp->rq_fbatch);
 }
 
+/**
+ * svc_rqst_res_to_bvec - Convert the Reply buffer into rq_bvec
+ * @rqstp: RPC transaction context
+ * @skip: count of leading rq_bvec entries left for the transport
+ *
+ * The filled entries point into rq_res without holding page references. The
+ * caller leaves rq_res intact while rq_bvec is in use.
+ *
+ * Return: the count of entries filled after @skip, or -ESERVERFAULT
+ * when rq_res does not fit in the remaining entries.
+ */
+int svc_rqst_res_to_bvec(struct svc_rqst *rqstp, unsigned int skip)
+{
+	return xdr_buf_to_bvec(rqstp->rq_bvec + skip,
+			       rqstp->rq_maxpages + RPCSVC_BVEC_HEADROOM - skip,
+			       &rqstp->rq_res);
+}
+EXPORT_SYMBOL_GPL(svc_rqst_res_to_bvec);
+
 /**
  * svc_exit_thread - finalise the termination of a sunrpc server thread
  * @rqstp: the svc_rqst which represents the thread.

-- 
2.56.0

