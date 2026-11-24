Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549755;
	b=IF/lNqs30MYGUUSmSXSddcOam+IGDKSRgfx++5g2YL3AjaEcBMM/XEvtC2EPPmnve3oF
	 U4y0KHd+L2WZbXwgE0EuZNeu7vWWXMFIW1GwMi/5NvLiA9ebasYM7oDQkfFT202v9YpgY
	 DP12WZaaeHHK2nR0mPUVnuLeU+y1vuEE11vYVnwIM+zw/mmEiJc+3bLdP5IIwX3Fp/zTz
	 oYkgjLA+tHTleN/e6MvNLYNy9DO+zcdsN7kun5w/BcZsF2B0nkSrBplMJQ+MBU4atpbOE
	 9/FaPriP6h7hQn7imlSpig5hKxWSLLddStXUyMLq9ooCfBkn4NxevwBbn/IdwSIOQ2Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549755;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Tv+WjnE1poltZNggXzTxqDJ17rxW7uEBKlv7N5rp1Ow=;
	b=H3JLCURKrGIXZtRGk7YAHbJbuHGu0apIY9JvDGIjUy58upNQfRJhcJ3b/jgplsTxYPOL
	 uvjREAKBrLyCGzjtYGML3akv7I80p5Zets2DVirTlnXOzZ8kkg4lG1pfYc18OTAdmg9Mr
	 tInnsZEeavfOGypHAWpWYSRlMOdQNDh29r0hwQIEQ4G3l2viIQKn2gLZMrCQk6XcZWzpI
	 JJ2cj2iPfbx2kbnVHtjrfEztrOlugwx1inbmNHQsNFwq9eYpvUifdRyHFGmEoCOHpNQCB
	 0w8jWRam+f+cXfLyjpc/E7KtWyZA4tdfeUSNdscr51F0KedzOD6wEgFLc56LB+RZDpw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kd4YPvk+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8D01606A680;
	Tue, 24 Nov 2026 19:49:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kd4YPvk+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DAFDE1F000D1;
	Tue, 24 Nov 2026 19:49:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549755;
	bh=Tv+WjnE1poltZNggXzTxqDJ17rxW7uEBKlv7N5rp1Ow=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kd4YPvk+Gjbb4ACwrFgSEnyOlVgOratgYnALxil65aPzY4WZIf4l6IZS1yfBhSlyX
	 r1CNmg9ZThHpK33d0HWxfNqX2BcJ2hbYQjsw1oe4XuiCM8r987EaWlvyM9cdNUbq+d
	 ZIkWPvqlsDN0We25Gj4S0JGxfytQyYXbHtJ9Xzwew6iDb6JmG3rZhaIrqmK4lV4dEV
	 dY0fycRFqs55AC7o8ZG+EYmJLZyXQEtKmyvGJKrs+M/beQApd/6vUAKtF760qQ1n1b
	 dsTqviNRmKOFDkZmnoN+B7sU06WQH4GcKBL0v3TK8eEu2KkX2KcMLAI5JAymTfmLUO
	 Pt/4eNt4DLvdA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:41 -0500
