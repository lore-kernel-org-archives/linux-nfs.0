Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE2FF3859DC
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 20:54:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791752095; cv=none; b=Q4+gQ68KUOM+3++oWKUUN+qpQKNv1skKmhmVK803tbw+H70f+loDugoyKStVcICbCGPTWxwQRrLZg/Bg4mQVBxs6uPNxeUZixmKBOXOEd+yv+smVpRf3CdUcUbwKWrdYp1sSiJtSFC/A9lDOEZ97j7CeSyrTT0mp/yDdFPysKCU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791752095; c=relaxed/simple;
	bh=cSuMDgjQKJFhCz3V4GbTzRq2AlUYRioY1gYaYHTxJz4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=VbLk8MVz/OmNfupbo34Osy/GLXmd3zXQrI8dhQUdFvdBtVAa7bXWXi5Mk/pCxOPnME51NlM4zrUrfod//IJGjCVyneWs/03LoovspbP/mG9xFeBUuW5uDz8sRWOjpN56FqxUm/IqByvI6sCSCv31zdbFc1JHTLYujMhwdJESPqY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=V5cCXWmx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="V5cCXWmx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E5C931F0089B;
	Sun, 11 Oct 2026 20:54:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791752092;
	bh=r8htZRCP/7hsWXK6auw4tnKhwejGXw7hg9XwXTQEh80=;
	h=From:To:Cc:Subject:Date;
	b=V5cCXWmxYGLpzqgqodThB249wDYcbWMi1KSQdW/YhOB7JRcKEv7Z0jpfNXWq8UbYU
	 DFmu//aO68AZGPmyV9hdKdEbG4M8ZVtn+eM0gAgCh00GBYyVGJq4Gcb6N3HXPzMIPV
	 FC9GkmX+ax/V5p7F6lqR8qmqsJ+nAxIFCI4GpByCHe1zxSWjmwdA7NiuVp5nPdG7Ps
	 W5n8o3DlMJAbSg+kxGVJZdBodCWnTKATddLK2QkjgwMWWMvHKwoVm7JyoDdKqSCaJt
	 DBQNUOhEygR5mHXmUdIsYsXfnYw3O9iOCRdhwStWIDboFgr9K//0uK2oBXboBXFk8P
	 nY+4LtII5T++A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: Christian Brauner <brauner@kernel.org>,
	<linux-nfs@vger.kernel.org>
Subject: [PATCH v1] NFSD: Take a file unhashed during construction back off the LRU
Date: Sun, 11 Oct 2026 16:54:51 -0400
Message-ID: <20261011205451.96638-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_file_do_acquire() inserts a new nfsd_file into the hash table,
opens the file, and only then adds the entry to the LRU. In between,
nfsd_file_cond_queue() can unhash the entry from any caller that
tests GC but not PENDING, such as nfsd_file_queue_for_close(), with
nothing on the LRU to remove. The constructor then calls
nfsd_file_lru_add(), so the entry sits on the LRU with HASHED clear.

The first laundrette pass after the caller's nfsd_file_put() reaps
the entry. nfsd_file_cache_shutdown_net() purges through the hash
table and misses the entry. With one net namespace, if
nfsd_file_cache_shutdown() runs before that laundrette pass,
list_lru_destroy() runs with the entry still linked, the struct file
stays open, and the export cannot be unmounted. With more than one
net namespace, the entry can outlive its namespace, because nf_net
does not hold a reference. A later laundrette pass then follows a
dangling nf_net pointer in nfsd_file_dispose_list_delayed().

A local F_SETLEASE, or nfsd_close_cached_files() on an NFS re-export,
reaches a file under construction when it races an open of the same
inode on another nfsd thread. A process that repeatedly takes and
releases a read lease on an exported file, while an NFSv3 client
reads that file, hits the window on three reads out of four. Before
commit 56221b42d717 ("nfsd: filecache: don't repeatedly add/remove
files on the lru list"), only nfsd_file_put() added an entry to the
LRU, after testing HASHED.

Test HASHED again after the LRU add. When the bit is clear, take the
entry off the LRU and drop the LRU's reference, so the caller's
nfsd_file_put() frees it.

Fixes: 56221b42d717 ("nfsd: filecache: don't repeatedly add/remove files on the lru list")
Assisted-by: https://github.com/brauner/linux-formal
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/filecache.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 42bd8c7859cf..ddca3d580019 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1311,8 +1311,17 @@ nfsd_file_do_acquire(struct svc_rqst *rqstp, struct net *net,
 	 */
 	if (status != nfs_ok || inode->i_nlink == 0)
 		nfsd_file_unhash(nf);
-	else if (want_gc)
+	else if (want_gc) {
 		nfsd_file_lru_add(nf);
+		/*
+		 * nfsd_file_cond_queue() can unhash nf before the LRU add.
+		 * Only one LRU removal succeeds, and that one drops the LRU
+		 * reference.
+		 */
+		if (!test_bit(NFSD_FILE_HASHED, &nf->nf_flags) &&
+		    nfsd_file_lru_remove(nf))
+			refcount_dec(&nf->nf_ref);
+	}
 
 	clear_and_wake_up_bit(NFSD_FILE_PENDING, &nf->nf_flags);
 	if (status == nfs_ok)
-- 
2.54.0

