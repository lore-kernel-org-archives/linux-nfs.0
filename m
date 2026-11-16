Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794862522;
	b=ZVsPdyPP6UDtTDQ4DE+1+zcFYQG4r1LbJcO2Y6fy7VoTx7E+95IkXp+iz8dVyoU2v7wT
	 BADFTX0xphIjJz4ZDtRggw75UfkOn9sHUCC5C3D0A+B8KxxxslFgx2qw/hS8JjEJjOlCO
	 N4oQU4CTAODc/CyzzG7X6Nsp7q9hY/YtuowQwl5m/Pe3AJV5ksOLQVEEdjTUFpHd/VaIM
	 Y4WL/ufHIuuZEsRRS+566uswi++KCzKBlj8gXf5FLijJtDwTHNmQ45U8elGdDqUBW8UM+
	 9VhJXzMMubgYZwJ+6eaG3fn16ZGLeyjVPLTwEih47hFwOxwpyu8UhD9wFS1uEwFxscA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794862522;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DwI2ii/9rzl2rfH14mh0v0I/aohQdp2cPgnOqPznoac=;
	b=Aj7mGgVIh94FrjY6eDQ3Lf4QCzSFYrYOzmkHA3b15Fx/a5dtNGb6SPxPhWGsjECNSkjx
	 D/Z+eiVzf7zV3Fj/MLMpPO38qmkaiYVQudC958bEyCBA2LNaZ80gM/rpPnH7fXbNP7aw/
	 Zg6j6UclBbFREQcvNmXyOTJ4RCltg69cB+Vwjr2mmovVwvwCKxhL/2mWa+litZhCC/2G+
	 0dDo7iu8XghSx/pVXK00CNDLyh3nG5Dulj8cIA9AcPNKds2nH0+9oUE4a17AQbL4Qxqo3
	 pJ8Je33S5Hgz1LMeSvbxPLu3ACnrfJt9PNH0VR8TBW30eD+rpETOQG3raSVFNk8Z97w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jfewTrDd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53693606A880;
	Mon, 16 Nov 2026 20:55:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jfewTrDd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D17DC1F000C4;
	Mon, 16 Nov 2026 20:55:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794862522;
	bh=DwI2ii/9rzl2rfH14mh0v0I/aohQdp2cPgnOqPznoac=;
	h=From:Date:Subject:To:Cc;
	b=jfewTrDd/0GoIiR+sX7P3UvM5S/Xy0E5lg7MUJDqqpIvN41UfAYi8pyuIuM0JIxPJ
	 +jIbkE4v7rbgPjpfhAaP4eqUk7IXVh8xwDre8xiNJCNSYBn52V0OwubrT/XJOCksjs
	 3bcHJj3S/5tH4neAT3Fz2Ric7Zfjpe2Ge9+otQHqpVVTbQlOj5l2KpIWA55gi2s1iP
	 m6LxrPmU+wBcOZpizhXBypWYJi5RGo8C9DeNABFYtqsLONTm94bkNbRiXFIIxtZ3+p
	 N/UJhGus6+0ErAkzeBBQi+OJKkEDPkWMhmF3kNZjd1/Ss5Z3WnYNxE0khIXfNnMX9t
	 pBmirohu8FSVA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 16 Nov 2026 15:55:17 -0500
Subject: [PATCH RFC] NFS: don't wait for writeback on close() with a write
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
Message-Id: <20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MwQpAQBCA4VfRnE2ZXRRX5QFc5SAGUyztSEre3
 eb4Hf7/AWUvrFBGD3i+RGV3ARRHMCy9mxllDAaTmJyILLpJUY9+YFxlkxMTk1FRWJtyZiBUh+d
 J7v/YQlNX0L3vB18zQp1mAAAA
