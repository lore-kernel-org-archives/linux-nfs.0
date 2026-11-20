Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795211483;
	b=YGaxmBkaVWA/o76GLaBUDDPBLsLE3EclcmcCXEg1TLa3S9AdhPdqPsrQh3zggsrhhwkk
	 GznfBEVzPIwUDigQGB/BDZzvjMptXmA3aRHgKusJ+a+Jy73XwGFqAb3JsE3jFvGc2j0cv
	 NATwoRnBjhzNyFgZIrWLN/5ndkWQ+rE9uiYEDsCkRG/F4+MO7WFcQ5Rx3KGqweA4zzNUy
	 y7TuOHdGYS/Xk7RBQAGv85BaY30HNrilI8WmUGRotBtKev976f4CO0G/fq0r+VNZMjt4f
	 e1rnLBmsKnBXzwmN8UTvzqWBQ8qEVCGOZZFCeHnYHT/Rd/TxsWiWYhQ8Bd4qJHE9Vbg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795211483;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DtBIizMz0IPXYRMcNfrR4DnnERvzjS7Ek3KF5mPQSZ4=;
	b=pmCHQsv7BwJF/Fukj4dUhheLV3nJpIwzN8HohxPkPsWWXxQrDpYxBIh5l8NcE9ngZjkB
	 IpBC33g8X8d2/cdgmAZv2Qi/6lCk9WxMmLVIaEAQEBo7bl2cff2hbh9fTIKjpeWxBByZU
	 NUjkUpAunkeDpfc14VZxNLhyouzrCLo8nrJ13uw4YsvI3S3EcN6JfEhdJUCCckWZRBaYM
	 tOE0C2eirFZ+QQnuajYo2JZfFzySeqtCMmwacTt0hTtdAZPeVPFN7Mj8cWZoFOjqvCNbo
	 CF5w4Q/aZWL11LUG1gFeQB8rGXsprAAiT47XDLdGcMumxxPcL6718d7crIGWu1DBvow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AlJVldfp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B077606A33B;
	Fri, 20 Nov 2026 21:51:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AlJVldfp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE3F81F000CF;
	Fri, 20 Nov 2026 21:51:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795211483;
	bh=DtBIizMz0IPXYRMcNfrR4DnnERvzjS7Ek3KF5mPQSZ4=;
	h=From:Date:Subject:To:Cc;
	b=AlJVldfp7hw8ZsHFDJt/h/2hVMq2o4qhJhjqwvbmy7qmi3feoChgupwXnmEOzr0zz
	 Y/uSb8nbjdeSu2OpyvZGKsKLm+kD2DeRcfdjZO+PaDRD7HVIQHWk/AcXfX4WJRMns8
	 p9mwXSqT1X0vVBsplQwSiWLrlDHNK91uDEOAwOzS1cOE14cZKyg1HGbeJIG8lIbhkN
	 g73mSATTNUntZaCpjYZkA+g8cFnCuXUJZluQyF1bVWe6qHM4nnJeG15EEMe2lYPdAK
	 uVY24s6FgkB8nb2ixpCoSyqHf3zS0eb3RBa/nOkp7pxNgXilbLdTl+D4Meov7+Gl6s
	 3RzfGiz2iqvFA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 13:51:17 -0800
Subject: [PATCH v2] NFS: don't wait for writeback on close() with a write
 delegation
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261120-nfs-space-limit-v2-1-7a5c0f9280ad@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2WNQQrCMBBFr1Jm7UgnMZG68h7SRYiTdrCmJSlFK
 b27seDK5Xvw318hcxLOcKlWSLxIljEWUIcKfO9ixyj3wqBqZYlIYwwZ8+Q84yBPmbFWhppG6xM
 bBWU1JQ7y2ou3tnAveR7Tez9Y6Gt/LfvXWggJg/ektSHbuPP1wSnycBxTB+22bR8aWwkirwAAA
 A==
