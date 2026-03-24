Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C42D3241665
	for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2026 13:04:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774357496; cv=none; b=P3G3VF5Q8CuCe+rJY8ThFxFufUoD7RlXajck2iNxa1W3NOYO58a/0LZt3UynG3G4lC4P69eTc3MplrnmRoxybaSIX3+ekiEpM7dScBtx1cAgEpcNs8CggWPrmw1i2TXemfAcmVtpRerMsCEP32pYshvMfCNx/srhu5FclK81RKQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774357496; c=relaxed/simple;
	bh=tPO26QCdsV9yR7xuiARlu84CAkfpHZ2pNK4xdKI2mcA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NMdvp+aTGg3GgcaZ+eRrTzsFOi0x6fSTEBPwSk7G1eSfCrW4X5jl/20adUQOYC7ap5GMok7Yt3f5ppfXvVkmENju/Yg9ryVu+PcGEepqQz0kou86GcJkEf/28ADTdZ/QRiGOD/rrHrp5QsDzhl191LZRQTUaPUAsW14HjQG0tzs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XR80WG8J; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XR80WG8J"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F378EC2BCB6;
	Tue, 24 Mar 2026 13:04:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774357496;
	bh=tPO26QCdsV9yR7xuiARlu84CAkfpHZ2pNK4xdKI2mcA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=XR80WG8JX2iGGdVXq2r92MRZ5FOJ/GFr4lx9c8e9+NeHxEREbNdhUyNoh8ukBHvsQ
	 myd7dTHEjr8rsp5tbUQdDurBpV1GkncAnnjdx8M0JsHCIrC2ENN1eWyjE1r5h+35UT
	 0NURIytwEBb2bD4/iwTt8dGyi0xRMq0Q7ReckXsgmHAESLd7ZMRY+1VTVYx3aJfu73
	 4TVw7cgNXUJZya0K43Ar8jLCL3FJFL9x5aEcPdBDfkOq8WZookgDS02UpC0pCtOYsi
	 YJ4Gud99B6hesXeHZd6Xl6gPG1ZecqUvzR1QPVE7FkFBt5ExRThzPr2c6x/QoO53C3
	 XM8QItU/dtLqw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] sunrpc: skip svc_xprt_enqueue when transport is busy
Date: Tue, 24 Mar 2026 09:04:49 -0400
Message-ID: <20260324130449.16437-4-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260324130449.16437-1-cel@kernel.org>
References: <20260324130449.16437-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

svc_xprt_resource_released() calls svc_xprt_enqueue()
whenever XPT_DATA or XPT_DEFERRED is set. During RPC
processing, svc_reserve_auth() reduces the reservation
counter and triggers this path while the current thread
still holds XPT_BUSY. The enqueue enters svc_xprt_ready(),
executes an smp_rmb(), READ_ONCE(), and tracepoint, then
returns false on seeing XPT_BUSY.

Trace data from a 256KB NFSv3 WRITE workload over TCP
shows this pattern generates roughly 195,000 wasted
enqueue calls -- approximately one per RPC -- each
paying the full svc_xprt_ready() cost for no benefit.

Add a BUSY check alongside the existing DATA|DEFERRED
check in svc_xprt_resource_released(). When the
transport is BUSY, the holder will call
svc_xprt_received() upon completion, which already
checks for pending work flags and re-enqueues.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc_xprt.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 36c8437cfd8d..d2b8f0396b6a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -440,16 +440,23 @@ static bool svc_xprt_reserve_slot(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 /*
  * After a caller releases write-space or a request slot,
  * re-enqueue the transport only when there is pending
- * work that a thread could act on. The smp_mb() pairs
+ * work that a thread could act on.  The smp_mb() pairs
  * with the smp_rmb() in svc_xprt_ready() and orders the
  * preceding counter update before the flags read so a
  * concurrent set_bit(XPT_DATA) is visible here.
+ *
+ * When the transport is BUSY, the thread holding it will
+ * call svc_xprt_received() upon completion, which checks
+ * for pending work and re-enqueues as needed.
  */
 static void svc_xprt_resource_released(struct svc_xprt *xprt)
 {
+	unsigned long xpt_flags;
+
 	smp_mb();
-	if (READ_ONCE(xprt->xpt_flags) &
-	    (BIT(XPT_DATA) | BIT(XPT_DEFERRED)))
+	xpt_flags = READ_ONCE(xprt->xpt_flags);
+	if (xpt_flags & (BIT(XPT_DATA) | BIT(XPT_DEFERRED)) &&
+	    !(xpt_flags & BIT(XPT_BUSY)))
 		svc_xprt_enqueue(xprt);
 }
 
-- 
2.53.0

