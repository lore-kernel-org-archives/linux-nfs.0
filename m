Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549761;
	b=LRA3uKK+ZBzPHxdHwqvFkXLrbVvFxokaU6ynQkdAMudWHZaPIDPydqQu2yn2c7jmP4mH
	 04QnIKiDOJsHVX3VBGzCpmGbm1oUbX3I+ykZVSCbynE9AmX9dkiZKX68WciCD8b1OE2yH
	 VR0NwiS0CjtHu5BjHyamjiek5Pnte2LE3zZy0jhwdmFyUPSZgeN91usU844cfi96eCFfi
	 aHYrS63BlNQzatnR60/72aD2SkeogDsn5CxscL8+mk4pnOrieonZL5jamOQqocQ9cCdgV
	 RzcrN5yAG/X2I6izxio2rCv8grna5XlGHZh+mlnC0zQinVBdfoMWweIvct5dT/18pwg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549761;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=i64St0ZDINPGuhs5UmewT2T5OBCrdSEPbCFt5v/89y4=;
	b=utG73gUjKUwpoSWRWTGfcqTnBtSEha4RBzQpeV72cAs0X/4rHNrQSmtfkZbxLveDgRet
	 U2d+30KNcFqhfAqmhGHsqHU8Vj4yxpYBpW3uT8ZpcEmPOdhbdOzqPTMvbYlVsBO8W5S16
	 5yUPpmmIb1eSsQKa9apy/8xbLgNXOWFzB0NnAi2nClVIzK4fHYMaORfMNuG6SrhUN8ijM
	 LjfdA5LNt7ampPuvhsYNMt8bOh0Ijt+5JfLkBUquyf4StE28566GNHAMW3W2NzAoxeFrj
	 qp2q7+XlN4HSb/civpIqBetGnuoi4W7Fqmw6JtDtVy6+fSUlIbXO3Xvvkyyi2Mja/gQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N5IvkwB0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE119606A68D;
	Tue, 24 Nov 2026 19:49:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N5IvkwB0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C8B021F000ED;
	Tue, 24 Nov 2026 19:49:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549761;
	bh=i64St0ZDINPGuhs5UmewT2T5OBCrdSEPbCFt5v/89y4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N5IvkwB0XDns4GHdyJBTE+CSfNqF79yh3mGki45T94l4PIDMbhVl9V7ShreOSwUS9
	 wDLAV5E6Yr1l2ofstOCpFMRWiQwLfEE1veNP3tp+JkEG8LkUJOOyGzmMYvsWZYzw+h
	 yh+qPhVpPu1gMzx4crEdjMLtZIxL/ccTpfYQWRQ0EkAn/vRkd2kG0VZzWSVKXR1F4f
	 b9LEM3LZ7NQDcJpHYpEVUnj6HbYX4BDbZp7T/71KlKpE492HcZeakxIMJE3LhspyFw
	 UnvIOLAcAPtvWoDVt61GobGWQgnvA3r7lixZZkPYZt8hLy226QLHFQ1fWbMJcrGAB6
	 SxeN+Eqq+MCnw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:45 -0500
Subject: [PATCH v3 06/12] nfsd: pin the client while a GETATTR holds a
 conflicting delegation
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
Message-Id: <20261124-delegts-fixes-v3-6-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4940; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=TfGwIIa640s+L2DJWLXZ1zXJX7IDlVxD/S2qTX7e29U=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo2jj0+UAcOw54/sBuiNgmFSa1rcxA/Lxpsp
 57IxYso+/uJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNgAKCRAADmhBGVaC
 FXosEADU3uyQrsfuk3rk6Q+VLqpd+N5csl8bnde+BFGtKMAnYiJUjTs5XyIu1A+yADuOEMoUqhr
 Ejy9xUa6IrlbJf8aK1mjWMIVqZOePZh9OvxFopot/Lj300BQAN7bInonM1x4hw2pTXxw0qcrUBU
 NJ9nqxBgoHEvcvnGe+mgg/CuUTvNPw/AUutMgq6AwEEwODb0ZmsGevqdAa/4G3CKDVMc3n3exoz
 mWmzRI3kW6hpCIZ8eo5p7yXOlpWjj3SeC/yDy9kw9S4A+46TXR9QVMC7y+G2sLaZ7B5X51S+hW5
 6gZlaMstCxYwWZeDUXAz2ASN7CgXM6GnvfqwooEAK6+n3bk21aixL7qQf6pdzJS6bJP5R8HOyFV
 zBydgHiN2vYoK4iam6tXAFSXQMNhJCdMFOCPKhOoCYTQ8firQdwT514/A8aYioHsdtz2ID9GwiN
 puAnOKwJRlrNUhNoMDnxqTAggfXMGBgHUOLVjbO5xwM1JLffEda+HNrVvlLJr2Mn7JLV2iUCHS9
 MoLuGl4haGmI+hcPhN1HLeIYjgragmexumn1jKorsrtwq0dUhYdpMOnhd1kBMucxbM3QfYdCZUt
 jrjnjkoJolU8/GV+Em9uRS3riQP006svarm9WbFTveGp3OHLt4xwvCHTlVQiDlaIARRgUbpuIkf
 5iiTFGz9lMGURww==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_deleg_getattr_conflict() takes a reference on a write delegation
