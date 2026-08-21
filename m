Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B6C3381E85;
	Fri, 21 Aug 2026 17:22:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787332978; cv=none; b=o9ugLACRxVgwvodgt5Nl4QsH/p1mhvOsdba2KjiJu7y36pY4FYuFA0BCzdG0DxfdzOdj3z1O6m8VuiJkKtbK9vTHB0myFyMzTeZXFQZPdhuEuyw9IGgsN0r623ATIAPm+xCDh2pDbiI3kbWBk2EVQQI76+QnHfkZNkUs9XEsDcs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787332978; c=relaxed/simple;
	bh=gBdC9HaXiTzP7mLoarU5HgD48sRU6gKKzhhey53iNss=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rxj+TufMUrZ7mDbaUgMl+P3gpKSPmwDZuPm287Wf3ttn6F4NClw3bW2V++cRkxcobQKkZl7sOkuKqyCNr8w+3je0rHFcgviU/BLfJULXB8XrUnoXNcqcI/wGWn9rtdpghPHB88OqvCprRdEH0kwkB29xZzb9Q1N8aaLKNBG3ANw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B4fEM6WS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B4fEM6WS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D7DE41F000E9;
	Fri, 21 Aug 2026 17:22:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787332977;
	bh=l65q6BXg0moRZQrNHmFhwcJZmAOVFr4+4RMBLrtBzfw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=B4fEM6WSFKlG5UGiDHM94VDRR/fjwUSA3tHJoTfa9kVKHECAYZWFySx5g38NWgqnQ
	 tyMNq+3b+izkyE6DHuPd1Gg5SgEsrt5DPT/XTbqe414EgYSK5lcppNLE+tnR/8rE9z
	 fOz4tognFfvscocvbUgTrfrOp9Scf8Rxds/CvPW4JMCnLDO5cCGWmHP+khx5OPX2xc
	 h5LazbKhd2MDrCZRC7iz+wci6BGwkbV5P5NjIlJ2b4PTYz7wFcLrrfMRDHS9Cp2efE
	 ydSoNM9kErqzJpyuh1Jop5Y0PaLjaG8RpTdO2q+f5yqgU4a9dLxThAqvgxJhWb1/Vi
	 0FUsrYlC8+/cQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 21 Aug 2026 13:22:41 -0400
Subject: [PATCH 3/5] SUNRPC: Flush a received record's pages once it is
 complete
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260821-tls-read-sock-2-v1-3-7ffce164eb45@kernel.org>
References: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
In-Reply-To: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2961; i=cel@kernel.org;
 h=from:subject:message-id; bh=gBdC9HaXiTzP7mLoarU5HgD48sRU6gKKzhhey53iNss=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqiIlrG+KdpsAAdhG9BFfS7DrG3y21wXIT3wIfq
 db7vhjVIRSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoiJawAKCRAzarMzb2Z/
 l6yGD/439J07DxviptkubwirImlKncS/X39sVuqpPezMZQZvfxDf4fHSveUlpS0qLdg/oAnf+SN
 ScE1kISQflpocJBShNZ9T+nSTMQB4zHpNaNzX8UmiXX+c4cpw9ILSjY/zRm/K6BQxFQM/bvk1f1
 V+y3PsFd5bSdWLJPul49WH04h7EFVhgLXxgYKYVxN6OSQLpOgy8yWufu+WkEF+GKUjt6D4oMtxK
 Jf/JZe9crNdL3lwm7CfO+ubhe6edXJ6MIR06ce67x8RxX69wz/E1Qyqw+W98MSxrTzSfzzCQBKD
 EZjp8SIme3OyyfjD21klLhwVBDVh1xaPCZfUfIIL2Tt2bZvh2msKjQEz+Y+KjObg3g95FA7K3rE
 FITxKkfqS+b+uYoCyEkAapVdkTQCLZBz3vTyVhLZpzLW538+2FMJsX8OWwsTS6YstgCsqX1DPvF
 m6hA8fe61ZHSa4AS/ihv8S7FSmocoE5u1fC3NcQYs5mWILBctXECaFFw+ho30c9/DHHRWGI53Hv
 HRSj8ygf2rC0RKaBpurKZfXZVfi8Km/pomI/pYELwnCghLKii824/o6fj1UEpTxi+fx9A+/wDnb
 /T/rKsY01idMR0VVjNjFd5yDbPMBOg9L13aE3XBrgWRTN3SNhA/qngHOFUiCMOJUCTH9rv9+9p4
 adL3VKGqp1ig+eA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_read_msg() flushes the destination pages after every
receive. A record that arrives in several pieces is therefore
flushed once per piece. A page spanning two pieces is flushed
twice. Nothing reads the message body before the record is
complete, so no reader needs the intermediate flushes.

Flush every page of the record in one pass from svc_tcp_recvfrom(),
once the last fragment has arrived. Remove svc_flush_bvec() and its
ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE guard. The guard avoided setting
up a bvec iterator, and a plain walk of rq_pages compiles away on
its own where flush_dcache_page() is an empty inline.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 36 +++++++++++++++---------------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ae1f3c474f8b..c7b94bd1898b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -334,25 +334,6 @@ svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
 	return ret;
 }
 
-#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
-static void svc_flush_bvec(const struct bio_vec *bvec, size_t size, size_t seek)
-{
-	struct bvec_iter bi = {
-		.bi_size	= size + seek,
-	};
-	struct bio_vec bv;
-
-	bvec_iter_advance(bvec, &bi, seek & PAGE_MASK);
-	for_each_bvec(bv, bvec, bi, bi)
-		flush_dcache_page(bv.bv_page);
-}
-#else
-static inline void svc_flush_bvec(const struct bio_vec *bvec, size_t size,
-				  size_t seek)
-{
-}
-#endif
-
 /*
  * Read from @rqstp's transport socket. The incoming message fills whole
  * pages in @rqstp's rq_pages array until the last page of the message
@@ -380,8 +361,6 @@ static ssize_t svc_tcp_read_msg(struct svc_rqst *rqstp, size_t buflen,
 		buflen -= seek;
 	}
 	len = svc_tcp_sock_recvmsg(svsk, &msg);
-	if (len > 0)
-		svc_flush_bvec(bvec, len, seek);
 
 	/* If we read a full record, then assume there may be more
 	 * data to read (stream based sockets only!)
@@ -1156,6 +1135,19 @@ static void svc_tcp_fragment_received(struct svc_sock *svsk)
 	svsk->sk_marker = xdr_zero;
 }
 
+/*
+ * Nothing reads the message body before the record is complete, so
+ * a single flush after the last fragment is enough.
+ */
+static void svc_tcp_flush_pages(struct svc_sock *svsk,
+				struct svc_rqst *rqstp)
+{
+	unsigned int pg, pages = DIV_ROUND_UP(svsk->sk_datalen, PAGE_SIZE);
+
+	for (pg = 0; pg < pages; pg++)
+		flush_dcache_page(rqstp->rq_pages[pg]);
+}
+
 /**
  * svc_tcp_recvfrom - Receive data from a TCP socket
  * @rqstp: request structure into which to receive an RPC Call
@@ -1202,6 +1194,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (svsk->sk_datalen < 8)
 		goto err_nuts;
 
+	svc_tcp_flush_pages(svsk, rqstp);
+
 	rqstp->rq_arg.len = svsk->sk_datalen;
 	rqstp->rq_arg.page_base = 0;
 	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {

-- 
2.54.0

