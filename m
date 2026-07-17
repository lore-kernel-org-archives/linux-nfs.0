Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21C313BFACC;
	Fri, 17 Jul 2026 11:09:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784286570; cv=none; b=Rf9NdwoaQMOCO5EYbkQTaPnrgbaCyn/p5ARZJBB/TPCzHIMFLtCryHTqSqQhJ/mQ/wPI68ykuJmLrwlqpSnQPo3OEd5aD72XydiuO8fxGMAz9XOUg67xe5qYOdyY/l9sRQDKkZvBKXa/EEndxhgFpCxdR4BCVFH3wLLCfT7sf2U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784286570; c=relaxed/simple;
	bh=CS8zI+qB91zpGRQIqSxDi2oHVm0zXoSDFRWk/S3h27w=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fXC6lk317TBVVUEmZi7L7u2zxrE+crBEkbkca+BJNPwyjJXWavCeAYnEQ0Et4Dh0W4kNKZFsgSp5u+gNPL5EWaNeQytffLiR2y62ZqNXXi+c4C0gqsc23KNvxsVA7C3U6+reahd6i+j61iXH5LjhahA4qYxTOAyzFRq9EAdUa1E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UiGurzF/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UiGurzF/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 037D31F00AC4;
	Fri, 17 Jul 2026 11:09:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784286555;
	bh=DCDIhE7c9pAvgc6YoJGBa4Coz73mEKhv06cmrK3JWGo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UiGurzF/P0ebFMnF4UNTTjkKHMC/NgxP99mLR8amo9EQRsgb9pTJZ8P09Ey5NdfON
	 n56Cf4owqgP+BUIDoTMpmib4Kx0DZ5IexlUQcf4rn4P1JzeNp4ABhgUCW5Au5n9iso
	 DZeAJxoAL0Qol+BMBDAg+Q/AXTGmfuvKKXhk7OYJhGHDg4k2dGgCuDBK5iHYAEdsHf
	 wMvzsoVQV+Ft9idn0DljVQR0cgBvEzcicnk/NHAcRVgp2UhpcBG7McM2PGkify8/gl
	 M7gg/LwSSSRt1Ezb9bZ3tZa12xL7LSdOfCf7RhZ6DCyQdYSTaaTLODH2cnUKyOM6EW
	 VSdqZfV/uFkzA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 17 Jul 2026 07:08:58 -0400
Subject: [PATCH v7 6/6] nfsd: export NFSv4 callback op stats via netlink
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260717-exportd-netlink-v7-6-b7ce17b83b60@kernel.org>
References: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
In-Reply-To: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3474; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CS8zI+qB91zpGRQIqSxDi2oHVm0zXoSDFRWk/S3h27w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqWg1UjK5p8uMIJjJMZQ6vPmWD1b6JxHDDF1I0z
 cdKNk9F6FSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaloNVAAKCRAADmhBGVaC
 FTupD/oDam6qvgMY/4pxVGN/zOhn1+QCfnTkp967ECsT1AJlaWgG4PYntQdnAQvbJM4lv0vhlNO
 +YtkVU8WbB1Sq0mjqt1Z9I8bxolhoMj75EMLD3CWZglC0REjWwaoTq2eYxuQPRhzqY/gvi1FYsF
 Ws0p809x5NJzIbMWm/yDo75+q8in0DSiyHRAkGYebTPTQFbbRJd5UBdnxZQrQymV5Iu6bn7O4ce
 My9V8yTfJ+OKPixQUMdURGNj2BDu8z0AE3HstQqC5bOe3s21EXI0izuSiWX/8FcSWXw5aFoCLD4
 Bmff7ndNkNvXVO+hsDius2Jew3bGC+zJTi/7Qc2eJEkoYLxgw1bQ0cHfkqkceyywxHKP4OWyelH
 ymFAXs25qhtRIrKY2PYksQMf2nRXMtfd/vlRUAweOeAsX1rZH7AofIcgYvYGcFP/+fwJaeebHfR
 9Hq5fV2cqRIo7lzFEfcO3VP9KN66J3Wi0sAX0sKGAKtrB30PzwowYThVDHHEAbqn00ksSWTJMpL
 mDwi5LRXq1ODN0k3JXMBi1j1iukdEmUGFbxObwxBZ7MdPRvDvulUdFlNtUxzktMa+6+FYR+s9gc
 f7BYobF81/i2L9Sb8gXmoO4+8mOHh7SaSjkPcJBuXSgzEIfYFN7/PLaQGl1Rg4LzCcIni/dFQ+l
 lgPkioVDkv4DDAg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add a proc4cb-ops nested attribute to the server-stats netlink dump,