Subject: [PATCH v3 02/12] nfsd: take freeze protection before updating
 delegation timestamps
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
Message-Id: <20261124-delegts-fixes-v3-2-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=9935; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CgmlacvwyZ3nFpEhzmaY9xy1jwN/aj4m+kVauBLvixQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo1ARnptVnFQsgOxYxjFYf9zpWxquNxAjh7s
 +3YvTK58IiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNQAKCRAADmhBGVaC
 Fc27D/4obht4QkTrA1E+aCRB7PWZ23PjEadmXOMKXCaM+qZTu9unUaPOfEIAfCb2JnCIvIubbEP
 PDdcZsiZ6WQ/hse47SLJ0MUd8ClXejHfH5icROgJybr0efhKWQHxvW+27utb/tVcsyo2cWsgkrp
 77/RjlbBgT3As0QflL5lE3Xqi0ULpaJYlswqglOEqCKIMUUb/X6UhBdwC+9gtmeeEb/O2DxxRD+
 OeoerNWfQxoF4VtPdNOAkP9lOW/h57JquDje30KFHPalxxm8MA8vFQJQe94G6jtVyuOLUYM1yP2
 q03/dVQKNw88zIjr4jpfI7cICvYzgqSs8Ci+1OUKcyvZGDkpCe8o6M4qpDeUBA/Xld2wRYrEJgn
 ghsv++2qfgmzOGv44gb1vxPMQj0CRJQxzHMjxylO1C30Aws22WMhKStnjewgPIRZZePYFEp5+8J
 WK3h0c65iq71X7j/VspQ9gJyNpeLBoA6hxWlhVcibWM8nw3KboDvlc7P+/zRDK4UWmrfA+y9RsP
 mGe+fDun1DBU231oFN+QQomMlIdjU7tP2OJAkn4GvFIBLbgAoa1NaZlc57hPWXvPgFFanTgfJKs
 qX3Jj2RCWK5DrSlURA7J/X15TLKhb9UZk4l9kl8dfw5kHVjdn6meZ3TXN25qT2xpBzUMdloNaY2
 Y7ZzLshqUmSl0wQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

cb_getattr_update_times(), nfsd_update_cmtime_attr() and
nfsd4_finalize_deleg_timestamps() call notify_change() under
inode_lock(), but nothing holds freeze protection for the export's
filesystem. They can therefore modify a frozen filesystem. On ext4, a
foreign GETATTR whose CB_GETATTR finds that the holder modified the file
trips the WARN_ON() in ext4_journal_check_start(), and the inode's mtime
and ctime change while the filesystem is frozen.

The delegation's file (but see CB_GETATTR below) and the COPY or CLONE
destination are open for write, so the mount's write access is held.
Only the superblock's freeze protection is missing. Freeze protection is
taken outside inode_lock.

- cb_getattr_update_times() runs in the nfsd thread that is processing
  the GETATTR. Rather than hold the thread until the thaw,
  cb_getattr_update_times() tries for freeze protection and returns
  NFS4ERR_DELAY, so the client retries. The GETATTR's delegation
  reference doesn't keep the file open, though. A racing DELEGRETURN or
  revocation can put fi_deleg_file, so pin fi_deleg_file to keep the
  write access. Skip the update once the delegation is unhashed, because
  the delegation's return may already have finalized the times. The
  times from CB_GETATTR are older and would roll the finalized times
  back.
- nfsd_update_cmtime_attr(), from COPY and CLONE, waits for the thaw, as
  the data change that made the update necessary did.
- nfsd4_finalize_deleg_timestamps() runs when a delegation's lease is
  released. FMODE_NOCMTIME is clear by then, so nothing sets the times
  later. DELEGRETURN waits for the thaw, as the WRITEs did. The
  delegation is already unhashed, so the laundromat can't revoke it
  meanwhile. The laundromat and NFSD shutdown may not wait, so they only
  try for freeze protection, and leave the times alone with a notice
  when the filesystem is frozen.

Reported-by: Christian Brauner <brauner@kernel.org>
Closes: https://lore.kernel.org/linux-nfs/20261114-abdrehen-mahnwache-farbpalette-9c31774145cc@brauner/
Fixes: 7e8ae8486e44 ("fs/nfsd: fix update of inode attrs in CB_GETATTR")
Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Fixes: 2863bac7f49c ("nfsd: update mtime/ctime on CLONE in presense of delegated attributes")
Fixes: 4183cf383b6f ("nfsd: update mtime/ctime on COPY in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 121 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 93 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 048b2616d783..f3d1065d3448 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1453,7 +1453,32 @@ static void put_deleg_file(struct nfs4_file *fp)
 	}
 }
 
