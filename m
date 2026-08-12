Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8FE244780B
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 14:24:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786544680; cv=none; b=epQbpUCSwdC6Ly6LQeaPHGBw16XkFJS4FF938W/3aAmDxyLOyEykV6lY5E42fVyHbgQuZpLPcZ0RwT2vWFWgPOsFFqOVekiZX854oc9f4GKp0eJ+LwBFI7vFYzfcw3ZtyKJGVXK38QPtK3twNU6QqvDgGdX+PxYvquIYO0a6j8A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786544680; c=relaxed/simple;
	bh=kX1SJ+XfyvfdnDSiWlvNpdY1d76Sr1WjV+AK0YLSD5A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QX/xhOFtS7fHfsaP24Wm892zaWDgXJ9u58nPG1YXP+Z6VJkNsEEn8v9C3N9G+TGsU0CBgjB7yb10zqiE80r44gapu48vTRDGixcSZeBL0o+beHqMIin/TEmeWmwk97MTg62ddkkTQRRBiaUioB4prDGFo4HkJ92LHSVbPKSlc7A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iYnOfz2T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iYnOfz2T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25B091F00A3E;
	Wed, 12 Aug 2026 14:24:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786544678;
	bh=asXT5qwo1aiK9zzdYgkAmEXCko8PBUDypaAVLwFdvIg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iYnOfz2TlSMvLqG5wlXVkrpFZxp7J3IxuSwUbrXNjb5uDiy4BPO1mbH7nyaEDvNSP
	 Ie8V8JZ5onGNSII0aBF/PEp+OQgbEHyxu+vpaQOlkdG/qEg3rX4DOz/ptoqlzcQ0PG
	 Uf5a89gXgXNKUkgsOfCxRqbzUL8/G5Q3mFj7DPbnzM9DDLcmMVYLl+g5agXpKO0k1b
	 EkW1IdtRDB41FPbN/T7R4M3OCs7wMtcgcjt6Zox5vhPsMj0BnmDStL9RwwdiI/QMwD
	 Cptfh407mNyJD5l6cSMsZCOfcJJt0Oj/N0uMdSGwCKI1rMSBEdkit6A2EhXc8jpLQN
	 fDlryXsjW13Vw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/3] NFSD: Make the write verifier reset helper available outside vfs.c
Date: Wed, 12 Aug 2026 10:24:34 -0400
Message-ID: <20260812142436.35042-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260812142436.35042-1-cel@kernel.org>
References: <20260812142436.35042-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A subsequent patch moves the NFSv4-specific portions of
nfsd4_clone_file_range() out of fs/nfsd/vfs.c and into its caller in
fs/nfsd/nfs4proc.c. One of those portions resets the write verifier
when the post-clone sync fails.

netns.h already exposes nfsd_reset_write_verifier(), but that is the
unconditional reset. commit_reset_write_verifier() wraps it with the
policy that decides which errors warrant a reset: -EAGAIN and -ESTALE
do not indicate a problem with durable storage, so they leave the
verifier alone. A caller outside vfs.c has to apply the same policy,
so make the wrapper visible rather than duplicate its switch.

Rename it to nfsd_maybe_reset_write_verifier() on the way out.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 29 ++++++++++++++++++++---------
 fs/nfsd/vfs.h |  5 +++++
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6d865f4f9ba3..fad51a899062 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -352,9 +352,20 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	return err;
 }
 
-static void
-commit_reset_write_verifier(struct nfsd_net *nn, struct svc_rqst *rqstp,
-			    int err)
+/**
+ * nfsd_maybe_reset_write_verifier - Reset the write verifier after an I/O error
+ * @nn: nfsd namespace holding the write verifier
+ * @rqstp: RPC transaction context
+ * @err: errno reported by the failed operation
+ *
+ * A write verifier reset tells clients that unstable data the server has
+ * already acknowledged might have been lost. Client response is to resend
+ * in-flight dirty data.
+ *
+ * Context: Process context.
+ */
+void nfsd_maybe_reset_write_verifier(struct nfsd_net *nn,
+				     struct svc_rqst *rqstp, int err)
 {
 	switch (err) {
 	case -EAGAIN:
@@ -735,7 +746,7 @@ __be32 nfsd4_clone_file_range(struct svc_rqst *rqstp,
 					&nfsd4_get_cstate(rqstp)->current_fh,
 					dst_pos,
 					count, status);
-			commit_reset_write_verifier(nn, rqstp, status);
+			nfsd_maybe_reset_write_verifier(nn, rqstp, status);
 			ret = nfserrno(status);
 		}
 	}
@@ -1472,21 +1483,21 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	}
 	if (host_err < 0) {
-		commit_reset_write_verifier(nn, rqstp, host_err);
+		nfsd_maybe_reset_write_verifier(nn, rqstp, host_err);
 		goto out_nfserr;
 	}
 	nfsd_stats_io_write_add(nn, exp, *cnt);
 	fsnotify_modify(file);
 	host_err = filemap_check_wb_err(file->f_mapping, since);
 	if (host_err < 0) {
-		commit_reset_write_verifier(nn, rqstp, host_err);
+		nfsd_maybe_reset_write_verifier(nn, rqstp, host_err);
 		goto out_nfserr;
 	}
 
 	if (iocb_flags && fhp->fh_use_wgather) {
 		host_err = wait_for_concurrent_writes(file);
 		if (host_err < 0)
-			commit_reset_write_verifier(nn, rqstp, host_err);
+			nfsd_maybe_reset_write_verifier(nn, rqstp, host_err);
 	}
 
 out_nfserr:
@@ -1662,14 +1673,14 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfsd_file *nf,
 			err2 = filemap_check_wb_err(nf->nf_file->f_mapping,
 						    since);
 			if (err2 < 0)
-				commit_reset_write_verifier(nn, rqstp, err2);
+				nfsd_maybe_reset_write_verifier(nn, rqstp, err2);
 			err = nfserrno(err2);
 			break;
 		case -EINVAL:
 			err = nfserr_notsupp;
 			break;
 		default:
-			commit_reset_write_verifier(nn, rqstp, err2);
+			nfsd_maybe_reset_write_verifier(nn, rqstp, err2);
 			err = nfserrno(err2);
 		}
 	} else
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 3aa4522ca0a4..18171ccc6d16 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -86,7 +86,12 @@ static inline bool nfsd_attrs_valid(struct nfsd_attrs *attrs)
 		attrs->na_pacl || attrs->na_dpacl);
 }
 
+struct nfsd_net;
+
 __be32		nfserrno (int errno);
+void		nfsd_maybe_reset_write_verifier(struct nfsd_net *nn,
+						struct svc_rqst *rqstp,
+						int err);
 __be32		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			       struct svc_export **expp);
 __be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
-- 
2.54.0

