Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72594313276
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2026 22:07:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771366063; cv=none; b=Gdfv0q5sygvnYTS+8peVMn4UMFELUr3V3qSXIIe5/wopWyzvqP5Fpx98UE9exop7oR2tFPXS2jRt/n/X0mv809cwL2rOxf0E5i+F3DqsLgxNY3UhRChvQ8FtYRuhnixgkS3p1h3032ADrx7UoecBnh/yYfJ3kROEvVShAWQCpUA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771366063; c=relaxed/simple;
	bh=/hoX34bCG97j7L4s0I5oblT96Dby0WX+YMkK0s//0R8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=s1ZJUvcF1eWjRlOwEIqWWfErqdd+A+95uEH3gC6D6BPYMriY9qI8tYmV+QnH6WmUzF8/a+0Ie7PCHfdAMp3xAIV/UOTNkp/9jbQ+4Znj7d6Kz5S3Dhg7N1+lJAcFO/gGUj2X1kpQ3h9hg5VXgXL27GcA3cMyVc2CnV0gWZfK/XM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=e95OdSu3; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="e95OdSu3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6FD7C4CEF7;
	Tue, 17 Feb 2026 22:07:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771366063;
	bh=/hoX34bCG97j7L4s0I5oblT96Dby0WX+YMkK0s//0R8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=e95OdSu3JXqMZdHY4tLEOMJT+vd1EGQ6rh1LHCm1DarClnBRgv1EiYR9Zv2OjHgmy
	 6AencZprdX/BtVX0ZKPK5DDMvaajejNJyJbWdNPtQhhr5/nW4tVZtuLPiLsDaRqgfJ
	 Xw1NvffqN7uQhrcrf9PpiUKLIgc68M2nxq2Im2JfBRKvREOD0So9uRokRY9GgYD4Sf
	 Zxq7nJusOAmVHuu5E0IqdULhMIClnttrAMLvnKJ8aPmMwvLczWi5qcsUnGyzV75Kqp
	 uFcChN2YvJh/g87DYRgbplhd5WBSgq6CrymNlIGIOypSJ8negZ/7aeE5XhM0kLUReu
	 owplUcfPmx5cA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 21/29] lockd: Hoist file_lock init out of nlm4svc_decode_shareargs()
Date: Tue, 17 Feb 2026 17:07:13 -0500
Message-ID: <20260217220721.1928847-22-cel@kernel.org>
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

The xdrgen-generated XDR decoders cannot initialize the
file_lock structure because it is an internal kernel type,
not part of the wire protocol. To prepare for converting
SHARE and UNSHARE procedures to use xdrgen, the file_lock
initialization must be moved from nlm4svc_decode_shareargs()
into the procedure handlers themselves.

This change removes one more dependency on the "struct
nlm_lock::fl" field in fs/lockd/xdr4.c, allowing the XDR
decoder to focus solely on unmarshalling wire data.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 16 ++++++++++++----
 fs/lockd/xdr4.c     |  3 ---
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index b4ed77125f68..6dd9afc59551 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -1049,6 +1049,7 @@ nlm4svc_proc_share(struct svc_rqst *rqstp)
 {
 	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_res *resp = rqstp->rq_resp;
+	struct nlm_lock	*lock = &argp->lock;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -1063,7 +1064,10 @@ nlm4svc_proc_share(struct svc_rqst *rqstp)
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	locks_init_lock(&lock->fl);
+	lock->svid = ~(u32)0;
+	resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file);
+	if (resp->status)
 		return resp->status == nlm__int__drop_reply ?
 			rpc_drop_reply : rpc_success;
 
@@ -1071,7 +1075,7 @@ nlm4svc_proc_share(struct svc_rqst *rqstp)
 	resp->status = nlmsvc_share_file(host, file, argp);
 
 	dprintk("lockd: SHARE         status %d\n", ntohl(resp->status));
-	nlmsvc_release_lockowner(&argp->lock);
+	nlmsvc_release_lockowner(lock);
 	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
@@ -1085,6 +1089,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp)
 {
 	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_res *resp = rqstp->rq_resp;
+	struct nlm_lock	*lock = &argp->lock;
 	struct nlm_host	*host;
 	struct nlm_file	*file;
 
@@ -1099,7 +1104,10 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp)
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	locks_init_lock(&lock->fl);
+	lock->svid = ~(u32)0;
+	resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file);
+	if (resp->status)
 		return resp->status == nlm__int__drop_reply ?
 			rpc_drop_reply : rpc_success;
 
@@ -1107,7 +1115,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp)
 	resp->status = nlmsvc_unshare_file(host, file, argp);
 
 	dprintk("lockd: UNSHARE       status %d\n", ntohl(resp->status));
-	nlmsvc_release_lockowner(&argp->lock);
+	nlmsvc_release_lockowner(lock);
 	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index dbbb2dfcb81b..308aac92a94e 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -257,9 +257,6 @@ nlm4svc_decode_shareargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	struct nlm_args *argp = rqstp->rq_argp;
 	struct nlm_lock	*lock = &argp->lock;
 
-	locks_init_lock(&lock->fl);
-	lock->svid = ~(u32)0;
-
 	if (!svcxdr_decode_cookie(xdr, &argp->cookie))
 		return false;
 	if (!svcxdr_decode_string(xdr, &lock->caller, &lock->len))
-- 
2.53.0