-static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct file *f)
+static void nfsd_cmtime_notice(struct inode *inode, int err)
+{
+	pr_notice_ratelimited("nfsd: Unable to update timestamps on inode %02x:%02x:%llu: %d\n",
+			      MAJOR(inode->i_sb->s_dev),
+			      MINOR(inode->i_sb->s_dev),
+			      inode->i_ino, err);
+}
+
+/* Caller holds freeze protection for @f's filesystem */
+static void __nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
+{
+	struct inode *inode = file_inode(f);
+	struct iattr attr = {
+		.ia_valid = ATTR_CTIME | ATTR_MTIME | ATTR_DELEG | flags,
+	};
+	int ret;
+
+	inode_lock(inode);
+	ret = notify_change(&nop_mnt_idmap, f->f_path.dentry, &attr, NULL);
+	inode_unlock(inode);
+	if (ret)
+		nfsd_cmtime_notice(inode, ret);
+}
+
+static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct file *f,
+					    bool may_wait)
 {
 	/* don't do anything if FMODE_NOCMTIME isn't set */
 	if ((READ_ONCE(f->f_mode) & FMODE_NOCMTIME) == 0)
@@ -1471,30 +1496,48 @@ static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct f
 	if (dp->dl_setattr)
 		return;
 
+	/*
+	 * FMODE_NOCMTIME is clear now, so nothing later sets the times.
+	 * DELEGRETURN waits for a thaw as the WRITEs did. The laundromat
+	 * and NFSD shutdown may not, so they leave the times alone while
+	 * the filesystem is frozen.
+	 */
+	if (may_wait) {
+		file_start_write(f);
+	} else if (!file_start_write_trylock(f)) {
+		nfsd_cmtime_notice(file_inode(f), -EBUSY);
+		return;
+	}
 	/* Stamp everything to "now" */
-	nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	__nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	file_end_write(f);
 }
 
-static void nfs4_unlock_deleg_lease(struct nfs4_delegation *dp)
+static void nfs4_unlock_deleg_lease(struct nfs4_delegation *dp, bool may_wait)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
 	struct nfsd_file *nf = rcu_dereference_protected(fp->fi_deleg_file, 1);
 
 	WARN_ON_ONCE(!fp->fi_delegees);
 
-	nfsd4_finalize_deleg_timestamps(dp, nf->nf_file);
+	nfsd4_finalize_deleg_timestamps(dp, nf->nf_file, may_wait);
 	kernel_setlease(nf->nf_file, F_UNLCK, NULL, (void **)&dp);
 	nfsd_fsnotify_recalc_mask(nf);
 	put_deleg_file(fp);
 }
 
-static void destroy_unhashed_deleg(struct nfs4_delegation *dp)
+static void __destroy_unhashed_deleg(struct nfs4_delegation *dp, bool may_wait)
 {
 	put_clnt_odstate(dp->dl_clnt_odstate);
-	nfs4_unlock_deleg_lease(dp);
+	nfs4_unlock_deleg_lease(dp, may_wait);
 	nfs4_put_stid(&dp->dl_stid);
 }
 
