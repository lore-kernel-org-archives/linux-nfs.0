Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795460004;
	b=uYM2kSSBEnQQmHpC427sJWuRJBa8u0DwV9xMW28E1U2pJTSt0ezOZffjVnDFoR5FAq+3
	 4zpc3O4SZepQiByLVPAKRP4OHnSi49WGnYOx9UbeOxtPlMC0ycUlGJstKPukzHJ0xZO7I
	 EEQSoLZHucOeYBe+aUX/sFIEM0jQQzcBpIzoN0AmU5azIU1MzyckHJTssxbfGmSBNF/6t
	 /gYY2EJJ5HWIN++NNbHKxtO5xjcQ5s6GCnE8FsQ5ydFEZwam+u0vk8QKKFSn+evxeLzmg
	 Ke5ttvfNMyHmfTU2ncgpCulHSYkiu6uK73dJ4nu0D34vQNDdRbFHo+qi+lPglqK2cww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795460004;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=mDDjyiIlCrdAlF9PzNSdijyzOoIaEQ1PZOUyfYz+Fok=;
	b=NBi6W3bdb6PdsQbxNuQXqvZAnXi/wDXdqWGO0fjL/hPV+Dgr7V/FZSsKYdbFwG3UAEs9
	 C93zl4qWCZgA8gLpdGhkgh0ylLMOfda85diOGBB4mrECEkOP70v+pkV2IqmEXnIL8gMCf
	 GNqpV8Dy61AszJccXHXa5nf6nvmFwn1MVB6fUPLGayAkZ+QL8mAvHI7ZwLscmFqSj0n5f
	 q7WLd1uloq0h8IT7biukWkIizv7F8rbRIlt/195WGH6zbbdkz3Igz1p6xeEdSRf2cKdt/
	 QsqLAU3yQS/jtF00sasMOr4+z839LHE2CrJkWFWX0GTV9mt/ikgCvH2WM7vJYkQ24Bg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EPvyvKzN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1A80606A336;
	Mon, 23 Nov 2026 18:53:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EPvyvKzN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C449B1F000CA;
	Mon, 23 Nov 2026 18:53:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795460003;
	bh=mDDjyiIlCrdAlF9PzNSdijyzOoIaEQ1PZOUyfYz+Fok=;
	h=From:Date:Subject:To:Cc;
	b=EPvyvKzNVScw3h0xYw3W1Xw2l1RAThG+bvBWWrISfwdHOwOOknoNRWHI8OGQ5tQEz
	 KX775a2aETYFfLZLI7VwL861MUp+GlD43nb44FrEEkxmRzo5FQiSxX7WRAz0+nQd5e
	 1NyPCMZz0pdh1wKs7H3rwXHbWP7qb8dTIWcV2EmicDu8v379QhHVM19CAtZPHYI3s4
	 QsgsJY8thiz1F7z7IB+Wx9PAFkhtuXNE6UnpXBsOIb55I9luVqtIFX15dqy51NZsql
	 PnK5lAR0G9ZilFlV0iaKQb74ZUC/PvA9Tt9hz1m6ay2MEPSSu/T+0Y8ZpVYWVB/p07
	 az75WC7rDpyww==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 13:53:04 -0500
Subject: [PATCH v3] NFS: don't wait for writeback on close() with a write
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
Message-Id: <20261123-nfs-space-limit-v3-1-993945e1a526@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2XN0QqCMBTG8VeRXbfY2Zq2rnqP6GLMMz1kKpuMQ
 nz3phAUXv4/OL8zs4iBMLJLMbOAiSINfQ51KJhrbd8gpzo3k0KWAKB47yOPo3XIO3rSxIXUYIx
 SJ9SS5asxoKfXJt7uuVuK0xDe24ME6/q1yp2VgAP3zoFSGkpjq+sDQ4/dcQgNW7EkfwAp9oDMQ
 GW1E97Is7D1H7AsywcrshfA8AAAAA==
