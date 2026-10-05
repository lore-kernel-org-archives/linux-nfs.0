Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83B2548B386
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 13:44:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791207851; cv=none; b=bO/XXmsiy1L6Qlkh74uWFbr8PEPnB+nA1zhzzfOaa1T2gg2Xk8WOYD/kkvkqXmGiIpU2+KOkEFtX1QspCLhdFWixIqlAECYWqt+H9266ef+k6FZSGBm7GkQ1jhPykxhClxcD7an0zziW5N8xevc4F9bLX2VMuUUGlcQXP83oLcc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791207851; c=relaxed/simple;
	bh=KGq8d8I0MUd7m+3sehJDv+6B3yXPQspA6uppXrCVPAQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=s9zY2ZYrixhaeH7biVFGhcqIk+/Z46+WWDiFbBMhtuWZK9qcpP6uycu2HF9P7N5YbPh1aoGr7g59DOlbVFUqp0KVSsPMXgKq2mwr0cLB6PmFNfLuqrVvW4pIpwNKw4y1jXZBdwz/nPj7g4IaLBOnEIl/CTXzjvVjp3t13GN5DYI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=CAdWRiFd; arc=none smtp.client-ip=209.85.160.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CAdWRiFd"
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-48ed460be50so992567fac.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2026 06:44:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791207848; x=1791812648; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=lzTJprDeN4VROcN1BZ0KyJDiQEqmFFVET4Lj+r/HK+E=;
        b=CAdWRiFdqOy8nNof2RCoxDB1oTAaguvwQ1YPAzTEka2ikI0Zm4Wh6mWiiZWKHR8Vxc
         mG4bu5vCIkG29FpD+f/wYMjstbeyNYkTDtkmFuBrDgMj4q9niCE4vC4CdghPv6Ldol7r
         eMmtlgyo7NH901WdK4kxzfqz0kiPYhd/E8T51Dwexh4cNHIPEiV5wJmDVbZrep16jVxQ
         qevPRunHBK+/lBvUbE8JOf+FeFonDIwA2/YRglNxLuvEkGW6EzwIFljHcnYqnTilxgHp
         +aHCLGr+cqS7w78aDTMWAJGgN2xabtKve2emC17+J/3CdM1hLMyHjD1Lgo15L74MvY1w
         GLjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791207848; x=1791812648;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lzTJprDeN4VROcN1BZ0KyJDiQEqmFFVET4Lj+r/HK+E=;
        b=VSVElGWtOGePi/kvI6V6iq+BKYQMOB7dHOADQ6dC0DOeozyRwiZy4+Ow0WaFykmdt5
         pLkgtWRPQCNx6AXBIJO/Y+qwv/tq4fy5bxqy+AmmTb5MRrbizue9QAu6fqmdMJ3/7gvc
         MDkyyVOFz46ZszerXq4LpAFUc/V3WwLAQdM/XaXES4WXMmR75XgLPfOPF8bXWGOtJYeC
         8MGcB1DhqrweTPO3i7kxcUp0mjr8FW4PUGf95TLzKx2bSX184yRY70NJ6olWR5ILVBmq
         regzMdpmbMCZ4ndwZYSEEYjEp/cOACdqd1SCdCklhqz6LsydLoxQ8SZnOnedxJKZBeN8
         DhHA==
X-Gm-Message-State: AFq9FYIr5AUq1XmOWreRMnpZeBnVZLzLAnfpxIDLqsCFm+FOn2y/8SpG
	Wig1FoEPAch2ihWUN+4ggwkbe969RZz9LwCGSPVsJ7iRr/qMi1GWlILs2wr6hJC+uDU=
