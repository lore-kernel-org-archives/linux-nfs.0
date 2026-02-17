Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38A3C313276
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2026 22:07:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771366056; cv=none; b=nVkbPn2Z3+hIB04BNJHUB3Gqwq9MFsZXGTULgjG/kCvc1T0S0JaJfoNRjZRnpk28MhiEijvq8lZyEpWdPT1S9BW4VAQxF2zDSQhAuTb/dLix0sEg4rCsmzI/uXQWIauT6Vr9LzEYaRnGOHNcJfZRthAoL1aAA1UpZYCb7QsN/d0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771366056; c=relaxed/simple;
	bh=2Tauw8rhSgd5c7s6kFoaW+N2ud3J7gomGN4C6NQMo0s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VDDChjmvsXTkbjO2wewev3kJ/6OdAWdyzrmFNNViZyAfMlLQRmeh0d799N+h0utXiDb73OVBO1eRUy6+a7OUMAqqdjg4/6zLmpibnZJiwcP6ngbMqI/4EfMKDe7zbhKLgHmFsMuVpIZD6OJe3fjqPY4u/n3oB4rZWDeukd2t0OA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ALgQxN3c; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ALgQxN3c"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 752EFC4CEF7;
	Tue, 17 Feb 2026 22:07:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771366056;
	bh=2Tauw8rhSgd5c7s6kFoaW+N2ud3J7gomGN4C6NQMo0s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ALgQxN3ckC2tvOn0N6Thdz48gQ4Hd/vGlgkxLwdQ191WtoKaLtH9PaAECfZ6KMxfn
	 QFysOtDrPyYQOT0zXxnlqdR/X2rI/d2gUZnycRb8u0oCpfE4hvmHn6m3W3HGcOYb0y
	 DCVeCIPlKRLgu6KR5sB3kyhb4GuZUTDEGc15GyizTrMTKYKT/jCIPfQPPI46PpAFTX
	 MGS85F45ocWZwkqdUBG6poaPZnlo3pn7kgFRhjr4823oaz2jDWHOf28vn5RBpTpSLI
	 mRx0vOFPvhoONTnmCVMgU5vq+cjkB97ByoNCxRpv4wD3yHHpgf1+KXOsArjVJo4fC0
	 U1Ef9tcYRCPwQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 12/29] lockd: Use xdrgen XDR functions for the NLMv4 UNLOCK_MSG procedure
Date: Tue, 17 Feb 2026 17:07:04 -0500
Message-ID: <20260217220721.1928847-13-cel@kernel.org>
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

Convert the UNLOCK_MSG procedure to use xdrgen functions
nlm4_svc_decode_nlm4_unlockargs and nlm4_svc_encode_void.
The procedure handler uses the nlm4_unlockargs_wrapper
structure that bridges between xdrgen types and the legacy
nlm_lock representation.

The pc_argzero field is set to zero because xdrgen decoders
reliably initialize all arguments, making the early
defensive memset unnecessary.

The NLM async callback mechanism uses client-side functions
which continue to take legacy struct nlm_res, preventing
UNLOCK and UNLOCK_MSG from sharing code for now.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 115 ++++++++++++++++++++++++--------------------
 1 file changed, 64 insertions(+), 51 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 01e21b0a8956..c42c641dc5b6 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -523,41 +523,6 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp)
 		rpc_drop_reply : rpc_success;
 }
 
