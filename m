Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B403313276
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2026 22:07:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771366068; cv=none; b=GIyHLvMme90e8Y4zjVym97kgWWEEsgIyn+nW5/KdkIxqWvRD6yzihy6Y4Ixx+d1V+SWEovf1GeeETXUmmbw2y2184iKCz0VhQceWkKUaq/+5+Iv3K60r5FVa+O5guiNWDJRw8khkzZ4N3B/1APPmmgojC7ztMQLgyyzboBljThY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771366068; c=relaxed/simple;
	bh=iYe5DLaRcikUcRUQ40NvCKSYbSXedS56+w9VtgWrjL0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WmOU8Y4Qz4mCinu3TYWOCcoXO1YwIHhFU2cjcNMjPwCuEBSz92yMLQZqWyjIr7jltjGdYXqWV1nKSfz+/XKxNBJWusZ3FjGDMHQ5wDJi1+gLEn45IzzssXCIvBgSjl+nkq9dJPs6ZVAp/z7eGGQgMZWEL7/LvxhDIS0nl6OGb/k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UIgT8J17; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UIgT8J17"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C641BC19421;
	Tue, 17 Feb 2026 22:07:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771366067;
	bh=iYe5DLaRcikUcRUQ40NvCKSYbSXedS56+w9VtgWrjL0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=UIgT8J17lRP5L/AFN6EuHIIbGOKgH+YhM/EhDIBsDX7pLUDXlZeTrpUinLzlc1r47
	 41B5afW+DDXPtvl5ZHF4vt07A4CVBnZT0sAEHdJ7wx44kZmf1Xm39G0MyZ5cU5N2iK
	 2UayJNq+BTlhDlVPOMxPxsrd30/Ey7S0ImkzgtX7MnjpdTZ7pvDyOpOdSzzsNcctjC
	 j7hVDwMYZmJjTo6bl8ftxZPGOJizr6QqdTk03trNZlPG/2mncx3RV3TkX9UP076iGS
	 7FPiLZ9trJ1UpO9yJHMG5P1Znvm1HTVn6Wzg7Z1n+MfA+mTqEXzAelXQlnBA3r+CPV
	 codjAxcTruqyw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 26/29] lockd: Use xdrgen XDR functions for the NLMv4 FREE_ALL procedure
Date: Tue, 17 Feb 2026 17:07:18 -0500
Message-ID: <20260217220721.1928847-27-cel@kernel.org>
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

With all other NLMv4 procedures now converted to xdrgen-generated
XDR functions, the FREE_ALL procedure can be converted as well.
This conversion allows the removal of nlm4svc_retrieve_args(),
a 79-line helper function that was used only by FREE_ALL to
retrieve client information from lockd's internal data
structures.

Replace the NLMPROC4_FREE_ALL entry in the nlm_procedures4
array with an entry that uses xdrgen-built XDR decoders and
encoders. The procedure handler is updated to use the new
wrapper structure (nlm4_notify_wrapper) and call
nlm4svc_lookup_host() directly, eliminating the need for the
now-removed helper function.

