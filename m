Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256655;
	b=Cj7NbQuUST6MXAl+qLTPF01rG9P6RSAd0fhScaJLyuK4Qu7AUAXpOTwFZHSJsUDR4xaA
	 gsgnZOVQXocM93Y7Sa+Va4CY6rnsHToqpXFWW9GRDp0LGWITQgzuhMNH9/ukUyAAvsBcE
	 2a7/yGFLSfjY570COh5xgqBuOcWW4LtAQIcVJpOZFv+XHa7jG8ucEQ7qql4W7AXZAmQGe
	 4eye+6Eh1+8A3qYRISJ1RZJNa9L3mLPVn/j2VHUyzqPKj0E02OVYuYp0tx+tnTgzf7IOp
	 OBAtzj5s8pGdArsxgrbj9v2ukmhmX5aVZxFK+3902zrKAtyMsqnd+ybkI5KCW7bGgoQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256655;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=b3zdAUQPcHI3v4v2UplAox3Jm4ZOonfcB87hBCXA6WQ=;
	b=zBnx54NFG8VXgYU20JCpDdAvp+KAHPKBsSleRiyZz62W6JRZ2KrZE9o4Ymte9CuaKTLu
	 wRHTaHsQPysyCmVxhPTK2Wg7K13wnZ/Wd28BM744KR3Mfg2+vuk+lMxNfgDd/Yu9US1d2
	 rze7wykU2H2DJCPFg/fPQu/DFWqr3oDjG6z02+HLMj7QqlOYsXP2ZXWEOM24Oq/XjwRgC
	 6FeGc1aHaC3BQm4R3GuP4kMkiwiLOoqhBrEXge35bigXMmz8PHqYPftwOor6SZzxjvfar
	 QbzBGNwbQfngP7brKzfUXoRBKICE4FXRrUDgNnRE8Kft3+cLWknvGD/traY32PjzU5g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aGM+Q9+S;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 629D7606A325;
	Mon,  9 Nov 2026 20:37:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aGM+Q9+S
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 215B31F008A2;
	Mon,  9 Nov 2026 20:37:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256655;
	bh=b3zdAUQPcHI3v4v2UplAox3Jm4ZOonfcB87hBCXA6WQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aGM+Q9+SgWKpWy/LrTP5MCrwe0NubXInm1HOA0LYML3WBOZSEMAWY18KoZdEo+PZa
	 GCl5frx+NE/avAb85JJdm02zyT6RvH4/maUm6bzoYAJJB+OPqNAYqhTQva9UjFD1dP
	 L2KxKNqeaK+I1JpbXtPznr21cS6ka4PzqGjz7wDe2s7CHqr+lfHjm0wBYta+5YPPF3
	 /vxDRMNTxIhhgl9CF9Tt6M0UfZRMdUTmPaxKiLR+M0EgTzbTU//hK+dkyDBgqNh4iY
	 ipUDbblkKSy0Z+bAsqe3V+Zzrut3dpHlKvqql8pbfFpp/UUtogXjTYvh72WMMJqcET
	 8Wcmm1t7kyr9A==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:46 -0500
Subject: [PATCH v3 5/8] nfsd: mark the delegation written on COPY/CLONE
 instead of stamping c/mtime
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
Message-Id: <20261109-deleg-cb-getattr-times-v3-5-710c7244a6ea@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8108; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CkFlfy/wnWqB66IYqPRq3+9X4fRG0rZJ9yIjAsi8eyg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i8BlVP6BgNhNa2BGptTSRcrnH8wABcQokN+4
 rvzeqmT+lqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIvAQAKCRAADmhBGVaC
 FX2qD/9jWtE3wqnM2m8zhvbd8mZSgb5ZQAsbwO9zhBx7UkRw+Ol/cJlywYeH0YIXQDrZ7UC5PoV
 4KSi1uDiOFna8n4JXoM/43Jxeh2wDqHOfdrbPyL5mIBcHa0EXiUQuoJ49I7YsLNvDRY5pWxbfGg
 MMWG/pXsOfjJbFZ4uAnPjvuJ/L5Yeg7VoBCC4Iiw2Zz23K0+4dsZiNAadCL+jtfERguuYGRx7Lu
 tIJk0AwQhh+FRVeQaMWbqcuZeQgZYL3aSzFhkBZUI4OddbjXHXyLJ3wcMJfFbDpTYV5y9beND6f
 PZ7t5g+5dP5p/ocVhqX8pYqHxmgtjs13X0h/RMvLieL7VozjruK+gGgUx56km1DtkU8CVEgAyDe
 1sdXgwpk0PjIe3V2J4l26F4c/tsP1+9zA87PPPp1Ewq1U1j/eFFXUo7GLa5wtxQpaNBnDR5IKZ3
 YAr7tSjAXPBt7CrxbC5PD5dyGsi0DJ3rRggZrzStG+GJkt1ut8NBWb+U07c4cNX62x8TGJ7/erd
 N6sJSzvPOV6AKwYlkw5ANA2tl8JGTEcUDmHmhjgUeD4IZBS1oX67Mg5Fm1nkd2m/tnhl0op1yVe
 MOCBVAB5dCmXPAaV6hkZR1yqwVl0uPeLTV7toT3ad1jlxgJgutvVqfoj+Ly7C2OQSBGJOQjn3Fa
 zbVGeLIMmVIZUtA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Under a timestamp delegation, nfsd stamps the destination's c/mtime to
