Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D414233FE0F
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 16:23:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784650993; cv=none; b=pwfn4g1p/lyT3Gzdpa8HQ1xESuxLAZc2oNl3xe+c+c1V2R8KhOOaXe3lEvxtrJm9mNzhejIHGzspPxC8KJQhi7tsYYURZ9xxvFudeNb46f0xHJ3EPs4dr7AJCv2gsLgMUjYtnfNTEpT6pkAeyoLXlvAjsaSzBxt9Lq6Fh8kCjN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784650993; c=relaxed/simple;
	bh=lBAq4tge68eBeEbHPkKuOwvoqse9zzuOUKaPK1SyeMo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UN8Li/rll80qbkJr+bHraqLK7ExNbT+6n0M+MULewo0OeVld0AKnCnjRKOLvt4DMqoJd6Aii9855F48k1YH6RR3u5vM8xxZ/4h3j3RpPDw8Q72yXGhcXh3YNgR1/qbM8OOPuyT35Ty8Al7lAOZXNFUqaR2Rf0Hlw5chRXCFAZA0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NcM735MK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NcM735MK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D29F1F00A3E;
	Tue, 21 Jul 2026 16:23:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784650991;
	bh=sv6w5b1tOzeP2ROvobICbFJHLe7385uzNTjdgqmzrCI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NcM735MKMZVC5mhTQqn4/mBr/3MyxS9cB8Qc4Fdq6zfNvRW4sTbdGcAj0aAYzoLQA
	 cxMbBGC1TcfPOLmrtJh0rCEq49ougiOnilZAsRCxDJ79hPqdTq7dC6f02A5bsRitpn
	 OVymzPvhkrcbsI7cVJUqt1ZkhLLU0XVF84Rl+H4ji5KjcR7Eu3dGJMktATAybVbkoo
	 f37r/VLNFZ7uFvAVLKU/brMcaB765rr2EFgmmkNv84A4SCxmnQ3dKnvtttKosYhQyR
	 rumvjCw9VA9jJgRyTlT8W2RJBP7FZzXSPe2ZetsHGAImPxMZD8E7yzFKaiaS0j0CJC
	 tRpKGRejjqctQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4] nfs_common: Synchronize access to the SSC client ops table
Date: Tue, 21 Jul 2026 12:23:05 -0400
Message-ID: <20260721162306.894558-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260721162306.894558-1-cel@kernel.org>
References: <20260721162306.894558-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd42_ssc_open() and nfsd42_ssc_close() load ssc_nfs4_ops without
synchronization while nfs42_ssc_register() and nfs42_ssc_unregister()
store to it. Those reads are safe today only through a non-obvious
invariant: an inter-server copy holds an active vers=4.2 mount of the
source across both calls, the mount pins the nfsv4 module through the
nfs_client's cl_nfs_mod reference, and unregister runs only at nfsv4
module exit, so it cannot run while a call is in flight. Replace that
implicit contract with synchronization local to the broker, so its
safety no longer rests on a caller in another subsystem.

Read the pointer under RCU so a reader observes it atomically as a
valid table or NULL. nfs42_ssc_unregister() stores NULL and then calls
synchronize_rcu(), so it cannot return while a reader still holds the
pointer.

The two readers need different handling because one sleeps and the
other does not. sco_close() does not sleep, so nfsd42_ssc_close() runs
it to completion inside the RCU read-side section and the
synchronize_rcu() in unregister waits for it. __nfs42_ssc_open() does
sleep -- it issues a GETATTR RPC to the source server and allocates
with GFP_KERNEL -- so it must not run inside an RCU read-side section.
Pin the provider module with try_module_get() while still under
rcu_read_lock(), drop the lock, invoke the open, then release the
module. The reference keeps the provider mapped across the sleep
without relying on the caller's mount. If the table has already been
torn down the copy gets -EIO.

Cc: Olga Kornievskaia <okorniev@redhat.com>
Cc: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/nfs4file.c       |  1 +
 fs/nfs_common/nfs_ssc.c | 40 ++++++++++++++++++++++++++++++----------
 include/linux/nfs_ssc.h |  1 +
 3 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index be40e126c539..b9ffd00e467c 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -400,6 +400,7 @@ static void __nfs42_ssc_close(struct file *filep)
 }
 
 static const struct nfs4_ssc_client_ops nfs4_ssc_clnt_ops_tbl = {
+	.owner = THIS_MODULE,
 	.sco_open = __nfs42_ssc_open,
 	.sco_close = __nfs42_ssc_close,
 };
