Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EBE250C285
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:50:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540657; cv=none; b=uGI2G7DMqkXBLHEFGyLskhvB7/nwyc96fWjXBt3hLH9PQvsD26NBFN10R/a0onxcM2BkNB1WtONL+429wG1i3E+EfhecsGgIlx/RcQUZXpDX4GBlp2qeesR8iNmjmnHaMGah7Dr+qdFyqDJCSlKg5i51twN1uNe+ATj9alshGtY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540657; c=relaxed/simple;
	bh=9sJ0wBIfHa0loLgoHpOqJimjKMPArRJU05yX0e1rPHI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rZ3gWzZfQHUKdr0S8d1nDfAp6k1UO1wBf2vrtLu7LoPRR26G0MW2NexFWQwXggOmHglX31YcYO+/v7uIX3P7XT7ZnBgsHCpqigw2nn3SNWpiBGlHPFcFtgTLoscgTF6zje8ZtnsL0nFtDv31T+30eIxiGVDyyuebXAYnJf6OB9c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=D9wuex1d; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="D9wuex1d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E9281F00A3D;
	Fri,  4 Sep 2026 16:50:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540655;
	bh=dCApN47+sCO1brt27KFwNWVquU9OuKd5gHLe7CyUbV0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=D9wuex1dhGriTXARIMEJ2JRmcJ62Sze3AvxyXpmROlwvxRIpouC/UDIk73MXK8xhS
	 stAor7TwKpe8AMsG7VruAi0V2Q4gOuA+pvdq0Fhp20vDcHarmz6eaG4O1mD8bYbBdf
	 2Tol+zDSFllMRw6efB7M/ioCJiLyYzdacV8BtEFNU2eqzgubaqdGWN9Lp/U5l35i9P
	 XxRBLxaLaq4QGM3B50U58ZhV4hM7lx2Ksrn1hZ2lvHN4G7d6R1RsUMEYUxaJHtYjvo
	 jbV4Zob3/LIpmhBIsqFcDfNs/9iFtgJHCj19K2aXTAItGmED+8LHAwDc6SkFk8fndT
	 q6SM1Qz9/2MLA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 02/10] SUNRPC: Bind the svc_rqst to its XDR streams
Date: Fri,  4 Sep 2026 12:50:44 -0400
Message-ID: <20260904165052.153327-3-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260904165052.153327-1-cel@kernel.org>
References: <20260904165052.153327-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A generated XDR codec function receives only an xdr_stream, but
some codecs need the RPC transaction the stream belongs to: to
reach the procedure's argument and result structures, or to mark
a page-resident byte range as a result payload. A client stream
already records its transaction in the rqst field; a server
stream records nothing, so each generated codec that needs the
svc_rqst would have to store it in xdrgen_ctx itself, and every
such site would decide on its own what the pointer means.

Store the svc_rqst in xdrgen_ctx from svcxdr_init_decode() and
svcxdr_init_encode() instead, and read it back through
svcxdr_rqst() so that no codec open-codes the cast from void *.
A codec running on a stream either of those initialized reaches
the transaction, and through it rq_argp and rq_resp. Every other
initializer leaves xdrgen_ctx NULL, so svcxdr_rqst() returns NULL
there and the guarantee is scoped to those two entry points; a
codec that needs the svc_rqst names them in its Context: line.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index b80161b849ce..e69aeb864a8d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -532,6 +532,8 @@ static inline void svc_reserve_auth(struct svc_rqst *rqstp, int space)
  * svcxdr_init_decode - Prepare an xdr_stream for Call decoding
  * @rqstp: controlling server RPC transaction context
  *
+ * The stream records @rqstp, so a codec running on it reaches the
+ * transaction with svcxdr_rqst().
  */
 static inline void svcxdr_init_decode(struct svc_rqst *rqstp)
 {
@@ -544,12 +546,15 @@ static inline void svcxdr_init_decode(struct svc_rqst *rqstp)
 
 	xdr_init_decode(xdr, buf, argv->iov_base, NULL);
 	xdr_set_scratch_folio(xdr, rqstp->rq_scratch_folio);
+	xdr->xdrgen_ctx = rqstp;
 }
 
 /**
  * svcxdr_init_encode - Prepare an xdr_stream for svc Reply encoding
  * @rqstp: controlling server RPC transaction context
  *
+ * The stream records @rqstp, so a codec running on it reaches the
+ * transaction with svcxdr_rqst().
  */
 static inline void svcxdr_init_encode(struct svc_rqst *rqstp)
 {
@@ -567,7 +572,19 @@ static inline void svcxdr_init_encode(struct svc_rqst *rqstp)
 	xdr->page_ptr = buf->pages - 1;
 	buf->buflen = PAGE_SIZE * (rqstp->rq_page_end - buf->pages);
 	xdr->rqst = NULL;
-	xdr->xdrgen_ctx = NULL;
+	xdr->xdrgen_ctx = rqstp;
+}
+
+/**
+ * svcxdr_rqst - Retrieve the transaction bound to an xdr_stream
+ * @xdr: stream to query
+ *
+ * Return: the controlling svc_rqst when @xdr was initialized by
+ * svcxdr_init_decode() or svcxdr_init_encode(), otherwise NULL.
+ */
+static inline struct svc_rqst *svcxdr_rqst(struct xdr_stream *xdr)
+{
+	return xdr->xdrgen_ctx;
 }
 
 /**
-- 
2.55.0

