Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE29C3F7A84;
	Fri, 17 Jul 2026 11:09:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784286569; cv=none; b=ZfYi5YKTwte4tzHvxHIFC23yf8GbA6avUv413Dy9PrZ/b3xEse2MAf7mBzx9ONSzwq4ZRbjCbvfwXf6eMcbS40KVtny2fr82DeQbktETDyrL/wj2hlG78iV52L0dWXZFXLonfrjKNBw8h0L2p7QIkzHa9Wg1DG92aBZbIufHZZU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784286569; c=relaxed/simple;
	bh=94d9mX1D850XINaow+l8oCCpvB+Sgb1At8dp3vkNX4I=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=DmyP6GG9xcEw4sGHCpD3w+LouOtaLFcEY9YHRM++TlHPkDA70GkZmD4kImGSYYNFDmyYB0avwwCtCN0f7iX7vBzadNUm7oQcHCdx/u2gWFESQEP3oz0q/KVQSQs0jkjy7eoNi/quTL2nYHX3K/TIANLzzxexiLAj3e1hRH0LNz8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MHvY5tdG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MHvY5tdG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EDF9B1F00A3F;
	Fri, 17 Jul 2026 11:09:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784286554;
	bh=RmnOPpqWq+Y2NvO0zZHAQlg+r+KmZLUR8nv7/fBKQMs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MHvY5tdG2D/tiM+qEda0oKhIMj+hD79OwJvgcQsbrV5PoQEjQZkS9Hdo4EB7eh22Q
	 RwckhkjtFXqfV6SiV6kyERRbBUV2Xp8xndfowyswmvXMNHv6hCTSX4FV4YraLKTjo7
	 o2jdqcsbbclVzLvCFRiMyNGpCVjZCVL+B+r07qL/OwJLCti/iv7DAFRy2gvn1ggzcs
	 Ga0uptLQykB9lb3NLWkt2RNLPuI/CDL+YB3FC40MuHm2ubZSFtLQ6PjZ5x4O7QnQFk
	 X/QaWRZ6xL0hvM38GqeFsRSZrzYlsnIAYUumeXkbLVB3HYLSsApUmKS93JCKmhQZaD
	 PBYOor2Y5o+aQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 17 Jul 2026 07:08:57 -0400
Subject: [PATCH v7 5/6] nfsd: count NFSv4 callback operations per netns
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260717-exportd-netlink-v7-5-b7ce17b83b60@kernel.org>
References: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
In-Reply-To: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=7453; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=94d9mX1D850XINaow+l8oCCpvB+Sgb1At8dp3vkNX4I=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqWg1TLuaNs/5eBM0011Q2lZOVjfIoKYWZqpS99
 xIRF39w1E2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaloNUwAKCRAADmhBGVaC
 FYMbD/4l2vFACzBz33TCx+B0gnYIbEsp37qSbFPWlgRdjnQU+2hcW9KbiLQphhGAf6UJSUkOsqI
 NXvAJxPFbGXF2MvPcny3eJPMQxTAjFdBGF8Ub122UqVzJ03ONklwJabnXNwqCKqFxS4K1jQ9wxw
 u8NM15KATYRdLeWlalbwlrx7cXNiUR6QbYG7+wYl86htx2VVEaxEO9D0y2mJOd0gsTm5gsLLMeH
 MCF0DlBbZdfgAocq7ffsm2u587tXPAMA89ZNrr9wLIrxbH6y3nXlKn+JWxLV500657WlbIcBC16
 lJle1vy8tnN7caVp2SnjMxKL3MGu10zn47N1PvN3El/TNFXWw8HqESwWa3WijsJ2nro0YUy+Upy
 EqobUcW9rQko+27ae8jWQ+BvT8QrO6KzT6mgSm7p5G/aTLoq8dMhGkDBiZOo13u3parbIGaVmgd
 WmioYvOCrD++xBcBHR6UnMxa2Q41TxXTZXsMkTPu4IezI6eFE0pPSuuNkEw0tI8N8gYhgNQaGru
 jlyw4lo0XHG4WOmAOTFuMRwyj2hmiZHJzbYP1C59LC+ae3URSsNmeo910ULXmg/5XP4PhzPO0V+
 Vl7ytyQGXoK9Q6lj0UtHRbcFFpuUGf4IZShOLEd6ktSsdLP2W/CsENPHakPwV6UJvDdRWDT+cI0
 qZJVhONHhiVKn1g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The NFS server tracks per-operation call counts for the forward channel
