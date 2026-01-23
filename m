Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E49827B4FA
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 18:53:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769194398; cv=none; b=c04SjLsXW9eM4v6BGbmq9OJqwCcKqri2A5B6ZFfp0OUusktZXT++ecpowuCe76gkYXF7V5Cjtngk1mU+8npiYJxuUe/IuJdtotMgB1gvf8RpLHNs+3XR9T+GwZTxiXBae6oZ90k+sxtiudb2gTx1Wf5RrYs2th0KlUJ6/jOJw5M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769194398; c=relaxed/simple;
	bh=uGKWfCjYt2F0Xku78ZZD0EXemicvVPAUT38UaWT2FAE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MOAksKM10AAISgfcT9bPL0rpLF1QKNUYAgE2ZwKnwkIL7c4xFiHAWyPI8tkUZISPMi6WoLUMyI06JXbvJjh9xg5LmNji+oQ2LHvwyOBsaHAvg5MWDVLnb42GIxGYSnq/1ZXtjCYfbu58huVeas7khd9oqa/R2zLkDo2+HxHkfc8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A5DLc0kW; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A5DLc0kW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A5978C19423;
	Fri, 23 Jan 2026 18:53:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769194398;
	bh=uGKWfCjYt2F0Xku78ZZD0EXemicvVPAUT38UaWT2FAE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=A5DLc0kWA4csr/uRA+iGh8MSUOOW9HbPV6o/aiPyF+N8xBQW+zvHQeVkQFTwrfd5L
	 emAfujYSeE4JVqNrsL5vTwGrHAGgRQm6BrUe8AGKNQk/uWcZVqQavO2oTdGxl8Dpzp
	 iQC7uW5L/7pzhnvTFr1eFMUCQJclgwKyAmrPHVTANqIpinDnA0/r2gNbnKkfzCCo99
	 3Q38CrxjYcu1KEAeEECxyiG4tMDA+il5Fjr60MnDUUr8xGCtrbauaptltYi4HODAP5
	 asUGy6CjX1Eopbo6kHpHY9HGUC1UElZ9hFsgFxQclu9f8e6km93cOSq4f04BkIQOJS
	 pZqhvtUOWs1bg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 19/42] lockd: Use xdrgen XDR functions for the NLMv4 UNLOCK procedure
Date: Fri, 23 Jan 2026 13:52:36 -0500
Message-ID: <20260123185259.1215767-20-cel@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260123185259.1215767-1-cel@kernel.org>
References: <20260123185259.1215767-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

UNLOCK releases locks acquired via the LOCK procedure. Conversion
of TEST, LOCK, CANCEL, and UNLOCK provides the complete set of
lock lifecycle operations required by the NLM protocol, enabling
clients to test for conflicts, acquire locks, abort pending lock
requests, and release held locks.

The procedure handler converts arguments from the xdrgen-generated
nlm4_unlockargs structure to the legacy nlm_lock representation
through nlm4_unlockargs_wrapper. This maintains compatibility with
core lockd logic while using XDR decoders and encoders generated
from the NLMv4 protocol specification.

The original __nlm4svc_proc_unlock function is retained because
the asynchronous callback path invokes it directly, bypassing
the RPC dispatch mechanism.

The pc_argzero field is zero because nlm4_svc_decode_nlm4_unlockargs
initializes all fields in argp->xdrgen, eliminating the need for
early memset of the argument buffer. Remaining argp fields outside
the xdrgen structure are cleared explicitly where needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 84 +++++++++++++++++++++++++++++++++++++++------
 1 file changed, 74 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 1b70935df4d0..f0f3e73eee75 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -55,6 +55,13 @@ struct nlm4_cancargs_wrapper {
 
 static_assert(offsetof(struct nlm4_cancargs_wrapper, xdrgen) == 0);
 
+struct nlm4_unlockargs_wrapper {
+	struct nlm4_unlockargs		xdrgen;
+	struct nlm_lock			lock;
+};
+
+static_assert(offsetof(struct nlm4_unlockargs_wrapper, xdrgen) == 0);
+
 struct nlm4_testres_wrapper {
 	struct nlm4_testres		xdrgen;
 	struct nlm_lock			lock;
@@ -592,10 +599,66 @@ __nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_res *resp)
 	return rpc_success;
 }
 
