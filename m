Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4CFB4E2378;
	Fri,  4 Sep 2026 14:17:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788531469; cv=none; b=DmHasMCqoDf5wvZv+wRdIIfOWDWblWQhje5f3PxHEnoIdTqefKSjs3jdKYaBbG97T5k7NCRDv8V58ElIX62zeR/M0dWpAcROYMurL089MNMMC2e3oVNovaNVZ72qTLXfvL1JSpHhE2GWS0CYEePIM9Z9Fb+9DW5Ux9Qeqj2WyBk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788531469; c=relaxed/simple;
	bh=JsdBO55uCRKWqXpn4EMIUC5/klUGfaKJEuis9Udc5ag=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=sc35jjxMKEOwJI5NHqmtYB+ZK3eZ0Sp+pclAL40+Odxe5TsOL0YpKJWnn4xNdoys6x+YDLsdZFdfsCyeFjwyesCeyNi/UQ5ItW2Nz6AReB8dUXjdZ4Z/trIwzla+d4IAzc4ya4GqtW5Cq/akH6+oKzPDJmwNh5+3rcI82kdCkZM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=K39kKo3p; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="K39kKo3p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7605B1F00A3F;
	Fri,  4 Sep 2026 14:17:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788531467;
	bh=02WNrILEH6/OPBx3GU+DghKYQb2lTWCkSVl6B+Kwx54=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=K39kKo3pO3Wi1iIeEFYGFOIIzwtw3uSy6W2WcidhSTZVVvaRTJHxI5lnqbVRzbUIC
	 neShbZWoVi2GqI929B7uJdIWAyYZ9TvPo2qDcIoSmYq6QwHjQwC8zj/tV7YxvCtjtB
	 wchgUkvw7FVvIeaIM/cTr3YvcX6Rc9QghrjYt/wN0yQphH5azpXo8Qrdb880R4vcoz
	 4daNwQh7+572ydIMf6GtzvBWeDNhgFQIIt4MaVQdTjRM3yyiBcT5E4MsdSfcPRTjD/
	 6sSZiJmH/MQ+Vl5rphFBBJXrJODaA3GeTcWuSmz6B6GG0aWp3x8YgR2NInweLep0Vj
	 0vZ0YIMPoppNw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 04 Sep 2026 10:17:34 -0400
Subject: [PATCH v3 3/3] nfsd: compare CB_GETATTR times against the inode
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260904-delegts-v3-3-b6062ba75f07@kernel.org>
References: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
In-Reply-To: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
To: Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6478; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=JsdBO55uCRKWqXpn4EMIUC5/klUGfaKJEuis9Udc5ag=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmtMGvDlmZOp+gTuqd0FL2nI6Pj5+/DM0BqLSQ
 4i2PSc6GKSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaprTBgAKCRAADmhBGVaC
 FVPDEACRy/zpmgftM56mjgFXqVIlfI7s/4DgQx6yTqpl6iNnETQUMISV+f/IOFDmfLpl0FGQPiu
 TUX1WgAoYtQbk8sdRmAfGJKq8eC6zKrqikOB1phgm/tCYVcc3KXfbzyz3x0FnPDl1zawuqcs+70
 QfmWxiI0oPfWTEwBv4xtsJp9/1YppsZqvfwDV3XTi/G9kKiiDJIrnoTSsi6H+op3HfF8AhN8FBA
 tcOe71xCHgqbTySBdmnWQar3h2fb3HaZm8Uwr6Rl9BNLRQbokXY/UJ4e4iyVbdI4BpBLB/B3gNm
 2xkH9xSnR7h3oxHRR3Oh50afnav8ZXTPvc3Um6Z/Hi1FP2LxIUZFOsQNfcW+LbZeBc83Ekk5owB
 /0k9uLNOHu4cw4DP7ZNTcOICGiW1zmsL/B9wazjmDilZ3FlEgh078FkTY8UXJDJhMxDIVVggfYD
 i3Or+V8GH9jRaNiAmnWvvNpvcgA7SdMjQBstw5vdYuJnFuXFvLutqUOl6xLcb+xP0knGYOxwqEo
 qfz6Iv3Yqy+qO4yTnmdt9rp/FMn33g4YehgiG+VT44Ljj1z4zLUuNnf2Jjf+DPNIptZPArdrNFD
 z4hvbzpwHTbfa0yWrNen9hz92YILjql/ow94lyhxFWrRevLp4T7dQ0rlFwah7XTdtyjkAtKX/ln
 fAYvn81EknKjW5A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

cb_getattr_update_times() vets the times that a client reports in a
CB_GETATTR against dl_atime, dl_mtime and dl_ctime. nfsd samples those
three when it grants the delegation, and nothing refreshes them. An
earlier CB_GETATTR or SETATTR can move the inode past them.

The vetting then compares against a stale value and accepts a report
that it must reject. setattr_copy() applies the atime and the mtime with
no check of the current value, so both move backwards. That is the
result the vetting exists to prevent.

Compare against the inode instead. Take the inode lock before the
comparison, so that a setattr from a concurrent delegation break cannot
land before notify_change() runs.

With this change, there is no longer a need to keep dl_atime/mtime/ctime
in the delegation. Drop those fields as well. That also drops a read of
an uninitialized struct kstat: the read-delegation arm assigned
stat.atime to dl_atime even when nfs4_delegation_stat() had not run.
Nothing consumed the value, since dl_atime is only read under
deleg_attrs_deleg().

Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
Assisted-by: LLM
Acked-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 49 +++++++++++++++++++++++++++++++------------------
 fs/nfsd/state.h     |  8 --------
 2 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ae0af9490fb1..b2b8d3a8030b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7307,9 +7307,6 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		open->op_delegate_type = deleg_ts ? OPEN_DELEGATE_WRITE_ATTRS_DELEG :
 						    OPEN_DELEGATE_WRITE;
 		dp->dl_cb_fattr.ncf_initial_cinfo = nfsd4_change_attribute(&stat);
