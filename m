Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 673F03B6C0C;
	Fri, 17 Jul 2026 11:09:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784286563; cv=none; b=ILFxBB9Plm6sbWq5aPu1PYM9AOiLushl/xrYC/OwCGVQR/emagcgJSYPTu9u24fNri2P/SPn5JxHrnaoS6FqKySaNjAoRkZK8SyftrDC2D8OhgLwJRdg8GSGnENyzUbpAAnxpV55jsLlY0Pid/rcmdNqP98mHVcKNYZKPiGEP3I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784286563; c=relaxed/simple;
	bh=F1LpEO6cHFt1uYeB1id8tH5t6HSMNhfH/uOVtWxB0/A=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=I52z3Jz8N/uA2kCc7I5SUCwCU2zqDSSKfD6akchI6dhuoMV6TR6mDjQf+rl6UcywOERWDCDac3Uds7yqihS7oL5ztVsj387SLnC7hIzj4F/G2gcK7veREkVFC0/fkLkZby+2Fw4ViA0Vyf56tZNmuwNzfndhaIoJbLM5pZnl+2Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j5qtlRVJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j5qtlRVJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5C631F00A3E;
	Fri, 17 Jul 2026 11:09:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784286550;
	bh=U+eZHGx05hGweQx8OCBjR81epQ4Yh2S7o/N4mWZmMWg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=j5qtlRVJAhvSrsKfzL/HenC3z+j4h+fk7dq0EKIqcSFE2nI1o2GzebFnrJX4WrNME
	 3b21hKBGKHSxKqw9asacpwUnKp0QN/imHIY9a1etshcc8eP5njHN03JR0KM5tHqPGT
	 qc7zpPhbNIjCJjdoJNn/aTUp2j2IeuRqVm7ZYD8JznMu0KY0Ox5366aisGgUYLQlTN
	 Q7KRVzPozZqyFnU6965Jq5gUpQ9gdKcPLQXZdqCumXT2d3oPA37nijG8rlPf0l3pQd
	 JCQmstfqz7uLVg6xQAicYANEsw6cHdNKF+sCWN6XynvNq5EWWSus2iJ8IXFmiaS3nK
	 IZPb2NynpMzbQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 17 Jul 2026 07:08:53 -0400
Subject: [PATCH v7 1/6] sunrpc: add per-netns per-procedure call counts to
 svc_stat
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260717-exportd-netlink-v7-1-b7ce17b83b60@kernel.org>
References: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
In-Reply-To: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5098; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=F1LpEO6cHFt1uYeB1id8tH5t6HSMNhfH/uOVtWxB0/A=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqWg1SPDzvnaIGnI2Js7yvgCLLupPiI2X5TozMK
 IyRjXk9k1CJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaloNUgAKCRAADmhBGVaC
 FU8uD/4yAbk7kH7iwD00t90nUui3vYucDVC5el057C6SATO8W3IiO4cWoQ4BxPqZMhqoDDVKrvB
 Du36Y9uzODwbso3zVdVIA5UPcKxLZuzFh2O2o+3kEDfl6kP9sBeQBYHtWeh5DC/8fZS/PX1uWmM
 40BZFtH385stIkOufbthXOn3vcZLFks9yDWJaCBOePkTMdDPPi8uMYPdUVgGxKtJU0q+b0io+Ik
 3WFaRPbZgppIpNx02H6LKsVyIMeMyeBhCeYgk0zafIDblDBsNCcNd+taNuo60AMRnVSV7EB/JRE
 hZ8I4puN/+SgNiRRh2mrTim1SeUqgGu2lMwSfL4ZaTRQ9SXcX0VbgvZqEyIYrJyEkjFZrRAEHb4
 RYb2/P6//qdt8EfA9gnWe1sGru4vRcHLeP73/Y6dFtF3LD5RD8sARZ4WyXWM0VQNE005SBRfXnm
 6hTEZ1s2eVtJxcnGAnXrjyjcg/m6NDWf7jV91aWd5dgAQcVxpO+enQpTCEGj2i9TIpJ9CWX7jYF
 x0acrJemklO/QD5efZe7Bt8njKvfgzNSOIGZ0VNIr6cXMJE94A2ddCzXpHxm891YeDGvO1DSvpV
 WhmEYHtCHz8rTOiAaWXaGKIhHeE8iZlNWqlR+6yAmLfCGuvEyO9tk9TgMmJripqnw8RbBUudpLg
 GfJKCyJDUIe2Law==
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

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c             |  8 +++++-
 include/linux/sunrpc/stats.h |  6 +++++
 net/sunrpc/svc.c             | 62 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7e1d5a5d6511..ae5a7f1ad917 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2516,9 +2516,12 @@ static __net_init int nfsd_net_init(struct net *net)
 
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
@@ -2536,6 +2539,8 @@ static __net_init int nfsd_net_init(struct net *net)
 #endif
 	return 0;
 
+out_svcstats_error:
+	svc_stat_free_counts(&nn->nfsd_svcstats);
 out_proc_error:
 	percpu_counter_destroy_many(nn->counter, NFSD_STATS_COUNTERS_NUM);
 out_repcache_error:
@@ -2576,6 +2581,7 @@ static __net_exit void nfsd_net_exit(struct net *net)
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
index d59e078f39d6..aef6406bab65 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1348,6 +1348,14 @@ svc_generic_init_request(struct svc_rqst *rqstp,
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
@@ -1359,6 +1367,60 @@ svc_generic_init_request(struct svc_rqst *rqstp,
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
2.55.0

