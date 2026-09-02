Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B29DE4AA1DF;
	Wed,  2 Sep 2026 18:54:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788375288; cv=none; b=UtJTd3IyyuOo0FPKawmfVR8i1ZY2V6hvMJYD7t+ER/r7otj9YEJNT8hvsq8bQdDVigTa9/kxhIxherDptlDLAI7qU8zhkZRkN8/xfVasGHoXCFLerAOyyLBANLKB5nXmY9ZjX2SfeNyXq9vPaU/SrF/HPo3aGV3ygshamLDe7KQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788375288; c=relaxed/simple;
	bh=zpOnJGCqrB02h1B0d3zznq9I/x9ePX3EJZB75zgYoog=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=oJTpr1AXzowRB/YiHZFNB7bSQdsMHK8fsE9Q14vFmBia4FGHXFxOA+wx9V2u86DfK/J8cDanC4s2y2AHg0+3Qi2Z21oP1+kUj3rzlSv63q6viPNQaMoxY3aBiy74WLtoE0JyEXWIA1495GbJel072rA5JYOZ7aBmuW5qpR5POIQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jbplDDe6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jbplDDe6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8567E1F00A3E;
	Wed,  2 Sep 2026 18:54:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788375280;
	bh=S3QnQC4IINb1+lU+a8EnNno4pHTc1k1fQ6VDr+Wyy2Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jbplDDe6JZWLUyinm/XwQ17joUyEIcqL3R776mr6pL6KSzIqYbl3oZJJGzTZNnWz/
	 lY3MxKXtMkerRMNWQ9vi+3zRJi83TZKS2qKVe4qFVrUPVQoq4XQ+EXVo1FADxWvNMT
	 pWrRNr6Ai6n48vgMgzPDtAQsQe2blXHPEVyqYSQ1jP4/5r5RUdeY+VbfIHm+fjHMu8
	 lUuorjQJyOKia6bJQji2jXj+5kLSdIdiqu1HN3Wxe85whtn/LogjZfc0yjixcBRA/l
	 goyDFRuVzBVB2Zv9b9oc5KqzZy/PvN8k+O0KA+oKypLwLrUYza/F9k5B+Z1tM7b27m
	 x3WERaX6m5nNg==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 02 Sep 2026 14:54:15 -0400
Subject: [PATCH v2 2/3] nfsd: accept a backdated timestamp from a
 delegation holder
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-delegts-v2-2-383cb289ce88@kernel.org>
References: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
In-Reply-To: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6270; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zpOnJGCqrB02h1B0d3zznq9I/x9ePX3EJZB75zgYoog=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmHDsQgSkvFxr2DA2fKK9iipK+tQzITNNguwn2
 D9SrBDaDLWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaphw7AAKCRAADmhBGVaC
 FRRoD/9XNn5IsikH7EfTaQXG37tHQVDyNQsLJmJZDzyAupdYefGKJSH/Fa/wHwqw+YP9blwVuau
 R/5FyCfm6Nbj1BUfJEV4mQjPaYsLYrvWtRzKzZvUHs06acLgyhYU4sAxK1HCfuIDUNLAPsyz836
 oVVXwK5zQZXFl6HgnkM5ZyfcHWt9C+mi3nOPZfZwPFWnpjJaI5Q3NnmNFGoEOz4cvpMVAlCGY7Q
 n13G2OXRYf5hQBEiL8B6HST2R/mOj7Ze+ASEYXTg+D8UpdBtSZlgUDqXRHYyrFah/dz3yk7xWYX
 VTduRIfhEpB1BT4andfb9/Gp/BdHG6FHRtGLPoOUm720AhBqvzahdaF252vo16XT7AkWyzU7f/m
 3Rhi3J372Ricir+RSFYC/t9987S5R4Yi2aBw0dnuhNeWCMn83hlGmPYVpLnjTpQPzh3BT8hm0y9
 BHj+TLzP/2Iv6p3YHhT6H3i8K4xVfH3AZvn9VhVnNaQ/dubW4Yav5NxNa4oAaTJWCZou/mDtRwN
 DxTIV8y9xPvFhj0NqA1WfNoTzyivUERXYsI1vU3iemsfm5Bp6EBtD2ZJ3zewr3lofyLSupqkwcY
 eOjn/YTB8CaHsGRSAhjTMPyIB1cmTzx0qDI0iH97ntP2XkgICc6QGoyHOss18HuIhaP5DJRYkBC
 2n2HEpb+rHsw4yw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A client with an attribute delegation reports the file times in a
SETATTR at DELEGRETURN. nfsd ignores a time that moves backwards. If the
file was written, nfsd4_finalize_deleg_timestamps() then stamps the
c/mtime with the current time, so the file keeps the DELEGRETURN time.
cp -p, rsync -t and tar -x lose timestamps. The SETATTR returns NFS4_OK.

