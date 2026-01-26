Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 517E71DDC07
	for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2026 20:39:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769459981; cv=none; b=EtbE1WikkBsTt8vwl4ca9Kf3BpKk8faBdqAvqroia/43hS6AZra1T8pQrgp/zT88604HQhdgb0ayru4fnoFiDY4pndVXIGxu4+pGlrQqzlGMHQWhRNnHEAPtctIMTOfClqciuliAL6FClUAWpeVlJdYqxxABzd7lsInQpJ8lkak=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769459981; c=relaxed/simple;
	bh=erePgpylkRwBIy/ZKfsg4/+D9GZFg0FUAZjCg6vYedI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hLNfxVxNsRdY6i4Gseus+kEVLnOtA6+g7q+0A3BzJ7BTj/KOF2rHpUQkzPR80Lv+ai5MTlfcKkqFkvSXUqLeQOl36lBklDwjq0jdBnxSyxPMEVQUdmMz030RYV7UHKOajQKl2XMvoXa5wTk6DHtSTtD9A/JaQWw/1873Zp7Mwb8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Zz6jLlgF; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zz6jLlgF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB753C116C6;
	Mon, 26 Jan 2026 20:39:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769459981;
	bh=erePgpylkRwBIy/ZKfsg4/+D9GZFg0FUAZjCg6vYedI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Zz6jLlgFDVPe7/S++lqKfbnZX4MIcXgepDKu/Xm8XaQ0PLJmrkh74ccHPH2esmGqK
	 ATTXSRz1oOwu0eFL1a0qNxrJKV9UMIRjt2Q3wHSId9gjdp0igf63TfH5lgns9mfagk
	 vsazmZ8jRrRc5qnH0oYl4hqfAT2xFk1dw1LPDGroPy/9r3mlQtCIAsWDSto8flxVjR
	 CinEZBMEgXExIunLZIpVhrj38+qsZ47VJIKUjqyX0BfKLo6Sk8gFHkJF9j/4Nzqf0s
	 7GFAWl/i3xXMxOTwuzuNUpeQVWVlNf83stCGePWbiiJCuhIdc0miCFkqFNaY8tutPS
	 c7JW8EpxWkdBA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 03/14] NFS: Split out the nfs40_nograce_recovery_ops into nfs40proc.c
Date: Mon, 26 Jan 2026 15:39:27 -0500
Message-ID: <20260126203938.450304-4-anna@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260126203938.450304-1-anna@kernel.org>
References: <20260126203938.450304-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@oracle.com>

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
---
 fs/nfs/nfs40.h     |  1 +
 fs/nfs/nfs40proc.c | 22 ++++++++++++++++++++++
 fs/nfs/nfs4_fs.h   |  6 ++++++
 fs/nfs/nfs4proc.c  | 34 +++++-----------------------------
 4 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs40.h b/fs/nfs/nfs40.h
index ad57172b49a3..c64e5ff6c9ff 100644
--- a/fs/nfs/nfs40.h
+++ b/fs/nfs/nfs40.h
@@ -6,6 +6,7 @@
 /* nfs40proc.c */
 extern const struct rpc_call_ops nfs40_call_sync_ops;
 extern const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops;
+extern const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops;
 
 /* nfs40state.c */
 int nfs40_discover_server_trunking(struct nfs_client *clp,
diff --git a/fs/nfs/nfs40proc.c b/fs/nfs/nfs40proc.c
index b2cc7519b226..867afdf4ecf4 100644
--- a/fs/nfs/nfs40proc.c
+++ b/fs/nfs/nfs40proc.c
@@ -18,6 +18,20 @@ static void nfs40_call_sync_done(struct rpc_task *task, void *calldata)
 	nfs4_sequence_done(task, data->seq_res);
 }
 
+static void nfs40_clear_delegation_stateid(struct nfs4_state *state)
+{
+	if (rcu_access_pointer(NFS_I(state->inode)->delegation) != NULL)
+		nfs_finish_clear_delegation_stateid(state, NULL);
+}
+
+static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+{
+	/* NFSv4.0 doesn't allow for delegation recovery on open expire */
+	nfs40_clear_delegation_stateid(state);
+	nfs_state_clear_open_state_flags(state);
+	return nfs4_open_expired(sp, state);
+}
+
 const struct rpc_call_ops nfs40_call_sync_ops = {
 	.rpc_call_prepare = nfs40_call_sync_prepare,
 	.rpc_call_done = nfs40_call_sync_done,
@@ -31,3 +45,11 @@ const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.establish_clid = nfs4_init_clientid,
 	.detect_trunking = nfs40_discover_server_trunking,
 };
