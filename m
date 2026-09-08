Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C515D54EEA3
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 13:42:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788874970; cv=none; b=UhVhdIjXYLbG80D/tnvkDoxhSgkPTPYWnBuYll0Gn0uhniMkvKsmnsFyBFe3nHhbutRuj7guLPBDy8uzi2/0r1yF2Ek163tUqM+Xg44BUsiq2/F+YrG79N5YmwrTGAxgMk2deXtY88W1fsUoVxIN1N9lvfm4XSrcZvAb6GVB7SI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788874970; c=relaxed/simple;
	bh=XMQMUdbO7ucmKm1omDdPHBrUYm0CE78z3mSjzNRbttA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PIPhIeQRDVoeR7F7KRUFZ/W6GLAXqjhqd5vPoow4D5+apfK6b+RIcGabUgOF3I4dGYX0k+j2otK7Z1DBH8Htx/fdKskYPFvfCU01t8+USa7C1/mQrahniDkuepEq6TVfl1k24sPaPCA2Y+U5qwkUBoFsPJx7AHNwWSCPs7KxdUw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B4DC1F00A3D;
	Tue,  8 Sep 2026 13:42:38 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 01/10] SUNRPC: Carry a generated-codec context pointer in struct xdr_stream
Date: Tue,  8 Sep 2026 09:42:25 -0400
Message-ID: <20260908134234.512312-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260908134234.512312-1-cel@kernel.org>
References: <20260908134234.512312-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A generated XDR codec function receives only an xdr_stream, yet
some codecs need state that the stream does not carry. Passing
that state as an additional argument changes the signature of
every function on the path from the program entry point down to
the one that consumes it, and for generated code it makes each
function's argument list depend on an analysis of the entire
specification.

Add xdrgen_ctx to struct xdr_stream, a pointer that the layer
initializing the stream sets aside for generated codecs to find,
following the precedent of seq_file->private and
netlink_callback->data. Every xdr_stream initializer clears it, so
a codec never reads a residual value left in a stream that was
allocated on the stack or taken from a transport's free pool.

Signed-off-by: Chuck Lever <cel@kernel.org>
Acked-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c          | 1 +
 include/linux/sunrpc/svc.h | 1 +
 include/linux/sunrpc/xdr.h | 1 +
 net/sunrpc/xdr.c           | 3 +++
 4 files changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 00ddaac499c6..6ea6cb0632f8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4609,6 +4609,7 @@ static void svcxdr_init_encode_from_buffer(struct xdr_stream *xdr,
 	xdr->p = p;
 	xdr->end = (void *)p + bytes;
 	buf->buflen = bytes;
+	xdr->xdrgen_ctx = NULL;
 }
 
 __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5fa9417e034d..b80161b849ce 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -567,6 +567,7 @@ static inline void svcxdr_init_encode(struct svc_rqst *rqstp)
 	xdr->page_ptr = buf->pages - 1;
 	buf->buflen = PAGE_SIZE * (rqstp->rq_page_end - buf->pages);
 	xdr->rqst = NULL;
+	xdr->xdrgen_ctx = NULL;
 }
 
 /**
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index b102b4f21e6b..2b33fc64be17 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -244,6 +244,7 @@ struct xdr_stream {
 	unsigned int nwords;	/* Remaining decode buffer length */
 
 	struct rpc_rqst *rqst;	/* For debugging */
+	void *xdrgen_ctx;	/* Context for generated codecs */
 };
 
 /*
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index cb2ef428651f..d95e80d85a89 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1162,6 +1162,7 @@ void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p,
 		iov->iov_len += len;
 	}
 	xdr->rqst = rqst;
+	xdr->xdrgen_ctx = NULL;
 }
 EXPORT_SYMBOL_GPL(xdr_init_encode);
 
@@ -1181,6 +1182,7 @@ void xdr_init_encode_pages(struct xdr_stream *xdr, struct xdr_buf *buf)
 	xdr->p = page_address(*xdr->page_ptr);
 	xdr->end = (void *)xdr->p + min_t(u32, buf->buflen, PAGE_SIZE);
 	xdr->rqst = NULL;
+	xdr->xdrgen_ctx = NULL;
 }
 EXPORT_SYMBOL_GPL(xdr_init_encode_pages);
 
@@ -1619,6 +1621,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p,
 		xdr->p = p;
 	}
 	xdr->rqst = rqst;
+	xdr->xdrgen_ctx = NULL;
 }
 EXPORT_SYMBOL_GPL(xdr_init_decode);
 
-- 
2.55.0

