Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 347193F787E;
	Fri, 17 Jul 2026 11:09:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784286561; cv=none; b=TbSU5IkjAi1+ua3MQElXp/6x35XJ0Qf/qptg60kbohQi8BNNFILJtSvFAcXl7BvH4sSE2yrl5G/5pWO/0jxAtnzmSV1WxA23+Z7zQ7BbFSNmKmvk8HRCjiXgsoCb8dAfdofrMN9NnYaQQL8oH/v9x9ekKv/INeZo1JqnDYRrbmM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784286561; c=relaxed/simple;
	bh=59tnNmI81A+TE/ri3pJnS4uQdabX+PWqmK4HXTejSio=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ocxRIkQXjFJkkDxn6KrZiR5srmRHcLuqovzOsYARlC3sCi73SeZqEREEqT2Ckp09qZp2YkKDkkmHEJCh7fi7JGhOtVB20Rpgv2N3JsNTpVQ8DHj2Zdv48V3NPni7kumPWfH/8HpZEnWE0oDUmcaNFkjq7WPl/arhswaDR9AQ/YQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RJ68CZux; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RJ68CZux"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C9CEF1F00A3D;
	Fri, 17 Jul 2026 11:09:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784286552;
	bh=qb1GlZisphJPQAbQd86M/SHe8tJzUUNE1J4JJINpITA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RJ68CZuxWKw+VU7359fPEB5Vm4q3PIQmShAH5+/k9pKM3W1JVl+QBRkcWjYMp73lh
	 IrKPl8bKCnAk+EwAp6dUhkR2yLkMdB340BKv2AhbkCyJg0CNoO1nZefgNknJcMaArD
	 3DvPLYGqbN5oZ8fNaANG/v1rAUIlPiu+pOkXMhIC8/XipQHQ8N/zJW9q5hEGLj3EIw
	 S4x+YKg/urNTLUsPgdLM2ZZvaYwTLgAxPn08TFeyUeORyJKYFION1PYP0NokicWvFZ
	 jxAl8WP0sj8wsOIQMDPeX2ym3ohI7W8SAlL+q7CvpDq0o0n/h2lspN01p0c4UZrX+V
	 6K8tbBeWwlL5A==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 17 Jul 2026 07:08:55 -0400
Subject: [PATCH v7 3/6] nfsd: implement server-stats-get netlink handler
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260717-exportd-netlink-v7-3-b7ce17b83b60@kernel.org>
References: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
In-Reply-To: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=14529; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=59tnNmI81A+TE/ri3pJnS4uQdabX+PWqmK4HXTejSio=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqWg1TG/kIsAgi+zgk9UE9UKtOeg960vrYEyS9n
 cBTvqN0NFWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaloNUwAKCRAADmhBGVaC
 FdhfD/sG0Lbmrs7w47m1wfxaniwnnoN1Y7gbnIZgROv4I4rGrsQc8GVCbfY4g9yaM/QrW85pUdf
 R8DQckdsWdJQOo1xHWJCcdxDRNqH59l7XpGTPzXKYRDs5YU/BpUU5pofNUinL1oUDlqpUFZT3Ii
 26+ztMk8By/hOsSbLv0ul6P/XZmoCJJv1JV9ro1pOv9JnaCKXbivTdlfLYITtAzMmlWKeUIhZwg
 4O8zoS4xTd39LISvscxb9/h0nwuFbLb4lh82ib6iMRPVPGR+822bB02eSngYVhzmeZS0wkunVLE
 HvkBsp96a03sgooJeZS5Jt31dm+F/j2Tat3UyrRJrcdYOv6Q96VgUNSAmEC9yYxLN0CKveRSsIm
 wgtsbmEUX7vsirCoDbVoEkCP/0pMn7zO795XzWO8t2LquaeR+bA8AmW4YowFY0fuvLb4j3rr/MN
 tAJ06gGWVFfHQfAd2F4f/YmL9Wbo2jO3pmBEg5H0gGRDSFTC57rSx8Ggv3hO7CQve1yPHz4DOnx
 uTwZMrIUm0FnF7V8GH55Ckd32XR8W18T1Vns7Rfdgy/PlubMFrKRFDF6qjDd4GTs6x3dmZougqg
 YnpHbcnuWQQpNggNH+PNjPA/aR58REG9cuegE/7lgNDsz/0jm9qvCezdNyuYXHCKOuQb4C5xchW
 w20bIocEmh8bcxw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Implement nfsd_nl_server_stats_get_dumpit() which exposes the