X-Change-ID: 20261113-nfs-space-limit-025199334e52
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4675; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=XIyjfteVFVehX4TAsx1KiW1qDqFZHHkTMsMvZPIwW1c=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq+225hs3CDFUimwAn6uN5KqaQxTvNZwaGmxgyy
 LZrpDeqkYyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavttuQAKCRAADmhBGVaC
 Fd6mD/44epiaYPzO83hC9hFwiaihB1KPHiM1P9s5tFYTVNOR8azU/1fMsZP+j+jaC3bSK+YK5kA
 P+SqpXQ5Wq9qkSkRlx3HC7EXWieSIiZrZkX3ieVOxuwJYxEjeLuo1HRotNNHIUYoMN6vIUC6wYi
 LRRlxDaVSGtPpsJoV6iY4cwCW/ZaRaCrDm9t4ZxxetJiQYiIbEeRNa5m01j6Lc1NFmlTeoCmBe8
 GRlIIAtDxmT7hKAjD2zlxwm2xkAP4uNFlGfRsQBP3AzYvbuvoRWIYnahIUTXp8nUKI+GqGb4e7C
 5RJNXsdN6zhUyeuAgUD9nr3wxV3AMkml9iCuOYJ7ikoI6NSL+1pkRRRTftva9C+vLim/xj4YLse
 gi0tf4GGEPSmuy7eu/MvU093Oaemr1AN5ICjm69OxCyqm3Z2J53IfnMwvN+7SYfrfjKshuC8v5c
 p8sbJ3p0ZwFmMinmq+zMvhczdhOIT2lCgY75Wq71RIU30tlqCXVEHPqR95CWIs9DkoRMGYkvFa7
 LR+HCY/JjXddj1URAbwHTUdWsSWataAlEaKKWMTTScEaBnhiHvQKxm+I0AZWGjaE2FUDXXYAG4e
 Za/aBPZ4IJnH1a0vZ4ybdl7MMiXmjJ2oIuabFeycs9I4TNfpz6aGQ6kDVgft1Jce5bdr+y/fv/s
 XMy1HKlR9UT9vyA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Commit 5445b1fbd123 ("NFSv4: Respect the server imposed limit on how
many changes we may cache") made close() write back, COMMIT and wait
whenever outstanding requests exceed the write delegation's
space_limit. Servers that send a limit of 0, knfsd included, therefore
get no close() benefit from write delegations, which knfsd now grants
even on write-only opens.

That flush buys nothing:

- CTO: no other client can open the file until the delegation is
  recalled, and the recall writes back our dirty data first.
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
delegation. In testing against a knfsd patched to send a nonzero
space_limit, single-threaded create/write/close went from ~92 to
~1,500 files/s.

User-visible change: ENOSPC/EDQUOT for data written just before close()
now shows up only via fsync(), not close().

For now, the pagemod_limit is still decoded but unused.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
I started looking at wiring up space_limit for nfsd's write delegations,
but afrer looking at how the client uses it, I think we're best off just
not bothering to respect it at all. Thoughts?
---
 fs/nfs/delegation.c | 25 -------------------------
 fs/nfs/delegation.h |  1 -
 fs/nfs/nfs4file.c   |  7 ++++---
 3 files changed, 4 insertions(+), 29 deletions(-)

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
index 9a434f5dda8d..04f4d8967e5b 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -122,10 +122,11 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
 		return 0;
 
 	/*
-	 * If we're holding a write delegation, then check if we're required
-	 * to flush the i/o on close. If not, then just start the i/o now.
+	 * A write delegation already provides close-to-open consistency:
+	 * no other client can open the file until it is recalled, and the
+	 * recall writes back our dirty data. Just start the i/o.
 	 */
-	if (!nfs4_delegation_flush_on_close(inode))
+	if (nfs_have_write_delegation(inode))
 		return filemap_fdatawrite(file->f_mapping);
 
 	/* Flush writes to the server and return any errors */

---
base-commit: 9d66f26fefacebfeed15de31c1123451a17ff119
change-id: 20261113-nfs-space-limit-025199334e52

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