the server's "now" after a COPY or CLONE. Since commit 6e7daa3dad29
("NFSv4.2: fix CLONE/COPY attrs in presence of delegated attributes"),
the client also stamps its own c/mtime afterwards and ignores the
server's. If the client's coarse stamp lands even slightly before the
server's, the server can't move ctime back when the holder returns its
times, and ctime changes after DELEGRETURN. COPY returns no attributes,
so the client can't avoid this.

Treat COPY/CLONE like WRITE: mark the delegation written and let the
holder supply the times. If the holder never returns them, DELEGRETURN
stamps them via nfsd4_finalize_deleg_timestamps(); other clients'
GETATTRs go through CB_GETATTR. The async COPY thread has no
filehandle, so look up the nfs4_file at launch, and have the thread
mark the delegation when the copy has written something. Do the lookup
for every async COPY, so a delegation granted while the copy ran is
covered too. nfsd_update_cmtime_attr() is left without callers; remove
it.

Fixes: 2863bac7f49c ("nfsd: update mtime/ctime on CLONE in presense of delegated attributes")
Fixes: 4183cf383b6f ("nfsd: update mtime/ctime on COPY in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  | 48 +++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs4state.c | 30 +-----------------------------
 fs/nfsd/state.h     |  2 +-
 fs/nfsd/xdr4.h      |  3 ++-
 4 files changed, 41 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 25613c1ffaaf..a65e13f0f77a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1438,6 +1438,25 @@ static void nfsd4_file_mark_deleg_written(struct nfs4_file *fi)
 	spin_unlock(&fi->fi_lock);
 }
 
+/*
+ * A COPY or CLONE into a file under a timestamp delegation is the holder's
+ * modification, like a WRITE: the holder supplies the c/mtime, and DELEGRETURN
+ * stamps them if it doesn't.
+ */
+static void nfsd4_copy_mark_deleg_written(struct svc_fh *fhp,
+					  struct nfsd_file *dst)
+{
+	struct nfs4_file *fi;
+
+	if (!(READ_ONCE(dst->nf_file->f_mode) & FMODE_NOCMTIME))
+		return;
+	fi = nfsd4_file_hash_lookup(fhp);
+	if (fi) {
+		nfsd4_file_mark_deleg_written(fi);
+		put_nfs4_file(fi);
+	}
+}
+
 static __be32
 nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    union nfsd4_op_u *u)
@@ -1576,8 +1595,8 @@ nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	status = nfserrno(host_err);
 
-	if (!status && (READ_ONCE(dst->nf_file->f_mode) & FMODE_NOCMTIME) != 0)
-		nfsd_update_cmtime_attr(dst->nf_file, 0);
+	if (!status)
+		nfsd4_copy_mark_deleg_written(&cstate->current_fh, dst);
 
 	nfsd_file_put(dst);
 	nfsd_file_put(src);
@@ -2198,6 +2217,10 @@ static void release_copy_files(struct nfsd4_copy *copy)
 		nfsd_file_put(copy->nf_dst);
 		copy->nf_dst = NULL;
 	}
