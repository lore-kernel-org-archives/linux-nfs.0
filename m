Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28CF72C08BC
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 18:53:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769194403; cv=none; b=sDFsIBNmFzoFWHFtehsXyUn3guatFlfjWLV0/hkp758ErxuyBB/sKg6VUW0iiHzkCAkXUvJPvaTcdK28giZBkOBj7VnPaAOagdomVr+aYOJvGXjLSUc6IEv4is9Llxq4KBqFiqcEZh8LAfgZzPNvYsPsjf7YltC5XpLLbh3SWTE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769194403; c=relaxed/simple;
	bh=anycXR44HsayKLiyl2uU9kgRh7k2F7sPNA01TkNIm+s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oVZ3Q5oPqZ0N0U5hKSZZ89sJR0gNFOXWTCwcnZPaEv/gsKD7E6kzat7SClQE8lgMRYOz1fPTrNisnMGdsIhWO3wcwdwW7AV6IfbF4kYIPg5NqYbsgz7y2I/39NRs1OfJjzC4KlgRtuwNhv8ZUQc/XeSadWJYoJ4o7g1nYYJhB9M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F1wUGCEg; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F1wUGCEg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6399CC19423;
	Fri, 23 Jan 2026 18:53:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769194403;
	bh=anycXR44HsayKLiyl2uU9kgRh7k2F7sPNA01TkNIm+s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=F1wUGCEg+iBGezor2Uf2E36ZsPwgu/aqWl8LqhJBuS1V7bz+qr/EQfVrKvuezlPCZ
	 dECG6HaJ8J4wdVpf3zcvcAZoZB/luf5TM+xbUWbN23AYfWbfFNNWrO/NsgyHV0xlx6
	 /KwocQniL3qZkiUDm7E7ssA7WRioD+P7nyN2S92ssODmS2XZgvK3oaKDPQkojSdtax
	 UTEPEoegkwiDpv2ghsoBD9NppI2CvnxT+dWYJOJ4a0D3udRRNVHM0+6kupjiYq6Hus
	 OgVW/8KXAGBzqTYEJ1KDPt/6baI1SPajL58qNSX8LXa3x8eunmm9FUq0a1k2UcGNXD
	 JsDXll2rD3acw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 25/42] lockd: Use xdrgen XDR functions for the NLMv4 UNLOCK_MSG procedure
Date: Fri, 23 Jan 2026 13:52:42 -0500
Message-ID: <20260123185259.1215767-26-cel@kernel.org>
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 113 ++++++++++++++++++++++++--------------------
 1 file changed, 63 insertions(+), 50 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 4c983a04e9f1..dafc1ea70cd7 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -517,40 +517,6 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp)
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
-		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
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
@@ -895,19 +861,66 @@ static __be32 nlm4svc_proc_cancel_msg(struct svc_rqst *rqstp)
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
+	return resp->status == nlm_drop_reply ? rpc_drop_reply : rpc_success;
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
@@ -1174,15 +1187,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
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
2.52.0

