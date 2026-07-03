Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A80F0318146;
	Fri,  3 Jul 2026 03:37:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783049842; cv=none; b=fBRBVoYWTXZjs2T1HNc94bK4Q2oQBcl1tg+uQMKKJdfr1ZmeRqSuktzJdKwwveKYmqMGyV0DGa7LItnCFA5KCYZVqxgUhdEN6ZArecO1IQQKYQKQaQD/QD8E2VuHST+W8I2n0B0j5zzMTlIY+YOGId1V2cQf5R3kakplbWcrcRI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783049842; c=relaxed/simple;
	bh=uw8dNJSIRwmPU6hOtEiQahKvItGTuZZB1YQm6EBduCg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=jL3hbWfoNiVNelmiUapShYcxWvV2l/xX43HgVpnnguIbAzjHdwKykxg7Ttw2IehS1aaThhK8ioDHmNVv0Mx2uLfORfjXwYqjk2PUm2P3ROGh9gjHEYDOTVRItBN2jq6c5zRoUgzznaLAW1Bw4XphYecdL082xZUseFZrBYrFv2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UGj2kn68; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UGj2kn68"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4106B1F000E9;
	Fri,  3 Jul 2026 03:37:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783049832;
	bh=h2gdU2TGu5W6JUdXVgFuxxtiDlZggXXUhPgQZuH1mDk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UGj2kn68+GqrZBevV7VHFoexAaSRizAN3uqVyKbC7ZTXEGxksBGkUvL4SasARkCh9
	 8asMxIHqQVGP0sCJyMCtevNDQ69+1DefTz+r1QNisDBH9GWyJQB7OyVWbhy6rA3Xwt
	 3QvI4eJIwrNY8nsaf2jWqJtIF3ToLYNQEGru72ayQq5Milon59IpLzd/Fp44yyJwJH
	 0p+kHVL3012Jc2s/MvA0TMTlDkgFUSf1KPOjStlBazQW2vi+OZqL8Ju0Ss1YMMpyRK
	 FZXIF0iKDZIgS5YZlUqEpLvuNYy78fK9nYNNAjBWvVn1HdpMAMAGKPXal9nqJMGgNc
	 WIz15MQj8oN9w==
From: Chuck Lever <cel@kernel.org>
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Chris Mason <clm@meta.com>
Subject: [PATCH 5.15.y] nfsd: reset write verifier on deferred writeback errors
Date: Thu,  2 Jul 2026 23:37:05 -0400
Message-ID: <20260703033705.1572486-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <2026070204-septum-trimness-cb0f@gregkh>
References: <2026070204-septum-trimness-cb0f@gregkh>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

From: Jeff Layton <jlayton@kernel.org>

commit 2090b05803faab8a9fa62fbff871007862cac1b7 upstream.

nfsd_vfs_write() and nfsd_commit() both call filemap_check_wb_err() to
detect deferred writeback errors, but neither rotates the server's write
verifier (nn->writeverf) when this check fails. Every other
durable-storage-failure path in these functions calls
commit_reset_write_verifier() before returning an error.

The missing rotation means clients holding UNSTABLE write data under the
current verifier will COMMIT, receive the unchanged verifier back, and
conclude their data is durable — silently dropping data that failed
writeback. This violates the UNSTABLE+COMMIT durability contract
(RFC 1813 §3.3.7, RFC 8881 §18.32).

Add commit_reset_write_verifier() calls at both filemap_check_wb_err()
error sites, matching the pattern used by adjacent error paths in the
same functions. The helper already filters -EAGAIN and -ESTALE
internally, so the calls are unconditionally safe.

Reported-by: Chris Mason <clm@meta.com>
Fixes: 555dbf1a9aac ("nfsd: Replace use of rwsem with errseq_t")
Cc: stable@vger.kernel.org
Assisted-by: kres:claude-opus-4-6
Signed-off-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
[ cel: open-code the reset; commit_reset_write_verifier() is v6.7 ]
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e1737984e0ca..7b0bc4507ad0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1133,8 +1133,11 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfsd_file *nf,
 	nfsd_stats_io_write_add(nn, exp, *cnt);
 	fsnotify_modify(file);
 	host_err = filemap_check_wb_err(file->f_mapping, since);
-	if (host_err < 0)
+	if (host_err < 0) {
+		nfsd_reset_write_verifier(nn);
+		trace_nfsd_writeverf_reset(nn, rqstp, host_err);
 		goto out_nfserr;
+	}
 
 	if (stable && use_wgather) {
 		host_err = wait_for_concurrent_writes(file);
@@ -1270,6 +1273,10 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfsd_file *nf,
 			nfsd_copy_write_verifier(verf, nn);
 			err2 = filemap_check_wb_err(nf->nf_file->f_mapping,
 						    since);
+			if (err2 < 0) {
+				nfsd_reset_write_verifier(nn);
+				trace_nfsd_writeverf_reset(nn, rqstp, err2);
+			}
 			err = nfserrno(err2);
 			break;
 		case -EINVAL:
-- 
2.54.0

