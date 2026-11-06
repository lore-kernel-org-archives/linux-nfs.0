Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997653;
	b=lpWL1MGu7tb+xJ+sIRIxZs7quEcWOOuQdJ//73BmuzPYOi9p4D0xwC6S4MeMIt2RUJKj
	 AfF0gOZAWcIgigUDlp0bGZsRM0XyQl4sAa5+dE1AfhnvVp7mW2iE/XBq5AVvxhKNOSzQ4
	 wY2NhtByrPDsU483NJbdoOSoP/q+ySdERBn9CVzR9w0+Hr9IEPJhF+nliEVmxBnE/5Y3z
	 VygLflYoQ/3ifizIVWnDMYm0nNl3dixUGxhrA9mXgpXBPL8i3MzwrGVsxgPIzeme5Zk0r
	 HczKnrdy5aMS1VENP0eqoOOmUT7JSNGygjfVsL2Lu59+57Bcplowt7I7EyyUnfJiOFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997653;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=dDcga8x1t2Mz0U84bROvlxnSmjwl5bpBj7aWQNiL0h0=;
	b=g9PRpawHydxrV8Z0Fqn8F5pRL8Ho0zclY+NVyCCF7qaeIhpKoHha0eM454/dhAPEXD8D
	 yQu7b35LO3kb5BB8jUz6y8pUZGvCg+7IOi+kZY9RVuezTVKtWXDKsw+Xfy/DoNX8C+ab5
	 tmaH2CvDn21eT1tdJE5h/QvDN5FsJk36N/3BwQJ0KmhMVPw1lEnQToa9xzRS0DepNv/aa
	 V/LE+6ugJ0DmI/q4OWw6rjngfG5Dlfa3K7v1FfwIoLIu6CeA+zinVFpN+/S+Fkqah4Dm0
	 KjwYbWf6OadtmB5VflNXBZuvh4KFwq55HsJCPy95NR5r9eJfzqCD8JqaWbAKHA7cbZw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="dyhP/ub0";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C521606A330;
	Fri,  6 Nov 2026 20:40:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dyhP/ub0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1AF401F008A1;
	Fri,  6 Nov 2026 20:40:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793997652;
	bh=dDcga8x1t2Mz0U84bROvlxnSmjwl5bpBj7aWQNiL0h0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dyhP/ub0J+BV2YPEXBSPQfpU9KBYBM5TcGAB85azW6t94gZqYigg3k4PGLLnefySt
	 EmrPxky3zcGtnvmkX5jLaHgJiK5+TYvC0z6ehszaWCGw7oL7qbA9LhPZnPlJvbNVlZ
	 8Kkoua7fv96BqfzLCPOj35CnAXgeoZVQHliBHt0MB7Xq35XKGifvU5GTruBTISkuEH
	 yLJ0nsOYoSiXItN9KM/9nW2c7+TwHgLGYi+qGwAx+lZFIG3nxAjn2mOKwLx2f2ndbq
	 TPlj0MOoP+9YEhZdjaUs1lE0GFA+L6FpugMIN210chNkpBu7ge4TmzYVTugzk+mWcL
	 Glg2VPfKSSV+g==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:40:28 -0500
