Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192824;
	b=q/r8m4H5I1Db6siSr63G2nuU8I3hHMoyy5u8+Kbq4D9VWgIb+SZQWkW/eGSg2UhbGU9I
	 ppbczLDXn9on38pcn3YITOV1codJ002Mmi9eCFwEqDf2FHBXtD1NdbsC3Z+dlDwLcR3O+
	 bOGrm7bGFRzAq9G081ov7NjPfvzqGnO2GZBgHedEAW5SA+XQF7wlAK4L3M9PdUpvaHSQA
	 g5LfheGyK7Jprpxs7sbiZKX1OkERkCNj4DRnm/2rAef+AbfI4J2A6LeiYptKjwBmR1ubI
	 IcXTQ2qWY699GPB2lsxwhBp8QzcK3/qsooEYR+SXNOCeRx40wYA5UMJsTyCksDziVSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192824;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=f1uBVWn4s/1zp+wuImj1j2AY/9zUVyUv703EsQmybr8=;
	b=AmdD9rirQ3oZVBAWBpgi/1WOiusvAlNI9Iqu6D6APOaJP5Un+AmW8hsEDwvYNdj7DkCl
	 Whg8l4lbAGZ+0oR0oTwnjc/QiamkFY7P+hiZDSmY1sR/PmtB0MLZTXoF6tIzG2LiT9Un4
	 Ll8U8J9FYnEDraIDN6FaYov/VU1mqX56P3ldchgjlU8AmiHZ0lpmTUooCZd3S67hjUIEh
	 rOjZsubEB4rGbMLv8QgLj7J+tvpqeAqmv7meEnRKbUHur1REBKebUuJZoTFrV13G87FMb
	 XSKE7SkPhwOX9O2YEf5mv3X6Yf97Hfi8doS2y3oW6eLQIb7vsId8RSdKpxXpMqOGpBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TqDA1WMK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FC5D60A3823;
	Fri, 20 Nov 2026 16:40:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TqDA1WMK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D08B61F000D4;
	Fri, 20 Nov 2026 16:40:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192824;
	bh=f1uBVWn4s/1zp+wuImj1j2AY/9zUVyUv703EsQmybr8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TqDA1WMK7qH24Ja1QE7ID44g4r+uId2St9SmKTlpcuFoI0aCOVGq3xC8wKDCoLPI0
	 RjhGXFOVX3USCQ1toRgwqwNE6AvbrqqQN4T+jarQwwppbWl7d0t8dXTWsvCsSYSniR
	 dL/aytVuQT8bTBCbThprzMwS1Fqq+rmGfOM1juAK8nLTtDcahNIG4+1UWwpeCJCpzm
	 Snd501pHMWy/g8BTI4UZixgzsWk5zr/yyJIXQzV1q4rojakzoDoSQfqxvqB75t5ofM
	 V8gPgQm+fKhzz4qQEj6EaMkii+FTrrK75zsmZpBaiyu8OXQjVK+aF5CX42l+HAlNOh
	 VDslMf86tUfIw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:12 -0800
Subject: [PATCH 06/11] nfsd: pin the client while a GETATTR holds a
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
Message-Id: <20261120-delegts-fixes-v1-6-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4878; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ddkZX/A/sapEzbY91TLtIexAzdmPuBoCVR3j+qEy8Vw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfxAvxojLqfVUZ48WaxJGl9JmQnDJ1gFQNp1
 a7muLHelV6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38QAKCRAADmhBGVaC
 Fcj1D/9uHBf6YsOvI6HMHQUESpm4dWRtB7JO9ai64LYZXIMFBbttxbyp0NFUoREZFlWSFuffZrw
 S4Bh0ks8V9qNdCYId8HDyE6/vgmTb96c2U1SLRjwUPCUuN6bb6oJPD2W62kD+pqDb/bbCZYAOtR
 JgPrGzBWDeBaSIL+3E4qsM273/C3rgxqVBKTsy5Gk0wFKGp/58H1iAofI73hDPCFaalwCPfxWn6
 kMwia6kXth+CsqhaqwbCa8Q6ZcATQjS0wZBs7t72tUkrvyVlYkFF5UEfqvK2eHruubR4pXjyWVN
 z7FWYAZQ6wv8w2zcMM65DqXZVQFfY+B4/dHKW9GIN2Hl+PrZj1Eq8NrD5cfZR2NWP3L6RZL39Pn
 fx05lOfBtceWuBFWeWTYkuVvmamWA6z9gLwT934wjnLKpXhrKl5aEgYpNrFXoiuOafa/ntn/p7D
 9X3DNNJsOeFE176rXYlZ+olTdvVCXLPqzDK1TLKhoUChaFKjkPUdZAJ8l8lAb2r0z3j/0rez1Ks
 qNlNiqnzhWSV5AZptPhwKEpVVGB2AyJ28KWFOdLpmIgOWJAPuIsCsq0ZULXa/EZ1+bPiFIO8Vaq
 IVIdI2AugR+WyCUrIwwqj0+2RCsFOP97sHsPHsSoqSVwqeMxY9E/C7f49DQHnXgZxdB2vyUKQ5s
 GZMTYXzDAS3pPag==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_deleg_getattr_conflict() takes a reference on a write delegation
it finds through the inode's lease, sends CB_GETATTR, waits for the
reply, and drops the reference only after that. nfsd4_encode_fattr4()
can also hold the delegation until it has encoded the reply.

A delegation reference doesn't keep its client alive.
__destroy_client() doesn't wait for stateid references, and the final
nfs4_put_stid() uses the client (cl_lock, the stateid idr and
->sc_free). If the client is destroyed while the GETATTR waits,
for example when its lease expires because it doesn't answer the
callback, the GETATTR's put can touch a freed nfs4_client.

Under flc_lock, while the lease is still on the inode, take a client
reference along with the delegation reference. Client teardown removes
the lease before free_client() drops the client's initial reference, so
the client is still live at that point. nfsd4_put_leased_deleg() drops
both references.

Fixes: c5967721e106 ("NFSD: handle GETATTR conflict with write delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 41 ++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4xdr.c   |  2 +-
 fs/nfsd/state.h     |  1 +
 3 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 64bf2e96dc7b..0cd139ee0048 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2912,6 +2912,38 @@ void nfsd4_put_client(struct nfs4_client *clp)
 	kref_put(&clp->cl_nfsdfs.cl_ref, __free_client);
 }
 
+/*
+ * Reference a delegation found through its lease, for use after flc_lock
+ * is dropped. A delegation reference alone doesn't keep the client:
+ * __destroy_client() doesn't wait for stateid references, yet
+ * nfs4_put_stid() uses the client. So pin the client as well. Caller
+ * holds flc_lock with @dp's lease on the inode. Client teardown removes
+ * the lease before free_client() drops the client's initial reference,
+ * so that reference is still held here.
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
@@ -10854,7 +10886,7 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
  *
  * Returns 0 if there is no conflict; otherwise an nfs_stat
  * code is returned. If @pdp is set to a non-NULL value, then the
- * caller must put the reference.
+ * caller must release it with nfsd4_put_leased_deleg().
  */
 __be32
 nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
@@ -10899,7 +10931,10 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
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
@@ -10940,7 +10975,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
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