it finds through the inode's lease, sends CB_GETATTR, waits for the
reply, and drops the reference only after the wait.
nfsd4_encode_fattr4() can also hold the delegation until the GETATTR
reply is encoded.

A delegation reference doesn't keep its client alive. __destroy_client()
doesn't wait for stateid references, and the final nfs4_put_stid() uses
the client (cl_lock, the stateid idr and ->sc_free). If the client is
destroyed while the GETATTR waits, the GETATTR's put can touch a freed
nfs4_client. For example, a client that does not reply to the CB_GETATTR
can have its lease expire during the wait.

Under flc_lock, while the lease is still on the inode, take a client
reference along with the delegation reference. Client teardown removes
the lease before free_client() drops the client's initial reference, so
the client is still live while the lease is on the inode.
nfsd4_put_leased_deleg() drops both references.

Fixes: c5967721e106 ("NFSD: handle GETATTR conflict with write delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 41 ++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4xdr.c   |  2 +-
 fs/nfsd/state.h     |  1 +
 3 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f865548c297b..07f8caed5198 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2921,6 +2921,38 @@ void nfsd4_put_client(struct nfs4_client *clp)
 	kref_put(&clp->cl_nfsdfs.cl_ref, __free_client);
 }
 
+/*
+ * Reference a delegation found through its lease, for use after flc_lock
+ * is dropped. A delegation reference alone doesn't keep the client.
+ * __destroy_client() doesn't wait for stateid references, yet
+ * nfs4_put_stid() uses the client, so pin the client as well. Caller
+ * holds flc_lock with @dp's lease on the inode. Client teardown removes
+ * the lease before free_client() drops the client's initial reference,
+ * so the initial reference is still held here.
+ */
+static bool nfsd4_get_leased_deleg(struct nfs4_delegation *dp)
+{
+	if (!refcount_inc_not_zero(&dp->dl_stid.sc_count))
+		return false;
+	nfsd4_get_client(dp->dl_stid.sc_client);
+	return true;
+}
+
+/**
+ * nfsd4_put_leased_deleg - release a delegation found through its lease
+ * @dp: delegation to release
+ *
+ * Drops the delegation and client references that the lease walk took.
+ * May free the client, so the caller must be able to sleep.
+ */
+void nfsd4_put_leased_deleg(struct nfs4_delegation *dp)
+{
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
+
+	nfs4_put_stid(&dp->dl_stid);
+	nfsd4_put_client(clp);
+}
+
 static void
 free_client(struct nfs4_client *clp)
 {
@@ -10889,7 +10921,7 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
  *
  * Returns 0 if there is no conflict; otherwise an nfs_stat
  * code is returned. If @pdp is set to a non-NULL value, then the
- * caller must put the reference.
+ * caller must release it with nfsd4_put_leased_deleg().
  */
 __be32
 nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
@@ -10934,7 +10966,10 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 		return 0;
 	}
 
-	refcount_inc(&dp->dl_stid.sc_count);
+	if (!nfsd4_get_leased_deleg(dp)) {
+		spin_unlock(&ctx->flc_lock);
+		return nfserr_jukebox;
+	}
 	ncf = &dp->dl_cb_fattr;
 	nfs4_cb_getattr(&dp->dl_cb_fattr);
 	spin_unlock(&ctx->flc_lock);
@@ -10975,7 +11010,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 	}
 	status = nfs_ok;
 out_status:
-	nfs4_put_stid(&dp->dl_stid);
+	nfsd4_put_leased_deleg(dp);
 	return status;
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 950c67362566..e6131095024f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4106,7 +4106,7 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		if (!timespec64_is_epoch(&ncf->ncf_cb_atime))
 			args.stat.atime = ncf->ncf_cb_atime;
 
-		nfs4_put_stid(&dp->dl_stid);
+		nfsd4_put_leased_deleg(dp);
 	} else {
 		args.change_attr = nfsd4_change_attribute(&args.stat);
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e9816000c943..f80abcc278f6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -977,6 +977,7 @@ extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
 void nfsd4_get_client(struct nfs4_client *clp);
 void nfsd4_put_client(struct nfs4_client *clp);
+void nfsd4_put_leased_deleg(struct nfs4_delegation *dp);
 void nfsd4_async_copy_reaper(struct nfsd_net *nn);
 bool nfsd4_has_active_async_copies(struct nfs4_client *clp);
 void nfsd_update_cmtime_attr(struct file *f, unsigned int flags);

-- 
2.56.1