diff --git a/fs/nfs_common/nfs_ssc.c b/fs/nfs_common/nfs_ssc.c
index a8e79ec68701..ef158008b803 100644
--- a/fs/nfs_common/nfs_ssc.c
+++ b/fs/nfs_common/nfs_ssc.c
@@ -13,7 +13,7 @@
 #include "../nfs/nfs4_fs.h"
 
 struct nfs_ssc_client_ops_tbl {
-	const struct nfs4_ssc_client_ops *ssc_nfs4_ops;
+	const struct nfs4_ssc_client_ops __rcu *ssc_nfs4_ops;
 };
 
 static struct nfs_ssc_client_ops_tbl nfs_ssc_client_tbl __read_mostly;
@@ -38,10 +38,24 @@ struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
 	 * source file cannot be opened, so callers get -EIO.
 	 */
 #if IS_ENABLED(CONFIG_NFSD_V4_2_INTER_SSC)
-	const struct nfs4_ssc_client_ops *ops = nfs_ssc_client_tbl.ssc_nfs4_ops;
+	const struct nfs4_ssc_client_ops *ops;
+	struct file *res;
 
-	if (ops)
-		return ops->sco_open(ss_mnt, src_fh, stateid);
+	/*
+	 * sco_open() sleeps and must not run inside an RCU read-side
+	 * section. Pin the provider module so the open runs with the
+	 * module held; try_module_get() fails once unregister begins,
+	 * and the copy then gets -EIO.
+	 */
+	rcu_read_lock();
+	ops = rcu_dereference(nfs_ssc_client_tbl.ssc_nfs4_ops);
+	if (ops && try_module_get(ops->owner)) {
+		rcu_read_unlock();
+		res = ops->sco_open(ss_mnt, src_fh, stateid);
+		module_put(ops->owner);
+		return res;
+	}
+	rcu_read_unlock();
 #endif
 
 	return ERR_PTR(-EIO);
@@ -53,17 +67,21 @@ EXPORT_SYMBOL_GPL(nfsd42_ssc_open);
  * @filp: struct file to be closed
  *
  * The real cleanup happens unconditionally in nfsd4_cleanup_inter_ssc().
- * The vfsmount is pinned until this function is called, preventing
- * the client from unregistering its SSC ops.
+ * The client ops table is read under RCU; nfs42_ssc_unregister() calls
+ * synchronize_rcu() so unregistration cannot complete while a close is
+ * in flight.
  */
 void nfsd42_ssc_close(struct file *filp)
 {
 	/* Live only under CONFIG_NFSD_V4_2_INTER_SSC; see nfsd42_ssc_open(). */
 #if IS_ENABLED(CONFIG_NFSD_V4_2_INTER_SSC)
-	const struct nfs4_ssc_client_ops *ops = nfs_ssc_client_tbl.ssc_nfs4_ops;
+	const struct nfs4_ssc_client_ops *ops;
 
+	rcu_read_lock();
+	ops = rcu_dereference(nfs_ssc_client_tbl.ssc_nfs4_ops);
 	if (ops)
 		ops->sco_close(filp);
+	rcu_read_unlock();
 #endif
 }
 EXPORT_SYMBOL_GPL(nfsd42_ssc_close);
@@ -78,7 +96,7 @@ EXPORT_SYMBOL_GPL(nfsd42_ssc_close);
  */
 void nfs42_ssc_register(const struct nfs4_ssc_client_ops *ops)
 {
-	nfs_ssc_client_tbl.ssc_nfs4_ops = ops;
+	rcu_assign_pointer(nfs_ssc_client_tbl.ssc_nfs4_ops, ops);
 }
 EXPORT_SYMBOL_GPL(nfs42_ssc_register);
 
@@ -92,10 +110,12 @@ EXPORT_SYMBOL_GPL(nfs42_ssc_register);
  */
 void nfs42_ssc_unregister(const struct nfs4_ssc_client_ops *ops)
 {
-	if (nfs_ssc_client_tbl.ssc_nfs4_ops != ops)
+	if (rcu_dereference_protected(nfs_ssc_client_tbl.ssc_nfs4_ops,
+				      true) != ops)
 		return;
 
-	nfs_ssc_client_tbl.ssc_nfs4_ops = NULL;
+	rcu_assign_pointer(nfs_ssc_client_tbl.ssc_nfs4_ops, NULL);
+	synchronize_rcu();
 }
 EXPORT_SYMBOL_GPL(nfs42_ssc_unregister);
 #endif /* CONFIG_NFS_V4_2 */
diff --git a/include/linux/nfs_ssc.h b/include/linux/nfs_ssc.h
index fc0d5d48dec2..b392d56a4dc2 100644
--- a/include/linux/nfs_ssc.h
+++ b/include/linux/nfs_ssc.h
@@ -14,6 +14,7 @@
  * NFS_V4
  */
 struct nfs4_ssc_client_ops {
+	struct module *owner;
 	struct file *(*sco_open)(struct vfsmount *ss_mnt,
 		struct nfs_fh *src_fh, nfs4_stateid *stateid);
 	void (*sco_close)(struct file *filep);
-- 
2.54.0