reusing the existing server-proc-entry (op/count) layout. The dump
gains a callback section that emits one entry per callback opcode
(OP_CB_GETATTR..OP_CB_OFFLOAD) from the per-netns callback counters,
paged across messages like the other per-operation sections.

This lets nfsstat report NFSv4 backchannel operation counts over
netlink, including CB_GETATTR which corresponds to the procfs
wdeleg_getattr line.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/netlink/specs/nfsd.yaml |  6 ++++++
 fs/nfsd/nfsctl.c                      | 27 +++++++++++++++++++++++++++
 include/uapi/linux/nfsd_netlink.h     |  1 +
 3 files changed, 34 insertions(+)

diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 2a89d355ee7b..642268819c6f 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -410,6 +410,11 @@ attribute-sets:
         type: nest
         nested-attributes: server-proc-entry
         multi-attr: true
+      -
+        name: proc4cb-ops
+        type: nest
+        nested-attributes: server-proc-entry
+        multi-attr: true
 
 operations:
   list:
@@ -621,6 +626,7 @@ operations:
             - proc3-ops
             - proc4-ops
             - proc4ops-ops
+            - proc4cb-ops
 
 mcast-groups:
   list:
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 93e18426039d..adb032b7311a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2451,6 +2451,29 @@ static int nfsd_nl_server_stats_nfs4ops(struct sk_buff *skb,
 
 	return 0;
 }
+
+/*
+ * Emit NFSv4 callback (backchannel) per-operation counts, resuming at *idx,
+ * which counts from OP_CB_GETATTR. Same return convention as
+ * nfsd_nl_server_stats_proc().
+ */
+static int nfsd_nl_server_stats_cbops(struct sk_buff *skb,
+				      struct nfsd_net *nn, int *idx)
+{
+	int op;
+
+	for (op = OP_CB_GETATTR + *idx; op <= OP_CB_OFFLOAD; op++, (*idx)++) {
+		u64 cnt = percpu_counter_sum_positive(&nn->cb_counter[op]);
+
+		if (!cnt)
+			continue;
+		if (nfsd_nl_put_proc_entry(skb, NFSD_A_SERVER_STATS_PROC4CB_OPS,
+					   op, cnt))
+			return -EMSGSIZE;
+	}
+
+	return 0;
+}
 #endif
 
 /* Sections of the server-stats dump, emitted in order across messages. */
@@ -2459,6 +2482,7 @@ enum {
 	NFSD_SERVER_STATS_PROC2,
 	NFSD_SERVER_STATS_PROC3,
 	NFSD_SERVER_STATS_PROC4,
+	NFSD_SERVER_STATS_PROC4CB,
 	NFSD_SERVER_STATS_PROC4OPS,
 	NFSD_SERVER_STATS_DONE,
 };
@@ -2527,6 +2551,9 @@ int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
 					NFSD_A_SERVER_STATS_PROC4_OPS, &idx);
 			break;
 #ifdef CONFIG_NFSD_V4
+		case NFSD_SERVER_STATS_PROC4CB:
+			ret = nfsd_nl_server_stats_cbops(skb, nn, &idx);
+			break;
 		case NFSD_SERVER_STATS_PROC4OPS:
 			ret = nfsd_nl_server_stats_nfs4ops(skb, nn, &idx);
 			break;
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index 3d076d173b1d..87da1d0bb21e 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -254,6 +254,7 @@ enum {
 	NFSD_A_SERVER_STATS_PROC3_OPS,
 	NFSD_A_SERVER_STATS_PROC4_OPS,
 	NFSD_A_SERVER_STATS_PROC4OPS_OPS,
+	NFSD_A_SERVER_STATS_PROC4CB_OPS,
 
 	__NFSD_A_SERVER_STATS_MAX,
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)

-- 
2.55.0