X-Change-ID: 20261113-nfs-space-limit-025199334e52
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Sagi Grimberg <sagi@grimberg.me>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5470; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=c2QWmwiTs/RxgE3GvnBF6ZiI0YLRaX6tm6szN1rqEsI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAMDa3wKlv6MUbAEl5DwBXFZ5Mxm0ekot+q9wI
 HtUhzyl8VOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawDA2gAKCRAADmhBGVaC
 FcRnEACVIAGD/jDhgZIqm+2QdUqK+ul2yKf7pGsUFF6VnntuDzsZ+dj6DZB2pmAsyAD2RfHU8TZ
 xsL6bwg+jYH7ovqs/3Zet+al8S+sEBVVhPmSlsgapna3TexMizhbEt3TUWn44sVTWGxUzril5zJ
 NQFvbQwRQIhb5nXTqkKPYvqFjSH+IfQUo8gwZYH2YF8omeqp0U6AsLVe80ZyDqYPo8tPN2C4sN5
 Hxk27GND+MqB7rWMZyJFouhHoCb5tHHzZeQubPCZrS+okckZ4B1jvDcPJBGBvXAe4s60WWqWGw7
 VWiwOf96Mdtr4+/dNmA+0Z4tCtimqjTWfRlR+MWY+CJzlPvHpOZUuIYifwljGZjGPvvaNbc2H3C
 y90iG4HK8KXdOJMlGeUcsl/ShyJyiNjdPB4Vm0RFISSIXZNvZpvER8TRimiOUy/iIS1j9ZIFmSH
 bnK2fXwZDkiQwKbJCxQeOGqj+J5qPp7IxZ6/l984KESvAAEjqW14AIvxGXNSRj27klFKax07Taa
 YpUOAssFPtBKhH6oKQdam8Vp1jAYGA4JFq+hZPM072omE9/SxCsruJiU6zQvM0PdGkQX62uNE2b
 kssi5Dyda0RVtfD0gCLbSCOpzbHpoeGG39PMweDY0TC+HXfA5+GI9+BxthyH7TiGQJqx/A+cGvt
 Zqlb7w4aQILHIug==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Commit 5445b1fbd123 ("NFSv4: Respect the server imposed limit on how
many changes we may cache") made close() write back, COMMIT and wait
whenever outstanding requests exceed the write delegation's
space_limit. Servers that send a limit of 0, knfsd included, therefore
get no close() benefit from write delegations, which knfsd now grants
even on write-only opens.

That flush is the wrong tool:

- CTO: no other client can open the file until the delegation is
  recalled. The recall doesn't flush before DELEGRETURN, though: since
  commit 4816fdadab9f ("NFSv4: Don't use synchronous delegation recall
  in exception handling") CB_RECALL doesn't even start writeback, and
  the state manager can't wait for it. WRITEs still in flight after
  close() can thus race with another client's OPEN. That gap already
  exists for servers that send a nonzero space_limit, and needs fixing
  in the recall path, not with a flush on every close().
- Error reporting is all that's left, and it's pointless. close() is
  not required to flush, and most filesystems don't, so checking for
  writeback errors there is unreliable at best: the failing writeback
  may not have happened yet. Applications that care must fsync(),
  which this doesn't change; errors are still recorded in the mapping
  and reported there.
- RFC 8881 says only that the client "should" abide by space_limit;
  exceeding it leaves the server's behavior undefined, and knfsd just
  returns NFS4ERR_NOSPC/NFS4ERR_DQUOT on WRITE or COMMIT.

Go back to just starting writeback on close() whenever we hold a write
delegation. While we're in here, change to using filemap_flush() so the
writeback is (mostly) non-blocking.

In testing against a knfsd patched to send a nonzero space_limit,
single-threaded create/write/close went from ~92 to ~1,500 files/s.

User-visible change: ENOSPC/EDQUOT for data written just before close()
now shows up only via fsync(), not close().

For now, the pagemod_limit is still decoded but unused.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Only a small change from the RFC, to incorporate Trond's suggestion to
switch to filemap_flush(). Also Cc'ing Sagi since he raised this issue
with Chuck and I a couple of years ago.
---
Changes in v2:
- Switch to using filemap_flush() instead of filemap_fdatawrite()
- Link to v1: https://lore.kernel.org/r/20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org
---
 fs/nfs/delegation.c | 25 -------------------------
 fs/nfs/delegation.h |  1 -
 fs/nfs/nfs4file.c   |  9 +++++----
 3 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ad774316f716..3a141d5ee0bd 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -1587,31 +1587,6 @@ bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags,
 	return ret;
 }
 
-/**
- * nfs4_delegation_flush_on_close - Check if we must flush file on close
- * @inode: inode to check
- *
- * This function checks the number of outstanding writes to the file
- * against the delegation 'space_limit' field to see if
- * the spec requires us to flush the file on close.
- */
-bool nfs4_delegation_flush_on_close(const struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_delegation *delegation;
-	bool ret = true;
-
-	rcu_read_lock();
-	delegation = rcu_dereference(nfsi->delegation);
-	if (delegation == NULL || !(delegation->type & FMODE_WRITE))
-		goto out;
-	if (atomic_long_read(&nfsi->nrequests) < delegation->pagemod_limit)
-		ret = false;
-out:
-	rcu_read_unlock();
-	return ret;
-}
-
 int nfs4_delegation_hash_alloc(struct nfs_server *server)
 {
 	int delegation_buckets, i;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index fba4699952b8..75f0edde65ea 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -83,7 +83,6 @@ void nfs_put_delegation(struct nfs_delegation *delegation);
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t type, int flags);
 int nfs4_check_delegation(struct inode *inode, fmode_t type);
-bool nfs4_delegation_flush_on_close(const struct inode *inode);
 void nfs_inode_find_delegation_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid);
 void nfs4_inode_make_writeable(struct inode *inode);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 9a434f5dda8d..6ff82e7edbf8 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -122,11 +122,12 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
 		return 0;
 
 	/*
-	 * If we're holding a write delegation, then check if we're required
-	 * to flush the i/o on close. If not, then just start the i/o now.
+	 * A write delegation already provides close-to-open consistency:
+	 * no other client can open the file until it is recalled, and the
+	 * recall writes back our dirty data. Just start the i/o.
 	 */
-	if (!nfs4_delegation_flush_on_close(inode))
-		return filemap_fdatawrite(file->f_mapping);
+	if (nfs_have_write_delegation(inode))
+		return filemap_flush(file->f_mapping);
 
 	/* Flush writes to the server and return any errors */
 	since = filemap_sample_wb_err(file->f_mapping);

---
base-commit: 9d66f26fefacebfeed15de31c1123451a17ff119
change-id: 20261113-nfs-space-limit-025199334e52

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

