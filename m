Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAEE146EC7C
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391676; cv=none; b=emKTM5mpqoHSutGaLUX/8GFMTEOU5W0H5uHCHs8yLCo4J7yrJWshy38g3d0Aa6ddBbdgRYGTtu5PP0SBa4HgpmOggQ2uVchdr+LkGclGUIBI5ychbG/Y9064aYyjLMaz7aQDx30tStmr+o+/2PwKtdoR0Nv42+vYNmAcBl8l8Sg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391676; c=relaxed/simple;
	bh=vw2LB0PUoV78TxgFmFu13eKW8mFqPmKkpfWNO87idpY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZUTYa3hzzQ/NDq26+Zp9uVlrX0I7nox8f3G706uHKHkVTGN5e1XafXs/t3WlTeYXGsWUPw66HDTv2RyTkDs1X7+fUy46Lt3eOTdTuWV+KOgpQ4GD32G0nUW4rNYNDO7YOPPrazv/j/gWeYiF8g+k6K3AeiCoZy/Dr0uMdm5vBeg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lSYaX9Q+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lSYaX9Q+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1DECB1F00898;
	Mon, 14 Sep 2026 13:14:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391674;
	bh=a4EyfNRQNyOeMnk/zjvhYLekScZUBT1Rk5+xnjJPXPI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lSYaX9Q+mp9z+ZtOHWCrFMBJJXiqK++7TKdH/MWaZj74b+jEbkcyci7hij57I5UY/
	 l3z3KP5z2ZU3vpOivEXcpBwyV9NZk7JQunh4o4tBPk/whCdNZc6J2ooBgDtHujwIRg
	 CChPrTkq5j3T3ae57lClbXasIiH7CyHKdehevFBfmw8JrrW6ppGpG7gYw7uZfJ9kBb
	 IHldxNv5Sds/qPJu0+EpGOtYNkVSLS1mAY/FzI7n0MwUteJy4h7KnlnweEG3abbb2U
	 MZJpZpLcDUypsalhkg9w9WKB9iNofTu5bVkKPC32z7HVAEbACn8hd0NRJFdQ0dl24i
	 CEaJXQ6AL9ZRA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:17 -0400
Subject: [PATCH nfs-utils v3 08/11] mountd: retry export attributes that
 fail to resolve for a passing reason
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nl-crossmnt-v3-8-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4491; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=vw2LB0PUoV78TxgFmFu13eKW8mFqPmKkpfWNO87idpY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/M0CnAk72kTns9fYUt/fcO+TBO4HSC/fI23E
 YT0BgwWV8GJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzNAAKCRAADmhBGVaC
 FadGEAC7QcRgFmSbJeHy5iLxD+ChXFBi8az5MgV4ymquWVhY6bfoZOJhh26OAq6L/wFFKLaTcaN
 cufboUKCABroT3akSmZWMIIBXeAujGb5hDthrkcQkc6K7SZefUhRCDP/nBJyeRAsvRzsyXj6tUd
 wF9z0DMGFbEPTrWCushSUlkHzCGgetP3G5BqjvbG4P/EBX7cO3Uz7z3DI8Qg96+H7jzaFbIf35f
 uA2CeIq1XGQhecMx0w79Gd0dRlfU/GEi97abF3GTzFtWzFEb0IIrw4QGpz9X44t4FaCReQMCO5U
 MLCWKadItm87OPg5HxgLkd/8V1ndTsY/onck/xluEFJO2nU4vX1Z938ex+Y1mmAL9Z5V4w42O00
 xed0mGVcjqY6aH9yA3zqFTPxkEalxzzHROXzahp86i2Ymu3G4Wnu13jBV8je6EKcIs/SyfCoev6
 vLmLL74wm3sVVmyqQVsQyWWHh/BAOILVfFP3SPMhGR1psEJ7OUq60pLPLZRb0G7iIRSl3wvpv75
 Id3zdgOoip+twsqL+Rn830bRTUjk364K2yghgmEPEK7dBTqGbBNNFopXwFpPleLKpFO6zAYe4Yh
 pPGtL4N6UG24x80BS6TIfAG+WWAxo8VVFg8qJUtCWpaR82j149CQyOhRN5b/JZTwYPmxHN8yXQI
 JCuDxdyaoh43UBg==
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
index cbe3df83b0eb..290ce09bb66e 100644
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
@@ -1845,6 +1869,10 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 	}
 
 	if (epp && export_attrs_build(&ea, path, epp) < 0) {
+		if (errno == EAGAIN) {
+			res = EXPORT_RETRY;
+			goto out;
+		}
 		xlog(explicit_export ? L_WARNING : D_GENERAL,
 		     "Cannot export %s, possibly unsupported"
 		     " filesystem or fsid= required", path);
@@ -3637,6 +3665,13 @@ static void nfsd_export(int f)
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

