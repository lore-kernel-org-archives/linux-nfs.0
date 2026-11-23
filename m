Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438767;
	b=H5N8InNHFQWsogJTgCbUEeXKamZTxSJQZ22V56d7xJXOUYH5/DQxOyGByOlrzZg2+H4i
	 AbGcuF/X5j3jU8i9u2wTg9g2ktDPhgjFdKLxVa+n/jR864uLXtznacMv2nFcHxW7jhW7s
	 ecYekXtlQ9LIn4m5KX2hXsMcOcMEpIv+3Vaoqz/YjEGb8HONzKfTP+45+i058dvA1QBI/
	 KxHc3TI+kDYLHgklfeOiR92E7JnHbeZ3jrUsDmTY0foGHmTQO/FSqRW+kLnnputjOE7I9
	 B00mORT7nJw25gX0GbRjlrDoYuTCDb/pa6OcxAuXhEvJoVflLtUVl62RThmbr6fIQdw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438767;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zaE48SwpJwbHgdI3gDYPBUV6vWllG5kgefVD1NaZAGQ=;
	b=rkWq+iSBRKJZsutDMKmcFGzXNPb32WiCVlX5/omP/R22jSEqaHfuVkp/ZmvfNudU9vGY
	 nZa+ZnFktqMWYSHbgpdCam9d4Eb4CJYZ4UYmOQBVDSiEs8i3fs1lL9TGVXVgv7qb+aa6C
	 zV05tOL1HC59oJJUetGslr6rwXwc/yJSKpUBMokLO6opjgvA1SS4RNbeWM/liFD4wUH+N
	 uV5d2+AMGjxaHzokZeYq9UZkuCVdxlUfmnPZTI45mdNpUSMfmP7E6+061NfGGvfgs/M16
	 DibrRzt6ZJqadY8DVGq2IXhoL3HTTO+OIIO+aMpwhTO4hszTOixC2OQybbaHtstxS1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Adv+R6d6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85536606A6B6;
	Mon, 23 Nov 2026 12:59:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Adv+R6d6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 719481F00A01;
	Mon, 23 Nov 2026 12:59:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438767;
	bh=zaE48SwpJwbHgdI3gDYPBUV6vWllG5kgefVD1NaZAGQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Adv+R6d6Sd7EPVUmjpGH+Lr2Zd866SZzOx9XYM5UjxINOY8weOWKE2jXs6pgFBSWU
	 0jRIf0RblGqLRnjn8VP/Us99yTiaeKvFkKsl7RTChRSwtmIdaJN3ghpK4dsSQaHDNw
	 /OlN7oxCDC4xysf3Jk+3zQYb3zIlPHqvQAPZfRTxU9/uZFuxEnZJyrHEWzPbxYSiVE
	 R+SvndSkQsmNry5yHxSX57g5HWu4yb3xXMWMSY8VAgOczLAzQJwOMRv8JN2zLnWPeK
	 7ZISX0ZKU3NHMVcIDeNT3QtQKYl2CY/D6lWMUMTK23gF01+pmw1bovRhg2biKW8TAF
	 zQ/echriYffIA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:09 -0800
Subject: [PATCH v2 06/11] nfsd: pin the client while a GETATTR holds a
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
Message-Id: <20261123-delegts-fixes-v2-6-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4940; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Jj1SuNKQYdokX6WLzLw6Ke20g93MDgEI4eliRp1qya8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDiley3Y1ugQJvvmhUfbKynDbHlEl2O0zo33Z
 G29aLnslZ6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pQAKCRAADmhBGVaC
 Ff49D/9F4QfM8PbisjDYkl5a+CIH/7V76ASygeGZ6ki4U98lAFhPo9/fRPt11fkbMkx1huCc35l
 G+DwGi4H1eqOtexcQ7vFj7ZFmoKeD8NGzDVI1dTwZ4JJ4QJQeJLIJMTH2y/hMWwpGGti9MgV9Sa
 HEifRuVf40Rf0JxH2PxXpPJGDvRCkkXbE251pMoSPjuG+DIeH93d4AAyXSzCJLchVxr9IE1GKA+
 3yjTGe1p6QVqk7E9a/RYrRbZh0++ZvhVhbIGcMGsnxkFWb9b3nNDSkJBL6vjwNFrxL/oMWjhsJ6
 PgonyvFmhUlxLqWTRgAN5oAJNrEyrH8qY/YLn684MoNTclSoiwoU22xxi2Gw7dRPlHgO5uUksdd
 sbmak77+fuQSusfSvcurtedC8chIwLPmeB9XLiE/MSHP1HTiLjg3mkpoIKYbtgN6yrr9ARkmeD8
 RUGcgVOh+EbxDrSTsDQp1thrZTZWh93t1tJao+kRYdFSfRa3IaTX5Fz8wL2ijldZ2pbqfI0EQYD
 tue+NMoxfIOmOI6qo1Nhix0umq+bnPSFAq2OeNFCNA8BM0GXHHqftIIBWyujst4pCJOjdiWmjwL
 kwCR92IEstn9SXC+Sxpvd0FIK26M6nMX1C8Gvc5oZIlLl84fFfXdVwXjtWJE5PAUVduk5cukkXg
 bdHNZgrowrKtb+Q==
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
index 4b28553efc8d..4e7bbaf65050 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2912,6 +2912,38 @@ void nfsd4_put_client(struct nfs4_client *clp)
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
@@ -10880,7 +10912,7 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
  *
  * Returns 0 if there is no conflict; otherwise an nfs_stat
  * code is returned. If @pdp is set to a non-NULL value, then the
- * caller must put the reference.
+ * caller must release it with nfsd4_put_leased_deleg().
  */
 __be32
 nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
@@ -10925,7 +10957,10 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
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
@@ -10966,7 +11001,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
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