Subject: [PATCH v2 2/5] nfsd: Honor delegated timestamps when change and
 size match
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
Message-Id: <20261106-deleg-cb-getattr-times-v2-2-8433618ab9a1@kernel.org>
References: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
In-Reply-To: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=17112; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Vv37uF8tVTPFFbGKVGgftIcWhDT9s/pK60Gif7/Qx/k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7jtRI2abCGQd4CaX2vCCZT6DN/pxXt91fFOvE
 9QQ3rSwZIeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau47UQAKCRAADmhBGVaC
 FX5vD/0eKko3r7SQuwTU9au7crZgkKr/aoebSoscMdDsSy/F/P9hSoVyczvwDBLdOEr+gOPo0Al
 FUVMcozIU+lBdfsA0twV0jVx2sATv3uLExFxi1AZBT9sukCUXLaB3OSQnyaasJYMQ6SlvLM79gA
 2PeI5dz/cfg55gXdoQAgag3059/DHuDI0uhGiiQzw3BXpmH6jeE7+QQpZCbXofSUdMfcy6C0jEg
 he0pYaR7DAuninHKvan6ggL7TVQYEcuCpP2vo26RvH8B3sRT/jFdwHMZMNF7UP9tlJlJTf1uaSI
 LPsWir5hZglcaen0UROU/IgyN3Jm4dRbAeBSOvWe8KoanIz+Nltrm0rHQ0Y2lpHJlGzPtE8a9a2
 1e0fH2pgl0MnLTJSsaLbYmIsLRVOxs57iZsQ1I7P9F/KRqEQ0gVA+fEi31W7VKeja+rNNRYLv/1
 OcgSOnny1amdUZqrX7a3sqEy4DTN/x6daMtPEcOPbyuPRS2gYiAUQgn0FtPsy6uUPfl+ksy2Awa
 bWEo+l0bTKKQwDRRhfng+JMLqCXpBriCs38Cq8+RgvPk3kUn8c5qfHhDW+pyhh8THLpR4lq+u9L
 IxhiCMWjUoZv1KMOPsw17rF2UIUtwKAKYXp4+TDxylpCbvxZsUHAwjgWWH4GlBwyoW5ys1CgKET
 d7jESl/mjrD3oSQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_deleg_getattr_conflict() applies time_deleg_access and
time_deleg_modify from a CB_GETATTR reply only when the reply's change
attribute or size differs from the server's. RFC 9754 section 5 makes
the holder of a timestamp delegation the authority for atime and mtime,
and puts no such condition on accepting them.

Because the delegation's file has FMODE_NOCMTIME, the holder's WRITEs
change neither mtime nor the change attribute on the server. After a
flushed WRITE, the CB_GETATTR reply matches on change and size, the
holder's mtime is dropped, and other clients see new data with the
pre-WRITE mtime. Since commit 304d81a2fbf2 ("nfsd: fix file change
detection in CB_GETATTR") compares against the current file size, this
also hits flushed extending WRITEs. Holder reads lose the atime the
same way.

- For timestamp delegations, always vet and apply the CB_GETATTR
  times. Set ATTR_FORCE: the times are the holder's, and the GETATTR
  caller need not own the file.
- Record applied times in dl_[amc]time so a repeated CB_GETATTR reply
  doesn't reapply them. Vet and record under inode_lock.
- dl_[amc]time now change after the grant, so vet a SETATTR's delegated
  times in nfsd_setattr() under the same inode_lock. Otherwise a
  CB_GETATTR can advance them between vetting and applying, and the
  SETATTR moves the times backward.
- Mark the file modified if mtime advanced, or if dl_written shows a
  holder WRITE whose mtime didn't pass dl_mtime (clock skew).
- Setting atime can bump i_version, which would leak into the stat-based
  change attribute and later go backwards against ++ncf_initial_cinfo.
  For timestamp delegations, always report ncf_initial_cinfo instead.
- The holder's own server-side changes (SETATTR, xattrs, fallocate,
  LINK, ...) neither break its delegation nor show up in its CB_GETATTR
  reply. Save the server's change attribute at grant and after each of
  our timestamp updates, and mark the file modified if it moved
  otherwise. dl_written can't be used: it would stamp mtime at
  DELEGRETURN.
- Log, rather than fail the GETATTR, if applying the holder's times
  fails.
- Annotate the lockless ncf_file_modified and dl_written accesses.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  43 ++++-----------
 fs/nfsd/nfs4state.c | 147 ++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/nfs4xdr.c   |   4 +-
 fs/nfsd/state.h     |   4 +-
 fs/nfsd/vfs.c       |   4 ++
 fs/nfsd/vfs.h       |  13 +++++
 6 files changed, 157 insertions(+), 58 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 03ea955f1fe9..4e5d5852bf57 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1338,35 +1338,6 @@ nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
 		exp_put(u->secinfo_no_name.sin_exp);
 }
 