X-Change-ID: 20261113-nfs-space-limit-025199334e52
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Sagi Grimberg <sagi@grimberg.me>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5484; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=vsLokkaLV6LQUvZbyMcO8yZQxqyRa25A/X9fFWnxpTo=;
 b=kA0DAAoBAA5oQRlWghUByyZiAGsEi5yjCDeWhow0TNke0rKpTu3qmx4vdbXHfG/G3XMSgBbba
 4kCMwQAAQoAHRYhBEvA17JEcbKhhOr10wAOaEEZVoIVBQJrBIucAAoJEAAOaEEZVoIVM0cP/R05
 tZu4OOcqgrEHLqTmWDeyoXjktoMd1llxbF5uIIy3Dx4LkMy9RFbVHxk5QQtZh566K5+VRCTDjHv
 QU0q1kfVPhIaR3ekmiBS3OTu5Q6LOS6sF9SagB4B8CHXf0gfl8e2O2R9i8y5UDAqrxbkgakWFnH
 ZeW/4sNm7n/lOffM5xX5gdSXVQcg9ILPYW6nVsYxEPLG55oKBNJJ5cQbIRoOtOWRy2Mn7G4yNhj
 s52XkMk2z5/UaniSS9CBEGttg/GPbDpfgpU/tcGN+iEdAIqJNh0obZmBYCJarBrVjaDM7QmveOY
 bJAJyplo+ye4MCj0X0buUSiRivHytzS2KXcPGtAEUPIdhpqwd/iMGfsYYnnOYtvLNtpNw5UYgXC
 GaXLxmPbAUuELb7NXwtiPbaZS3B7vaMTOG5ITJUP2VXA3576O+iWYf0yEJXCAW8wwxmbAJjuQu4
 xW0C1zjoTH4iMA2bEbcYTiyEloZ6+W+RL4G9yk9dB6IK7Yf6rsgfSiJA7rM7ChlIIpKbvyjd+iK
 BgrzaTr8bLwk6q2WF8qLJ4ZjaOU0iz8UnFSeZOxv/SPdTOPnutlb0mVfKFVKplHUGEvU4DA7Fg9
 rg4JoYfMk8hbYcJWaP6KRCS/ud575ACEVYOWEWbvCP8q/0lUlgENrdLX3iyC1SoIU8//7rCGPgo
 MiI5S
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Commit 5445b1fbd123 ("NFSv4: Respect the server imposed limit on how
many changes we may cache") made close() write back, COMMIT and wait
whenever outstanding requests exceed the write delegation's
space_limit. Servers that send a limit of 0, knfsd included, therefore
get no close() benefit from write delegations, which knfsd now grants
even on write-only opens.

Dropping that flush breaks close-to-open consistency. The NFS client
returns a write delegation without waiting for writeback. Since commit
4816fdadab9f ("NFSv4: Don't use synchronous delegation recall in
exception handling"), CB_RECALL does not even start writeback.

This is a conscious decision that it's better to break CTO than block
the DELEGRETURN.

Beyond CTO, the flush buys little:

- Error reporting is pointless. close() is not required to flush, and
  most filesystems don't, so checking for writeback errors there is
  unreliable at best: the failing writeback may not have happened yet.
  Applications that care must fsync(), which this doesn't change;
  errors are still recorded in the mapping and reported there.
- RFC 8881 says only that the client "should" abide by space_limit;
  exceeding it leaves the server's behavior undefined, and knfsd just
  returns NFS4ERR_NOSPC/NFS4ERR_DQUOT on WRITE or COMMIT.

Go back to just starting writeback on close() whenever we hold a write
delegation. While we're in here, change to using filemap_flush() so the
writeback is (mostly) non-blocking.

In testing against a knfsd patched to send a nonzero space_limit,
single-threaded create/write/close went from ~92 to ~1,500 files/s.

For now, the pagemod_limit is still decoded but unused.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
One more minor change. The last version's comment was misleading. This
version should make it clear that we're aware of the potential CTO race
but consider that less harmful than blocking the DELEGRETURN.
---
Changes in v3:
- Change comment and changelog to better describe the CTO effects.
- Link to v2: https://lore.kernel.org/r/20261120-nfs-space-limit-v2-1-7a5c0f9280ad@kernel.org

Changes in v2:
- Switch to using filemap_flush() instead of filemap_fdatawrite()
- Link to v1: https://lore.kernel.org/r/20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org
---
 fs/nfs/delegation.c | 25 -------------------------
 fs/nfs/delegation.h |  1 -
 fs/nfs/nfs4file.c   | 11 +++++++----
 3 files changed, 7 insertions(+), 30 deletions(-)

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
index 9a434f5dda8d..74071c63a786 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -122,11 +122,14 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
 		return 0;
 
 	/*
-	 * If we're holding a write delegation, then check if we're required
-	 * to flush the i/o on close. If not, then just start the i/o now.
+	 * Under a write delegation, start the i/o without waiting for it.
+	 * The NFS client also sends DELEGRETURN without waiting for
+	 * writeback, so another client can open the file and read data
+	 * older than this close(). Losing close-to-open consistency is
+	 * preferred over holding the delegation until the WRITEs finish.
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

