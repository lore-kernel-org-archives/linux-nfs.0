Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78519288C20
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 18:53:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769194402; cv=none; b=gwd0bEfKpvKyIlJNDLTwL9upgDst5Aznbaj1/6YpNNSOeYxNSCDHLFgaitujzE/PiR1tTMsNok2cF+Bi/0KSOjEwErUr1D4t2Ni7+1MVxwNr5+Ve2NhWFQI68Za69G47sS17qsOHXZE10JtMfkab7BKmGsvM3eAz29Qk47JDDBQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769194402; c=relaxed/simple;
	bh=7MTDiNnaYjacXBGZrmHxgfklPRkgebY/oW8wIE11NV0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=c8vWGywkYE7jEeVL71bN6LFmUi6BQOzJHMAZLUXLnku1xOcsG6IwSSY9YQkfNr135Tf4kvKrCwtCcvpQjePwGsaXcvz6U05TuU+MRgiY7a9Y1GpdK8alSPVwsZ4F5ctuqM5jLZpqT2DGHAyzerxs+eILAUlWyQf5Z0nj7yGP6Uo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=qRgQI/mC; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="qRgQI/mC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9458AC19424;
	Fri, 23 Jan 2026 18:53:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769194402;
	bh=7MTDiNnaYjacXBGZrmHxgfklPRkgebY/oW8wIE11NV0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=qRgQI/mCliQ6fo52HbINoXXf7ffStrLGd7Yv2n3v9V54CN5AnyjM6DBeBPeK10B0F
	 OlYD2QVprQ19N3Skg/9/twbzJizawoWabN4a4tbvmcd6DSJ83ZeQFvaARb8ml3OFcL
	 asGingWpfqBm8ZwT9zaPaeNHchBeD1CE3OQpB12W0dAieYHmexO0x5zqaXiBfxsShB
	 yp6ZIzLREHsmSedxFpu9WBy1nYJUxHKToRYNCGJ3PmKwDL2QNS1Lnb/WTy4hX3ttMZ
	 5WyXaAIAi1B1tLUp11B/239yeuf+tpxPUFNWUC+xEjwHtmjeXQH62lwdQkoXYp0JcY
	 uARkm1mzGlEzQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 24/42] lockd: Use xdrgen XDR functions for the NLMv4 CANCEL_MSG procedure
Date: Fri, 23 Jan 2026 13:52:41 -0500
Message-ID: <20260123185259.1215767-25-cel@kernel.org>
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

The CANCEL_MSG procedure is part of NLM's asynchronous lock
request flow, where clients send CANCEL_MSG to cancel pending
lock requests. This patch continues the xdrgen migration by
converting CANCEL_MSG to use generated XDR functions.

This patch converts the CANCEL_MSG procedure to use xdrgen
functions nlm4_svc_decode_nlm4_cancargs and
nlm4_svc_encode_void generated from the NLM version 4 protocol
specification. The procedure handler uses xdrgen types through
the nlm4_cancargs_wrapper structure that bridges between
generated code and the legacy nlm_lock representation.

The pc_argzero field is set to zero because xdrgen decoders
reliably initialize all arguments in the argp->xdrgen field,
making the early defensive memset unnecessary. Remaining argp
fields are cleared as needed.

The NLM async callback mechanism uses client-side functions
which continue to take legacy results like struct nlm_res,
preventing CANCEL and CANCEL_MSG from sharing code for now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 111 +++++++++++++++++++++++++-------------------
 1 file changed, 64 insertions(+), 47 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 7ab458648637..4c983a04e9f1 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -453,37 +453,6 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp)
 	return nlm4svc_do_lock(rqstp, true);
 }
 