-/*
- * UNLOCK: release a lock
- */
-static __be32
-__nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_res *resp)
-{
-	struct nlm_args *argp = rqstp->rq_argp;
-	struct nlm_host	*host;
-	struct nlm_file	*file;
-
-	dprintk("lockd: UNLOCK        called\n");
-
-	resp->cookie = argp->cookie;
-
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace(SVC_NET(rqstp))) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
-	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return resp->status == nlm__int__drop_reply ?
-			rpc_drop_reply : rpc_success;
-
-	/* Now try to remove the lock */
-	resp->status = nlmsvc_unlock(SVC_NET(rqstp), file, &argp->lock);
-
-	dprintk("lockd: UNLOCK        status %d\n", ntohl(resp->status));
-	nlmsvc_release_lockowner(&argp->lock);
-	nlmsvc_release_host(host);
-	nlm_release_file(file);
-	return rpc_success;
-}
-
 /**
  * nlm4svc_proc_unlock - UNLOCK: Remove a lock
  * @rqstp: RPC transaction context
@@ -904,19 +869,67 @@ static __be32 nlm4svc_proc_cancel_msg(struct svc_rqst *rqstp)
 				__nlm4svc_proc_cancel_msg);
 }
 
+static __be32
+__nlm4svc_proc_unlock_msg(struct svc_rqst *rqstp, struct nlm_res *resp)
+{
+	struct nlm4_unlockargs_wrapper *argp = rqstp->rq_argp;
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
+					   &file, &argp->xdrgen.alock, F_UNLCK);
+	if (resp->status)
+		goto out;
+
+	resp->status = nlmsvc_unlock(net, file, &argp->lock);
+	nlmsvc_release_lockowner(&argp->lock);
+
+out:
+	if (file)
+		nlm_release_file(file);
+	nlmsvc_release_host(host);
+	return resp->status == nlm__int__drop_reply ?
+		rpc_drop_reply : rpc_success;
+}
+
+/**
+ * nlm4svc_proc_unlock_msg - UNLOCK_MSG: Remove an existing lock
+ * @rqstp: RPC transaction context
+ *
+ * Returns:
+ *   %rpc_success:		RPC executed successfully.
+ *   %rpc_system_err:		RPC execution failed.
+ *
+ * RPC synopsis:
+ *   void NLMPROC4_UNLOCK_MSG(nlm4_unlockargs) = 9;
+ *
+ * The response to this request is delivered via the UNLOCK_RES procedure.
+ */
 static __be32 nlm4svc_proc_unlock_msg(struct svc_rqst *rqstp)
 {
-	struct nlm_args *argp = rqstp->rq_argp;
-	struct nlm_host	*host;
+	struct nlm4_unlockargs_wrapper *argp = rqstp->rq_argp;
+	struct nlm_host *host;
 
-	dprintk("lockd: UNLOCK_MSG    called\n");
-
-	host = nlmsvc_lookup_host(rqstp, argp->lock.caller, argp->lock.len);
+	host = nlm4svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false);
 	if (!host)
 		return rpc_system_err;
 
-	return nlm4svc_callback(rqstp, host, NLMPROC_UNLOCK_RES,
-				__nlm4svc_proc_unlock);
+	return nlm4svc_callback(rqstp, host, NLMPROC4_UNLOCK_RES,
+				__nlm4svc_proc_unlock_msg);
 }
 
 static __be32 nlm4svc_proc_granted_msg(struct svc_rqst *rqstp)
@@ -1185,15 +1198,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= XDR_void,
 		.pc_name	= "CANCEL_MSG",
 	},
-	[NLMPROC_UNLOCK_MSG] = {
-		.pc_func = nlm4svc_proc_unlock_msg,
-		.pc_decode = nlm4svc_decode_unlockargs,
-		.pc_encode = nlm4svc_encode_void,
-		.pc_argsize = sizeof(struct nlm_args),
-		.pc_argzero = sizeof(struct nlm_args),
-		.pc_ressize = sizeof(struct nlm_void),
-		.pc_xdrressize = St,
-		.pc_name = "UNLOCK_MSG",
+	[NLMPROC4_UNLOCK_MSG] = {
+		.pc_func	= nlm4svc_proc_unlock_msg,
+		.pc_decode	= nlm4_svc_decode_nlm4_unlockargs,
+		.pc_encode	= nlm4_svc_encode_void,
+		.pc_argsize	= sizeof(struct nlm4_unlockargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "UNLOCK_MSG",
 	},
 	[NLMPROC_GRANTED_MSG] = {
 		.pc_func = nlm4svc_proc_granted_msg,
-- 
2.53.0

