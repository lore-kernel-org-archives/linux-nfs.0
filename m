Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49F203F9F3C;
	Tue, 26 May 2026 13:36:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779802574; cv=none; b=QDbxpx/fCIdQD4pMEdc1v/iyk4ATho7ozQggOIqYGa7GmzZOLL+ZxO50NaTm7yh/cKLYhmNOoIF+nHNIiSP4jekTqZMnzpul1Pi1beaWGTbbJixERENV9xpB+6s8Z3/cMq92ZgYCjKtQblBlgAnEGSNc4TtE0RYT5Si53V9Pc9s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779802574; c=relaxed/simple;
	bh=4dmFSYyu5dVAuzUoWKFe688QeWWurx+Zr7f4H59QbVc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=l69Zq/cWSdAxv3aGVTCEe2EeLvNxzknlpQojeBqsecrkz/NuXT8Roc82Kv7JolkkGU8KoWZ3X19Je+IqmQTrfut6y3eSxY8xr8H1ojGrUrd25Tnb77By2CXS26LavS7w4/P0CMWI6QtcIpVFEUrRiU7UBb7VYbfUC7M2buZ2Rww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Y50wA5V5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y50wA5V5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 702E41F000E9;
	Tue, 26 May 2026 13:36:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779802573;
	bh=DA2E0roGnlqQ2HFYCxvWZc3WFGEHO3rZ0uowe66+XAg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Y50wA5V5TSOPZrfgM1n2SzkOj6TvVUOivvEOmbdT3I95vE1NsW3FPFzdPKH4ii06W
	 pKVXvq5XjiWNegCoeqwc5/izrWWq2w/SiRLixTBZHTHwAhhUcdxQZc4RffjOzp18Er
	 7RA4/DAXHnb30EJ1tY9T5+S7t+t49zmBE5bgRFlPXOXysqm96G1/iCIwbaspodGhq0
	 WN3uhIqfVBBuMHccLhbkUtX2KH84c0puGA2P0AGCFTHa+dDZdXk/uoj3/rElMuInlf
	 MDDINafuFrkI13Ziwklut83NLlU6QlPW6GjM7afzC0CCchw50Shko1qKX57/1ok2h+
	 iD0fq7+dn6aMg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 26 May 2026 09:35:57 -0400
Subject: [PATCH 3/6] svcrdma: reject oversized Read segments at decode time
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260526-rpc-kernel-bugs-v1-3-e251306ccca9@oracle.com>
References: <20260526-rpc-kernel-bugs-v1-0-e251306ccca9@oracle.com>
In-Reply-To: <20260526-rpc-kernel-bugs-v1-0-e251306ccca9@oracle.com>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Chuck Lever <chuck.lever@oracle.com>, Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2532;
 i=chuck.lever@oracle.com; h=from:subject:message-id;
 bh=ilXDf07YelaVSR07Fd2KtghEt5c6sM4c8H9r5ITQqBQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqFaHJ1Aw5iP2SeGXYNtjSCK/tkv4aEPMt18z8C
 R6vUYMoNL6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCahWhyQAKCRAzarMzb2Z/
 l0ZID/93iEXp4pWo9iSpTIBc6t6AZpcNEAeICfgH6AzB5BCKqjokJR04WATA/5Ps92XepD7Ev2F
 g6ClwRmw3L48/2Hy46r2nDwXGHQIpGwKvsWqQwKPbw5Ajp416k9dSNKR3q7GspgMsaCUj4yxpoQ
 lyfpxeS1ADZOxavpsfeFVb90D7F/PPegRicRlmPTP9ZU3cQ4OqT1Up5NZwHFkb6I1ooR1Hr620X
 xG+Xq2K/+w8XHIDcqdWqhFpXhcEkoK6RhUNd0qtmwv2ZzS3UZ1iIcU9PCnNLxSouGuQvvwGpakZ
 JlDaESWTA0q+loMGr1MiKBPj/MTVL9fCs2PFvyQmHFhwwllY83uVLnKLyMvZ/J41SmdeUTuatzt
 R9UCxRdZlWYhcuzBk0LUR5eUk89AfJsPbu+RUEyNiOBxEDpfNnX9riLwzHVZPsk7pi8vEZ560s/
 oeKfajh6GlabY67EoNcUu7BJ47ILX/KUn23Oa7LZmDxobAFLe7fyBwPb7N63JBQAjhbv+U03XnK
 s/Po2B5F2QzBPYHR3IjaBFlbJH6UbxCxQcfgyuT3zxtR4sc3G7lk7+MQihwYOziDjdjscbhY682
 9FtRQkvMt3bkobW20xvuau1Zv1s/917oJ+Mq5fhcQtPXL0mgyD2JMBGwcr/QgJRdbZYtmj9eWDz
 bd4mj+xTGMDv9rQ==
X-Developer-Key: i=chuck.lever@oracle.com; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The RPC/RDMA Read list decoder stores wire-supplied segment
lengths without validation.  xdr_count_read_segments() checks
4-byte alignment for non-zero position values but does not
cap the segment length.

An oversized rs_length reaches svc_rdma_build_read_segment(),
which derives nr_bvec from it and can drive a large dynamic
bvec allocation before verifying that enough rq_pages remain.
If the post-allocation page-overrun guard fires, the freshly
acquired rw context is not returned, leaking the resource.

Reject any segment whose length exceeds the receive context's
page budget during Read list decoding, consistent with how
xdr_check_write_chunk() bounds Write segment counts against
rc_maxpages.  Also return the rw context on the existing
post-allocation overrun path in svc_rdma_build_read_segment(),
keeping that defensive guard balanced.

Fixes: 5ee62b4a9113 ("svcrdma: use bvec-based RDMA read/write API")
Signed-off-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 2 ++
 net/sunrpc/xprtrdma/svc_rdma_rw.c       | 5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index fe9bf0371b6e..15c1d8ae5301 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -458,6 +458,8 @@ static bool xdr_count_read_segments(struct svc_rdma_recv_ctxt *rctxt, __be32 *p)
 
 		xdr_decode_read_segment(p, &position, &handle,
 					    &length, &offset);
+		if (length > rctxt->rc_maxpages << PAGE_SHIFT)
+			return false;
 		if (position) {
 			if (position & 3)
 				return false;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 182bd577e0b7..587e4cd29303 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -1013,7 +1013,7 @@ static int svc_rdma_build_read_segment(struct svc_rqst *rqstp,
 		len -= seg_len;
 
 		if (len && ((head->rc_curpage + 1) > rqstp->rq_maxpages))
-			goto out_overrun;
+			goto out_put;
 	}
 
 	ret = svc_rdma_rw_ctx_init(rdma, ctxt, segment->rs_offset,
@@ -1027,7 +1027,8 @@ static int svc_rdma_build_read_segment(struct svc_rqst *rqstp,
 	cc->cc_sqecount += ret;
 	return 0;
 
-out_overrun:
+out_put:
+	svc_rdma_put_rw_ctxt(rdma, ctxt);
 	trace_svcrdma_page_overrun_err(&cc->cc_cid, head->rc_curpage);
 	return -EINVAL;
 }

-- 
2.54.0