NFS server statistics currently available via /proc/net/rpc/nfsd
through the nfsd generic netlink family.

The handler uses a dump operation to stream statistics across one
or more netlink messages. The reply is divided into sections that
are emitted in order:

  - scalar stats (reply cache, filehandle, IO, network, RPC),
    emitted once in the first message, then

  - per-version procedure counts (proc2/3/4-ops) and the NFSv4
    per-operation counts (proc4ops-ops), using the per-netns
    vs_count arrays.

cb->args[0] tracks the current section and cb->args[1] the entry
index within it, so a section that does not fit in the current
message is closed and resumed in the next one. This matters because
the first dump message is allocated at NLMSG_GOODSIZE (a single page
on most architectures) regardless of the client's receive buffer;
packing every counter into one message would overflow it and fail
the dump with -EMSGSIZE. Userspace merges the attributes from every
message.

This allows nfsstat to retrieve server statistics via netlink
with a procfs fallback for older kernels.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/netlink/specs/nfsd.yaml | 105 ++++++++++++++++
 fs/nfsd/netlink.c                     |   5 +
 fs/nfsd/netlink.h                     |   2 +
 fs/nfsd/nfsctl.c                      | 222 ++++++++++++++++++++++++++++++++++
 include/uapi/linux/nfsd_netlink.h     |  35 ++++++
 5 files changed, 369 insertions(+)

diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 8f36fadd68f7..2a89d355ee7b 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -330,6 +330,86 @@ attribute-sets:
           of which client holds the state. Intended for use after
           all clients have been unexported from a given path,
           enabling the underlying filesystem to be unmounted.
+  -
+    name: server-proc-entry
+    attributes:
+      -
+        name: op
+        type: u32
+      -
+        name: count
+        type: u64
+      -
+        name: pad
+        type: pad
+  -
+    name: server-stats
+    attributes:
+      -
+        name: rc-hits
+        type: u64
+      -
+        name: rc-misses
+        type: u64
+      -
+        name: rc-nocache
+        type: u64
+      -
+        name: pad
+        type: pad
+      -
+        name: fh-stale
+        type: u64
+      -
+        name: io-read
+        type: u64
+      -
+        name: io-write
+        type: u64
+      -
+        name: netcnt
+        type: u32
+      -
+        name: netudpcnt
+        type: u32
+      -
+        name: nettcpcnt
+        type: u32
+      -
+        name: nettcpconn
+        type: u32
+      -
+        name: rpccnt
+        type: u32
+      -
+        name: rpcbadfmt
+        type: u32
+      -
+        name: rpcbadauth
+        type: u32
+      -
+        name: rpcbadclnt
+        type: u32
+      -
+        name: proc2-ops
+        type: nest
+        nested-attributes: server-proc-entry
+        multi-attr: true
+      -
+        name: proc3-ops
+        type: nest
+        nested-attributes: server-proc-entry
+        multi-attr: true
+      -
+        name: proc4-ops
+        type: nest
+        nested-attributes: server-proc-entry
+        multi-attr: true
+      -
+        name: proc4ops-ops
+        type: nest
+        nested-attributes: server-proc-entry
+        multi-attr: true
 
 operations:
   list:
@@ -516,6 +596,31 @@ operations:
         request:
           attributes:
             - path
+    -
+      name: server-stats-get
+      doc: dump NFS server statistics
+      attribute-set: server-stats
+      dump:
+        reply:
+          attributes:
+            - rc-hits
+            - rc-misses
+            - rc-nocache
+            - fh-stale
+            - io-read
+            - io-write
+            - netcnt
+            - netudpcnt
+            - nettcpcnt
+            - nettcpconn
+            - rpccnt
+            - rpcbadfmt
+            - rpcbadauth
+            - rpcbadclnt
+            - proc2-ops
+            - proc3-ops
+            - proc4-ops
+            - proc4ops-ops
 
 mcast-groups:
   list:
diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
index fbee3676d253..eba8b353f412 100644
--- a/fs/nfsd/netlink.c
+++ b/fs/nfsd/netlink.c
@@ -225,6 +225,11 @@ static const struct genl_split_ops nfsd_nl_ops[] = {
 		.maxattr	= NFSD_A_UNLOCK_EXPORT_PATH,
 		.flags		= GENL_ADMIN_PERM | GENL_CMD_CAP_DO,
 	},
+	{
+		.cmd	= NFSD_CMD_SERVER_STATS_GET,
+		.dumpit	= nfsd_nl_server_stats_get_dumpit,
+		.flags	= GENL_CMD_CAP_DUMP,
+	},
 };
 
 static const struct genl_multicast_group nfsd_nl_mcgrps[] = {
diff --git a/fs/nfsd/netlink.h b/fs/nfsd/netlink.h
index af41aa0d4a65..027e2953db26 100644
--- a/fs/nfsd/netlink.h
+++ b/fs/nfsd/netlink.h
@@ -42,6 +42,8 @@ int nfsd_nl_cache_flush_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_unlock_ip_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_unlock_filesystem_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_unlock_export_doit(struct sk_buff *skb, struct genl_info *info);
+int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
+				    struct netlink_callback *cb);
 
 enum {
 	NFSD_NLGRP_NONE,
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index ae5a7f1ad917..7731051105c9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2331,6 +2331,228 @@ int nfsd_nl_cache_flush_doit(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
+/* Emit a single server-proc-entry nest: { op, count }. */
+static int nfsd_nl_put_proc_entry(struct sk_buff *skb, int attr,
+				  u32 op, u64 count)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, attr);
+	if (!nest)
+		return -EMSGSIZE;
+	if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, op) ||
+	    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
+			      count, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
+		nla_nest_cancel(skb, nest);
+		return -EMSGSIZE;
+	}
+	nla_nest_end(skb, nest);
+	return 0;
+}
+
+/* Emit the scalar server-stats counters. Only ever called on a fresh skb. */
+static int nfsd_nl_server_stats_scalars(struct sk_buff *skb,
+					struct nfsd_net *nn,
+					struct svc_stat *statp)
+{
+	if (nla_put_u64_64bit(skb, NFSD_A_SERVER_STATS_RC_HITS,
+			percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_HITS]),
+			NFSD_A_SERVER_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, NFSD_A_SERVER_STATS_RC_MISSES,
+			percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_MISSES]),
+			NFSD_A_SERVER_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, NFSD_A_SERVER_STATS_RC_NOCACHE,
+			percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_NOCACHE]),
+			NFSD_A_SERVER_STATS_PAD))
+		return -EMSGSIZE;
+
+	if (nla_put_u64_64bit(skb, NFSD_A_SERVER_STATS_FH_STALE,
+			percpu_counter_sum_positive(&nn->counter[NFSD_STATS_FH_STALE]),
+			NFSD_A_SERVER_STATS_PAD))
+		return -EMSGSIZE;
+
+	if (nla_put_u64_64bit(skb, NFSD_A_SERVER_STATS_IO_READ,
+			percpu_counter_sum_positive(&nn->counter[NFSD_STATS_IO_READ]),
+			NFSD_A_SERVER_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, NFSD_A_SERVER_STATS_IO_WRITE,
+			percpu_counter_sum_positive(&nn->counter[NFSD_STATS_IO_WRITE]),
+			NFSD_A_SERVER_STATS_PAD))
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, NFSD_A_SERVER_STATS_NETCNT, statp->netcnt) ||
+	    nla_put_u32(skb, NFSD_A_SERVER_STATS_NETUDPCNT, statp->netudpcnt) ||
+	    nla_put_u32(skb, NFSD_A_SERVER_STATS_NETTCPCNT, statp->nettcpcnt) ||
+	    nla_put_u32(skb, NFSD_A_SERVER_STATS_NETTCPCONN, statp->nettcpconn))
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, NFSD_A_SERVER_STATS_RPCCNT, statp->rpccnt) ||
+	    nla_put_u32(skb, NFSD_A_SERVER_STATS_RPCBADFMT, statp->rpcbadfmt) ||
+	    nla_put_u32(skb, NFSD_A_SERVER_STATS_RPCBADAUTH, statp->rpcbadauth) ||
+	    nla_put_u32(skb, NFSD_A_SERVER_STATS_RPCBADCLNT, statp->rpcbadclnt))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+/*
+ * Emit per-version procedure counts for one NFS version, resuming at *idx.
+ * Returns 0 when the version has been fully emitted (or is not present), or
+ * -EMSGSIZE when @skb filled up, leaving *idx at the entry still to emit.
+ */
+static int nfsd_nl_server_stats_proc(struct sk_buff *skb,
+				     struct svc_stat *statp,
+				     struct svc_program *prog,
+				     unsigned int ver, int attr, int *idx)
+{
+	unsigned long __percpu *counts;
+	unsigned int nproc;
+
+	if (!statp->vs_count || ver >= prog->pg_nvers ||
+	    !prog->pg_vers[ver] || !statp->vs_count[ver])
+		return 0;
+
+	counts = statp->vs_count[ver];
+	nproc = prog->pg_vers[ver]->vs_nproc;
+
+	for (; *idx < nproc; (*idx)++) {
+		unsigned long count = 0;
+		int cpu;
+
+		for_each_possible_cpu(cpu)
+			count += per_cpu(counts[*idx], cpu);
+
+		if (!count)
+			continue;
+		if (nfsd_nl_put_proc_entry(skb, attr, *idx, count))
+			return -EMSGSIZE;
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_NFSD_V4
+/*
+ * Emit NFSv4 per-operation counts, resuming at *idx. Same return convention
+ * as nfsd_nl_server_stats_proc().
+ */
+static int nfsd_nl_server_stats_nfs4ops(struct sk_buff *skb,
+					struct nfsd_net *nn, int *idx)
+{
+	for (; *idx <= LAST_NFS4_OP; (*idx)++) {
+		u64 cnt = percpu_counter_sum_positive(
+				&nn->counter[NFSD_STATS_NFS4_OP(*idx)]);
+
+		if (!cnt)
+			continue;
+		if (nfsd_nl_put_proc_entry(skb, NFSD_A_SERVER_STATS_PROC4OPS_OPS,
+					   *idx, cnt))
+			return -EMSGSIZE;
+	}
+
+	return 0;
+}
+#endif
+
+/* Sections of the server-stats dump, emitted in order across messages. */
+enum {
+	NFSD_SERVER_STATS_SCALARS = 0,
+	NFSD_SERVER_STATS_PROC2,
+	NFSD_SERVER_STATS_PROC3,
+	NFSD_SERVER_STATS_PROC4,
+	NFSD_SERVER_STATS_PROC4OPS,
+	NFSD_SERVER_STATS_DONE,
+};
+
+/**
+ * nfsd_nl_server_stats_get_dumpit - dump NFS server statistics
+ * @skb: reply buffer
+ * @cb: netlink metadata and command arguments
+ *
+ * The server-stats object is emitted across one or more netlink messages.
+ * cb->args[0] tracks the current section and cb->args[1] the entry index
+ * within it, so a section that does not fit in the current message is resumed
+ * in the next one. The scalar counters are small and emitted once, in the
+ * first message; userspace merges the attributes from every message.
+ *
+ * Returns the size of the reply or a negative errno.
+ */
+int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
+				    struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct svc_stat *statp = &nn->nfsd_svcstats;
+	struct svc_program *prog = statp->program;
+	int section = cb->args[0];
+	int idx = cb->args[1];
+	void *hdr;
+
+	if (section >= NFSD_SERVER_STATS_DONE)
+		return 0;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+			  cb->nlh->nlmsg_seq, &nfsd_nl_family,
+			  NLM_F_MULTI, NFSD_CMD_SERVER_STATS_GET);
+	if (!hdr)
+		return -ENOBUFS;
+
+	/* Scalar stats fit easily and are emitted in the first message. */
+	if (section == NFSD_SERVER_STATS_SCALARS) {
+		if (nfsd_nl_server_stats_scalars(skb, nn, statp))
+			goto err_cancel;
+		section = NFSD_SERVER_STATS_PROC2;
+		idx = 0;
+	}
+
+	/*
+	 * Emit as many of the remaining sections as fit. A section returning
+	 * -EMSGSIZE means the message is full: close it and resume from the
+	 * same section/index on the next call with a fresh skb. Each entry is
+	 * small enough to fit in a fresh skb, so forward progress is assured.
+	 */
+	while (section < NFSD_SERVER_STATS_DONE) {
+		int ret = 0;
+
+		switch (section) {
+		case NFSD_SERVER_STATS_PROC2:
+			ret = nfsd_nl_server_stats_proc(skb, statp, prog, 2,
+					NFSD_A_SERVER_STATS_PROC2_OPS, &idx);
+			break;
+		case NFSD_SERVER_STATS_PROC3:
+			ret = nfsd_nl_server_stats_proc(skb, statp, prog, 3,
+					NFSD_A_SERVER_STATS_PROC3_OPS, &idx);
+			break;
+		case NFSD_SERVER_STATS_PROC4:
+			ret = nfsd_nl_server_stats_proc(skb, statp, prog, 4,
+					NFSD_A_SERVER_STATS_PROC4_OPS, &idx);
+			break;
+#ifdef CONFIG_NFSD_V4
+		case NFSD_SERVER_STATS_PROC4OPS:
+			ret = nfsd_nl_server_stats_nfs4ops(skb, nn, &idx);
+			break;
+#endif
+		}
+
+		if (ret == -EMSGSIZE)
+			goto out;
+		if (ret)
+			goto err_cancel;
+
+		section++;
+		idx = 0;
+	}
+
+out:
+	genlmsg_end(skb, hdr);
+	cb->args[0] = section;
+	cb->args[1] = idx;
+	return skb->len;
+
+err_cancel:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
 int nfsd_cache_notify(struct cache_detail *cd, struct cache_head *h, u32 cache_type)
 {
 	struct genlmsghdr *hdr;
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index f5b75d5caba9..3d076d173b1d 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -225,6 +225,40 @@ enum {
 	NFSD_A_UNLOCK_EXPORT_MAX = (__NFSD_A_UNLOCK_EXPORT_MAX - 1)
 };
 
+enum {
+	NFSD_A_SERVER_PROC_ENTRY_OP = 1,
+	NFSD_A_SERVER_PROC_ENTRY_COUNT,
+	NFSD_A_SERVER_PROC_ENTRY_PAD,
+
+	__NFSD_A_SERVER_PROC_ENTRY_MAX,
+	NFSD_A_SERVER_PROC_ENTRY_MAX = (__NFSD_A_SERVER_PROC_ENTRY_MAX - 1)
+};
+
+enum {
+	NFSD_A_SERVER_STATS_RC_HITS = 1,
+	NFSD_A_SERVER_STATS_RC_MISSES,
+	NFSD_A_SERVER_STATS_RC_NOCACHE,
+	NFSD_A_SERVER_STATS_PAD,
+	NFSD_A_SERVER_STATS_FH_STALE,
+	NFSD_A_SERVER_STATS_IO_READ,
+	NFSD_A_SERVER_STATS_IO_WRITE,
+	NFSD_A_SERVER_STATS_NETCNT,
+	NFSD_A_SERVER_STATS_NETUDPCNT,
+	NFSD_A_SERVER_STATS_NETTCPCNT,
+	NFSD_A_SERVER_STATS_NETTCPCONN,
+	NFSD_A_SERVER_STATS_RPCCNT,
+	NFSD_A_SERVER_STATS_RPCBADFMT,
+	NFSD_A_SERVER_STATS_RPCBADAUTH,
+	NFSD_A_SERVER_STATS_RPCBADCLNT,
+	NFSD_A_SERVER_STATS_PROC2_OPS,
+	NFSD_A_SERVER_STATS_PROC3_OPS,
+	NFSD_A_SERVER_STATS_PROC4_OPS,
+	NFSD_A_SERVER_STATS_PROC4OPS_OPS,
+
+	__NFSD_A_SERVER_STATS_MAX,
+	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
+};
+
 enum {
 	NFSD_CMD_RPC_STATUS_GET = 1,
 	NFSD_CMD_THREADS_SET,
@@ -244,6 +278,7 @@ enum {
 	NFSD_CMD_UNLOCK_IP,
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
+	NFSD_CMD_SERVER_STATS_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)

-- 
2.55.0