(proc4ops) but keeps no statistics for the NFSv4 backchannel (callback)
operations it sends to clients.

Add a per-netns array of percpu counters for callback operations, indexed
by RFC 8881 callback opcode (OP_CB_GETATTR..OP_CB_OFFLOAD), and bump the
relevant counter in nfsd4_run_cb(), which is hit exactly once per callback
that is actually queued.

CB_GETATTR is sent when a GETATTR conflicts with an outstanding write
delegation, which is roughly what the dedicated wdeleg_getattr counter
tracked. The two are not identical: the old counter incremented on every
such conflict, whereas the CB_GETATTR counter only counts callbacks that
are actually queued, so concurrent conflicts that coalesce onto an
already in-flight CB_GETATTR are now counted once rather than once per
conflict. Report the procfs "wdeleg_getattr" line from the CB_GETATTR
counter and drop the now-redundant NFSD_STATS_WDELEG_GETATTR counter, its
helper, and its increment site.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h        | 12 +++++++++++-
 fs/nfsd/nfs4callback.c | 22 +++++++++++++++++++++-
 fs/nfsd/nfs4state.c    |  2 --
 fs/nfsd/nfsctl.c       | 14 ++++++++++++++
 fs/nfsd/stats.c        |  2 +-
 fs/nfsd/stats.h        |  5 +++--
 6 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index a7bd7b67fa4f..71eebfea020d 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -53,11 +53,16 @@ enum {
 	NFSD_STATS_FIRST_NFS4_OP,	/* count of individual nfsv4 operations */
 	NFSD_STATS_LAST_NFS4_OP = NFSD_STATS_FIRST_NFS4_OP + LAST_NFS4_OP,
 #define NFSD_STATS_NFS4_OP(op)	(NFSD_STATS_FIRST_NFS4_OP + (op))
-	NFSD_STATS_WDELEG_GETATTR,	/* count of getattr conflict with wdeleg */
 #endif
 	NFSD_STATS_COUNTERS_NUM
 };
 
+/*
+ * Per-netns NFSv4 callback (backchannel) per-operation counters, indexed
+ * directly by RFC 8881 callback opcode (OP_CB_GETATTR..OP_CB_OFFLOAD).
+ */
+#define NFSD_STATS_CB_OPS_NUM	(OP_CB_OFFLOAD + 1)
+
 /*
  * Represents a nfsd "container". With respect to nfsv4 state tracking, the
  * fields of interest are the *_id_hashtbls and the *_name_tree. These track
@@ -200,6 +205,11 @@ struct nfsd_net {
 	/* Per-netns stats counters */
 	struct percpu_counter    counter[NFSD_STATS_COUNTERS_NUM];
 
+#ifdef CONFIG_NFSD_V4
+	/* Per-netns NFSv4 callback (backchannel) per-operation counters */
+	struct percpu_counter    cb_counter[NFSD_STATS_CB_OPS_NUM];
+#endif
+
 	/* sunrpc svc stats */
 	struct svc_stat          nfsd_svcstats;
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 71dcb448fa0a..a901bbe67e03 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -39,6 +39,7 @@
 #include "nfsd.h"
 #include "state.h"
 #include "netns.h"
+#include "stats.h"
 #include "trace.h"
 #include "xdr4cb.h"
 #include "xdr4.h"
@@ -1921,12 +1922,31 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 bool nfsd4_run_cb(struct nfsd4_callback *cb)
 {
 	struct nfs4_client *clp = cb->cb_clp;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	const struct nfsd4_callback_ops *ops = cb->cb_ops;
+	u32 minorversion = clp->cl_minorversion;
 	bool queued;
 
 	nfsd41_cb_inflight_begin(clp);
 	queued = nfsd4_queue_cb(cb);
-	if (!queued)
+	if (queued) {
+		if (ops) {
+			nfsd_stats_cb_op_inc(nn, ops->opcode);
+			/*
+			 * Minorversion > 0 callbacks prepend a CB_SEQUENCE op
+			 * (see encode_cb_sequence4args()); count it like the
+			 * forechannel counts SEQUENCE, so it isn't perpetually
+			 * reported as zero.  CB_NULL probes (ops == NULL) carry
+			 * no CB_SEQUENCE -- and on 4.1+ they are dropped without
+			 * sending any RPC (see nfsd4_run_cb_work()) -- so they
+			 * must not be counted here.
+			 */
+			if (minorversion > 0)
+				nfsd_stats_cb_op_inc(nn, OP_CB_SEQUENCE);
+		}
+	} else {
 		nfsd41_cb_inflight_end(clp);
+	}
 	return queued;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 19810419f457..18e17232cf94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10122,7 +10122,6 @@ __be32
 nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 			     struct nfs4_delegation **pdp)
 {
-	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
 	struct file_lock_context *ctx;
 	struct nfs4_delegation *dp = NULL;
@@ -10162,7 +10161,6 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 		return 0;
 	}
 