The .pc_argzero field is set to zero because xdrgen decoders
fully initialize all fields in argp->xdrgen, making the early
defensive memset unnecessary. The remaining argp fields that
fall outside the xdrgen structures are cleared explicitly as
needed.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 125 ++++++++++++--------------------------------
 1 file changed, 33 insertions(+), 92 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 62c90827dfae..ca0409ea6b2d 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -69,6 +69,12 @@ struct nlm4_notifyargs_wrapper {
 
 static_assert(offsetof(struct nlm4_notifyargs_wrapper, xdrgen) == 0);
 
+struct nlm4_notify_wrapper {
+	struct nlm4_notify		xdrgen;
+};
+
+static_assert(offsetof(struct nlm4_notify_wrapper, xdrgen) == 0);
+
 struct nlm4_testres_wrapper {
 	struct nlm4_testres		xdrgen;
 	struct nlm_lock			lock;
@@ -191,80 +197,6 @@ nlm4svc_lookup_file(struct svc_rqst *rqstp, struct nlm_host *host,
 	return nlm_granted;
 }
 
-/*
- * Obtain client and file from arguments
- */
-static __be32
-nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
-			struct nlm_host **hostp, struct nlm_file **filp)
-{
-	struct nlm_host		*host = NULL;
-	struct nlm_file		*file = NULL;
-	struct nlm_lock		*lock = &argp->lock;
-	__be32			error = 0;
-
-	/* nfsd callbacks must have been installed for this procedure */
-	if (!nlmsvc_ops)
-		return nlm_lck_denied_nolocks;
-
-	if (lock->lock_start > OFFSET_MAX ||
-	    (lock->lock_len && ((lock->lock_len - 1) > (OFFSET_MAX - lock->lock_start))))
-		return nlm4_fbig;
-
-	/* Obtain host handle */
-	if (!(host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len))
-	 || (argp->monitor && nsm_monitor(host) < 0))
-		goto no_locks;
-	*hostp = host;
-
-	/* Obtain file pointer. Not used by FREE_ALL call. */
-	if (filp != NULL) {
-		int mode = lock_to_openmode(&lock->fl);
-
-		lock->fl.c.flc_flags = FL_POSIX;
-
-		error = nlm_lookup_file(rqstp, &file, lock);
-		if (error)
-			goto no_locks;
-		*filp = file;
-
-		/* Set up the missing parts of the file_lock structure */
-		lock->fl.c.flc_file = file->f_file[mode];
-		lock->fl.c.flc_pid = current->tgid;
-		lock->fl.fl_start = (loff_t)lock->lock_start;
-		lock->fl.fl_end = lock->lock_len ?
-				   (loff_t)(lock->lock_start + lock->lock_len - 1) :
-				   OFFSET_MAX;
-		lock->fl.fl_lmops = &nlmsvc_lock_operations;
-		nlmsvc_locks_init_private(&lock->fl, host, (pid_t)lock->svid);
-		if (!lock->fl.c.flc_owner) {
-			/* lockowner allocation has failed */
-			nlmsvc_release_host(host);
-			return nlm_lck_denied_nolocks;
-		}
-	}
-
-	return 0;
-
-no_locks:
-	nlmsvc_release_host(host);
-	switch (error) {
-	case nlm_granted:
-		return nlm_lck_denied_nolocks;
-	case nlm__int__stale_fh:
-		return nlm4_stale_fh;
-	case nlm__int__failed:
-		return nlm4_failed;
-	default:
-		if (be32_to_cpu(error) >= 30000) {
-			pr_warn_once("lockd: unhandled internal status %u\n",
-				     be32_to_cpu(error));
-			return nlm4_failed;
-		}
-		return error;
-	}
-}
-
 /**
  * nlm4svc_proc_null - NULL: Test for presence of service
  * @rqstp: RPC transaction context
@@ -1191,21 +1123,30 @@ static __be32 nlm4svc_proc_nm_lock(struct svc_rqst *rqstp)
 	return nlm4svc_do_lock(rqstp, false);
 }
 
-/*
- * FREE_ALL: Release all locks and shares held by client
+/**
+ * nlm4svc_proc_free_all - FREE_ALL: Discard client's lock and share state
+ * @rqstp: RPC transaction context
+ *
+ * Returns:
+ *   %rpc_success:		RPC executed successfully.
+ *
+ * RPC synopsis:
+ *   void NLMPROC4_FREE_ALL(nlm4_notify) = 23;
  */
-static __be32
-nlm4svc_proc_free_all(struct svc_rqst *rqstp)
+static __be32 nlm4svc_proc_free_all(struct svc_rqst *rqstp)
 {
-	struct nlm_args *argp = rqstp->rq_argp;
+	struct nlm4_notify_wrapper *argp = rqstp->rq_argp;
 	struct nlm_host	*host;
 
-	/* Obtain client */
-	if (nlm4svc_retrieve_args(rqstp, argp, &host, NULL))
-		return rpc_success;
+	host = nlm4svc_lookup_host(rqstp, argp->xdrgen.name, false);
+	if (!host)
+		goto out;
 
 	nlmsvc_free_host_resources(host);
+
 	nlmsvc_release_host(host);
+
+out:
 	return rpc_success;
 }
 
@@ -1452,15 +1393,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= NLM4_nlm4_res_sz,
 		.pc_name	= "NM_LOCK",
 	},
-	[NLMPROC_FREE_ALL] = {
-		.pc_func = nlm4svc_proc_free_all,
-		.pc_decode = nlm4svc_decode_notify,
-		.pc_encode = nlm4svc_encode_void,
-		.pc_argsize = sizeof(struct nlm_args),
-		.pc_argzero = sizeof(struct nlm_args),
-		.pc_ressize = sizeof(struct nlm_void),
-		.pc_xdrressize = St,
-		.pc_name = "FREE_ALL",
+	[NLMPROC4_FREE_ALL] = {
+		.pc_func	= nlm4svc_proc_free_all,
+		.pc_decode	= nlm4_svc_decode_nlm4_notify,
+		.pc_encode	= nlm4_svc_encode_void,
+		.pc_argsize	= sizeof(struct nlm4_notify_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "FREE_ALL",
 	},
 };
 
@@ -1474,10 +1415,10 @@ union nlm4svc_xdrstore {
 	struct nlm4_unlockargs_wrapper	unlockargs;
 	struct nlm4_notifyargs_wrapper	notifyargs;
 	struct nlm4_shareargs_wrapper	shareargs;
+	struct nlm4_notify_wrapper	notify;
 	struct nlm4_testres_wrapper	testres;
 	struct nlm4_res_wrapper		res;
 	struct nlm4_shareres_wrapper	shareres;
-	struct nlm_args			args;
 };
 
 static DEFINE_PER_CPU_ALIGNED(unsigned long,
-- 
2.53.0

