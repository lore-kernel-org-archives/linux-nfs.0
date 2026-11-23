Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438762;
	b=0heqIi1vaGxUj6k/cIjO4/SiTZgq1N2P251Tn+97iSMYFtmNYv/B5sFQq21XGGLyCl7n
	 P91neC+0CqpV26H1cOSYKdtOAPGMm3UTh55PzabuOIf4Cnll+SVo/9UbQh1xxM5golzwK
	 Zip82JkuVEKcumUsSGLio0tXgqRkHf/kYyi99Gqu+IZ+Jw1bLAiaXdezK3lWtG6G5GvZV
	 jNjeXfqdP8JfgAyhBPfdwSsre/SKPwzg+n5HiUjsaWSy/MTA5oxRRyUz61p7Ocejpmivv
	 TGTYrTSPPYkKm0CZkxEWh8Dw1VAdYwC4sDB3RNDC3rsa5Kff/0DfAhqCzS/EG5bRlVg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438762;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=KnepBTJjo66IEmpzQ3QeX21M0rSVtxeua0VXtDBHJaI=;
	b=dT16OBcRNyIXzozYq/c4WzmRswd3BLdVFxyy+nCtdFUkaAvjiKCOmpY0VO5pp2JpwcW1
	 RFuyTD7ioq3aahzXJGMpkXV5PIDy1lorI9QR5X7H/3kAUnqeen22iuoa8u06QW6VU0VII
	 Epo/yiwd+TbePPUOWU9U/iliZUkoYyYtmZacIjv3emWLpZu6RKkM05cLPhv/K1aWUV+xS
	 +WtTQAyc51ATPk+IXuqwHvbS082hP7pdBBO8Jf2/5q4H+X7kVpXsa2+kcVQMNcXv9HC21
	 1gXR0aQMzZDEWx3qCasI4+7MjSeRqIwzy2k+xe0zuN00857zHLW3lcyKmIqyjFdkkPA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DDVF64bA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF65E606A337;
	Mon, 23 Nov 2026 12:59:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DDVF64bA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 388861F000C4;
	Mon, 23 Nov 2026 12:59:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438761;
	bh=KnepBTJjo66IEmpzQ3QeX21M0rSVtxeua0VXtDBHJaI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DDVF64bAzf0gv4+09ejfDuzDmOyvNq5lSWuY7CyRpJALYyk+2BTgydscM5/ahlH4V
	 RpRySJ7S1pw9AumG/o0+lpo4TFT5DEuyP1GzdZ01Icd31NvzskAkHhzReZ4CCnI0FC
	 G7egb1EfG9biOl+T9JoNKGHv2pt8XB3XTXxkRrQzRbF1UhLmyVgbv2OnyA1HC7cNqa
	 LVwy0i/lPfJ/1QUD3p1zlg6ThgUgM64CnqnHMN1zJ6qSYXu5aQB5qQ9781u56oaPP3
	 IMY7R+kDavZdfte/D2NE20LCfYiIbyDC7lI4ijj24vU7Nb5OUQu6VymgktPmmyHTKb
	 nwrpXOj9+53uw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:05 -0800
Subject: [PATCH v2 02/11] nfsd: take freeze protection before updating
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
Message-Id: <20261123-delegts-fixes-v2-2-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=7103; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=siM3Fruva1HZQ0wkK2WCrB2jPAhnxOtCg9CqBlLhuQA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDikAGGUxMWGZNmfpfbfiLnRmYgeu0PtgZWg1
 2vFOHTzLu+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pAAKCRAADmhBGVaC
 FawpD/93/qWOQ4fw8r0MoB6J07piVEHcjj0OfVez6Q2ESF9a1zKWVlKrE0CC8F+FJX74fMlapQ7
 09RxREjhc2uMRzpJ8foWB7AV5AN1aevHDE18UjaPIjgOvfr0AdJIXdrU/JIoGH3rsum4ZXoZ2AZ
 TbfqS2tbvFEFjD4vLsspW62GdKpo2QBTAVA3P0cawPX68co4jKJSCPDKMx2v6uI5cqnAPGyDdAM
 j+L7pC76BULnXgM21fhGPHuS8T6DaBv/DHoVQjbIj8bsfxakdEPfLtZDUe75+gXHiI3yesm6+Pk
 05qbiJheu+MR6C/f/oYLxi9x0ubcG8gqpJWOVMJXUlV63KP9LvbtHEl6ZZyYnS9B9aOlZfd1ytE
 iNp66j1xUr/gu7K+T97J6MJwV1UNvrrAKSmRCkKarVcsiahYupCBBo1YcakYhkFqrdURFPkeVvm
 RmiOuXHG98yHgww2WrlF4cHGebgCUDS3QyPKGOfjgA4vCtwrsQ7MnTiMXGKy6Z3rfW1OfTk/36M
 yQIhkZ9j6ISSNvNwqX0PUq70FyuFT0H6zWdPP4oa754hZR6d0Bn6LeaboRF4rraygkAYHbqv+tt
 x7ZW0IrdyOrfZwWTiPlo+OJIyCV6jvNUnfA+owu4Uf4wQmMKEtbU9SUqwTbW7nGzV05IHTD38TB
 WXgU/Yi1TM6ToUw==
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
  released, including from the laundromat and during NFSD shutdown.
  Neither path may wait for a thaw, so nfsd4_finalize_deleg_timestamps()
  only tries for freeze protection, and leaves the times alone with a
  notice when the filesystem is frozen.

Reported-by: Christian Brauner <brauner@kernel.org>
Closes: https://lore.kernel.org/linux-nfs/20261114-abdrehen-mahnwache-farbpalette-9c31774145cc@brauner/
Fixes: 7e8ae8486e44 ("fs/nfsd: fix update of inode attrs in CB_GETATTR")
Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Fixes: 2863bac7f49c ("nfsd: update mtime/ctime on CLONE in presense of delegated attributes")
Fixes: 4183cf383b6f ("nfsd: update mtime/ctime on COPY in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 94 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 75 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 048b2616d783..c4c0f6cfa14d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1453,6 +1453,30 @@ static void put_deleg_file(struct nfs4_file *fp)
 	}
 }
 
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
 static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct file *f)
 {
 	/* don't do anything if FMODE_NOCMTIME isn't set */
@@ -1471,8 +1495,18 @@ static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct f
 	if (dp->dl_setattr)
 		return;
 
+	/*
+	 * This function also runs from the laundromat and from NFSD
+	 * shutdown. Neither path may wait for a frozen filesystem to
+	 * thaw, so leave the times alone while the filesystem is frozen.
+	 */
+	if (!file_start_write_trylock(f)) {
+		nfsd_cmtime_notice(file_inode(f), -EBUSY);
+		return;
+	}
 	/* Stamp everything to "now" */
-	nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	__nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	file_end_write(f);
 }
 
 static void nfs4_unlock_deleg_lease(struct nfs4_delegation *dp)
@@ -10755,8 +10789,11 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
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
@@ -10780,10 +10817,40 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
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
 
@@ -11052,25 +11119,14 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
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

