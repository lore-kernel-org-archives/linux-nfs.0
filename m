Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793656344;
	b=4GWnT55S0xVNzYFSsX+W5tH5hosQuY1ScfCwBpuhzPRPtgm2oA2XrJt3nXSQq1UxfLhu
	 vWzhZdR8SGHkmBVipo/dhujyjSi4ekU9ki+AlzdSfB/TRxAQ76vwfVYXeI8ELHwQkMxb/
	 78Td939HsuhX+TWIUIqa3Xnoer2H/j1hxI4HrLuKSmQe095aNewxwfdisGXDakwPn6HC0
	 rD12KtNdPmsrIYZb7HqYVPZcu+T2UxWIUA2t21atF8EcDLqHsVoJKXpbMzel4DJil6ONh
	 CnFY7MRo1Z2Je3Cw+/6Q9LO75DGR8/2xBau9rd/9Ge0juUSbuSbZ+F3Fs+D/ajW6JUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793656344;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=EPomS9iqBJjqCjAmXOl+NbnTN+UsI+4ZDl2yaW93wJA=;
	b=uZrsjMSUePnOkAJjqcR7x6lIZiWuZi5ZMew9WCIrUZEjOwwIYP+wOjtTokpRTlSQBjw3
	 Alg+ziCcZAa17g/Z7S7wxjx99FnBB1p0cihLLQy0uJ/NaJn6A0Ndh9ZpKwdMfIhCqVNA8
	 bPpuKG+LdIibJtuwnF5j94MHO/mS9yKZrLEnCv7+imWiZ3VKqVvpp8NCcjp5/NYjAJeam
	 F/qzDdniYWEacA+JBQHFaDUD/aLh9sbYNZMgYBXi2zJUzBRgGJ3sloTtrVHCsoqxrJ2e7
	 1HdeXgg5krrp9RotwBWuweRcNNOJmQ5sgusYuRVsLcxSRr3fAi/mGbVCsqzltCAXDww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lrqEqlOd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61EDD606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 21:52:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lrqEqlOd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B4ABA1F00A1C;
	Mon,  2 Nov 2026 21:52:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793656343;
	bh=EPomS9iqBJjqCjAmXOl+NbnTN+UsI+4ZDl2yaW93wJA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lrqEqlOdeBly10FN0IbrsW+YwUkoaJyE5qVYAmswfv0CQNTnn9hr1pgLIo4KxTlDn
	 HlEu8wsUv9qqrAUyYG4Kf82wDlGIzB6ml9HlLztYuw3QgvQU3AJCo1XYH36egg9Hot
	 JlwDF24cIVcttKiJkmZ7tMz29ulWJeWpPKM+4QL8X3Pbl/8cdUmiYoXINEpWKZz2aA
	 Old8VB49YYxPZXBGlrBD5RESzPsvP1Me+bL7h7ZpQitVrVyMzQjYAG1b7voDUb5tKn
	 pFDrfo7tnnHj8B0kQBs10IjDdu1yIjs/92WJGmMx3KeNdqZp1vCdgfzc6PFgaUrkiB
	 fcbiMsV5buckA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS/localio: probe again for LOCALIO when localio_enabled is set to Y
Date: Mon,  2 Nov 2026 16:52:19 -0500
Message-ID: <20261102215220.16055-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102215220.16055-1-snitzer@kernel.org>
References: <20261102215220.16055-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

localio_enabled is checked on every I/O.  Setting it to N sends the next
I/O of every client over the network, and setting it back to Y resumes
LOCALIO for a client that uses it.  But a client that probed while
localio_enabled was N was disabled by the probe, and nothing probes it
again: NFSv3 probes again only when nfs3_localio_probe_throttle is set,
and NFSv4 only after state recovery.  Such a client stays on the network
after localio_enabled is set to Y.

Give localio_enabled a set handler that, on a change from N to Y, queues
a probe for every ready client, in every network namespace, that does not
use LOCALIO.  On the module command line there are no clients yet, and
nothing is probed.

Tested with NFSv3 and NFSv4.2 on a loopback mount: a client mounted with
localio_enabled=N sent its writes over the network, and after
localio_enabled was set to Y it sent none.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/localio.rst |  3 ++
 fs/nfs/localio.c                          | 51 ++++++++++++++++++++++-
 2 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/nfs/localio.rst b/Documentation/filesystems/nfs/localio.rst
index 79808b37d7457..e8f44332cc806 100644
--- a/Documentation/filesystems/nfs/localio.rst
+++ b/Documentation/filesystems/nfs/localio.rst
@@ -312,6 +312,9 @@ Module Parameters
 /sys/module/nfs/parameters/localio_enabled (bool)
 controls if LOCALIO is enabled, defaults to Y. If client and server are
 local but 'localio_enabled' is set to N then LOCALIO will not be used.
+It is checked on every I/O: setting it to N sends the next I/O of every
+client over the network, and setting it back to Y resumes LOCALIO.  A
+client that probed while it was N is probed again when it is set to Y.
 
 /sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
 controls if O_DIRECT extends down to the underlying filesystem, defaults
diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index d5859e8c2a2a8..80a496d6fe0d6 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -25,6 +25,7 @@
 #include <linux/nfs_xdr.h>
 
 #include "internal.h"
+#include "netns.h"
 #include "pnfs.h"
 #include "nfstrace.h"
 
@@ -55,7 +56,31 @@ struct nfs_local_fsync_ctx {
 };
 
 static bool localio_enabled __read_mostly = true;
-module_param(localio_enabled, bool, 0644);
+
+static void nfs_local_probe_all(void);
+
+/*
+ * localio_enabled is checked on every I/O, so turning it off stops LOCALIO
+ * at once and turning it back on resumes it for clients that use it.  A
+ * client that probed while it was off was disabled, and nothing probes it
+ * again: turning it on probes every client that does not use LOCALIO.
+ */
+static int localio_enabled_set(const char *val, const struct kernel_param *kp)
+{
+	bool was = READ_ONCE(localio_enabled);
+	int ret;
+
+	ret = param_set_bool(val, kp);
+	if (!ret && !was && READ_ONCE(localio_enabled))
+		nfs_local_probe_all();
+	return ret;
+}
+
+static const struct kernel_param_ops localio_enabled_ops = {
+	.set = localio_enabled_set,
+	.get = param_get_bool,
+};
+module_param_cb(localio_enabled, &localio_enabled_ops, &localio_enabled, 0644);
 
 static void nfs_local_do_read(struct nfs_local_kiocb *iocb,
 			      const struct rpc_call_ops *call_ops);
@@ -222,6 +247,30 @@ void nfs_local_probe_async(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs_local_probe_async);
 
+/* Probe every client, in every namespace, that does not use LOCALIO. */
+static void nfs_local_probe_all(void)
+{
+	struct nfs_client *clp;
+	struct net *net;
+
+	/* Set on the module command line: there are no clients yet. */
+	if (!nfs_net_id)
+		return;
+
+	down_read(&net_rwsem);
+	for_each_net(net) {
+		struct nfs_net *nn = net_generic(net, nfs_net_id);
+
+		spin_lock(&nn->nfs_client_lock);
+		list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link)
+			if (clp->cl_cons_state == NFS_CS_READY &&
+			    !nfs_client_is_local(clp))
+				nfs_local_probe_async(clp);
+		spin_unlock(&nn->nfs_client_lock);
+	}
+	up_read(&net_rwsem);
+}
+
 static inline void nfs_local_file_put(struct nfsd_file *localio)
 {
 	/* nfs_to_nfsd_file_put_local() expects an __rcu pointer
-- 
2.52.0

