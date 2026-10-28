Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793196643;
	b=V+IK90L9DGFWCBTlSUrI/HW1VWCu6opHgtkAVG0GBKF5lFMQbPSIXS/3EiZYHgZvWAbf
	 sYiCD0pUfkUS+BMReFXc8gkNWP5HK5gyZ5oKTDBDMkwEdU/xX/sKv9XUIgn9qMTBee12O
	 0BJRg/0CfS/1036rqS6CNgklPiQ6LfGKhzM2U4As70UgEbc6QOvfk0SgRkieFjcfAOGyR
	 Pa/NwYN/02sVPnwoGS6/7R7FmxCWyBR3E/Ubn9ILIiRTYErFPazsI1cxOlicH8vO2ks99
	 3KfYxeH7W0hxCznLhb1stkEtp2A46/UbBZ+VbKeJhBZSIlR1pYwHT+OFBocjMH/xanA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793196643;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=4BRT1/zIsyosY6pflwCLcmCWvRIh0NtUfvIwl0z89uk=;
	b=bpuXrhrkRCiF/JyyyZpBInN1bMVuPN4XpFfARGFXTbzlaDd0F9YEBKKHRrS6GXqvSv5u
	 ik52KweOo15u9ISdfq0vZs8wZsEEjHqYv56e4iu6W2WlNmAg2Nh7Y7s9iqFEAcgZ+CrLa
	 6vfJ136OvuKqiM0VIbfAw86HRX4BKFfRfjyCtAyDd6A4eaUvkyGFU7GGYx1Nce8SJ4+3W
	 7U+kt27ddrwlGGCo5pVyOJqvJTvj+GNVChX4NtqGrXdRSuYIqq5Eg/QSydh5ek4OcSeVh
	 NLl6OY6ENDVB5PlqnT3WAfyU0fRhE4EdB5PQrB2hNlTfS8Z/Uhz4azbowV4fh/9rwQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bBa8TRTF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0BE6606A31A;
	Wed, 28 Oct 2026 14:10:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bBa8TRTF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 063B21F01825;
	Wed, 28 Oct 2026 14:10:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793196642;
	bh=4BRT1/zIsyosY6pflwCLcmCWvRIh0NtUfvIwl0z89uk=;
	h=From:Date:Subject:To:Cc;
	b=bBa8TRTFmzcrgllgJTEQt/b18VFkSZgtDfE+SbqhcyGmU/5t2Uxq8yrr180hcmOse
	 TuaY0Hui4WzYPU3tzs3hLbw5yHMrNcLL0HJNJtyjuHLYowyItXtPDZrr1UYm7RZWfW
	 dOcw2LSsTvw/3bq3zjsroRL0aXysE3BBIqYIa/84hdIzCsYY4PHp9PSzM/yCHIFX9I
	 tTSJ96pxTUiWyuFvLi/h3SJ9OCxDU8zDYtqbm9TPKHetU7cLPe5ErtbIemLqlcdeV1
	 yo5Zj2QtYGb8Mw2+jwArarRczpngQvfmzuqxb8d8/e3KlJQg3taIo/rz7sQutp9bcz
	 fXf+6jJOQRd6Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 28 Oct 2026 10:10:38 -0400
Subject: [PATCH] NFSD: Don't dereference cp_clp in async COPY tracepoints
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261028-nfsd-testing-v1-1-9116f59c4f77@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzNDAyML3by04hTdktTiksy8dF3D1FRTszRLY5PkFAsloJaCotS0zAqwcdG
 xtbUAjziGVF4AAAA=