X-Gm-Gg: AYBFou3ZvGmnE7y3uZ06Yo0k8EsS+Lsaj3MBzJaauUSx/Sk6bHBHvyrZohfALNB5lis
	CWaW6IoF0ApPnn8bSDNYEt0ID4e9mSB8wBmFYFYwGteTkWdY7uhQLLa48J5sfcAJ26XEwPKKwiR
	nYP63Dxqw60UtTRzSuaCtRp+K1VtOYOGvW0jKL5GZz9Ow7vgZcGh4MmY770MynQKdGOxSGEpHck
	3hBrRX0YZwUlh3hbazpQu4sfjtn0P4RCwuy4KOHww/adOe1zNYqajGCJSBNEMGuF+06Y7hVK1BO
	WgZhLMxQXATk6LTZYif2Ap8mbW+YfN/ykPBzdH6lEhOzSSCy3+Jzu7DfkUXFzroPPusMsGtMz2I
	N5TVNfdzKUOsmkAYK6P5Ckjh+K96NGwADEbbl8jyUwnczXS8nLFHBAFl3ZdvtTeYjOwe5nwFaTz
	+cge+Qvp07W9WTv2kzxpPGY0LnIIkh3YtW+RUbJ82+QpOkh93ELnSA0T16RB+7mtVWlIM4fbo20
	P2K7Cvao+fIV7TRqItCGvSIU1BIm5elOtKXTPQqVQ==
X-Received: by 2002:a05:6870:80c9:b0:497:4b0a:61fa with SMTP id 586e51a60fabf-49e3a8a24c4mr5926899fac.28.1791207847927;
        Mon, 05 Oct 2026 06:44:07 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-49e16a4ecacsm9269274fac.1.2026.10.05.06.44.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 06:44:07 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] lockd: make the nlm_file reference count atomic
Date: Mon,  5 Oct 2026 09:44:05 -0400
Message-ID: <3caeffa75660e6d9a9e0646f38263157b3b6d56d.1790963561.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

nlmsvc_create_block() takes its reference on the nlm_file with
file->f_count++ while holding only that file's f_mutex.  Every other
update of f_count is made under nlm_file_mutex, and can come from
another task: nlm_traverse_files() pins each file it visits and runs
from lockd_down() in any network namespace and from nfsd's unlock_ip and
unlock_filesystem, and nlm_release_file() runs from the release of a
GRANTED callback.  An update can be lost, and the count then reaches
zero while a reference is still held:

  BUG: KASAN: slab-use-after-free in nlm_release_file+0x504/0x7e8 [lockd]
  Read of size 4 at addr ffff0000a738f6c4 by task lockd/11494

  Call trace:
   nlm_release_file+0x504/0x7e8 [lockd]
   nlm4svc_do_lock+0x2bc/0x468 [lockd]
   nlm4svc_proc_lock+0x1c/0x30 [lockd]
   nlmsvc_dispatch+0xa8/0x200 [lockd]
   svc_process_common+0xb08/0x1b80 [sunrpc]
   svc_process+0x424/0xb70 [sunrpc]
   svc_recv+0x1680/0x2408 [sunrpc]
   lockd+0x148/0x288 [lockd]

  Allocated by task 10651:
   nlm_lookup_file+0x2a4/0x5c0 [lockd]
   nlm4svc_lookup_file.constprop.0+0x4dc/0x848 [lockd]
   nlm4svc_do_lock+0x284/0x468 [lockd]
   nlm4svc_proc_lock+0x1c/0x30 [lockd]

  Freed by task 11494:
   nlm_release_file+0x46c/0x7e8 [lockd]
   nlmsvc_free_block+0x1a4/0x298 [lockd]
   nlmsvc_lock+0x2cc/0x1a80 [lockd]
   nlm4svc_do_lock+0x324/0x468 [lockd]
   nlm4svc_proc_lock+0x1c/0x30 [lockd]

