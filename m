Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DC553612D8
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 01:40:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787449228; cv=none; b=Z3JJ8JCkaVipVhQ9MPWEjWI/Prksdy02ErRnJQWabALQY3oGSl42MjemaIzo74NtfiO0tB2fc5VdShfuHyp3WNpZpUndapSF9Sz4HVw0+P6p79/z4UDFPhddN9MT7zQctK0BWWuP6P3Wn2pOVirJ6GRqbaNPtydQ2nnsqMPbors=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787449228; c=relaxed/simple;
	bh=ys1Tdxj8ouHjbwJtYte7q7Lwv356iCYaSxo2veTE0L4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kSn5A0J4a8MxZMI0yfBktJ26uBGq6v5GLc5zbLRr1tWTtvpONoKfXbrrrU4bs5pP8Sq0Q93CFFebPPxfholAw+VKO10A2QDYOUAb1ZMYWshpHAbNGYyhgiGupvXZSDDmUJZxa7E/Iy/RLEXiFPo4TVREBkmcvYLVFgTsQEPzyeI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jWKLFbSs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jWKLFbSs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 17C1E1F00A3E;
	Sun, 23 Aug 2026 01:40:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787449226;
	bh=+0KNAk2fNKhKwYrh1f1sgiubznbU4e6nhKrT5lNB60w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jWKLFbSsBxpVs6pZP+WLgsT/vSN77nFjRklruMzZXsR4XYJAulKU64BTtbaMK8zzU
	 aThbXWzQliIza4721fgcWXdaITifvR12EGSw/fVosMGl8kn2ITrHewc/zdlxNjh188
	 fX+HIieg7/hAUDugOWNQNDFjFOOqbZWfX5DfEZHVbpmpCnhjtqfBFAURzDRseY+bH/
	 j0tqpc/2gWwP9TUSxqpkoPKJj6EderqckzUrCQQxX7P0hSD0A0Y2WbLK9P0FgQb11i
	 pdqMYBal5V15k2pOUoHqPf5RmbwxMkE93L/xr+IDCHgj4V30jiz5VIqC0oH12VWCnZ
	 ctAG8YZrnI+NA==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 22 Aug 2026 21:40:16 -0400
Subject: [PATCH v3 2/2] lockd: Serialize block retries against host
 teardown
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260822-lockd-retry-blocked-uaf-v3-2-761661eae60c@kernel.org>
References: <20260822-lockd-retry-blocked-uaf-v3-0-761661eae60c@kernel.org>
In-Reply-To: <20260822-lockd-retry-blocked-uaf-v3-0-761661eae60c@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3267; i=cel@kernel.org;
 h=from:subject:message-id; bh=ys1Tdxj8ouHjbwJtYte7q7Lwv356iCYaSxo2veTE0L4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqik+IAzy43AbSBaHXZgEdnvVrLoTTfc+ez2zME
 vDc8tKFIgiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaopPiAAKCRAzarMzb2Z/
 l7r8D/0ckzdJ8s4gImY6Q20EVi+IAhF1z4N971RYjgviRxp6rXtO59croOqr83DwclwjiUC3GLj
 uYrZdUdiKtYvYBWpaGnS9YXIASafvTB6nNREcQpdNIXi6UiA3gcz9/Jd6HfYFYcjevGzKXs9U6h
 iWKrgHowoq0exx3GYmNJn1wFTcbrzKFThCGVURgW6V+dBhGSFv0rcrk58ZZapYlNjW5KFOnYQ3W
 U0KV5ZQVKh6tU521Hj6HMdhD6s6tFBLiOmfNfAnvkxrIwHJP6Mgp4F67/d+Xmn9sLQN+nOi1Uoi
 NSzzWfgrGU5VzFmezSWylDVpauh7uPqkC7LgfwAe1lUAkWG1Gy0pFsE7cbf9/cLLR3yKzeQn3V9
 8Dka7HonxcfTqLy5WpAN4jiQOOmpfy3tqAAVyd71uA2JGn2LIKS4TKB8K3ho3wvcm2YwzgZDu19
 2C0tLXvYhNYVTi3aFOSmfuO5zP3cN8m4vmCQUrMmCOZusquObGp3pKmT3k6Slfv2idAo22bqBFM
 8Nr1PNZxebcKodPQsn+fvt8gJ/ckHKqJrf6qcSIbLGhsIeSnlecyzaZwacXg00PxTnWpRGb6Rwk
 FrIYWTF216dJ6jUABMZnUu6U1ppm4RDi3HQDQL20ncQcNt4rcTq7nGfMTk8GWHI9AgLvjAk6mBx
 2BjkHb6FtKTNveQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nlmsvc_grant_blocked() unlinks a block from nlm_blocked before it
