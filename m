Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B69153AE188;
	Fri, 19 Jun 2026 15:26:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781882812; cv=none; b=t6Q/5xY7exZ9q8hixn107HjuhVo5WYdjUktAIHT0C9UOEhK7QhTM9VJDR1QiomfM3Jl/tNJBcBWhb26dUeXAVemBeGlE2AqgriRzh2Rn0LBRYz5jqlDllLhN4Q97VneUTlbvXVtmzijhNfyFXfJfZ1EolCOSQpcQT2yuVgpFzCI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781882812; c=relaxed/simple;
	bh=uZ2FBmxOoVhJsLeuZtKLiGJZ3fUw16DLYpIJJdwXrAI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=YKYZjYHeQUAZpXeWcYoXoYh7WTwnSHv8lFfUre0vXTCfvPlBgW9PwVrI7UVs1a1wwEJQuqawgzBebX7RZod9ruxf5to05/d367Rr2J+wrCjDf5uMVzIbJXzUb2DPs5HwDirkwCk0n7qZfXLzmONPeh163pKYYO/+Y71OreSYAto=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WDx90DII; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WDx90DII"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9455B1F00AC4;
	Fri, 19 Jun 2026 15:26:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781882811;
	bh=Ajw8xEIbnhyGqpeHFElvJETCGD/Q08OjHIPkMg7eBg8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WDx90DIIcT+4YCyZfuhDwxAVPDBjnnOQQilCyZ3LF60gjQ9D/8hueeC6xusymaZHk
	 rFxSobL0tYSFQdeTaAkAMIo8rRY0L+Q5CTJYaqQe31Cp729+gt0jIVWsCj2nfWJ8+x
	 DmdfMe2DSI0btUZkcu0VeMSsLe0T/qxid62Vkjklyola3J2d3mHNVFgL3MTDWUfBDF
	 kfO0/dZ04shRrv8Ir+g7hc5zcoG1c4SZfHq3Q2TsdY09UFiDzMK7sJRNUy6y6jQuo7
	 r0jxwJ0LmTFlkhZAhln6SOUkasjeL079Jq1aKWAckpJoRH4LicTNGy2mM386XD3rH0
	 GT1MWgGavfgdQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 19 Jun 2026 11:26:36 -0400
Subject: [PATCH v6 1/6] sunrpc: add per-netns per-procedure call counts to
 svc_stat
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260619-exportd-netlink-v6-1-ddef3499793c@kernel.org>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
In-Reply-To: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5117; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=uZ2FBmxOoVhJsLeuZtKLiGJZ3fUw16DLYpIJJdwXrAI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNV+33ax7VjMtg3Fwng4NSnfpRfG17lDafcbdA
 /YgiRgiAM6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajVftwAKCRAADmhBGVaC
 FdbTEADNwTnrpC9yW+/ie1/dNRbOlqirrCa4hRisYJpc/QJY+Dvqn7NCreEeHCwHEH5DC5TDUBQ
 Vfk2b2a7KM2mOvxqPbKYeJtzisbID8X1M3VV2LjdI58oSv7HQkPTzFtjvxNk/OksSet2r7EVpGQ
 ISsxnlhJn93qLYNH7hkZgjhGXu+m3bHzZ4/OcMwf548IjOJZq17ZDvj34DTeV+QYVN9pCfZ4Ueh
 nqnWnjx2Dvd50Kidl3Or7LVmVf7/sf1KJzYpGTwZV8RwGKX3L+YnZLMhFN5PivfUAPsEde/ecJ1
 vWyARIwPyyMrVZ7HNzHykuvMaLQTN7jPbcqYqBQUnwJgf4PJNbNhBcYssQxq/x/8wAeik793/KA
 HvkA8smO/pJmWMmL+fcuBB1djAeeMHmDcLziqw1XsDqKcX+sdYDIM2xS/bB6xL475em3abao+21
 3y5oBIFKOiRX/AP7aIUpG1U67hMB4/bB3zO/jn7nqmKavBbcBmSTOui0bdDSckCtA71CVc1NrYN
 9q3h3H/sGwLpUUVPeFkWJ0n+8w2eJ6ec+TndE6g3HHcg4gVQYsBmVwOjOpFxYZ+rLRGcMRPSk0Z
 E/5uPEXhbYju8GIMeRbzWG4AJgqsfR6O2I7R8U1ojZ0leR3OcOA829uauCVN19+3rZU2k/jMCHE
 +DqNnfAARxY4T3w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The existing per-procedure call counts live in global
svc_version->vs_count[] arrays which are not network-namespace-aware.
Add per-netns equivalents in struct svc_stat so the upcoming netlink
stats interface can return namespace-scoped statistics.

Add a vs_count pointer array to struct svc_stat, along with
svc_stat_alloc_counts() and svc_stat_free_counts() helpers to manage
per-version percpu call count arrays.

Increment the per-net counter alongside the global one in
svc_generic_init_request(). Call the alloc/free helpers from
nfsd_net_init() and nfsd_net_exit().

Assisted-by: Claude:claude-opus-4-6
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c             |  8 +++++-
 include/linux/sunrpc/stats.h |  6 +++++
 net/sunrpc/svc.c             | 62 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index caf59421f8f4..601301e34fc7 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2514,9 +2514,12 @@ static __net_init int nfsd_net_init(struct net *net)
 
 	memset(&nn->nfsd_svcstats, 0, sizeof(nn->nfsd_svcstats));
 	nn->nfsd_svcstats.program = &nfsd_programs[0];
