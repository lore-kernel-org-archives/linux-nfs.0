Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB216472091
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143948; cv=none; b=QtDfVEHEaqUouG9LUsRAGE7xj184I/PvfdP2c9bQJRB4dPsOvGmZQkxu6Bc/T543FuJuK+Y+cr+24OipUbPPuVCUXCZ9NLBlp916MtXhydsqTTwYE5Nb8pZh5TUGf7q6hCuZ12l1aQXjsqFKPypTUNCq4RNbXvWhmXcXI2aTsU4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143948; c=relaxed/simple;
	bh=+PdaxVcvGIrChrEokPIR0w3thnNDA6bJOuoydoA1cKY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=VBx0c5TsBpZKKfzdzJJrbUJV4hvrSi5XkCIZ/kiVUwrdl5c3iB1nzj8GRPCRpS0rBSHW6KBOqwFskeb6AAReyxozGu4zze9WgD/n9a4xzCI2B1/EI4eJO3wG9Yf/ZrRahqqTwE1+kl4T6g5JeSvs/xIriO3bgG9iW4KOL5/f4KI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SEoapiBQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SEoapiBQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3AFB51F0089A;
	Fri, 11 Sep 2026 16:25:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143946;
	bh=S3E8vd3S7nZzh1gsKg/mFkXyK9B9p7NpTu7/30tBtgU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SEoapiBQeSmxkrP4tKzLtwsrj+BIrBfoH+048WlSvDImShzS821/XpXqbPw7U+LgC
	 mxCptBBA4RbLMXzk8x9wrpcvd+LHamvBKPujwi76wb5JWqXDxfufkTzde7spqwk+yR
	 BHM4JsTA3yrAupqBYjaotZL2Hpve9bi+ocyPlMr/VpXLG20vcm5jVhUmw9dC+/srHc
	 3kCctsripQgv5W5ZQ0LA9DCnKN7nHtCYhJegTjywo8BV07KE25ZSuVIwPn1hh/fPH3
	 PNXHMQJTCiio2ynTq7dDTm4gbyOUi1EQx55kSXGjgtBAytvXvFpIcDAJh4rwFcVWXq
	 vzT3Y/bT7Bu6g==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:33 -0400
Subject: [PATCH nfs-utils v2 08/10] mountd: retry export attributes that
 fail to resolve for a passing reason
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-8-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4468; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=+PdaxVcvGIrChrEokPIR0w3thnNDA6bJOuoydoA1cKY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuEi9fJAnzgYK0YNBFwR5ose9c63drIOQZH7
 YP18oQlJJ6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrhAAKCRAADmhBGVaC
 FQDnD/44RiVP5PYh4s9DVg0WgA9GyJVzUI8oG1Eo02ZJQhK8d19CSn1y2tNEjbPnkt6eEE0LTup
 TKHXzGuTmDtfP5gr9wA3CH977l1fem1d2YFIa33usmWHcVJrZsdI7bCXeq+KusPbt3VPI0vXs8G
 17sJQHPiGU9yytAG8qy0C6XR0/161ALXT6MzLjBIm1jMz9J0YPVd74zeQQ8hCix0MmY0fLejKu1
 t4QpEzgyXXkKuChv02Mj05X5V7yk7KF2VF2UX0eQQwgWevlkmCBBnuGLR7r+S5xCN+5xto1SVrD
 QNHp4jwrIEYZHe7SKopCTmHU/YQNHCoFjJLtf8KuGorv6wDOLVf5MKdA0XQVOgbMk3wy8kdr+TD
 hicMb3qyZk7CpjShXPQArygJzSdTjRl3yCQ5D4TqsshvWfSi5qvhAow67exL8LycGgT0KlbJ0gi
 //EJ0P4raq8cheGHO/qtm4vWFLP541YznqRjoGYy7lVline6StZqSY+rBOsIUT45PTBjIp6k65q
 wa+04Ysk5PuCszAixFBnF1v8l4vMONfPSpPmvgqTk4/FucnZTP23KVpW/T1Fh0KGs3yHzMTZpZM
 /SaiOu5LntPaQEFD9IHd+if/C30xM2L4xG54RLbbJzqPO/hoVklnkMHWvc2QGCz4QEuSId8JBTf
 10tzohUgDH0iwtg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

