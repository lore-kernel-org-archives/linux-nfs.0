Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A24B0448BA9
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 13:40:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787665237; cv=none; b=NZoo/kMXLpFbIuMzUdBrFGWrUk7gU1usmLNiEtFoimwE5D42qEtnGMMW5pox8VTEMciPQa0MFOe/Ch3voDQRtE+IZswn6m7PwrlDoY1AQemx5pJaWJCCog1RscEE1i9qp+CjfmgoawQ2Ujz38gMMI+0F5qHXUMaxtHWjMwatgDo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787665237; c=relaxed/simple;
	bh=oppuXcHBoMiC6YdWAgygUfKjnJZMQLEWFCC/6MTNlMA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=GoQhFSNmrHTrFG4q4Vxtkb+Nm0YRCOzNbqesGrky2ug+X200UHaScKgwq5ByijHHPK2WLYYAArfkqrHBOv1peVgam2lPTR4ijZc5C6gZWfH1+CkfLZCVcUJCq/vVbnVaSEpoI33E03DqW7lEYqRFBFFi4TcjqxxFjqxmH8khR3k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=K+qm61Uj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="K+qm61Uj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA2681F000E9;
	Tue, 25 Aug 2026 13:40:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787665236;
	bh=J4403p5pYb+no5Jacm7Rqra5FSD1YbRJx56fRKHK4bk=;
	h=From:To:Cc:Subject:Date;
	b=K+qm61UjAoSIjKFDodyVmg9sdXcCx+motERq2M+KY59LnUJQ5EC3OqofOkcddAhF4
	 xWPG7djaEsj13ykzSGnpYy+Jxs7a1IrgiJsnTmZT8g05M/tP/bl7Xkbjp7+2PtpC0n
	 LqZhlp5omEFW+TvHgdN8y1k0lDioOdKcF2VKGSJTPCfUyd49BbhVICE7Y9ycnRmdHF
	 HG3aAHmzkLrvykspSoDAtc0sSMCLjq7YVOMds+Ar6/5Aa828tJ6NepeIkl9nyGtCkf
	 XajLwCoZjYQ6gQ15ZrphBVrjnCgvq+IQT//8lKV7ac0SAr23XxGf6sGBHs0av4X0mr
	 1sx4JTHJvJXEA==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Subject: [RFC PATCH] xprtrdma: Fix Write chunk payload corruption on a short reply header
Date: Tue, 25 Aug 2026 09:40:33 -0400
Message-ID: <20260825134033.325599-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RFC 1813 lets an NFSv3 server return READ3resok with
attributes_follow set to FALSE. The client reserves room in the head
iovec for the largest possible reply header, so the inline part of
such a reply falls short of that reservation by the 21 words of the
omitted fattr3. rpcrdma_inline_fixup() repoints the head iovec at
the received message but leaves its length at the reservation, so
the last 84 bytes of the iovec cover stale receive buffer content.

xdr_realign_pages() finds a head iovec longer than the decode
position and takes the difference for reply data.
xdr_shrink_bufhead() shifts those bytes into the page list, so the
READ returns transport data where the first 84 bytes of file content
belong. An ordinary NFSv3 mount corrupts only the first READ,
because nfs3_read_done() records the shorter header size for
subsequent calls. A FlexFiles NFSv3 data server corrupts every READ,
because the layout driver installs its own completion callback and
nfs3_read_done() skips that bookkeeping.

Reduce the head iovec to the number of bytes actually received when
a Write chunk carried the payload. Commit cb0ae1fbb2f5 ("xprtrdma:
Do not update {head, tail}.iov_len in rpcrdma_inline_fixup()")
dropped that adjustment while repairing krb5p reply decoding. An
authentication flavor that touches the payload cannot use a Write
chunk, so restoring the adjustment only for Write chunks leaves the
krb5p repair alone.

Fixes: cb0ae1fbb2f5 ("xprtrdma: Do not update {head, tail}.iov_len in rpcrdma_inline_fixup()")
Reported-by: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Closes: https://lore.kernel.org/linux-nfs/SA6PR06MB104695205126871E29444567A8BA02@SA6PR06MB10469.namprd06.prod.outlook.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtrdma/rpc_rdma.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

Note: Compile-tested only.


diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1285f04cdac1..42698a2622a4 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1244,6 +1244,16 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 	/* Build the RPC reply's Payload stream in rqst->rq_rcv_buf */
 	base = (char *)xdr_inline_decode(xdr, 0);
 	rpclen = xdr_stream_remaining(xdr);
+
+	/* The head iovec is sized for a maximum-length reply header.
+	 * Leaving its length unadjusted lets xdr_realign_pages() shift
+	 * stale receive buffer bytes over the Write chunk payload.
+	 */
+	if (writelist && rpclen < rqst->rq_rcv_buf.head[0].iov_len) {
+		rqst->rq_rcv_buf.head[0].iov_len = rpclen;
+		rqst->rq_private_buf.head[0].iov_len = rpclen;
+	}
+
 	r_xprt->rx_stats.fixup_copy_count +=
 		rpcrdma_inline_fixup(rqst, base, rpclen, writelist & 3);
 
-- 
2.54.0