-		dp->dl_atime = stat.atime;
-		dp->dl_ctime = stat.ctime;
-		dp->dl_mtime = stat.mtime;
 		spin_lock(&f->f_lock);
 		if (deleg_ts)
 			f->f_mode |= FMODE_NOCMTIME;
@@ -7318,7 +7315,6 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	} else {
 		open->op_delegate_type = deleg_ts && nfs4_delegation_stat(dp, currentfh, &stat) ?
 					 OPEN_DELEGATE_READ_ATTRS_DELEG : OPEN_DELEGATE_READ;
-		dp->dl_atime = stat.atime;
 		trace_nfsd_deleg_read(&dp->dl_stid.sc_stateid);
 	}
 	nfs4_put_stid(&dp->dl_stid);
@@ -10447,7 +10443,7 @@ nfsd4_get_writestateid(struct nfsd4_compound_state *cstate,
 /**
  * nfsd4_vet_deleg_time - vet and set the timespec for a delegated timestamp update
  * @req: timestamp from the client
- * @orig: original timestamp in the inode
+ * @cur: current timestamp in the inode
  * @now: current time
  *
  * Given a timestamp from the client response, check it against the
@@ -10455,15 +10451,17 @@ nfsd4_get_writestateid(struct nfsd4_compound_state *cstate,
  * if the inode's timestamp needs to be updated, and false otherwise.
  * @req may also be changed if the timestamp needs to be clamped.
  */
-bool nfsd4_vet_deleg_time(struct timespec64 *req, const struct timespec64 *orig,
-			  const struct timespec64 *now)
+static bool nfsd4_vet_deleg_time(struct timespec64 *req,
+				 const struct timespec64 *cur,
+				 const struct timespec64 *now)
 {
-
 	/*
-	 * "When the time presented is before the original time, then the
-	 *  update is ignored." Also no need to update if there is no change.
+	 * RFC 9754 has the server ignore a time that is before the original
+	 * one. Compare against the value in the inode rather than the original:
+	 * an earlier CB_GETATTR or SETATTR may have moved it, and a report that
+	 * does not advance it is stale.
 	 */
-	if (timespec64_compare(req, orig) <= 0)
+	if (timespec64_compare(req, cur) <= 0)
 		return false;
 
 	/*
@@ -10484,30 +10482,45 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 	struct iattr attrs = { };
 	int ret;
 
+	/*
+	 * Take the inode lock first, so that a setattr from a delegation break
+	 * cannot land between the comparison and notify_change(). The atime can
+	 * still move under us: touch_atime() takes no lock, and FMODE_NOCMTIME
+	 * does not cover it.
+	 */
+	inode_lock(inode);
+
 	if (deleg_attrs_deleg(dp->dl_type)) {
 		struct timespec64 now = current_time(inode);
+		struct timespec64 atime = inode_get_atime(inode);
+		struct timespec64 mtime = inode_get_mtime(inode);
 
 		attrs.ia_atime = ncf->ncf_cb_atime;
 		attrs.ia_mtime = ncf->ncf_cb_mtime;
 
-		if (nfsd4_vet_deleg_time(&attrs.ia_atime, &dp->dl_atime, &now))
+		if (nfsd4_vet_deleg_time(&attrs.ia_atime, &atime, &now))
 			attrs.ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
 
-		if (nfsd4_vet_deleg_time(&attrs.ia_mtime, &dp->dl_mtime, &now)) {
-			attrs.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
+		/*
+		 * A change to the mtime must show in the ctime.
+		 * inode_set_ctime_deleg() takes the mtime when it advances the
+		 * ctime, and stamps the current time otherwise.
+		 */
+		if (nfsd4_vet_deleg_time(&attrs.ia_mtime, &mtime, &now)) {
+			attrs.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET |
+					  ATTR_CTIME | ATTR_CTIME_SET;
 			attrs.ia_ctime = attrs.ia_mtime;
-			if (nfsd4_vet_deleg_time(&attrs.ia_ctime, &dp->dl_ctime, &now))
-				attrs.ia_valid |= ATTR_CTIME | ATTR_CTIME_SET;
 		}
 	} else {
 		attrs.ia_valid |= ATTR_MTIME | ATTR_CTIME;
 	}
 
-	if (!attrs.ia_valid)
+	if (!attrs.ia_valid) {
+		inode_unlock(inode);
 		return 0;
+	}
 
 	attrs.ia_valid |= ATTR_DELEG;
-	inode_lock(inode);
 	ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
 	inode_unlock(inode);
 	return ret;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd9294f024bb..e7fe2af45f53 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -330,11 +330,6 @@ struct nfs4_delegation {
 		struct nfsd4_cb_notify	dl_cb_notify;
 	};
 
-	/* For delegated timestamps */
-	struct timespec64	dl_atime;
-	struct timespec64	dl_mtime;
-	struct timespec64	dl_ctime;
-
 	/* For dir delegations */
 	u32			dl_notify_mask;
 	u32			dl_child_attrs[2];
@@ -357,9 +352,6 @@ static inline bool deleg_attrs_deleg(u32 dl_type)
 	       dl_type == OPEN_DELEGATE_WRITE_ATTRS_DELEG;
 }
 
-bool nfsd4_vet_deleg_time(struct timespec64 *cb, const struct timespec64 *orig,
-			  const struct timespec64 *now);
-
 #define cb_to_delegation(cb) \
 	container_of(cb, struct nfs4_delegation, dl_recall)
 

-- 
2.55.0