-	nfsd_stats_wdeleg_getattr_inc(nn);
 	refcount_inc(&dp->dl_stid.sc_count);
 	ncf = &dp->dl_cb_fattr;
 	nfs4_cb_getattr(&dp->dl_cb_fattr);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7731051105c9..93e18426039d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2736,6 +2736,13 @@ static __net_init int nfsd_net_init(struct net *net)
 	if (retval)
 		goto out_repcache_error;
 
+#ifdef CONFIG_NFSD_V4
+	retval = percpu_counter_init_many(nn->cb_counter, 0, GFP_KERNEL,
+					  NFSD_STATS_CB_OPS_NUM);
+	if (retval)
+		goto out_cb_counter_error;
+#endif
+
 	memset(&nn->nfsd_svcstats, 0, sizeof(nn->nfsd_svcstats));
 	nn->nfsd_svcstats.program = &nfsd_programs[0];
 	retval = svc_stat_alloc_counts(&nn->nfsd_svcstats);
@@ -2764,6 +2771,10 @@ static __net_init int nfsd_net_init(struct net *net)
 out_svcstats_error:
 	svc_stat_free_counts(&nn->nfsd_svcstats);
 out_proc_error:
+#ifdef CONFIG_NFSD_V4
+	percpu_counter_destroy_many(nn->cb_counter, NFSD_STATS_CB_OPS_NUM);
+out_cb_counter_error:
+#endif
 	percpu_counter_destroy_many(nn->counter, NFSD_STATS_COUNTERS_NUM);
 out_repcache_error:
 	nfsd_idmap_shutdown(net);
@@ -2804,6 +2815,9 @@ static __net_exit void nfsd_net_exit(struct net *net)
 	nfsd_net_cb_shutdown(nn);
 	nfsd_proc_stat_shutdown(net);
 	svc_stat_free_counts(&nn->nfsd_svcstats);
+#ifdef CONFIG_NFSD_V4
+	percpu_counter_destroy_many(nn->cb_counter, NFSD_STATS_CB_OPS_NUM);
+#endif
 	percpu_counter_destroy_many(nn->counter, NFSD_STATS_COUNTERS_NUM);
 	nfsd_idmap_shutdown(net);
 	nfsd_export_shutdown(net);
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index 9a03e097cfe5..f16559813292 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -65,7 +65,7 @@ static int nfsd_show(struct seq_file *seq, void *v)
 			   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_NFS4_OP(i)]));
 	}
 	seq_printf(seq, "\nwdeleg_getattr %lld",
-		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GETATTR]));
+		percpu_counter_sum_positive(&nn->cb_counter[OP_CB_GETATTR]));
 
 	seq_putc(seq, '\n');
 #endif
diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index 87736b7fbf28..70eaf5f20bda 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -71,9 +71,10 @@ static inline void nfsd_stats_drc_mem_usage_sub(struct nfsd_net *nn, s64 amount)
 }
 
 #ifdef CONFIG_NFSD_V4
-static inline void nfsd_stats_wdeleg_getattr_inc(struct nfsd_net *nn)
+static inline void nfsd_stats_cb_op_inc(struct nfsd_net *nn, u32 opcode)
 {
-	percpu_counter_inc(&nn->counter[NFSD_STATS_WDELEG_GETATTR]);
+	if (opcode >= OP_CB_GETATTR && opcode <= OP_CB_OFFLOAD)
+		percpu_counter_inc(&nn->cb_counter[opcode]);
 }
 #endif
 #endif /* _NFSD_STATS_H */

-- 
2.55.0