X-Change-ID: 20261028-nfsd-testing-1ee56f934cd8
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Yifan Zhang <yfzhang23@stu.pku.edu.cn>, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5285; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QYbxlce+C/ZVlhxVFqskvOP8wo7FVTQi2Vz0y8YHBks=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4gJhAVeCNCBdbp2kMFoqe/kXKJ/TezOsiLOnP
 4yR1lATPbCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauICYQAKCRAADmhBGVaC
 FcPfEACwAyKUMMMkFCnqqYT7+9JRBzrYZg0LtdPs8izC+hFnAiR01ZvLfpJ6aJvaJmKlN6wj/q5
 xuR+u27Qsnwp2r/JJMrdxUN5HJPoij7GtlPPsczKmI5VyBNXcCMSmF6U8+8kgBj0pjiQBSBFFbv
 MttRvrOL/ZOp0QjyssyHYCJHP4Oo9QrgiYCBldlofxrg0ltez2jzzg2EeG8zu0fWePr/j2o/fGB
 FyduMAYPkAuhu8TrNP0/hOtWYaJOnSrmOg6fvlOcyXtB9AMzpiZNMfn45CcLtarqkc8eGqvJI9p
 J8pNPfl99Ap08KKJ9UBVQKBR2imjYXxhctgf4cNlt06jV7lZL1kLGbx5gyQ84PQNKtHX1WfB5sY
 avOv+dqh7gaYQvHW2bavBRKyHN8Y2liwdmpqLkWvhYNzzfaNXYbtnc0wyQANtRWsCA898uoQvZt
 mIq/3mz0+Yym0hjsIgD/+NHphXOB4xhuvKNFwoG+Aa+teQZFoZQfZvTAXVOBBRefKlygJ9h6gDQ
 Ifd6bdyYKUMPHpB3izc4ykM94ymhfzthwttkOtz75vr/xGMB/+Ok5+hHgeyZNMZ/MSloVqcosM6
 bgQA7ZJQbttVuVIIXjEj3IJdwb8RkxOLK5hQlhrJMsWmSWAKGf+E3TKtnCBMY2wFElV9YGOorlC
 pGkoM60BLksDUdw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_unhash_copy() and find_async_copy() clear cp_clp before
nfsd4_stop_copy() fires trace_nfsd_copy_async_cancel(), which reads
copy->cp_clp->cl_addr: NULL deref on shutdown or OFFLOAD_CANCEL. The
kthread's nfsd_copy_async{,_done} events race the same clear.

Pass the client explicitly: cp_stid.sc_client for async copies (never
cleared), cstate->clp for the sync paths.

