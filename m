Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC8E4313276
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2026 22:07:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771366050; cv=none; b=V1U4kzOg0zYGxNYcIeEFneo4gIx4zDaVu3nocY1t6rsicWlLoMJwnjS/twxbaFK7tFP/3EHvfjhl/rnxtbDQXnnSBqaCYFbF9JJ8q/2QiBy4PGmW381mXAxCaQ7Uj5DHFvTW/rW573sQlc0uSIibx/DWXMaI9kTsv5wLCgPd+JM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771366050; c=relaxed/simple;
	bh=JfZ221IObvE9Y/zaI7W92VE8fir7BU7Mr/sPNXB30Q8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mx3N3pV4fvKgXKWa9OkX1lXwGiCiH6NsfpkbO1lEZV536UG4DgCWrEyjs3JVJbNB6hsb7E7+mZgsYB0zummlPRLGwzjIfM2a30Cn9fh9EAT2KJ6X0QZfvqlIipR835QkDK1Aewbdh/nKbjKwEwNurXKa8FqMOxY/mkCuFxBN2vo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gs1QfFTg; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gs1QfFTg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D1D42C19423;
	Tue, 17 Feb 2026 22:07:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771366050;
	bh=JfZ221IObvE9Y/zaI7W92VE8fir7BU7Mr/sPNXB30Q8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=gs1QfFTg5862TmC3nQrt8SxVAU2mIXeYqLuHJ5NXFW3tD/Xh5UuiV0hy9Nv8+5+R/
	 QXraYlpc0CETibQ33YmZga9UtQfkRlkGjTBPhUmx9y70Vb8RT3zlXSKWAE52Yb7Z5F
	 wA1xClwTmWe4DJG2MHbTt9O57DIlz08MyNdjYqvevvRlgmq+qO6Ky7J5FdZxanhOyj
	 Dq1ZCREChxC1kFjfkdIdG20GB4CRT8K5WlIb2Z0OgAIZsQ/dy8t89klHvYEHcA3gGa
	 RqhaH8mqKWCJQtj8pvD5OusaWBuqDP4I0ulE69epEU1GkDyoCCLt1wlWADif3gFK1t
	 AcPiDhEV9M7aw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 05/29] lockd: Use xdrgen XDR functions for the NLMv4 CANCEL procedure
Date: Tue, 17 Feb 2026 17:06:57 -0500
Message-ID: <20260217220721.1928847-6-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260217220721.1928847-1-cel@kernel.org>
References: <20260217220721.1928847-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

The NLM CANCEL procedure allows clients to cancel outstanding
blocked lock requests, completing the set of lock-related
operations that share common lookup patterns. This patch
continues the xdrgen migration by converting the CANCEL
procedure, leveraging the same nlm4svc_lookup_host() and
nlm4svc_lookup_file() helpers established in the TEST procedure
conversion to maintain consistency across the series.

This patch converts the CANCEL procedure to use xdrgen functions
nlm4_svc_decode_nlm4_cancargs and nlm4_svc_encode_nlm4_res
generated from the NLM version 4 protocol specification. The
procedure handler uses xdrgen types through a wrapper structure
that bridges between generated code and the legacy nlm_lock
representation still used by the core lockd logic.

The pc_argzero field is set to zero because xdrgen decoders
reliably initialize all arguments in the argp->xdrgen field,
making the early defensive memset unnecessary. Remaining argp
fields are cleared as needed.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 86 +++++++++++++++++++++++++++++++++++++++------
 1 file changed, 76 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 2cad72562ef2..4a3815599a65 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -48,6 +48,13 @@ struct nlm4_lockargs_wrapper {
 
 static_assert(offsetof(struct nlm4_lockargs_wrapper, xdrgen) == 0);
 
+struct nlm4_cancargs_wrapper {
+	struct nlm4_cancargs		xdrgen;
+	struct nlm_lock			lock;
+};
+
+static_assert(offsetof(struct nlm4_cancargs_wrapper, xdrgen) == 0);
+
 struct nlm4_testres_wrapper {
 	struct nlm4_testres		xdrgen;
 	struct nlm_lock			lock;
@@ -495,10 +502,68 @@ __nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_res *resp)
 	return rpc_success;
 }
 
+/**
+ * nlm4svc_proc_cancel - CANCEL: Cancel an outstanding blocked lock request
+ * @rqstp: RPC transaction context
+ *
+ * Returns:
+ *   %rpc_success:		RPC executed successfully
+ *   %rpc_drop_reply:		Do not send an RPC reply
+ *
+ * RPC synopsis:
+ *   nlm4_res NLMPROC4_CANCEL(nlm4_cancargs) = 3;
+ *
+ * Permissible procedure status codes:
+ *   %NLM4_LCK_GRANTED:		The requested lock was canceled.
+ *   %NLM4_LCK_DENIED:		There was no lock to cancel.
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
 nlm4svc_proc_cancel(struct svc_rqst *rqstp)
 {
-	return __nlm4svc_proc_cancel(rqstp, rqstp->rq_resp);
+	struct nlm4_cancargs_wrapper *argp = rqstp->rq_argp;
+	unsigned char type = argp->xdrgen.exclusive ? F_WRLCK : F_RDLCK;
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
+						     type);
+	if (resp->xdrgen.stat.stat)
+		goto out;
+
+	resp->xdrgen.stat.stat = nlmsvc_cancel_blocked(net, file, &argp->lock);
+	nlmsvc_release_lockowner(&argp->lock);
+
+out:
+	if (file)
+		nlm_release_file(file);
+	nlmsvc_release_host(host);
+	return resp->xdrgen.stat.stat == nlm__int__drop_reply ?
+		rpc_drop_reply : rpc_success;
 }
 
 /*
@@ -839,15 +904,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= NLM4_nlm4_res_sz,
 		.pc_name	= "LOCK",
 	},
-	[NLMPROC_CANCEL] = {
-		.pc_func = nlm4svc_proc_cancel,
-		.pc_decode = nlm4svc_decode_cancargs,
-		.pc_encode = nlm4svc_encode_res,
-		.pc_argsize = sizeof(struct nlm_args),
-		.pc_argzero = sizeof(struct nlm_args),
-		.pc_ressize = sizeof(struct nlm_res),
-		.pc_xdrressize = Ck+St,
-		.pc_name = "CANCEL",
+	[NLMPROC4_CANCEL] = {
+		.pc_func	= nlm4svc_proc_cancel,
+		.pc_decode	= nlm4_svc_decode_nlm4_cancargs,
+		.pc_encode	= nlm4_svc_encode_nlm4_res,
+		.pc_argsize	= sizeof(struct nlm4_cancargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nlm4_res_wrapper),
+		.pc_xdrressize	= NLM4_nlm4_res_sz,
+		.pc_name	= "CANCEL",
 	},
 	[NLMPROC_UNLOCK] = {
 		.pc_func = nlm4svc_proc_unlock,
@@ -1057,6 +1122,7 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 union nlm4svc_xdrstore {
 	struct nlm4_testargs_wrapper	testargs;
 	struct nlm4_lockargs_wrapper	lockargs;
+	struct nlm4_cancargs_wrapper	cancargs;
 	struct nlm4_testres_wrapper	testres;
 	struct nlm4_res_wrapper		res;
 	struct nlm_args			args;
-- 
2.53.0

