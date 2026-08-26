Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EE3E42E416
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 14:34:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787754858; cv=none; b=LX3LCSGlotOrSs0pdvxUHAW85a6KZZ6WE3mm3axBB3lkw8PieXqRSOv5m+/jRI7oT8qO/mJrGPl2mhJkJemyQLe0sMdvsGTBBxD1RJWkHliWuRem63WL56TO4bB7feXUaEos0HZF7qiBsoAo7FFXu1yzwQT1ExaZmPUikXhK7S4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787754858; c=relaxed/simple;
	bh=UMODuBa0DDr4jQBv+A61IRwYeaVrZnoGlUVGRM/j2W8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ZWqe5sICl6i47uGIPc4K1Mh3abhcrk7rHht7Rv+R5KqtxD3UzIkpjTssHXlC7UMQV0jAVHEaDUio60YwVN3ncXwl+31LcVW8k8RkAud7gdDQF+LuPKe2oCJGFGQ+J4q1fPSOkKtkvcbsRBRA6KyM6mwzZ70jNFa/p7RgK4fWYDA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gGXp4wV2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gGXp4wV2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E47E1F000E9;
	Wed, 26 Aug 2026 14:34:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787754857;
	bh=Rk+AmXDqbTCCQr82MZkC+lR33tXYei6uGdxcxhjanfs=;
	h=From:To:Cc:Subject:Date;
	b=gGXp4wV2nokAdtUPWp/PgogAHP5f7Fx+F3xQZvj79CzZ4VZ4D6FsxncMDvxbHAeEW
	 4WyhkLryjzCet7HSRjYUytjDS92+wl6Do6ih/EWteZYmKVC8tUEx/QJb9jW7jLMHVB
	 mwK5Gf97NHL4nxqun7CBLx7E542A0FJEDq+a/ZVbI1XZH0xfMOmZIwVXEaN8AjWXVR
	 AlypPFTj6q/yLQsCSrNAQpNYg+loUQGu7mGZ8S4aQGSNXi5I45alCdQC3bp0dFLgOf
	 gDLJIZ5lezrwUvXzTNFCtNeWlDyZYV6OZMUeBkDzF7Q7aPY5XrdeOjZm260rpITC4A
	 UyLoZaQr2XKNQ==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Subject: [PATCH v2] xprtrdma: Fix Write chunk payload corruption on a short reply header
Date: Wed, 26 Aug 2026 10:34:15 -0400
Message-ID: <20260826143415.62041-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An NFSv3 server may return READ3resok with attributes_follow set to
FALSE. The client has already reserved enough head iovec space for
the largest possible reply header, so such a reply falls 84 bytes
short of that estimate.

rpcrdma_inline_fixup() points the head iovec at the received message
but leaves its length at the reserved size, so it runs past the header
into stale receive buffer content. xdr_realign_pages() then shifts
those bytes into the page list, and the READ returns transport data
where READ payload belongs.

nfs3_read_done() records the shorter header size, so on an ordinary
NFSv3 mount, only the first READ is corrupted. However, the FlexFiles
layout driver installs its own completion callback, so every READ
from a data server is corrupt.

To address this, reduce the head iovec to the header bytes actually
received when a Write chunk carries the READ payload. An auth flavor
that transforms the payload cannot use a Write chunk, so scoping it
to Write chunks leaves krb5[ip] alone.

Fixes: cb0ae1fbb2f5 ("xprtrdma: Do not update {head, tail}.iov_len in rpcrdma_inline_fixup()")
Reported-by: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Closes: https://lore.kernel.org/linux-nfs/SA6PR06MB104695205126871E29444567A8BA02@SA6PR06MB10469.namprd06.prod.outlook.com/
Signed-off-by: Chuck Lever <cel@kernel.org>

---
Changes in v2:
- Reduce the head iovec to the inline header bytes received.
- Exclude a Responder's implicit XDR roundup from that length.
- Link to v1: https://lore.kernel.org/r/20260825134033.325599-1-cel@kernel.org
---
 net/sunrpc/xprtrdma/rpc_rdma.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1285f04cdac1..ba8bdca8a49f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1243,9 +1243,19 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 
 	/* Build the RPC reply's Payload stream in rqst->rq_rcv_buf */
 	base = (char *)xdr_inline_decode(xdr, 0);
-	rpclen = xdr_stream_remaining(xdr);
+	rpclen = rep->rr_hdrbuf.len - xdr_stream_pos(xdr);
+	if (writelist)
+		rpclen &= ~3;
+	if (unlikely(!rpclen))
+		return -EIO;
+	if (writelist && rpclen < rqst->rq_rcv_buf.head[0].iov_len) {
+		rqst->rq_rcv_buf.head[0].iov_len = rpclen;
+		rqst->rq_private_buf.head[0].iov_len = rpclen;
+	}
+
 	r_xprt->rx_stats.fixup_copy_count +=
-		rpcrdma_inline_fixup(rqst, base, rpclen, writelist & 3);
+		rpcrdma_inline_fixup(rqst, base, rpclen,
+				     xdr_pad_size(writelist));
 
 	r_xprt->rx_stats.total_rdma_reply += writelist;
 	return rpclen + xdr_align_size(writelist);
-- 
2.55.0

