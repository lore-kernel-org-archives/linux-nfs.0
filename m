Received: from mail-qv2-f12.google.com (mail-qv2-f12.google.com [74.125.230.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89D064C227C
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:16:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790950605; cv=none; b=RMw7zM1F1Zcl05erWW84YXoRhcLJw3AmS0b4SY/SqmTLgQOkJ17SqMI6S7Q3JmJOPxx0m7rx5ToIfhHtCLPUAtkxUMEaFP/+lwqKtnQmaRZvm/wo7uHE+M8GlrzXVCKqE0JYMIpMNRt7sT8a3qVVikW00Qw4fBM9kouDyoITwqk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790950605; c=relaxed/simple;
	bh=LsQWgEd56Tz3QSgmzdQMpig+HooGjzuX6Zxjb55UQHk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=E4kL5MLO4zEXAONQpk1ye2LkmWq2IfKjfb2++X6yINOYDRzZubZ8WredycVu4detKYtQ2ZcrFmZNgxcSExhDA3ECMWlKe/Qa4ld1+YPCE6QQASxZuAuwVR/K5DeCoEowNpnDM7i1YCgXxM74wVpVa5ULr/DY7Wp0XDW4kSyABn8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=CN8ydbMM; arc=none smtp.client-ip=74.125.230.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CN8ydbMM"
Received: by mail-qv2-f12.google.com with SMTP id 6a1803df08f44-91058dd77a2so928496d6.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 07:16:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790950597; x=1791555397; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=VjzYafw7a1LCq4x8vpIi6ZhRI9WsTGqku0sTiJZowPo=;
        b=CN8ydbMMsJ0M2VQCLgC3Zl2lsRFCcxbU6aDb7WrGL3wBEcvXkaXEZRruFtmf9iZZl7
         +OUjqCKzdv1ihoOZPIAOP9u+I/m4sCVROrxp27YZ+FM6T9s1wKofK+E4ZKpjtlVGWbZ1
         Xulhzm4qe6+htn8jPp7LLsTzT6AvpVlkgF5K2tdJSrWeGcDvmX/L+1JvGBPxTUzk1yDq
         yBwj24iZLlQmtkiK1DdWlkBRS6hDSRy2wdbasx4RJR4cWCr/W3Puh5VvWdbiI+z57n6/
         O8K9FRyECxbjaE7BkUO2NHwL688ePz+jYUFCnnehA4u77ky1g8DI5lV1D6JB6Ron+BEh
         qAQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790950597; x=1791555397;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=VjzYafw7a1LCq4x8vpIi6ZhRI9WsTGqku0sTiJZowPo=;
        b=aIvt23GA+AoneisStpb7up5Xgq6DyE/Zk7CvmefL2kz2fMgNiAvAKG00WhTtUToYiW
         SrrTTLKoW/oyrjJACEEGgT1n+1s7vEh0lW3cTseoH6PsR7nFw4BpVoanW4AIJYwe3GWJ
         //n+7KfHh5ZBFhHMerNzRs3jpH3cRQwcuK9YSoLkcqz+OObVunmV586C+JV3U5/au9sa
         22gIEu+ZHIfb2YqO1Ts0dyrCYjd1ZqEfx7Cci2y+ga2C+wZqNzpxTm1P5dgF2AbHCxMG
         teL3ZO5IGBC5mwhZIbknJG8riQdXUUSXa0Bne9Sq5HsyIZl1L8Y65vw6wKpNVMUgtkDn
         N41g==
X-Gm-Message-State: AFuF++mYhLw6T5mrNy73hUnJkQqZ+braYt7XLpze6s564mHZZF9OFrL4
	wHfNrCuikaQ5rUYWVRKeDK0aNwx81EYja9Hq9rFJZQLUw006JaRe5phQbOxpGq+9JOY=
X-Gm-Gg: AYBFou3dkMC1z5PQWpkf4L3YJpVNs4HtosCtUyncB/R3nUMZZDqCOTsytu6kLHGtcyG
	GfXDRVY9UBa06I2d5RtrgvatCMZQ1dLt7c1HPIEfmBGPFvBSfwfaAwNRM3DeOAausxiVkoeDty7
	QfdBr6feWNxSnCFxUqnhp/z7B5gDapr4MS5MtNhlf9QG/lEbCyOUdmHlDvHBKyCX3l1YcnjfUBb
	E10hG+p2idzvif5NFsih1Ihjhvn/ie9nckBJdPR0dqsVJzoOoMC97TfOgIx3ZWkoFZxS6jOpdEk
	FiS7JnhWoKLB7lUlm9cPNmosR6lQiaBp/yai8R5Qitsqx7fAYEtCi3SeOk97SL+h6yPAkTCgN2Q
	nnUrx3/bEhmrw8KwABQwbxoKAxsHJX8RA9SdKQh8OwnKMyVv7bNz+irNEUmxCAb549sJJ0lo47T
	xJqsqGTXzVyrvpyAYYS8cZfarHyxvuHaharZvqBOkREOnudjs7I5Od0zbuz8rz1vFCPtXpSlHlC
	6xbl5qaNCcayZeEn18cb0IJ7ZQl7qRk7A==
X-Received: by 2002:a05:6214:2c0d:b0:914:4511:9273 with SMTP id 6a1803df08f44-917c0131758mr53534466d6.31.1790950596786;
        Fri, 02 Oct 2026 07:16:36 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-917e0bcd906sm20582136d6.31.2026.10.02.07.16.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 07:16:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: make the nlm_file reference count atomic
Date: Fri,  2 Oct 2026 10:16:34 -0400
Message-ID: <6469ea852a2ad9d650a0bcdc8e2609bbaaec9f98.1790948497.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

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