-/*
- * Validate that the requested timestamps are within the acceptable range. If
- * timestamp appears to be in the future, then it will be clamped to
- * current_time().
- */
-static void
-vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
-{
-	struct timespec64 now = current_time(dp->dl_stid.sc_file->fi_inode);
-	struct iattr *iattr = &setattr->sa_iattr;
-
-	if ((setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
-	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
-		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
-
-	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
-		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
-			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
-				dp->dl_setattr = true;
-			else
-				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
-		} else {
-			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
-					     ATTR_MTIME | ATTR_MTIME_SET);
-		}
-	}
-}
-
 static __be32
 nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
@@ -1378,10 +1349,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		.na_pacl	= posix_acl_dup(setattr->sa_pacl),
 		.na_dpacl	= posix_acl_dup(setattr->sa_dpacl),
 	};
-	bool save_no_wcc, deleg_attrs;
 	struct nfs4_stid *st = NULL;
 	struct inode *inode;
 	__be32 status = nfs_ok;
+	bool save_no_wcc;
+	u32 deleg_attrs;
 	int err;
 
 	deleg_attrs = setattr->sa_bmval[2] & (FATTR4_WORD2_TIME_DELEG_ACCESS |
@@ -1407,13 +1379,13 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 			/* Only for *_ATTRS_DELEG flavors */
 			if (deleg_attrs_deleg(dp->dl_type)) {
-				vet_deleg_attrs(setattr, dp);
+				/* nfsd_setattr() vets them under inode_lock */
+				attrs.na_deleg = dp;
+				attrs.na_deleg_attrs = deleg_attrs;
 				status = nfs_ok;
 			}
 		}
 	}
-	if (st)
-		nfs4_put_stid(st);
 	if (status)
 		goto out_err;
 
@@ -1452,6 +1424,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	fh_drop_write(&cstate->current_fh);
 out_err:
+	if (st)
+		nfs4_put_stid(st);
 	nfsd_attrs_free(&attrs);
 	return status;
 }
@@ -1463,8 +1437,9 @@ static void nfsd4_file_mark_deleg_written(struct nfs4_file *fi)
 		struct nfs4_delegation *dp = list_first_entry(&fi->fi_delegations,
 							      struct nfs4_delegation, dl_perfile);
 
+		/* Read locklessly by nfsd4_deleg_getattr_conflict() */
 		if (dp->dl_type == OPEN_DELEGATE_WRITE_ATTRS_DELEG)
-			dp->dl_written = true;
+			WRITE_ONCE(dp->dl_written, true);
 	}
 	spin_unlock(&fi->fi_lock);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cd70d86f4bc6..8306a647fe9b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1472,7 +1472,7 @@ static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct f
 	spin_unlock(&f->f_lock);
 
 	/* was it never written? */
-	if (!dp->dl_written)
+	if (!READ_ONCE(dp->dl_written))
 		return;
 
 	/* did it get a setattr for the timestamps at some point? */
@@ -7539,6 +7539,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		open->op_delegate_type = deleg_ts ? OPEN_DELEGATE_WRITE_ATTRS_DELEG :
 						    OPEN_DELEGATE_WRITE;
 		dp->dl_cb_fattr.ncf_initial_cinfo = nfsd4_change_attribute(&stat);
+		dp->dl_cb_fattr.ncf_srv_cinfo = dp->dl_cb_fattr.ncf_initial_cinfo;
 		dp->dl_atime = stat.atime;
 		dp->dl_ctime = stat.ctime;
 		dp->dl_mtime = stat.mtime;
@@ -10718,16 +10719,82 @@ bool nfsd4_vet_deleg_time(struct timespec64 *req, const struct timespec64 *orig,
 	return true;
 }
 