+/**
+ * nlm4svc_proc_unlock - UNLOCK: Remove a lock
+ * @rqstp: RPC transaction context
+ *
+ * Returns:
+ *   %rpc_success:		RPC executed successfully.
+ *   %rpc_drop_reply:		Do not send an RPC reply.
+ *
+ * RPC synopsis:
+ *   nlm4_res NLMPROC4_UNLOCK(nlm4_unlockargs) = 4;
+ *
+ * Permissible procedure status codes:
+ *   %NLM4_GRANTED:		The requested lock was released.
+ *   %NLM4_DENIED_GRACE_PERIOD:	The server has recently restarted and is
+ *				re-establishing existing locks, and is not
+ *				yet ready to accept normal service requests.
+ *
+ * The Linux NLM server implementation also returns:
+ *   %NLM4_DENIED_NOLOCKS:	A needed resource could not be allocated.
+ *   %NLM4_STALE_FH:		The request specified an invalid file handle.
+ *   %NLM4_FBIG:		The request specified a length or offset
+ *				that exceeds the range supported by the
+ *				server.
+ *   %NLM4_FAILED:		The request failed for an unspecified reason.
+ */
 static __be32
 nlm4svc_proc_unlock(struct svc_rqst *rqstp)
 {
-	return __nlm4svc_proc_unlock(rqstp, rqstp->rq_resp);
+	struct nlm4_unlockargs_wrapper *argp = rqstp->rq_argp;
+	struct nlm4_res_wrapper *resp = rqstp->rq_resp;
+	struct net *net = SVC_NET(rqstp);
+	struct nlm_host	*host = NULL;
+	struct nlm_file	*file = NULL;
+
+	resp->xdrgen.cookie = argp->xdrgen.cookie;
+
+	resp->xdrgen.stat.stat = nlm_lck_denied_grace_period;
+	if (locks_in_grace(net))
+		goto out;
+
+	resp->xdrgen.stat.stat = nlm_lck_denied_nolocks;
+	host = nlm4svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false);
+	if (!host)
+		goto out;
+
+	resp->xdrgen.stat.stat = nlm4svc_lookup_file(rqstp, host, &argp->lock,
+						     &file, &argp->xdrgen.alock,
+						     F_UNLCK);
+	if (resp->xdrgen.stat.stat)
+		goto out;
+
+	resp->xdrgen.stat.stat = nlmsvc_unlock(net, file, &argp->lock);
+	nlmsvc_release_lockowner(&argp->lock);
+
+out:
+	if (file)
+		nlm_release_file(file);
+	nlmsvc_release_host(host);
+	return resp->xdrgen.stat.stat == nlm_drop_reply ?
+		rpc_drop_reply : rpc_success;
 }
 
 /*
@@ -903,15 +966,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= NLM4_nlm4_res_sz,
 		.pc_name	= "CANCEL",
 	},
-	[NLMPROC_UNLOCK] = {
-		.pc_func = nlm4svc_proc_unlock,
-		.pc_decode = nlm4svc_decode_unlockargs,
-		.pc_encode = nlm4svc_encode_res,
-		.pc_argsize = sizeof(struct nlm_args),
-		.pc_argzero = sizeof(struct nlm_args),
-		.pc_ressize = sizeof(struct nlm_res),
-		.pc_xdrressize = Ck+St,
-		.pc_name = "UNLOCK",
+	[NLMPROC4_UNLOCK] = {
+		.pc_func	= nlm4svc_proc_unlock,
+		.pc_decode	= nlm4_svc_decode_nlm4_unlockargs,
+		.pc_encode	= nlm4_svc_encode_nlm4_res,
+		.pc_argsize	= sizeof(struct nlm4_unlockargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nlm4_res_wrapper),
+		.pc_xdrressize	= NLM4_nlm4_res_sz,
+		.pc_name	= "UNLOCK",
 	},
 	[NLMPROC_GRANTED] = {
 		.pc_func = nlm4svc_proc_granted,
@@ -1112,6 +1175,7 @@ union nlm4svc_xdrstore {
 	struct nlm4_testargs_wrapper	testargs;
 	struct nlm4_lockargs_wrapper	lockargs;
 	struct nlm4_cancargs_wrapper	cancargs;
+	struct nlm4_unlockargs_wrapper	unlockargs;
 	struct nlm4_testres_wrapper	testres;
 	struct nlm4_res_wrapper		res;
 	struct nlm_args			args;
-- 
2.52.0