retries the lock, then re-inserts it. nlmsvc_traverse_blocks() skips a
block that is not on nlm_blocked, so a teardown scan that runs during a
retry passes it by and the retry puts it back. The surviving block pins
its host. lockd warns that it could not shut down the host module, and
the host outlives its network namespace.

Hold the file's f_mutex across the retry, and extend the scan's hold
across its unlink, so a scan and a retry of the same file can no longer
interleave. Drop the mutex before releasing a block reference, since
the last put takes f_mutex. A retry that waited out a scan re-checks
under nlm_blocked_lock that its block is still queued and due.

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20260819162247.2970703-1-cel@kernel.org?part=1
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/lockd/svclock.c | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 8d83283d3e21..495eacb3264f 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -295,14 +295,17 @@ void nlmsvc_traverse_blocks(struct nlm_host *host,
 	list_for_each_entry_safe(block, next, &file->f_blocks, b_flist) {
 		if (!match(block->b_host, host))
 			continue;
-		/* Do not destroy blocks that are not on
-		 * the global retry list - why? */
+		/*
+		 * nlmsvc_retry_blocked() holds f_mutex while the block
+		 * is off nlm_blocked, so a block off the list here has
+		 * been retired.
+		 */
 		if (list_empty(&block->b_list))
 			continue;
 		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
-		mutex_unlock(&file->f_mutex);
 		nlmsvc_unlink_block(block);
+		mutex_unlock(&file->f_mutex);
 		nlmsvc_release_block(block);
 		goto restart;
 	}
@@ -1012,6 +1015,8 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 {
 	unsigned long	timeout = MAX_SCHEDULE_TIMEOUT;
 	struct nlm_block *block;
+	struct nlm_file *file;
+	bool due;
 
 	spin_lock(&nlm_blocked_lock);
 	while (!list_empty(&nlm_blocked) && !svc_thread_should_stop(rqstp)) {
@@ -1026,6 +1031,25 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
 
+		/*
+		 * Hold f_mutex so nlmsvc_traverse_blocks() cannot scan
+		 * the file while the retry has the block off nlm_blocked.
+		 */
+		file = block->b_file;
+		mutex_lock(&file->f_mutex);
+		spin_lock(&nlm_blocked_lock);
+		due = !list_empty(&block->b_list) &&
+		      block->b_when != NLM_NEVER &&
+		      !time_after(block->b_when, jiffies);
+		spin_unlock(&nlm_blocked_lock);
+
+		if (!due) {
+			mutex_unlock(&file->f_mutex);
+			nlmsvc_release_block(block);
+			spin_lock(&nlm_blocked_lock);
+			continue;
+		}
+
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
 			block, block->b_when);
 		if (block->b_flags & B_QUEUED) {
@@ -1034,6 +1058,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			retry_deferred_block(block);
 		} else
 			nlmsvc_grant_blocked(block);
+		mutex_unlock(&file->f_mutex);
 		nlmsvc_release_block(block);
 		spin_lock(&nlm_blocked_lock);
 	}

-- 
2.54.0

