Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D176A494A0F;
	Thu,  4 Jun 2026 17:06:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780592809; cv=none; b=eevFHx7OZQgaRuM1J/grEwDFZmu3E94wBq/1mmHzHU2vs4XG1ChxY0SOFmJ77VgsCpQ52Ih421eJ32XPDHm1PEgBU99CXsvNAFQ/M3T/PLjklXCq5EZUV+rhanajsFH+wYMKJN61FoDNGeJulSMAkztJBvwP7Agn4kPv4khnIG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780592809; c=relaxed/simple;
	bh=gl5u9T/WLsv9NTBax558oFwZ21E9wEI7/d37tIqkhUE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mBVqZPI7/uimeEeqQB/wvYTh7y1b3sKyP26FA6Eee6ryjWjeV8Xx2uFiMXD/57ooYKAC51QM6pKMxCWtIGex7qvmqgsqC8z7zw64YQavX7cTKWgeUbCFo4NjWBPMHSTIRf9qfV51fFBqY6UEix6A2+SZwzHm8WTvjWKJ3KCZ0S8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ov6I12f3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ov6I12f3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 832501F0089B;
	Thu,  4 Jun 2026 17:06:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780592807;
	bh=6Q+6ltYCCo2mDT/WucqCnba4SUIQ8Iu39pG0SvFlirY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ov6I12f3LQZKnWLTVy5xfL+FIPgAdCv0SdlVGaRjMs+A/jK7xzSYVMnElTR8ZB2jZ
	 D6VVpaMuWhC8ORa2rIVNIUNPeuienneYqByTFIenlu2Sq4K0LBuiarsrYgFw0R/Owd
	 pw6hXyuDcq6wMDVjeHvYeUOsp/46ynqwxsTWKekPz1HT0wtIQ8bGXKgVyHAP8KB3/6
	 5kXxEOOOdwn8dmCXLtVxLliZlNNwb+z9MvKIAQMxXS1y2kNDxeatzLYzM+p+NPOYzI
	 Q0l1RCayq9ffL0WfBulO1G/rFxVDslGsFzPOjt2TA7JjoAbIMmuqFgML9+8mLid90u
	 rV7F9rFKlLTmA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 04 Jun 2026 13:06:35 -0400
Subject: [PATCH 3/8] xprtrdma: Check frwr_wp_create() during connect
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260604-xprtrdma-refcount-v1-3-f74553f461e9@oracle.com>
References: <20260604-xprtrdma-refcount-v1-0-f74553f461e9@oracle.com>
In-Reply-To: <20260604-xprtrdma-refcount-v1-0-f74553f461e9@oracle.com>
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1958;
 i=chuck.lever@oracle.com; h=from:subject:message-id;
 bh=cmYagXODy/yqCft5L24NlmwNLE3KSuDltPN21XJngD8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqIbCm2N5tJFkWM56VjQjuilO0jCY7YvN+0rQyj
 RUZYHU9y2yJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaiGwpgAKCRAzarMzb2Z/
 l5CZEACneNamZeYhF0hds66EDFP1sRqXIysYcGLa9iKf6U6cvGptGZlTClcmVpJtYzbDVd+6ono
 ax+TcsSuqscaX5zOnV34fkuOT3KaBp4AZHJiPgzRtE+/maBPvbbLS9mfuLFRaQZemxdCo+PEcI+
 Zo0LvUGb+JLgYpFP92zW0geskpGPON1PTugpHu4JCCL50U+3W6/3Im8hMhCf4SGIsbKcm5Y/18k
 6es96OAXKR7ZYNhwqnrH8Pgj2WbSkJSfnzPSPh7xnC2LjNjiYiYjDj+rGJDHW9vhKkDVZqniIuZ
 tho3ci8QNe7NC3+wCP9+lTDYRxlIJTFknWOFDeTrGk4hYJFa5K2+IIOt4tvb1eOXXodIwTb+I3h
 yJ8esK9PE9gqtjzvEm3DKeFpJgusTT4YIwwdRUNkTdSAxvnLoBvRdYvPQWK8+B7Ny2e5L9/qLFS
 a6OsYVaiI8Oqds/Su8JGUbfTf+NdSi6PLPHp0JHp8mlK3Krde1UFQahhvBHCuiyMAn9FOGqZC+2
 BoHZB/M3dmWbUx/S2Ytw0gpNLLIaLCXAOZB9eHLQ5kj4Remnf1f/OHvCPL6fyJrjiPwnAHxRAZl
 Kelh1ZMDMumJUuT8m67UObnNguKDGSJeohUOi2OUhlR9yOJ91AouWjWblS6nFRGxKGSb3pbcQPE
 LEk2pFpQqrbS1Pg==
X-Developer-Key: i=chuck.lever@oracle.com; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

frwr_wp_create() creates the singleton Memory Region used to encode
padding for Write chunks whose payload length is not XDR-aligned. Its
failure paths return a negative errno and leave ep->re_write_pad_mr set
to NULL.

rpcrdma_xprt_connect() currently ignores that return value. If
frwr_wp_create() fails after the rest of the connection setup succeeds,
xprt_rdma_connect_worker() treats the connection attempt as successful
and sets XPRT_CONNECTED. A later NFS/RDMA read with a non-4-byte-aligned
receive page length reaches rpcrdma_encode_write_list(), passes the NULL
write-pad MR to encode_rdma_segment(), and dereferences it.

This is locally triggerable on an NFS/RDMA client after a connect or
reconnect hits a local MR allocation, DMA-map, MR-map, or post-send
failure; a remote peer alone cannot force the local MR setup failure.

Check the return value and fail the connect as -ENOTCONN, matching the
adjacent setup failures. This keeps XPRT_CONNECTED clear and lets the
normal reconnect path retry.

Fixes: 21037b8c2258 ("xprtrdma: Provide a buffer to pad Write chunks of unaligned length")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index ea78f82ec4d3..04b4b0b40a3b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -549,7 +549,17 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
 		goto out;
 	}
 	rpcrdma_mrs_create(r_xprt);
-	frwr_wp_create(r_xprt);
+
+	/*
+	 * rpcrdma_encode_write_list() dereferences the write-pad
+	 * MR with no NULL check, so fail the connect rather than
+	 * publish a transport whose write-pad MR is NULL.
+	 */
+	rc = frwr_wp_create(r_xprt);
+	if (rc) {
+		rc = -ENOTCONN;
+		goto out;
+	}
 
 out:
 	trace_xprtrdma_connect(r_xprt, rc);

-- 
2.54.0