-static __be32
-__nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_res *resp)
-{
-	struct nlm_args *argp = rqstp->rq_argp;
-	struct nlm_host	*host;
-	struct nlm_file	*file;
-
-	dprintk("lockd: CANCEL        called\n");
-
-	resp->cookie = argp->cookie;
-
-	/* Don't accept requests during grace period */
-	if (locks_in_grace(SVC_NET(rqstp))) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
-	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
-
-	/* Try to cancel request. */
-	resp->status = nlmsvc_cancel_blocked(SVC_NET(rqstp), file, &argp->lock);
-
-	dprintk("lockd: CANCEL        status %d\n", ntohl(resp->status));
-	nlmsvc_release_lockowner(&argp->lock);
-	nlmsvc_release_host(host);
-	nlm_release_file(file);
-	return rpc_success;
-}
-
 /**
  * nlm4svc_proc_cancel - CANCEL: Cancel an outstanding blocked lock request
  * @rqstp: RPC transaction context
@@ -863,19 +832,67 @@ static __be32 nlm4svc_proc_lock_msg(struct svc_rqst *rqstp)
 				__nlm4svc_proc_lock_msg);
 }
 
+static __be32
+__nlm4svc_proc_cancel_msg(struct svc_rqst *rqstp, struct nlm_res *resp)
+{
+	struct nlm4_cancargs_wrapper *argp = rqstp->rq_argp;
+	unsigned char type = argp->xdrgen.exclusive ? F_WRLCK : F_RDLCK;
+	struct net *net = SVC_NET(rqstp);
+	struct nlm_file	*file = NULL;
+	struct nlm_host	*host = NULL;
+
+	resp->status = nlm_lck_denied_nolocks;
+	if (nlm4_netobj_to_cookie(&resp->cookie, &argp->xdrgen.cookie))
+		goto out;
+
+	resp->status = nlm_lck_denied_grace_period;
+	if (locks_in_grace(net))
+		goto out;
+
+	resp->status = nlm_lck_denied_nolocks;
+	host = nlm4svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false);
+	if (!host)
+		goto out;
+
+	resp->status = nlm4svc_lookup_file(rqstp, host, &argp->lock,
+					   &file, &argp->xdrgen.alock, type);
+	if (resp->status)
+		goto out;
+
+	resp->status = nlmsvc_cancel_blocked(net, file, &argp->lock);
+	nlmsvc_release_lockowner(&argp->lock);
+
+out:
+	if (file)
+		nlm_release_file(file);
+	nlmsvc_release_host(host);
+	return resp->status == nlm_drop_reply ? rpc_drop_reply : rpc_success;
+}
+
+/**
+ * nlm4svc_proc_cancel_msg - CANCEL_MSG: Cancel an outstanding lock request
+ * @rqstp: RPC transaction context
+ *
+ * Returns:
+ *   %rpc_success:		RPC executed successfully.
+ *   %rpc_system_err:		RPC execution failed.
+ *
+ * RPC synopsis:
+ *   void NLMPROC4_CANCEL_MSG(nlm4_cancargs) = 8;
+ *
+ * The response to this request is delivered via the CANCEL_RES procedure.
+ */
 static __be32 nlm4svc_proc_cancel_msg(struct svc_rqst *rqstp)
 {
-	struct nlm_args *argp = rqstp->rq_argp;
-	struct nlm_host	*host;
+	struct nlm4_cancargs_wrapper *argp = rqstp->rq_argp;
+	struct nlm_host *host;
 
-	dprintk("lockd: CANCEL_MSG    called\n");
-
-	host = nlmsvc_lookup_host(rqstp, argp->lock.caller, argp->lock.len);
+	host = nlm4svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false);
 	if (!host)
 		return rpc_system_err;
 
-	return nlm4svc_callback(rqstp, host, NLMPROC_CANCEL_RES,
-				__nlm4svc_proc_cancel);
+	return nlm4svc_callback(rqstp, host, NLMPROC4_CANCEL_RES,
+				__nlm4svc_proc_cancel_msg);
 }
 
 static __be32 nlm4svc_proc_unlock_msg(struct svc_rqst *rqstp)
@@ -1147,15 +1164,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= XDR_void,
 		.pc_name	= "LOCK_MSG",
 	},
-	[NLMPROC_CANCEL_MSG] = {
-		.pc_func = nlm4svc_proc_cancel_msg,
-		.pc_decode = nlm4svc_decode_cancargs,
-		.pc_encode = nlm4svc_encode_void,
-		.pc_argsize = sizeof(struct nlm_args),
-		.pc_argzero = sizeof(struct nlm_args),
-		.pc_ressize = sizeof(struct nlm_void),
-		.pc_xdrressize = St,
-		.pc_name = "CANCEL_MSG",
+	[NLMPROC4_CANCEL_MSG] = {
+		.pc_func	= nlm4svc_proc_cancel_msg,
+		.pc_decode	= nlm4_svc_decode_nlm4_cancargs,
+		.pc_encode	= nlm4_svc_encode_void,
+		.pc_argsize	= sizeof(struct nlm4_cancargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "CANCEL_MSG",
 	},
 	[NLMPROC_UNLOCK_MSG] = {
 		.pc_func = nlm4svc_proc_unlock_msg,
-- 
2.52.0

