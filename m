Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997656;
	b=sb702DcwCpg+t9GtV7/sY0hrWnRGvhVqUD2NM3zchR3vL63Lztq91dxePo0MdAi9COYc
	 JFWnOgdZE/XlIOAWHlK64DYcu7zWbBN3PwMUolUyvm7OqqR9kfRZUT48KxbNHrnIdAfLJ
	 i5sijVwp0hkcYKLA+1JRnsZc49xLnhFecrhRzjoN+YsgNfUD4S3LYpyJUTNK3Tj3PucdR
	 AyHf+gN1kpoEXegLWzDB5t4WCPZV/w23mBEwtnVeUdkTe+wkS3q/RSbO7Sp7Fuf7/A+0k
	 DJPI2fuRmuShc7a3SdD8f+HHPqG3du04vsoXAllUx5aErEI2oDD9pqJNZY77AxDyGwg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997656;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=yzxi5MO+FZ+4cCKKvEI+jYQFL51rqA8IqdeXo9rNAd8=;
	b=rDCTrP2ODamInxok8vkjXmlEtaG6rSwvYLgEu6MUi3hhcdx3DyxtzAp4l8LgYkXvF96e
	 SgGRdIbZD0DNJ7856itAV+v1dfk4QUo/G2m5iFIOrxEwIhUu1rQg+Wb7deD/caGytrfZx
	 XHslmrw5UxMm6lETEvAFfN15BLOpdxvkt5lC7KP4GOUyrJcJWMwAhnR7Jz4ZfX7o/VoyG
	 BqYFBHH3wpD9jMDsO0c7uRPFBU5tMI1d0TFi2fV3YC5HTEh7KMJLBR18u1jvKGjm8pYrB
	 WzJP22kJGHOuekUH9hb9tPei22hS29UvkU6v/E5XO3yF3+mnuG83c1CJZxW8ImA/93Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oB0QMvrh;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7921606D801;
	Fri,  6 Nov 2026 20:40:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oB0QMvrh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF5541F008A2;
	Fri,  6 Nov 2026 20:40:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793997655;
	bh=yzxi5MO+FZ+4cCKKvEI+jYQFL51rqA8IqdeXo9rNAd8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oB0QMvrh5xW6YV+DbiktqaVcvZuYe6p1N1HGwfen8Rvyw28tdsi1LSnoxIa7OO+rr
	 0e/VccxM2Ab/kEktFUMv7ncaSO/M344LDSx08JMAbX6R5O+4AXyDW0w9eSfHoso6Vu
	 ZhdEA9HLX7Cj4eYMTAlvO2FFEXAHu+IqklEd0bGw6/AcubDD6vETd/5ftA5U7n/s22
	 fZ0d+7kzzU93tqTsHVt7uLrgNYYNcN661nf7hQywEh3PaBStAS4wTSSQ9s1LpVIoap
	 t+kDcEzp6LWegwiOd5C3E/gwQJbf+LLQNitTdfUapipzlnAXVm09vRmz29nN4xHJ0c
	 wdMuXfrHg/sVA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:40:31 -0500