That is v7.2 with commit 526c49cff3f7 ("lockd: pin next file across
nlm_inspect_file lock-drop") applied, with NLM lock and unlock traffic
in one network namespace while a second namespace mounts and unmounts
NFSv3, which shuts lockd down in that namespace each time.

Make f_count an atomic_t.  Files are still only freed under
nlm_file_mutex, and nlmsvc_create_block() increments a count that its
caller already holds.  It is an atomic_t rather than a refcount_t
because the count rests at zero while only locks hold the file in the
table.

Fixes: d9f6eb75d490 ("lockd: blocks should hold a reference to the nlm_file")
Cc: <stable@vger.kernel.org> # 526c49cff3f7: lockd: pin next file across nlm_inspect_file lock-drop
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
Changes in v2:
 - no code change; sent with an in-body From so the author matches the
   Signed-off-by
 v1: https://lore.kernel.org/linux-nfs/6469ea852a2ad9d650a0bcdc8e2609bbaaec9f98.1790948497.git.bcodding@hammerspace.com/

 fs/lockd/lockd.h   |  2 +-
 fs/lockd/svclock.c |  2 +-
 fs/lockd/svcsubs.c | 18 ++++++++++--------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/lockd.h b/fs/lockd/lockd.h
index 14cc952fe81a..55958e490ee4 100644
--- a/fs/lockd/lockd.h
+++ b/fs/lockd/lockd.h
@@ -201,7 +201,7 @@ struct nlm_file {
 	struct lockd_share *	f_shares;	/* DOS shares */
 	struct list_head	f_blocks;	/* blocked locks */
 	unsigned int		f_locks;	/* guesstimate # of locks */
-	unsigned int		f_count;	/* reference count */
+	atomic_t		f_count;	/* reference count */
 	struct mutex		f_mutex;	/* avoid concurrent access */
 };
 
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 495eacb3264f..0a6540409ef8 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -221,7 +221,7 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
 	block->b_daemon = rqstp->rq_server;
 	block->b_host   = host;
 	block->b_file   = file;
-	file->f_count++;
+	atomic_inc(&file->f_count);
 
 	/* Add to file's list of blocks */
 	list_add(&block->b_flist, &file->f_blocks);
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index ffab76278bb2..147852e8c3be 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -186,9 +186,10 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 	hlist_add_head(&file->f_list, &nlm_files[hash]);
 
 found:
-	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
+	dprintk("lockd: found file %p (count %d)\n", file,
+		atomic_read(&file->f_count));
 	*result = file;
-	file->f_count++;
+	atomic_inc(&file->f_count);
 
 out_unlock:
 	mutex_unlock(&nlm_file_mutex);
@@ -333,7 +334,8 @@ nlm_file_inuse(struct nlm_file *file)
 	struct file_lock *fl;
 	struct file_lock_context *flctx = locks_inode_context(inode);
 
-	if (file->f_count || !list_empty(&file->f_blocks) || file->f_shares)
+	if (atomic_read(&file->f_count) || !list_empty(&file->f_blocks) ||
+	    file->f_shares)
 		return 1;
 
 	if (flctx && !list_empty_careful(&flctx->flc_posix)) {
@@ -371,7 +373,7 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match,
 		file = hlist_entry_safe(nlm_files[i].first,
 					struct nlm_file, f_list);
 		if (file)
-			file->f_count++;
+			atomic_inc(&file->f_count);
 		while (file) {
 			/*
 			 * Pin the next neighbour before we drop the mutex
@@ -384,7 +386,7 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match,
 			next = hlist_entry_safe(file->f_list.next,
 						struct nlm_file, f_list);
 			if (next)
-				next->f_count++;
+				atomic_inc(&next->f_count);
 
 			if (!is_failover_file || is_failover_file(data, file)) {
 				mutex_unlock(&nlm_file_mutex);
@@ -395,7 +397,7 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match,
 				mutex_lock(&nlm_file_mutex);
 			}
 
-			file->f_count--;
+			atomic_dec(&file->f_count);
 			nlm_file_release(file);
 			file = next;
 		}
@@ -417,13 +419,13 @@ void
 nlm_release_file(struct nlm_file *file)
 {
 	dprintk("lockd: nlm_release_file(%p, ct = %d)\n",
-				file, file->f_count);
+				file, atomic_read(&file->f_count));
 
 	/* Lock file table */
 	mutex_lock(&nlm_file_mutex);
 
 	/* If there are no more locks etc, delete the file */
-	if (--file->f_count == 0 && !nlm_file_inuse(file))
+	if (atomic_dec_and_test(&file->f_count) && !nlm_file_inuse(file))
 		nlm_delete_file(file);
 
 	mutex_unlock(&nlm_file_mutex);
-- 
2.53.0