-static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation *dp)
+/**
+ * nfsd4_vet_deleg_attrs - vet the delegated timestamps in a SETATTR
+ * @iattr: attributes to be set
+ * @dp: timestamp delegation held by the SETATTR's sender
+ * @deleg_attrs: FATTR4_WORD2_TIME_DELEG_* bits in the SETATTR
+ *
+ * Drop requested timestamps that don't pass nfsd4_vet_deleg_time(), and
+ * clamp ones in the future. The caller holds the inode_lock across this
+ * and applying @iattr, so cb_getattr_update_times() can't move dl_*time
+ * in between.
+ */
+void nfsd4_vet_deleg_attrs(struct iattr *iattr, struct nfs4_delegation *dp,
+			   u32 deleg_attrs)
+{
+	struct inode *inode = dp->dl_stid.sc_file->fi_inode;
+	struct timespec64 now = current_time(inode);
+
+	lockdep_assert_held_write(&inode->i_rwsem);
+
+	if ((deleg_attrs & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
+	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
+		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+
+	if (deleg_attrs & FATTR4_WORD2_TIME_DELEG_MODIFY) {
+		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
+			iattr->ia_ctime = iattr->ia_mtime;
+			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
+				dp->dl_setattr = true;
+			else
+				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
+		} else {
+			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
+					     ATTR_MTIME | ATTR_MTIME_SET);
+		}
+	}
+}
+
+static int nfsd4_srv_cinfo(const struct path *path, u64 *cinfo)
 {
-	struct inode *inode = d_inode(dentry);
+	struct kstat stat;
+	int ret;
+
+	ret = vfs_getattr(path, &stat,
+			  STATX_MODE | STATX_CTIME | STATX_CHANGE_COOKIE,
+			  AT_STATX_SYNC_AS_STAT);
+	if (!ret)
+		*cinfo = nfsd4_change_attribute(&stat);
+	return ret;
+}
+
+static void cb_getattr_update_times(const struct path *path,
+				    struct nfs4_delegation *dp)
+{
+	struct inode *inode = d_inode(path->dentry);
 	struct nfs4_cb_fattr *ncf = &dp->dl_cb_fattr;
 	struct iattr attrs = { };
+	u64 cinfo;
 	int ret;
 
+	/* Serialize vetting against dl_*time with their update below */
+	inode_lock(inode);
 	if (deleg_attrs_deleg(dp->dl_type)) {
 		struct timespec64 now = current_time(inode);
 
+		/*
+		 * The holder's own SETATTRs, xattr changes, fallocates, LINKs
+		 * etc. don't break its delegation and don't show up in its
+		 * CB_GETATTR reply. Any change to the server's change
+		 * attribute other than our own timestamp updates is one of
+		 * those.
+		 */
+		if (!READ_ONCE(ncf->ncf_file_modified) &&
+		    (nfsd4_srv_cinfo(path, &cinfo) ||
+		     cinfo != ncf->ncf_srv_cinfo))
+			WRITE_ONCE(ncf->ncf_file_modified, true);
+
 		attrs.ia_atime = ncf->ncf_cb_atime;
 		attrs.ia_mtime = ncf->ncf_cb_mtime;
 
@@ -10740,24 +10807,55 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 			if (nfsd4_vet_deleg_time(&attrs.ia_ctime, &dp->dl_ctime, &now))
 				attrs.ia_valid |= ATTR_CTIME | ATTR_CTIME_SET;
 		}
+
+		/*
+		 * The times are the holder's, so don't hold the GETATTR
+		 * caller to the owner check for setting them.
+		 */
+		if (attrs.ia_valid)
+			attrs.ia_valid |= ATTR_FORCE;
 	} else {
 		attrs.ia_valid |= ATTR_MTIME | ATTR_CTIME;
 	}
 
 	if (!attrs.ia_valid)