+
+const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
+	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
+	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
+	.recover_open	= nfs40_open_expired,
+	.recover_lock	= nfs4_lock_expired,
+	.establish_clid = nfs4_init_clientid,
+};
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 50e4a4deea48..b56113b70d88 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -351,7 +351,13 @@ extern void nfs4_update_changeattr(struct inode *dir,
 extern int nfs4_buf_to_pages_noslab(const void *buf, size_t buflen,
 				    struct page **pages);
 extern int nfs4_open_reclaim(struct nfs4_state_owner *, struct nfs4_state *);
+extern int nfs4_open_expired(struct nfs4_state_owner *, struct nfs4_state *);
 extern int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request);
+extern int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request);
+extern void nfs_state_clear_delegation(struct nfs4_state *state);
+extern void nfs_finish_clear_delegation_stateid(struct nfs4_state *state,
+						const nfs4_stateid *stateid);
+extern void nfs_state_clear_open_state_flags(struct nfs4_state *state);
 
 #if defined(CONFIG_NFS_V4_1)
 extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 54f61b34e372..00a92e6653a1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1848,7 +1848,7 @@ static void nfs_state_set_open_stateid(struct nfs4_state *state,
 	write_sequnlock(&state->seqlock);
 }
 
-static void nfs_state_clear_open_state_flags(struct nfs4_state *state)
+void nfs_state_clear_open_state_flags(struct nfs4_state *state)
 {
 	clear_bit(NFS_O_RDWR_STATE, &state->flags);
 	clear_bit(NFS_O_WRONLY_STATE, &state->flags);
@@ -1870,7 +1870,7 @@ static void nfs_state_set_delegation(struct nfs4_state *state,
 	write_sequnlock(&state->seqlock);
 }
 
-static void nfs_state_clear_delegation(struct nfs4_state *state)
+void nfs_state_clear_delegation(struct nfs4_state *state)
 {
 	write_seqlock(&state->seqlock);
 	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
@@ -2862,7 +2862,7 @@ static int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4_state
 	return err;
 }
 
-static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
 {
 	struct nfs_open_context *ctx;
 	int ret;
@@ -2875,27 +2875,13 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
-static void nfs_finish_clear_delegation_stateid(struct nfs4_state *state,
+void nfs_finish_clear_delegation_stateid(struct nfs4_state *state,
 		const nfs4_stateid *stateid)
 {
 	nfs_remove_bad_delegation(state->inode, stateid);
 	nfs_state_clear_delegation(state);
 }
 
-static void nfs40_clear_delegation_stateid(struct nfs4_state *state)
-{
-	if (rcu_access_pointer(NFS_I(state->inode)->delegation) != NULL)
-		nfs_finish_clear_delegation_stateid(state, NULL);
-}
-
-static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
-{
-	/* NFSv4.0 doesn't allow for delegation recovery on open expire */
-	nfs40_clear_delegation_stateid(state);
-	nfs_state_clear_open_state_flags(state);
-	return nfs4_open_expired(sp, state);
-}
-
 static int nfs40_test_and_free_expired_stateid(struct nfs_server *server,
 					       nfs4_stateid *stateid, const struct cred *cred)
 {
@@ -7669,7 +7655,7 @@ int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request)
 	return err;
 }
 
-static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request)
+int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_exception exception = {
@@ -10793,17 +10779,7 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.reclaim_complete = nfs41_proc_reclaim_complete,
 	.detect_trunking = nfs41_discover_server_trunking,
 };
-#endif /* CONFIG_NFS_V4_1 */
 
-static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
-	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
-	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
-	.recover_open	= nfs40_open_expired,
-	.recover_lock	= nfs4_lock_expired,
-	.establish_clid = nfs4_init_clientid,
-};
-
-#if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
-- 
2.52.0