export_attrs_build() answers -1 both for a filesystem that can never be
exported and for one it could not measure this time:

 - nfsd_path_statfs() on a re-exported NFS mount can give ETIMEDOUT with
   "softerr", or EIO with plain "soft"
 - fsidnum_get_by_path() returns the same false whether fsidd is
   restarting, answered with nonsense, or has no fsid for the path

Both then set errno to EINVAL, so both downcalls deny the path for
default_ttl.  An fsidd restart takes a working re-export offline until the
negative entry expires.

Report EAGAIN for the cases we cannot decide and keep EINVAL for the rest.
The netlink path turns EAGAIN into EXPORT_RETRY, and nfsd_export() leaves
the request for the next upcall, which is what both already do when
is_mountpoint() fails oddly.

statfs errors are sorted with path_lookup_error(), the same test
is_mountpoint() callers use, plus two that are decidable even though it
does not name them:

 - ENOSYS: a filesystem with no statfs will never answer
 - 0: a chrooted worker thread ran the stat and its errno never reached
   us, which is how the is_mountpoint() callers already read it

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 support/export/cache.c | 41 ++++++++++++++++++++++++++++++++++++++---
 1 file changed, 38 insertions(+), 3 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 7b2ad3ca1611..1a734a4f61f4 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1145,7 +1145,9 @@ struct export_attrs {
  * it must not inherit the parent's fsid= or uuid= - if it does, both end up
  * claiming the same filehandles and the client sees ESTALE.
  *
- * Returns 0, or -1 with errno set if @path cannot be exported at all.
+ * Returns 0, or -1 with errno set: EAGAIN if we could not work the attributes
+ * out this time and the caller should ask again, anything else if @path is
+ * genuinely not exportable.
  */
 static int export_attrs_build(struct export_attrs *ea, char *path,
 			      struct exportent *exp)
@@ -1161,8 +1163,24 @@ static int export_attrs_build(struct export_attrs *ea, char *path,
 		struct statfs st;
 
 		if (nfsd_path_statfs(path, &st)) {
+			int err = errno;
+
 			xlog(L_WARNING, "unable to statfs %s", path);
-			errno = EINVAL;
+			/*
+			 * A strange error - the ETIMEDOUT a "softerr" NFS
+			 * re-export gives, or the EIO a plain "soft" one gives
+			 * - leaves us unable to say whether the path is
+			 * exportable, so ask again later.  Two errors are not
+			 * of that kind: ENOSYS, because a filesystem with no
+			 * statfs will never answer, and 0, which means a
+			 * chrooted worker thread ran the statfs and we never
+			 * saw its errno - is_mountpoint() callers read that as
+			 * definitive too.
+			 */
+			if (err != 0 && err != ENOSYS && !path_lookup_error(err))
+				errno = EAGAIN;
+			else
+				errno = EINVAL;
 			return -1;
 		}
 
@@ -1179,7 +1197,13 @@ static int export_attrs_build(struct export_attrs *ea, char *path,
 		if (exp->e_reexport != REEXP_NONE &&
 		    reexpdb_fsidnum_by_path(path, &search_fsidnum,
 			    exp->e_reexport == REEXP_AUTO_FSIDNUM) == 0) {
-			errno = EINVAL;
+			/*
+			 * fsidnum_get_by_path() answers the same way whether
+			 * fsidd is unreachable, gave us nonsense, or has no
+			 * fsid for this path.  A restarting fsidd must not
+			 * deny a working re-export, so ask again later.
+			 */
+			errno = EAGAIN;
 			return -1;
 		}
 		ea->fsidnum = search_fsidnum;
@@ -1802,6 +1826,10 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 	}
 
 	if (epp && export_attrs_build(&ea, path, epp) < 0) {
+		if (errno == EAGAIN) {
+			res = EXPORT_RETRY;
+			goto out;
+		}
 		xlog(L_WARNING, "Cannot export %s, possibly unsupported"
 		     " filesystem or fsid= required", path);
 		epp = NULL;
@@ -3582,6 +3610,13 @@ static void nfsd_export(int f)
 				      NULL, 60);
 		} else if (dump_to_cache(f, buf, sizeof(buf), dom, path,
 					 &found->m_export, 0) < 0) {
+			/*
+			 * We could not work out the attributes this time.
+			 * Leave the request for the next upcall rather than
+			 * denying an export that is probably fine.
+			 */
+			if (errno == EAGAIN)
+				goto out;
 			xlog(L_WARNING,
 			     "Cannot export %s, possibly unsupported filesystem"
 			     " or fsid= required", path);

-- 
2.55.0

