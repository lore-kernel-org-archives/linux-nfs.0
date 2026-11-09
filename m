Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256652;
	b=gsSz6PD8xuH5G59dZRLrwyNzvH0d6VLjHzaiJ5O0QIRoM0zdMWNXa4iZA+R5WZDoLzYi
	 czdv5usl9rwkDRTXj2vcpr/MF672b1UaMTBVh0MuXTQ4Su/fADVgrAL5jmxtjMODTAPj7
	 C3dpuaEzLCpSg2s477mYUw26dmwc2bnx6ynRnO6WpWCDZ00KN+C1jmFBbtmO1jwPnhPX2
	 YLPMZXzGeNlQWYjE5ZjddjtxSxYzMHFSLed5WBI2kikyiU6IP0ABDxrxQgq4ZBrLXOEaI
	 iEuvei7bv5i/aVdJVAEjRj28HI0GlCV1Za8B9Po5s0CCqofl3+aaMHLuvgMs9B7Hwzg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256652;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=hoOhHWfz0wQT3LPF0DQCreARMieM4FfpYRby4p0O4ps=;
	b=nzL/QnAzHT2CbPJBQu/oKV32s3MtwBazVi3EIvvDojjoPILNHdF282qxIKk04qtUPInB
	 xr+HL+0ALmVUL5DpPin/ssEnz7H95Ivxs6BBbt7hd3FeHrrXiF4S0RrWLBcnYOf1Q69Mp
	 o9mB27xhihK8LthBbW/QVtm8nWlkjQ3op9GcN4c0vM8OwQPLNf4Ffr5bOMYHdXTYPyCIK
	 SIS3+rQgLy7O7X4ERb1+dCW2RyVUdFqwJBdF2J5yK8qx6zJlosvkiqn0kDI0lBQIw920c
	 K+68LKSswPrmioFoNprZPGGnMbOZjeT5ShADQ0r/vLXIIjeRxmvBMHNiYt3NPSt/l7w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NnHUo09D;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBB81606A33C;
	Mon,  9 Nov 2026 20:37:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NnHUo09D
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7213D1F008A1;
	Mon,  9 Nov 2026 20:37:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256651;
	bh=hoOhHWfz0wQT3LPF0DQCreARMieM4FfpYRby4p0O4ps=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NnHUo09D9p8s944P+b9mMF7MNK77Rb0J4M/T+KXcYlEzpx6O+zA8Haw/GNvxvvkDo
	 QxF9uRW+69FMlwXSTtbfE+FVuzX/B3QxS7Y4bCSNzBQu1Ilz6SAr34pfK8PYE36nIW
	 hj0JGKVxAUO2saMiG4J/V/ouRLQY5Xit4uVuGZDFQjrJfsDLmMX4cbEhyg9xbTpOC2
	 jYJ/yTQYIHkrSJpzyITMCdC41XvDkrpvYOmWR//vA05iOICY9P+x1dMCBHuBuKHOPs
	 5ZVI21O0V6NbLbzQWr54WGXeMVkZdJkYrdk+zoT7aItYkeCDhMVFIXtxTsncdYlhp3
	 7eyWdGjJHUgEQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:43 -0500
Subject: [PATCH v3 2/8] nfsd: Honor delegated timestamps when change and
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
Message-Id: <20261109-deleg-cb-getattr-times-v3-2-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=19761; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=nn7LIxIsuVheVcSzybstX6EtGDDatfX+c4dTe/0aDqA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i78j6xZEfrGs1GeDH49PEUJTXIJNj8EXdXlL
 OqsOrToxaqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIu/AAKCRAADmhBGVaC
 FUbaD/4uWNgz/jyS7THvxQYkBoovmosMLvW161XpAIBLsvtAMUzvUziVGO5hJklZPoI45MogHQA
 92Uh4ZG06ZAWuCfYTgFt54r0cGdzJYCK0bgocVe9q44TYLQRF9wbpPQikG4cIa4FT/kBxlB5h4y
 ib1Fa2j97JlY4VJd+xjdenxvM1mQWmDbB759txqtKGBzsUXTApXLQHDOR45aFUqlzb/+OeGX4Od
 zY8YYZQ7GECKY7Vtz5ghhhdRbOwN902PcjIxzSPYx+dwhN/a7RRKDas7n0+gFa5dmTjm8Fd52Cz
 QwHolH0cpeRtzksKVsnacmu1ABXK+UMGnreN4im8hfgkTD2Zg7oDwQi4CkzM8CqBZpv8KekBJDW
 mLG9+KTCf7KzeIyMTpYYWnSs0BPT4ckVqBzLPQoRtZW+m4Be3K8PvlpUbn3mvnIzS58QP9wQfy7
 UHU8e2GfToWMgELvvnu1GwmKz3fu4hv+MJ9YoZGEy0kGmJG6/JaztF3U4Gqm9n1qdta6ob1XWFr
 ozL/YMm247Ppx1PvqcU01gNUsu9DDX0V8LFpP5Vt//FPk4kbK2ZvXhlkFNdD+xjh47nDahhw64n
 uwNz9zzdyifaQTtOv3aMMr9gszEnYH0o0J84Gs2/QzptYP5L7i2N0Ve2gkRQOxZdm0lh8Njb2P+
 XS9pdXaLfnlunLg==
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
  times, with ATTR_FORCE: the GETATTR caller need not own the file.