+	if (copy->cp_dst_fi) {
+		put_nfs4_file(copy->cp_dst_fi);
+		copy->cp_dst_fi = NULL;
+	}
 }
 
 /*
@@ -2301,8 +2324,9 @@ static int nfsd4_do_async_copy(void *data)
 	set_bit(NFSD4_COPY_F_COMPLETED, &copy->cp_flags);
 	trace_nfsd_copy_async_done(async->cp_stid.sc_client, copy);
 	atomic_dec(&copy->cp_nn->pending_async_copies);
-	if (copy->cp_res.wr_bytes_written > 0 && copy->attr_update)
-		nfsd_update_cmtime_attr(copy->nf_dst->nf_file, 0);
+	/* The holder may DELEGRETURN as soon as it sees CB_OFFLOAD */
+	if (copy->cp_res.wr_bytes_written > 0 && copy->cp_dst_fi)
+		nfsd4_file_mark_deleg_written(copy->cp_dst_fi);
 	nfsd4_send_cb_offload(async);
 	/* Drop the kthread's reference (taken in nfsd4_copy()); copy may be freed after this. */
 	nfs4_put_copy(async);
@@ -2382,9 +2406,12 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * the callback stateid zeroed.
 		 */
 		dup_copy_fields(copy, &async_copy->cp_copy);
-		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
-			       FMODE_NOCMTIME) != 0)
-			async_copy->cp_copy.attr_update = true;
+		/*
+		 * The copy thread has no filehandle. A timestamp delegation
+		 * may be granted while the copy runs.
+		 */
+		async_copy->cp_copy.cp_dst_fi =
+			nfsd4_file_hash_lookup(&cstate->current_fh);
 		memcpy(async_copy->cp_cb_offload.co_referring_sessionid.data,
 		       cstate->session->se_sessionid.data,
 		       NFS4_MAX_SESSIONID_LEN);
@@ -2415,10 +2442,9 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	} else {
 		status = nfsd4_do_copy(copy, copy->nf_src->nf_file,
 				       copy->nf_dst->nf_file, true);
-		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
-			       FMODE_NOCMTIME) != 0 &&
-				copy->cp_res.wr_bytes_written > 0)
-			nfsd_update_cmtime_attr(copy->nf_dst->nf_file, 0);
+		if (copy->cp_res.wr_bytes_written > 0)
+			nfsd4_copy_mark_deleg_written(&cstate->current_fh,
+						      copy->nf_dst);
 	}
 out:
 	trace_nfsd_copy_done(copy, status);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4566fa86f82f..3bb518270b8b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6304,7 +6304,7 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 		nfs4_put_stid(&last->st_stid);
 }
 
-static noinline_for_stack struct nfs4_file *
+noinline_for_stack struct nfs4_file *
 nfsd4_file_hash_lookup(const struct svc_fh *fhp)
 {
 	struct inode *inode = d_inode(fhp->fh_dentry);
@@ -11177,34 +11177,6 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
 	return ERR_PTR(status);
 }
 
-/**
- * nfsd_update_cmtime_attr - update file's delegated ctime/mtime,
- *                           and optionally other attributes (ie ATTR_ATIME).
- * @f: pointer to an opened file
- * @flags: any additional flags that should be updated
- *
- * Given upon opening a file delegated attributes were issues, update
- * @f attributes to current times.
- */
-void nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
-{
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
-}
-
 static void
 nfsd4_run_cb_notify(struct nfsd4_cb_notify *ncn)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9e8699810e33..8a189f1b0133 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -981,13 +981,13 @@ void nfsd4_get_client(struct nfs4_client *clp);
 void nfsd4_put_client(struct nfs4_client *clp);
 void nfsd4_async_copy_reaper(struct nfsd_net *nn);
 bool nfsd4_has_active_async_copies(struct nfs4_client *clp);
-void nfsd_update_cmtime_attr(struct file *f, unsigned int flags);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_netobj name,
 				struct xdr_netobj princhash, struct nfsd_net *nn);
 int nfsd_handle_dir_event(u32 mask, const struct inode *dir, const void *data,
 			  int data_type, const struct qstr *name);
 
 void put_nfs4_file(struct nfs4_file *fi);
+struct nfs4_file *nfsd4_file_hash_lookup(const struct svc_fh *fhp);
 extern void nfs4_put_cpntf_state(struct nfsd_net *nn,
 				 struct nfs4_cpntf_state *cps);
 extern __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index feda5464f260..8cebeafbfc20 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -646,7 +646,8 @@ struct nfsd4_copy {
 
 	struct nfsd_file        *nf_src;
 	struct nfsd_file        *nf_dst;
-	bool			attr_update;
+	/* async: file whose timestamp delegation the copy marks written */
+	struct nfs4_file	*cp_dst_fi;
 
 	struct nfsd4_ssc_umount_item *ss_nsui;
 	struct nfs_fh		c_fh;

-- 
2.56.0