+static void destroy_unhashed_deleg(struct nfs4_delegation *dp)
+{
+	__destroy_unhashed_deleg(dp, false);
+}
+
 /**
  * nfs4_delegation_exists - Discover if this delegation already exists
  * @clp:     a pointer to the nfs4_client we're granting a delegation to
@@ -1593,7 +1636,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp, unsigned short statusmask)
 	return true;
 }
 
-static void destroy_delegation(struct nfs4_delegation *dp)
+static void destroy_delegation(struct nfs4_delegation *dp, bool may_wait)
 {
 	bool unhashed;
 	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net,
@@ -1603,7 +1646,7 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 	unhashed = unhash_delegation_locked(dp, SC_STATUS_CLOSED);
 	spin_unlock(&nn->deleg_lock);
 	if (unhashed)
-		destroy_unhashed_deleg(dp);
+		__destroy_unhashed_deleg(dp, may_wait);
 }
 
 /**
@@ -7529,7 +7572,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		f = rcu_dereference_protected(dp->dl_stid.sc_file->fi_deleg_file, 1)->nf_file;
 		if (!nfsd4_add_rdaccess_to_wrdeleg(rqstp, open, fh, stp) ||
 				!nfs4_delegation_stat(dp, currentfh, &stat)) {
-			destroy_delegation(dp);
+			destroy_delegation(dp, false);
 			nfs4_put_stid(&dp->dl_stid);
 			goto out_no_deleg;
 		}
@@ -9280,7 +9323,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto put_stateid;
 
 	trace_nfsd_deleg_return(stateid);
-	destroy_delegation(dp);
+	destroy_delegation(dp, true);
 	smp_mb__after_atomic();
 	wake_up_var(d_inode(cstate->current_fh.fh_dentry));
 put_stateid:
@@ -10755,8 +10798,11 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 {
 	struct inode *inode = d_inode(dentry);
 	struct nfs4_cb_fattr *ncf = &dp->dl_cb_fattr;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 	struct iattr attrs = { };
-	int ret;
+	struct nfsd_file *nf;
+	bool hashed;
+	int ret = 0;
 
 	if (deleg_attrs_deleg(dp->dl_type)) {
 		struct timespec64 now = current_time(inode);
@@ -10780,10 +10826,40 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 	if (!attrs.ia_valid)
 		return 0;
 
+	/*
+	 * The reference on @dp doesn't keep the delegation's file open.
+	 * A racing DELEGRETURN or revocation can put fi_deleg_file, so
+	 * pin fi_deleg_file to keep the mount's write access.
+	 */
+	rcu_read_lock();
+	nf = nfsd_file_get(rcu_dereference(fp->fi_deleg_file));
+	rcu_read_unlock();
+	if (!nf)
+		return 0;
+
+	/*
+	 * Don't hold an nfsd thread until a frozen filesystem thaws.
+	 * NFS4ERR_DELAY makes the client retry.
+	 */
+	if (!file_start_write_trylock(nf->nf_file)) {
+		nfsd_file_put(nf);
+		return -EAGAIN;
+	}
 	attrs.ia_valid |= ATTR_DELEG;
 	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
+	/*
+	 * Once @dp is unhashed, its return or revocation may already have
+	 * finalized the times under inode_lock. The CB_GETATTR times are
+	 * older and would roll the finalized times back.
+	 */
+	spin_lock(&fp->fi_lock);
+	hashed = delegation_hashed(dp);
+	spin_unlock(&fp->fi_lock);
+	if (hashed)
+		ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
 	inode_unlock(inode);
+	file_end_write(nf->nf_file);
+	nfsd_file_put(nf);
 	return ret;
 }
 
@@ -11052,25 +11128,14 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
  * @flags: any additional flags that should be updated
  *
  * Given upon opening a file delegated attributes were issues, update
- * @f attributes to current times.
+ * @f attributes to current times. Waits for a frozen filesystem to thaw,
+ * like the data change that makes this necessary.
  */
 void nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
 {
-	int ret;
-	struct inode *inode = file_inode(f);
-	struct iattr attr = {
-		.ia_valid = ATTR_CTIME | ATTR_MTIME | ATTR_DELEG | flags,
-	};
-
-	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, f->f_path.dentry, &attr, NULL);
-	inode_unlock(inode);
-	if (ret)
-		pr_notice_ratelimited("nfsd: Unable to update timestamps on "
-				      "inode %02x:%02x:%llu: %d\n",
-				      MAJOR(inode->i_sb->s_dev),
-				      MINOR(inode->i_sb->s_dev),
-				      inode->i_ino, ret);
+	file_start_write(f);
+	__nfsd_update_cmtime_attr(f, flags);
+	file_end_write(f);
 }
 
 static void

-- 
2.56.1