-		return 0;
+		goto out_unlock;
 
 	attrs.ia_valid |= ATTR_DELEG;
-	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
+	ret = notify_change(&nop_mnt_idmap, path->dentry, &attrs, NULL);
+	if (ret) {
+		/* Don't fail the GETATTR over the holder's times */
+		pr_notice_ratelimited("nfsd: Unable to apply delegated timestamps on inode %02x:%02x:%llu: %d\n",
+				      MAJOR(inode->i_sb->s_dev),
+				      MINOR(inode->i_sb->s_dev),
+				      inode->i_ino, ret);
+		goto out_unlock;
+	}
+
+	/* Don't reapply the same times on every CB_GETATTR */
+	if (attrs.ia_valid & ATTR_ATIME_SET)
+		dp->dl_atime = attrs.ia_atime;
+	if (attrs.ia_valid & ATTR_CTIME_SET)
+		dp->dl_ctime = attrs.ia_ctime;
+	if (attrs.ia_valid & ATTR_MTIME_SET) {
+		dp->dl_mtime = attrs.ia_mtime;
+		/*
+		 * FMODE_NOCMTIME kept the holder's WRITEs from bumping the
+		 * change attribute; a newer delegated mtime is evidence of
+		 * them.
+		 */
+		WRITE_ONCE(ncf->ncf_file_modified, true);
+	}
+	if (deleg_attrs_deleg(dp->dl_type) && !nfsd4_srv_cinfo(path, &cinfo))
+		ncf->ncf_srv_cinfo = cinfo;
+out_unlock:
 	inode_unlock(inode);
-	return ret;
 }
 
 /**
  * nfsd4_deleg_getattr_conflict - Recall if GETATTR causes conflict
  * @rqstp: RPC transaction context
- * @dentry: dentry of inode to be checked for a conflict
+ * @path: path of inode to be checked for a conflict
  * @pdp: returned WRITE delegation, if one was found
  *
  * This function is called when there is a conflict between a write
@@ -10772,7 +10870,7 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
  * caller must put the reference.
  */
 __be32
-nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
+nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, const struct path *path,
 			     struct nfs4_delegation **pdp)
 {
 	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
@@ -10780,7 +10878,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 	struct nfs4_delegation *dp = NULL;
 	struct file_lease *fl;
 	struct nfs4_cb_fattr *ncf;
-	struct inode *inode = d_inode(dentry);
+	struct inode *inode = d_inode(path->dentry);
 	__be32 status;
 
 	ctx = locks_inode_context(inode);
@@ -10830,25 +10928,32 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 		status = nfs_ok;
 		goto out_status;
 	}