+	retval = svc_stat_alloc_counts(&nn->nfsd_svcstats);
+	if (retval)
+		goto out_proc_error;
 	if (!nfsd_proc_stat_init(net)) {
 		retval = -ENOMEM;
-		goto out_proc_error;
+		goto out_svcstats_error;
 	}
 
 	for (i = 0; i < sizeof(nn->nfsd_versions); i++)
@@ -2534,6 +2537,8 @@ static __net_init int nfsd_net_init(struct net *net)
 #endif
 	return 0;
 
+out_svcstats_error:
+	svc_stat_free_counts(&nn->nfsd_svcstats);
 out_proc_error:
 	percpu_counter_destroy_many(nn->counter, NFSD_STATS_COUNTERS_NUM);
 out_repcache_error:
@@ -2574,6 +2579,7 @@ static __net_exit void nfsd_net_exit(struct net *net)
 	kfree_sensitive(nn->fh_key);
 	nfsd_net_cb_shutdown(nn);
 	nfsd_proc_stat_shutdown(net);
+	svc_stat_free_counts(&nn->nfsd_svcstats);
 	percpu_counter_destroy_many(nn->counter, NFSD_STATS_COUNTERS_NUM);
 	nfsd_idmap_shutdown(net);
 	nfsd_export_shutdown(net);
diff --git a/include/linux/sunrpc/stats.h b/include/linux/sunrpc/stats.h
index 3ce1550d1beb..087ade905e29 100644
--- a/include/linux/sunrpc/stats.h
+++ b/include/linux/sunrpc/stats.h
@@ -37,9 +37,15 @@ struct svc_stat {
 				rpcbadfmt,
 				rpcbadauth,
 				rpcbadclnt;
+
+	/* Per-version per-procedure call counts (per-cpu, per-netns) */
+	unsigned long __percpu	**vs_count;
 };
 
 struct net;
+int			svc_stat_alloc_counts(struct svc_stat *statp);
+void			svc_stat_free_counts(struct svc_stat *statp);
+
 #ifdef CONFIG_PROC_FS
 int			rpc_proc_init(struct net *);
 void			rpc_proc_exit(struct net *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dd80a2eaaa74..0cee079df1cb 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1438,6 +1438,14 @@ svc_generic_init_request(struct svc_rqst *rqstp,
 	/* Bump per-procedure stats counter */
 	this_cpu_inc(versp->vs_count[rqstp->rq_proc]);
 
+	/* Bump per-net per-procedure stats counter */
+	if (rqstp->rq_server->sv_stats &&
+	    rqstp->rq_server->sv_stats->program == progp &&
+	    rqstp->rq_server->sv_stats->vs_count &&
+	    rqstp->rq_server->sv_stats->vs_count[rqstp->rq_vers])
+		this_cpu_inc(rqstp->rq_server->sv_stats->vs_count
+				[rqstp->rq_vers][rqstp->rq_proc]);
+
 	ret->dispatch = versp->vs_dispatch;
 	return rpc_success;
 err_bad_vers:
@@ -1449,6 +1457,60 @@ svc_generic_init_request(struct svc_rqst *rqstp,
 }
 EXPORT_SYMBOL_GPL(svc_generic_init_request);
 
+/**
+ * svc_stat_alloc_counts - allocate per-netns per-version call count arrays
+ * @statp: svc_stat whose vs_count arrays should be allocated
+ *
+ * statp->program must be set before calling this.
+ *
+ * Returns zero on success, or a negative errno otherwise.
+ */
+int svc_stat_alloc_counts(struct svc_stat *statp)
+{
+	struct svc_program *prog = statp->program;
+	unsigned int i;
+
+	statp->vs_count = kcalloc(prog->pg_nvers,
+				  sizeof(unsigned long __percpu *),
+				  GFP_KERNEL);
+	if (!statp->vs_count)
+		return -ENOMEM;
+
+	for (i = 0; i < prog->pg_nvers; i++) {
+		if (!prog->pg_vers[i])
+			continue;
+		statp->vs_count[i] = __alloc_percpu(prog->pg_vers[i]->vs_nproc *
+					    sizeof(unsigned long),
+					    sizeof(unsigned long));
+		if (!statp->vs_count[i])
+			goto err;
+	}
+	return 0;
+err:
+	svc_stat_free_counts(statp);
+	return -ENOMEM;
+}
+EXPORT_SYMBOL_GPL(svc_stat_alloc_counts);
+
+/**
+ * svc_stat_free_counts - free per-netns per-version call count arrays
+ * @statp: svc_stat whose vs_count arrays should be freed
+ */
+void svc_stat_free_counts(struct svc_stat *statp)
+{
+	struct svc_program *prog = statp->program;
+	unsigned int i;
+
+	if (!statp->vs_count)
+		return;
+
+	for (i = 0; i < prog->pg_nvers; i++)
+		free_percpu(statp->vs_count[i]);
+	kfree(statp->vs_count);
+	statp->vs_count = NULL;
+}
+EXPORT_SYMBOL_GPL(svc_stat_free_counts);
+
 /*
  * Common routine for processing the RPC request.
  */

-- 
2.54.0