Subject: [PATCH v2 5/5] nfsd: mark the delegation written on COPY/CLONE
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
Message-Id: <20261106-deleg-cb-getattr-times-v2-5-8433618ab9a1@kernel.org>
References: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
In-Reply-To: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6510; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QDZmG66B93zNtGVblZ7nkvT1E3eui/pn2XB86GIcVzk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7jtRpwEOO2UIkB4OFpgrCvETBkTpVvsb63iNB
 IGHjUb+QqqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau47UQAKCRAADmhBGVaC
 FUXAD/wIcaY24TPTH933FXBVuWM+HlKZMxoAS07ldpkRH7qy6QOcMkZH8cmR4he3OSyY6VUQx4v
 CIvcOll6xTymJcd3ffWz2mtAuXugJuDqanhxvBeNK2mWvhPmqwlVQNaSecAWWxamChwL0d0LB9s
 DW615Ti75T/S7h8Dcj5Py9aqZWRAezNl+P1Uc+N5xpE7XI/idNVzX4Q//yj166DDB1TAXbfbEIr
 TKxC/pAaX1mopxlSl6mVhyRIC+DF8PfX9aD+KZPXdkag0MCjFkLQUg6vSHQTxcKYhvO7kkpluvr
 RLsC0LQn8/K3QC4OUFzLgMraSQItoXB/WWCcZrjjTIyH4syjU74hf9x5PT75wySbyUsPz62cyYn
 snk8Lh2iraFl4cCQEP+u8BwYeh/+SaEXIm7SHGYewVBxUvXlr1mIGCa/0028uwAwxWxBhxxXFK0
 BCGgHOPNNG1+aOWOy3KSney+Hi1OJ959SW4xyLLZOtSe94BphuFDhEJJbK1A6oeZuEHVWVDSGCf
 RifJXtspRLB+p0bEi5UQ5Bgv2CclTuiVka5BzkcsH6bYtKiy8GAnyQ2Ue+JSvAelcjTsdb3COKD
 cr8aN0POIPIP+/N2qeAvDfLynLUnISftxQmkZfytRJaLtudIhuEb/j7ol/j0L0fHA1Q1i/xZo/M
 vK6BRa207kH1dCw==
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
stamps them via nfsd4_finalize_deleg_timestamps(); other clients' GETATTRs
go through CB_GETATTR. The async COPY thread has no filehandle, so look
up the nfs4_file at launch, and have the thread mark the delegation when
the copy has written something. That also covers a delegation granted
while the copy ran.

Fixes: 2863bac7f49c ("nfsd: update mtime/ctime on CLONE in presense of delegated attributes")
Fixes: 4183cf383b6f ("nfsd: update mtime/ctime on COPY in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  | 49 ++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      |  3 ++-
 4 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 25613c1ffaaf..c7ede1e7f697 100644
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
+	/* Before CB_OFFLOAD tells the holder to supply the times */
+	if (copy->cp_res.wr_bytes_written > 0 && copy->cp_dst_fi)
+		nfsd4_file_mark_deleg_written(copy->cp_dst_fi);
 	nfsd4_send_cb_offload(async);
 	/* Drop the kthread's reference (taken in nfsd4_copy()); copy may be freed after this. */
 	nfs4_put_copy(async);
@@ -2382,9 +2406,13 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * the callback stateid zeroed.
 		 */
 		dup_copy_fields(copy, &async_copy->cp_copy);
-		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
-			       FMODE_NOCMTIME) != 0)
-			async_copy->cp_copy.attr_update = true;
+		/*
+		 * The copy thread has no filehandle. Look up the file now;
+		 * the thread marks its delegation if the copy writes.
+		 */
+		if (READ_ONCE(copy->nf_dst->nf_file->f_mode) & FMODE_NOCMTIME)
+			async_copy->cp_copy.cp_dst_fi =
+				nfsd4_file_hash_lookup(&cstate->current_fh);
 		memcpy(async_copy->cp_cb_offload.co_referring_sessionid.data,
 		       cstate->session->se_sessionid.data,
 		       NFS4_MAX_SESSIONID_LEN);
@@ -2415,10 +2443,9 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
index 360b8886dbc0..fcf7874514cf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6288,7 +6288,7 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 		nfs4_put_stid(&last->st_stid);
 }
 
-static noinline_for_stack struct nfs4_file *
+noinline_for_stack struct nfs4_file *
 nfsd4_file_hash_lookup(const struct svc_fh *fhp)
 {
 	struct inode *inode = d_inode(fhp->fh_dentry);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9c36076921de..f7a8c04be540 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -988,6 +988,7 @@ int nfsd_handle_dir_event(u32 mask, const struct inode *dir, const void *data,
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