Reported-by: Yifan Zhang <yfzhang23@stu.pku.edu.cn>
Closes: https://lore.kernel.org/linux-nfs/179317462025.87538.12362003258355443382@stu.pku.edu.cn/
Fixes: 62a8642ba00a ("NFSD: Fix nfsd4_shutdown_copy()")
Fixes: 62c0f6eaf050 ("nfsd: fix UAF in async copy cancel and shutdown")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 10 +++++-----
 fs/nfsd/trace.h    | 20 ++++++++++++--------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a50f9dcb3a31..b572210ee526 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1653,7 +1653,7 @@ static void release_copy_files(struct nfsd4_copy *copy);
 
 static void nfsd4_stop_copy(struct nfsd4_async_copy *copy)
 {
-	trace_nfsd_copy_async_cancel(&copy->cp_copy);
+	trace_nfsd_copy_async_cancel(copy->cp_stid.sc_client, &copy->cp_copy);
 	/*
 	 * Join the kthread before releasing its resources. The task_struct is
 	 * pinned in nfsd4_copy(), so kthread_stop() is safe even after the
@@ -2245,7 +2245,7 @@ static int nfsd4_do_async_copy(void *data)
 	struct nfsd4_copy *copy = &async->cp_copy;
 	__be32 nfserr = nfs_ok;
 
-	trace_nfsd_copy_async(copy);
+	trace_nfsd_copy_async(async->cp_stid.sc_client, copy);
 	if (nfsd4_ssc_is_inter(copy)) {
 		struct file *filp;
 
@@ -2280,7 +2280,7 @@ static int nfsd4_do_async_copy(void *data)
 	 * joining.
 	 */
 	set_bit(NFSD4_COPY_F_COMPLETED, &copy->cp_flags);
-	trace_nfsd_copy_async_done(copy);
+	trace_nfsd_copy_async_done(async->cp_stid.sc_client, copy);
 	atomic_dec(&copy->cp_nn->pending_async_copies);
 	if (copy->cp_res.wr_bytes_written > 0 && copy->attr_update)
 		nfsd_update_cmtime_attr(copy->nf_dst->nf_file, 0);
@@ -2306,7 +2306,7 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	copy->cp_clp = cstate->clp;
 	if (nfsd4_ssc_is_inter(copy)) {
-		trace_nfsd_copy_inter(copy);
+		trace_nfsd_copy_inter(cstate->clp, copy);
 		if (!inter_copy_offload_enable || nfsd4_copy_is_sync(copy)) {
 			status = nfserr_notsupp;
 			goto out;
@@ -2317,7 +2317,7 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		}
 	} else {
-		trace_nfsd_copy_intra(copy);
+		trace_nfsd_copy_intra(cstate->clp, copy);
 		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy);
 		if (status)
 			goto out;
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 951af645d1cb..e7b186307c21 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -2481,9 +2481,10 @@ TRACE_EVENT(nfsd_ctl_fh_key_set,
 
 DECLARE_EVENT_CLASS(nfsd_copy_class,
 	TP_PROTO(
+		const struct nfs4_client *clp,
 		const struct nfsd4_copy *copy
 	),
-	TP_ARGS(copy),
+	TP_ARGS(clp, copy),
 	TP_STRUCT__entry(
 		__field(bool, intra)
 		__field(bool, async)
@@ -2526,7 +2527,7 @@ DECLARE_EVENT_CLASS(nfsd_copy_class,
 		__entry->src_cp_pos = copy->cp_src_pos;
 		__entry->dst_cp_pos = copy->cp_dst_pos;
 		__entry->cp_count = copy->cp_count;
-		__assign_sockaddr(addr, &copy->cp_clp->cl_addr,
+		__assign_sockaddr(addr, &clp->cl_addr,
 				sizeof(struct sockaddr_in6));
 	),
 	TP_printk("client=%pISpc intra=%d async=%d "
@@ -2547,8 +2548,9 @@ DECLARE_EVENT_CLASS(nfsd_copy_class,
 
 #define DEFINE_COPY_EVENT(name)				\
 DEFINE_EVENT(nfsd_copy_class, nfsd_copy_##name,	\
-	TP_PROTO(const struct nfsd4_copy *copy),	\
-	TP_ARGS(copy))
+	TP_PROTO(const struct nfs4_client *clp,		\
+		 const struct nfsd4_copy *copy),	\
+	TP_ARGS(clp, copy))
 
 DEFINE_COPY_EVENT(inter);
 DEFINE_COPY_EVENT(intra);
@@ -2580,9 +2582,10 @@ TRACE_EVENT(nfsd_copy_done,
 
 DECLARE_EVENT_CLASS(nfsd_copy_async_done_class,
 	TP_PROTO(
+		const struct nfs4_client *clp,
 		const struct nfsd4_copy *copy
 	),
-	TP_ARGS(copy),
+	TP_ARGS(clp, copy),
 	TP_STRUCT__entry(
 		__field(int, status)
 		__field(bool, intra)
@@ -2627,7 +2630,7 @@ DECLARE_EVENT_CLASS(nfsd_copy_async_done_class,
 		__entry->src_cp_pos = copy->cp_src_pos;
 		__entry->dst_cp_pos = copy->cp_dst_pos;
 		__entry->cp_count = copy->cp_count;
-		__assign_sockaddr(addr, &copy->cp_clp->cl_addr,
+		__assign_sockaddr(addr, &clp->cl_addr,
 				sizeof(struct sockaddr_in6));
 	),
 	TP_printk("client=%pISpc status=%d intra=%d async=%d "
@@ -2650,8 +2653,9 @@ DECLARE_EVENT_CLASS(nfsd_copy_async_done_class,
 #define DEFINE_COPY_ASYNC_DONE_EVENT(name)		\
 DEFINE_EVENT(nfsd_copy_async_done_class,		\
 	nfsd_copy_async_##name,				\
-	TP_PROTO(const struct nfsd4_copy *copy),	\
-	TP_ARGS(copy))
+	TP_PROTO(const struct nfs4_client *clp,		\
+		 const struct nfsd4_copy *copy),	\
+	TP_ARGS(clp, copy))
 
 DEFINE_COPY_ASYNC_DONE_EVENT(done);
 DEFINE_COPY_ASYNC_DONE_EVENT(cancel);

---
base-commit: 19bbac00ad1cfa28e9127488f161ffc2ac03fad4
change-id: 20261028-nfsd-testing-1ee56f934cd8

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