-	if (!ncf->ncf_file_modified) {
+	if (!READ_ONCE(ncf->ncf_file_modified)) {
 		if (ncf->ncf_initial_cinfo != ncf->ncf_cb_change)
-			ncf->ncf_file_modified = true;
+			WRITE_ONCE(ncf->ncf_file_modified, true);
 		else if (i_size_read(inode) != ncf->ncf_cb_fsize)
-			ncf->ncf_file_modified = true;
+			WRITE_ONCE(ncf->ncf_file_modified, true);
+		/* FMODE_NOCMTIME hid flushed WRITEs from the change attribute */
+		else if (READ_ONCE(dp->dl_written))
+			WRITE_ONCE(ncf->ncf_file_modified, true);
 	}
-	if (ncf->ncf_file_modified) {
-		int err;
-
+	/*
+	 * The holder of a timestamp delegation is the authority for atime
+	 * and mtime (RFC 9754, section 5), even if change and size match.
+	 * Applying them can bump i_version, so for these delegations the
+	 * reply always takes its change attribute from ncf_initial_cinfo.
+	 */
+	if (READ_ONCE(ncf->ncf_file_modified) || deleg_attrs_deleg(dp->dl_type)) {
 		/*
 		 * Per section 10.4.3 of RFC 8881, the server would
 		 * not update the file's metadata with the client's
 		 * modified size
 		 */
-		err = cb_getattr_update_times(dentry, dp);
-		if (err) {
-			status = nfserrno(err);
-			goto out_status;
-		}
+		cb_getattr_update_times(path, dp);
+		/*
+		 * Set even if unmodified: another thread may set
+		 * ncf_file_modified before our caller encodes the reply.
+		 */
 		ncf->ncf_cur_fsize = ncf->ncf_cb_fsize;
 		*pdp = dp;
 		return nfs_ok;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 434b6cfc5741..c6e0cfba07da 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4084,7 +4084,7 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	    (attrmask[1] & (FATTR4_WORD1_TIME_ACCESS |
 			    FATTR4_WORD1_TIME_MODIFY |
 			    FATTR4_WORD1_TIME_METADATA))) {
-		status = nfsd4_deleg_getattr_conflict(rqstp, dentry, &dp);
+		status = nfsd4_deleg_getattr_conflict(rqstp, &path, &dp);
 		if (status)
 			goto out;
 	}
@@ -4095,7 +4095,7 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	if (dp) {
 		struct nfs4_cb_fattr *ncf = &dp->dl_cb_fattr;
 
-		if (ncf->ncf_file_modified) {
+		if (READ_ONCE(ncf->ncf_file_modified)) {
 			++ncf->ncf_initial_cinfo;
 			args.stat.size = ncf->ncf_cur_fsize;
 		}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d9aecef95bae..9c36076921de 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -212,6 +212,8 @@ struct nfs4_cb_fattr {
 
 	bool ncf_file_modified;
 	u64 ncf_initial_cinfo;
+	/* server change attr after our last timestamp update, under inode_lock */
+	u64 ncf_srv_cinfo;
 	u64 ncf_cur_fsize;
 };
 
@@ -1041,7 +1043,7 @@ static inline bool try_to_expire_client(struct nfs4_client *clp)
 }
 
 extern __be32 nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp,
-		struct dentry *dentry, struct nfs4_delegation **pdp);
+		const struct path *path, struct nfs4_delegation **pdp);
 
 struct nfsd4_get_dir_delegation;
 struct nfs4_delegation *nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 02df2ff02d60..c06a834caa26 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -631,6 +631,10 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		}
 	}
 
+	if (attr->na_deleg)
+		nfsd4_vet_deleg_attrs(iap, attr->na_deleg,
+				      attr->na_deleg_attrs);
+
 	for (retries = 1;;) {
 		struct iattr attrs;
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 73ab9d34a275..0fad264b7aeb 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -103,6 +103,10 @@ struct nfsd_attrs {
 	struct posix_acl	*na_pacl;	/* input */
 	struct posix_acl	*na_dpacl;	/* input */
 
+	/* input: vet these FATTR4_WORD2_TIME_DELEG_* times under inode_lock */
+	struct nfs4_delegation	*na_deleg;
+	u32			na_deleg_attrs;
+
 	int			na_labelerr;	/* output */
 	int			na_dpaclerr;	/* output */
 	int			na_paclerr;	/* output */
@@ -177,6 +181,15 @@ int		nfsd_clone_file_range(struct file *src, u64 src_pos,
 				      u64 count, errseq_t *since);
 int		nfsd_clone_sync_range(struct file *src, struct file *dst,
 				      u64 dst_pos, u64 count, errseq_t since);
+void		nfsd4_vet_deleg_attrs(struct iattr *iattr,
+				      struct nfs4_delegation *dp,
+				      u32 deleg_attrs);
+#else
+static inline void nfsd4_vet_deleg_attrs(struct iattr *iattr,
+					 struct nfs4_delegation *dp,
+					 u32 deleg_attrs)
+{
+}
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create_locked(struct svc_rqst *, struct svc_fh *,
 				struct nfsd_attrs *attrs, int type, dev_t rdev,

-- 
2.56.0