- Record applied times in dl_[amc]time, from both CB_GETATTR and
  SETATTR, so a repeated or stale holder time can't reapply or move
  them backward. Vet, apply and record under inode_lock; SETATTR's
  vetting moves into nfsd_setattr() for that.
- Mark the file modified if mtime advanced, if dl_written shows a
  holder WRITE (clock skew can keep its mtime from passing), or if the
  server's change attribute moved other than by nfsd's own timestamp
  updates: the holder's SETATTRs, xattrs, fallocates, LINKs etc.
  neither break its delegation nor show up in its CB_GETATTR reply.
  Track that in ncf_srv_cinfo, not dl_written, which would make
  DELEGRETURN stamp mtime.
- Setting atime can bump i_version, which would leak into the
  stat-based change attribute and later go backwards against
  ++ncf_initial_cinfo. For timestamp delegations, always report
  ncf_initial_cinfo instead.
- Log, rather than fail the GETATTR, if applying the times fails.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4callback.c |   2 +-
 fs/nfsd/nfs4ctl.h      |  15 ++++
 fs/nfsd/nfs4proc.c     |  43 +++---------
 fs/nfsd/nfs4state.c    | 184 ++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c      |   4 +-
 fs/nfsd/state.h        |   4 +-
 fs/nfsd/vfs.c          |   6 ++
 fs/nfsd/vfs.h          |   4 ++
 8 files changed, 199 insertions(+), 63 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 70ab4fd32195..901aeab88956 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -396,7 +396,7 @@ encode_cb_getattr4args(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr,
 	u32 bmap[3];
 
 	bmap[0] = FATTR4_WORD0_SIZE;
-	if (!ncf->ncf_file_modified)
+	if (!READ_ONCE(ncf->ncf_file_modified))
 		bmap[0] |= FATTR4_WORD0_CHANGE;
 
 	if (deleg_attrs_deleg(dp->dl_type)) {
diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
index e0d1246ca337..bcc42df3a9ee 100644
--- a/fs/nfsd/nfs4ctl.h
+++ b/fs/nfsd/nfs4ctl.h
@@ -22,6 +22,8 @@ struct inode;
 struct dentry;
 struct svc_rqst;
 struct nfsd_net;
+struct iattr;
+struct nfs4_delegation;
 
 #ifdef CONFIG_NFSD_V4
 extern unsigned long max_delegations;
@@ -35,6 +37,10 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
 int nfsd4_create_laundry_wq(void);
 void nfsd4_destroy_laundry_wq(void);
 bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode);
+void nfsd4_vet_deleg_attrs(struct iattr *iattr, struct nfs4_delegation *dp,
+			   u32 deleg_attrs);
+void nfsd4_record_deleg_attrs(const struct iattr *iattr,
+			      struct nfs4_delegation *dp);
 
 extern int nfsd4_is_junction(struct dentry *dentry);
 extern int register_cld_notifier(void);
@@ -63,6 +69,15 @@ static inline bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp,
 {
 	return false;
 }
+static inline void nfsd4_vet_deleg_attrs(struct iattr *iattr,
+					 struct nfs4_delegation *dp,
+					 u32 deleg_attrs)
+{
+}
+static inline void nfsd4_record_deleg_attrs(const struct iattr *iattr,
+					    struct nfs4_delegation *dp)
+{
+}
 
 static inline int nfsd4_is_junction(struct dentry *dentry)
 {
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
index cd70d86f4bc6..a8966d1f786f 100644
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
@@ -10718,16 +10719,111 @@ bool nfsd4_vet_deleg_time(struct timespec64 *req, const struct timespec64 *orig,
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
+ * clamp ones in the future. Set dl_setattr if both the mtime and ctime
+ * pass.
+ *
+ * Context: Caller holds the inode_lock across this, applying @iattr, and
+ * nfsd4_record_deleg_attrs(), so cb_getattr_update_times() can't move
+ * dl_*time in between.
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
+/**
+ * nfsd4_record_deleg_attrs - record delegated timestamps just applied
+ * @iattr: vetted attributes, not the copy notify_change() altered
+ * @dp: timestamp delegation whose holder supplied the times
+ *
+ * Set dl_*time to the times applied, so a stale holder time can't move
+ * them backward and a repeated CB_GETATTR reply isn't reapplied.
+ *
+ * Context: Caller holds the inode_lock.
+ */
+void nfsd4_record_deleg_attrs(const struct iattr *iattr,
+			      struct nfs4_delegation *dp)
+{
+	struct inode *inode = dp->dl_stid.sc_file->fi_inode;
+
+	lockdep_assert_held_write(&inode->i_rwsem);
+
+	if (iattr->ia_valid & ATTR_ATIME_SET)
+		dp->dl_atime = iattr->ia_atime;
+	if (iattr->ia_valid & ATTR_MTIME_SET)
+		dp->dl_mtime = iattr->ia_mtime;
+	/* inode_set_ctime_deleg() keeps a later ctime */
+	if (iattr->ia_valid & ATTR_CTIME)
+		dp->dl_ctime = inode_get_ctime(inode);
+}
+
+static int nfsd4_srv_cinfo(const struct path *path, u64 *cinfo)
+{
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
 {
-	struct inode *inode = d_inode(dentry);
+	struct inode *inode = d_inode(path->dentry);
 	struct nfs4_cb_fattr *ncf = &dp->dl_cb_fattr;
-	struct iattr attrs = { };
+	struct iattr attrs = { }, tmp;
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
+		 * attribute other than nfsd's own timestamp updates is one
+		 * of those.
+		 */
+		if (!READ_ONCE(ncf->ncf_file_modified) &&
+		    (nfsd4_srv_cinfo(path, &cinfo) ||
+		     cinfo != ncf->ncf_srv_cinfo))
+			WRITE_ONCE(ncf->ncf_file_modified, true);
+
 		attrs.ia_atime = ncf->ncf_cb_atime;
 		attrs.ia_mtime = ncf->ncf_cb_mtime;
 
@@ -10740,24 +10836,53 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
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
+	/* notify_change() truncates the times in its iattr argument */
+	tmp = attrs;
+	ret = notify_change(&nop_mnt_idmap, path->dentry, &tmp, NULL);
+	if (ret) {
+		/* Don't fail the GETATTR over the holder's times */
+		pr_notice_ratelimited("nfsd: Unable to apply delegated timestamps on inode %02x:%02x:%llu: %d\n",
+				      MAJOR(inode->i_sb->s_dev),
+				      MINOR(inode->i_sb->s_dev),
+				      inode->i_ino, ret);
+		goto out_unlock;
+	}
+
+	if (!deleg_attrs_deleg(dp->dl_type))
+		goto out_unlock;
+
+	nfsd4_record_deleg_attrs(&attrs, dp);
+	/*
+	 * FMODE_NOCMTIME kept the holder's WRITEs from bumping the change
+	 * attribute; a newer delegated mtime is evidence of them.
+	 */
+	if (attrs.ia_valid & ATTR_MTIME_SET)
+		WRITE_ONCE(ncf->ncf_file_modified, true);
+	if (!nfsd4_srv_cinfo(path, &cinfo))
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
@@ -10767,12 +10892,14 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
  * delegation before replying to the GETATTR. See RFC 8881 section
  * 18.7.4.
  *
- * Returns 0 if there is no conflict; otherwise an nfs_stat
- * code is returned. If @pdp is set to a non-NULL value, then the
- * caller must put the reference.
+ * If @pdp is set to a non-NULL value, then the caller must put the
+ * reference.
+ *
+ * Return: nfs_ok if there is no conflict or a CB_GETATTR resolved it;
+ * otherwise an nfs_stat code.
  */
 __be32
-nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
+nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, const struct path *path,
 			     struct nfs4_delegation **pdp)
 {
 	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
@@ -10780,7 +10907,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 	struct nfs4_delegation *dp = NULL;
 	struct file_lease *fl;
 	struct nfs4_cb_fattr *ncf;
-	struct inode *inode = d_inode(dentry);
+	struct inode *inode = d_inode(path->dentry);
 	__be32 status;
 
 	ctx = locks_inode_context(inode);
@@ -10830,25 +10957,32 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
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
+		/* FMODE_NOCMTIME hid flushed WRITEs from the change attr */
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
+		 * ncf_file_modified before the caller encodes the reply.
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
index d9aecef95bae..9e8699810e33 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -212,6 +212,8 @@ struct nfs4_cb_fattr {
 
 	bool ncf_file_modified;
 	u64 ncf_initial_cinfo;
+	/* change attr after nfsd's last timestamp update; inode_lock */
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
index 02df2ff02d60..260ba57b5542 100644
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
 
@@ -646,6 +650,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (!nfsd_wait_for_delegreturn(rqstp, inode))
 			break;
 	}
+	if (attr->na_deleg && !host_err)
+		nfsd4_record_deleg_attrs(iap, attr->na_deleg);
 	if (attr->na_seclabel && attr->na_seclabel->len)
 		attr->na_labelerr = security_inode_setsecctx(dentry,
 			attr->na_seclabel->data, attr->na_seclabel->len);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 73ab9d34a275..78cfa0dcaf5c 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -103,6 +103,10 @@ struct nfsd_attrs {
 	struct posix_acl	*na_pacl;	/* input */
 	struct posix_acl	*na_dpacl;	/* input */
 
+	/* input: vet and record these FATTR4_WORD2_TIME_DELEG_* times */
+	struct nfs4_delegation	*na_deleg;
+	u32			na_deleg_attrs;
+
 	int			na_labelerr;	/* output */
 	int			na_dpaclerr;	/* output */
 	int			na_paclerr;	/* output */

-- 
2.56.0