The client applies an explicit utimensat() to its own inode. It sends no
SETATTR while it holds the delegation, so the backdated value reaches
nfsd only as TIME_DELEG_MODIFY. The client can send an RPC for each time
change instead. That also works, but it loses the caching that the
delegation allows.

The delegation makes the client the authority for these times, so treat
its SETATTR as a statement of fact. The client can set the same value
with an ordinary SETATTR, which nfsd applies without a check.

- nfsd accepts a backwards atime or mtime.
- An mtime that moves backwards sets the ctime to the current time.
  inode_set_ctime_deleg() does that, so nfsd does not compare against the
  ctime here. The ctime never moves backwards.
- The client reports the times at every DELEGRETURN, changed or not. Drop
  a report that already matches the inode, and leave the ctime alone when
  neither the mtime nor the data moved. Otherwise an untouched file gets a
  new change attribute every time a delegation comes back and every other
  client drops its cache, notify_change() runs for nothing, and a holder
  that does not own the file gets -EPERM out of setattr_prepare() where it
  used to get NFS4_OK.
- dl_setattr stops nfsd4_finalize_deleg_timestamps() from stamping over
  the reported times, so only the branch that carries a c/mtime update may
  set it. A write that follows a no-op SETATTR would otherwise lose its
  timestamps.
- nfsd still clamps a future time.
- The CB_GETATTR path keeps the old rule. A backwards time there shows
  a stale report.

RFC 9754 says that the server ignores a time before the original time.
This patch does not follow that sentence. The same section also says
that the server MUST accept the change or MUST reject it with
NFS4ERR_DELAY. A silent discard does neither. A retry after
NFS4ERR_DELAY carries the same backdated value, so that option cannot
succeed.

There is still one gap: nfsd cannot tell an explicit utimensat() from a
report of a write. An mtime after the ctime and before the current time
therefore sets the ctime to that mtime, instead of to "now". RFC 9754
requires this. Fixing that would require the client to issue an RPC for
the mtime.

Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 63 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 51 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bb74eef43938..36fead027fce 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1292,27 +1292,66 @@ nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
 }
 
 /*
- * Validate that the requested timestamps are within the acceptable range. If
- * timestamp appears to be in the future, then it will be clamped to
- * current_time().
+ * A client holding a delegation with delegated timestamps is the authority for
+ * the file's timestamps, so a SETATTR from it asserts what they are rather than
+ * reporting that they have advanced. Honor a value that moves a timestamp
+ * backwards: the client could set the same value with an ordinary SETATTR, so
+ * refusing it here only loses data. Clamp a value in the future to the current
+ * time, as RFC 9754 permits.
+ */
+static void
+clamp_deleg_time(struct timespec64 *req, const struct timespec64 *now)
+{
+	if (timespec64_compare(req, now) > 0)
+		*req = *now;
+}
+
+/*
+ * Apply the timestamps that a delegation holder supplied in a SETATTR.
  */
 static void
 vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
 {
-	struct timespec64 now = current_time(dp->dl_stid.sc_file->fi_inode);
+	struct inode *inode = dp->dl_stid.sc_file->fi_inode;
+	struct timespec64 now = current_time(inode);
 	struct iattr *iattr = &setattr->sa_iattr;
 
-	if ((setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
-	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
-		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+	/*
+	 * The client reports the times at every DELEGRETURN, changed or not.
+	 * Drop a report that matches the inode. An untouched file then keeps its
+	 * change attribute, and nfsd_setattr() skips the call into the
+	 * filesystem.
+	 *
+	 * The times are read without i_rwsem. A conflicting writer must break
+	 * the delegation first, and FMODE_NOCMTIME stops the holder's own writes
+	 * from stamping the c/mtime. touch_atime() and a CB_GETATTR can still
+	 * move them here. A stale read then costs at most one extra update.
+	 */
+	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) {
+		struct timespec64 atime = inode_get_atime(inode);
+
+		clamp_deleg_time(&iattr->ia_atime, &now);
+
+		if (timespec64_equal(&iattr->ia_atime, &atime))
+			iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+	}
 
 	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
-		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
+		struct timespec64 mtime = inode_get_mtime(inode);
+
+		clamp_deleg_time(&iattr->ia_mtime, &now);
+
+		if (dp->dl_written ||
+		    !timespec64_equal(&iattr->ia_mtime, &mtime)) {
 			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
-				dp->dl_setattr = true;
-			else
-				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
+
+			/*
+			 * Keep nfsd4_finalize_deleg_timestamps() from stamping
+			 * over the values the client just supplied. Only the
+			 * branch that carries a c/mtime update may set this, or
+			 * a write after a no-op SETATTR loses its timestamps.
+			 */
+			dp->dl_setattr = true;
 		} else {
 			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
 					     ATTR_MTIME | ATTR_MTIME_SET);

-- 
2.55.0

