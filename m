Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B87704B489D
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 18:42:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789152181; cv=none; b=OnYcaCHB5pPaP6bmId7WKxCjD9ORNg4dNgYf09RodNXozBFrRn7aYyd6sitIB4Ue3VbcK0D59aM05CZWtV6I9IG7HdjUQOfgLWp4tBTTtcIs3uYR5HcoythMvy8cAxjzpFLiqShcfntzkmcKCxswG1ngKFallAhhH5TQMD/JUZg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789152181; c=relaxed/simple;
	bh=1HLjrpD7WTlCIAO5ddYcC4mZCrtah/NYA5Oc8DjqA9I=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eQDa2a/jaL+ypHQQYPUluTVvB3snCV4lr36GSzJlML+HGUKOe+0UUz32BXMFqpg2DIILptYrzShMQA5EFbev1mWeIwPgzTLOblHDBfaNmyLRJtl44Zi6iO7luzyTMDXspR5ws/RzjZlczy0vBGhfSjOMAqK1g+Ql4Xi/9yW8+wY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ohyV9d4T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ohyV9d4T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8DD201F000FF;
	Fri, 11 Sep 2026 18:42:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789152160;
	bh=hJLZtUrBsKaZHndIGiQhtjl+4t28hLHVodt4tvlXEY8=;
	h=From:To:Cc:Subject:Date;
	b=ohyV9d4ToT1f7nBUmvId7o7ie36x86aD/jtFp9YkfdpRloW2WcrTcq7zY5fHeQ8Ww
	 2f8IkPXDcwBNLmxesbT05Gtg9+tfer0NZ6YxIJgbMQ3vjQhEV66W7y2sBUYt+w+Akr
	 bCBtvQ5uMp9GC6m4LT6H8YWdujlixod5UmywOMwfYo8kjRXsE0FyaTd2Pc+a1ywL51
	 pxmGf5V+dviZlvjcEk4+Tspf+evCR/7W6d5F89PtRf43CZi7+cW2RXDwxzNY5GxXVy
	 HF5XdqXCDrGdY5WYWO5YA/aSdUtdOYuqyp9nxB6+BJeK3n7fasFk+Giw1t8vTSNQ7F
	 1pP3QBIxrxsKQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: defer the final superblock deactivation
Date: Fri, 11 Sep 2026 14:42:39 -0400
Message-ID: <20260911184239.90154-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A writeback worker can self-deadlock on sb->s_umount when it drops the
last active reference to an NFS superblock:

  wb_workfn
    __writeback_inodes_wb
      super_trylock_shared(sb)          <- s_umount held shared
      writeback_sb_inodes
        nfs_writepages
          nfs_do_writepage              <- fatal error: out_launder
            nfs_write_error
              nfs_release_request
                nfs_put_lock_context
                  __put_nfs_open_context
                    nfs_sb_deactive
                      deactivate_super
                        down_write(&sb->s_umount)   <- deadlock

Open contexts pin the superblock through server->active. Once the
mount has been detached (an expired automounted submount, or a lazy
umount), the open context attached to an outstanding write request can
hold the last s_active reference. If the server then fails writes with
an error that nfs_error_is_fatal_on_server() treats as fatal,
nfs_do_writepage() releases the request inline from the flusher, and
the final deactivate_super() tries to take s_umount exclusively while
the same task already holds it shared.

This was hit on a 6.12-based client whose server began rejecting
requests with AUTH_TOOWEAK (-EACCES). The flush worker hung in
deactivate_super(), and every later automount of the same filesystem
blocked in grab_super() behind it.

Keep dropping non-final references inline, but hand the final
deactivate_super() to nfsiod so it runs without s_umount held. The work
item lives in struct nfs_server, which cannot be freed until that final
reference is dropped, and nfsiod_workqueue is drained by nfsiod_stop()
at module unload.

Commit 324d003b0cd8 ("NFS: add nfs_sb_deactive_async to avoid
deadlock") added a similar deferral for a different deadlock. It was
reverted by commit 322b2b9032f4 ("Revert "NFS: add nfs_sb_deactive_async
to avoid deadlock"") once that deadlock was fixed in the RPC layer. The
revert did not address the s_umount recursion above.

Cc: stable@vger.kernel.org [no Fixes tag due to no clear regression point]
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/client.c           |  1 +
 fs/nfs/internal.h         |  1 +
 fs/nfs/super.c            | 28 ++++++++++++++++++++++++++--
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dbb5131375f8d..6e85fb9d9afde 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1094,6 +1094,7 @@ struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->ss_src_copies);
 
 	atomic_set(&server->active, 0);
+	INIT_WORK(&server->deactivate_work, nfs_sb_deactive_workfn);
 	atomic_long_set(&server->nr_active_delegations, 0);
 
 	server->io_stats = nfs_alloc_iostats();
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 23e9b3d1fdd51..604bc4b0c1ebb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -537,6 +537,7 @@ extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
 extern bool nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
+extern void nfs_sb_deactive_workfn(struct work_struct *work);
 extern int nfs_client_for_each_server(struct nfs_client *clp,
 				      int (*fn)(struct nfs_server *, void *),
 				      void *data);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa284fb684746..b7ba7be44cb93 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -203,12 +203,36 @@ bool nfs_sb_active(struct super_block *sb)
 }
 EXPORT_SYMBOL_GPL(nfs_sb_active);
 
+void nfs_sb_deactive_workfn(struct work_struct *work)
+{
+	struct nfs_server *server = container_of(work, struct nfs_server,
+						 deactivate_work);
+
+	/* May free @server; do not touch it after this call. */
+	deactivate_super(server->super);
+}
+
+/*
+ * Drop the superblock reference held on behalf of server->active.
+ *
+ * The final s_active reference must not be dropped synchronously: callers
+ * such as __put_nfs_open_context() can run from writeback, where
+ * __writeback_inodes_wb() already holds sb->s_umount shared, so the
+ * down_write() in deactivate_super() would self-deadlock. Non-final
+ * references are dropped inline; the final one is handed to nfsiod.
+ *
+ * The queued work owns an s_active reference until it runs, so no other
+ * caller can see s_active == 1 and try to queue it again while pending.
+ */
 void nfs_sb_deactive(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
-	if (atomic_dec_and_test(&server->active))
-		deactivate_super(sb);
+	if (!atomic_dec_and_test(&server->active))
+		return;
+	if (atomic_add_unless(&sb->s_active, -1, 1))
+		return;
+	queue_work(nfsiod_workqueue, &server->deactivate_work);
 }
 EXPORT_SYMBOL_GPL(nfs_sb_deactive);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ea0746b515ba9..c4e6f98ccd28d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -280,6 +280,7 @@ struct nfs_server {
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */
+	struct work_struct	deactivate_work; /* deferred final deactivate_super() */
 
 	/* mountd-related mount options */
 	struct sockaddr_storage	mountd_address;
-- 
2.43.0

