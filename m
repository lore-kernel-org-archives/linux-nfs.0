Received: from mail-wm1-f100.google.com (mail-wm1-f100.google.com [209.85.128.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E12B431A50
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 18:15:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.100
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791569760; cv=none; b=sn0zJmrI/5bP+Y+cz1T7VDqTKm2LIlyLc+b5togmvKulaF7UQApmUBY/TvM/lCWPnsUhuBXU4m7FI+P9xHe2HzU0MnsgNOBb5mWac9DDynVIHP+Ff/j5WOzKK4cXU4aZlYNtrZAlGkSywOSAbr6J2Ed0hh6JlFxmlHvamrWtlak=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791569760; c=relaxed/simple;
	bh=KQQJ+CHj3noUPqd3hIOKH/SstTaXg/xWE+mbjKTc6QU=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=TXBA8qTxdUS2IceZk89mKsGt12/LUWWXbhqQR1Yq+beVmwJNVI+8G9PrtaY6dI1yzLz+FZctLODxPXR9Q2fvafPVhoTo6kkcsnOW7OwETUilsXa//+ARjkFPxXvBxIt/ynzP2jOQWA08OBehgOPTOjrBbRFCz9ca7fArUxGN4IQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=UhkTVboJ; arc=none smtp.client-ip=209.85.128.100
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="UhkTVboJ"
Received: by mail-wm1-f100.google.com with SMTP id 5b1f17b1804b1-49ff680331aso1097675e9.3
        for <linux-nfs@vger.kernel.org>; Fri, 09 Oct 2026 11:15:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1791569757; x=1792174557; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=PKh0n31LZjAabx1GRWM6AQ6aUQk08xh7miYGIsbVSlE=;
        b=UhkTVboJozaRtNyHM6Olto+yCVOvaRrcj12FNiuV9ycRnF/aBvS61RGdwrgywKZc2U
         GP3JIIF6SKj3uc12yTxsFzSV9n/oSsmi0aV74KPxz/0iWS7v58/jNAtoUlrKbMamJzA9
         dG9PSCQYXl5BjtVvfr8Kx2b+iBwKbo+uLpplrSZYL0aDC0Jx2l2mRtde8kUWqoT7gIle
         A6Fk12LXVCzePCAdwmRPYoFAZLRs89347znKeuWC8UjsR+O7vqBF6clh6Uup+fG7Q1EE
         8dciMLfoT8dM/0i/620Fu8qEYBWjlhBlCibxbrTFhm20G5FlACO6wsgjzpiUv3soG64C
         zErA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791569757; x=1792174557;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=PKh0n31LZjAabx1GRWM6AQ6aUQk08xh7miYGIsbVSlE=;
        b=ndN5EkZjHcRY4Psuqh0cDiaDn3rxuo4jI2BXzqlpkIjNTcJIOVJ4uqdN9cnb2sg8lY
         dEWGKcjbWtnTVo0jKe3eq/uz1K3PSaTTNJXfeRiH2eCTJQRIEMuznhc1wCx1yaU6BWEC
         +wEh8hSyuSrFIPnIPvEmdRr3K5N7UR9sOUCxI+9JdpFPt1w+wUZqG1mSvzpAq6VK+EdB
         mCyjy27g67HYbQkFeoRn/vraFYs2MXgZyHPUzf4RNv4K/NG9gCd1HfROYgQHFKldYD/H
         ZALEso/6LG7/z2XIxkL86KKknoej3urx1cDLl6MxTj/0jMlRE6whdP9U/F7/fJq6rTt+
         FREQ==
X-Forwarded-Encrypted: i=1; AKwUvBwDAZ2a8VDbN76T4gdbaUQbZtm19ugy+GEfH+87DFmmvnF8yU6McHvFeIZv1lvRkZ/3jwPOVkdnvnw=@vger.kernel.org
X-Gm-Message-State: AFuF++lXCHv0xYwOioR2IWYrczd3RooqomxUkQuN81Mbm+tekffY3TZt
	/HTvCmx2nA6kLKzVrBoxFYgLMUPy5WLcB+yIMeOXksITJIZmrQdGljt2sS9v74CaWBes53AlhBO
	Q+QBrrtrJwgnpRZMqDtlhObrCLvtDgsE8sawx
X-Gm-Gg: AYBFou1be3iH7A0SegHVY5YuvuCc8RvOnBHWVOn70P25rDANnLHCTwboUImVIYE6BzO
	A9nul5AAE8BRD4Zci+gk7Z3SyF0am+mFbbpYF+ACQG7+YGHrNQpeYG1ArnUS1b8ymz5dYxjlz/7
	bp4bT8/kBb5PTZpPykJxivtMejItZs7W5CLlkOuFowZyFeMJbglqxb8LCqCtnZJnmg0LMN1JCut
	dVJXxcK5XMVfMiDbjT6XKAdXHVDhT+m21fBPvHqQibRcBzbGqS2vG8nnnasreJQm6nXwVXWL7gd
	6nYC6jtAclR9ctGWs7XoSp7ndPUeg4dRdYdUdINoWXiNdoIJa7kTbxJ87T+Bi8mybJhccpZ7Plx
	ofUlv7tZSq5iErwSRIA1SSnbcN6ok2aqivdw6UJY=
X-Received: by 2002:a05:600c:609a:b0:4a1:717b:7976 with SMTP id 5b1f17b1804b1-4a18e4b15e5mr54406015e9.35.1791569756709;
        Fri, 09 Oct 2026 11:15:56 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-4a18bc48302sm7189525e9.2.2026.10.09.11.15.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 09 Oct 2026 11:15:56 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id F24603401CB;
	Fri,  9 Oct 2026 11:15:54 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Chuck Lever <cel@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>,
	Yongjian Mu <ymu@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH] xprtrdma: trim head iovec when the payload arrives via a Write chunk
Date: Fri,  9 Oct 2026 18:15:54 +0000
Message-Id: <20261009181554.2280374-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Yongjian Mu <ymu@everpuredata.com>

The upper layer sets rq_rcv_buf.head[0].iov_len from its estimate of the
reply header size. For RPCSEC_GSS that estimate includes
auth->au_ralign, which gss_create_new() initializes to GSS_VERF_SLACK >>
2 (25 XDR words, or 100 bytes) and which is corrected to the real
verifier size only after the first reply on that rpc_auth has been
unwrapped. In this case, the krb5 MIC verifier is 36 bytes, so every
request encoded before the first reply completes has a head that is 64
bytes too long.

On TCP this is harmless: xdr_realign_pages() moves the excess head
bytes, which are genuine reply data, into the page list. With
RPC-over-RDMA and a Write chunk (sec=krb5, i.e. RPC_GSS_SVC_NONE, where
DDP is allowed), the payload has already been placed directly into the
page list, and the receive buffer holds only the inline part of the
reply. rpcrdma_inline_fixup() clamps its local copy of the head length
to the inline length but leaves head.iov_len untouched, so
xdr_realign_pages() still sees iov_len > cur and shifts whatever lies
past the inline reply in the receive buffer into the front of the
directly-placed payload:

  rpc_xdr_recvfrom:  head=[...,196] page=524288 tail=[...,64]
  rpc_xdr_alignment: nfsv4 READ offset=132 copied=64

The first 64 bytes returned by each such READ are incorrect (zeroed, or
shifted right by 64 bytes depending on the kernel's xdr_shrink_bufhead()
implementation). This is readily hit with pNFS flexfiles over RDMA and
sec=krb5: the per-DS rpc_clnt gets a fresh rpc_auth whose first RPC is a
large READ. Reads following the first completed reply return the
expected data.

Commit cb0ae1fbb2f5 ("xprtrdma: Do not update {head, tail}.iov_len in
rpcrdma_inline_fixup()") removed the head-length correction while fixing
the handling of pure-inline krb5p replies.

When a Write chunk conveyed the payload, trim head.iov_len (in both
rq_rcv_buf and rq_private_buf, which call_decode() expects to match) to
the inline length actually received so that the XDR layer does not
realign the page list. Pure inline replies and Reply chunk replies are
unchanged.

Fixes: cb0ae1fbb2f5 ("xprtrdma: Do not update {head, tail}.iov_len in rpcrdma_inline_fixup()")
Cc: stable@vger.kernel.org
Signed-off-by: Yongjian Mu <ymu@everpuredata.com>
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1285f04cdac1..bebc9a20b28e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -984,7 +984,7 @@ void rpcrdma_reset_cwnd(struct rpcrdma_xprt *r_xprt)
  * @rqst: controlling RPC request
  * @srcp: points to RPC message payload in receive buffer
  * @copy_len: remaining length of receive buffer content
- * @pad: Write chunk pad bytes needed (zero for pure inline)
+ * @writelist: bytes conveyed by the Write chunk (zero for pure inline)
  *
  * The upper layer has set the maximum number of bytes it can
  * receive in each component of rq_rcv_buf. These values are set in
@@ -998,13 +998,16 @@ void rpcrdma_reset_cwnd(struct rpcrdma_xprt *r_xprt)
  * Returns the count of bytes which had to be memcopied.
  */
 static unsigned long
-rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
+rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len,
+		     u32 writelist)
 {
 	unsigned long fixup_copy_count;
 	int i, npages, curlen;
 	char *destp;
 	struct page **ppages;
 	int page_base;
+	int pad = writelist & 3;
+	unsigned int delta;
 
 	/* The head iovec is redirected to the RPC reply message
 	 * in the receive buffer, to avoid a memcopy.
@@ -1016,8 +1019,20 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	 * head.iov_len bytes are copied into the page list.
 	 */
 	curlen = rqst->rq_rcv_buf.head[0].iov_len;
-	if (curlen > copy_len)
+	if (curlen > copy_len) {
+		/* These READ replies have no inline fields after the payload.
+		 * Trim the head without moving the directly-placed data.
+		 */
+		if (writelist) {
+			delta = curlen - copy_len;
+
+			rqst->rq_rcv_buf.head[0].iov_len = copy_len;
+			rqst->rq_private_buf.head[0].iov_len = copy_len;
+			rqst->rq_rcv_buf.buflen -= delta;
+			rqst->rq_private_buf.buflen -= delta;
+		}
 		curlen = copy_len;
+	}
 	srcp += curlen;
 	copy_len -= curlen;
 
@@ -1245,7 +1260,7 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 	base = (char *)xdr_inline_decode(xdr, 0);
 	rpclen = xdr_stream_remaining(xdr);
 	r_xprt->rx_stats.fixup_copy_count +=
-		rpcrdma_inline_fixup(rqst, base, rpclen, writelist & 3);
+		rpcrdma_inline_fixup(rqst, base, rpclen, writelist);
 
 	r_xprt->rx_stats.total_rdma_reply += writelist;
 	return rpclen + xdr_align_size(writelist);
-- 
2.34.1

