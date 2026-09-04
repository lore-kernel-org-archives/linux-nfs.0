Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC8124CA29A;
	Fri,  4 Sep 2026 14:17:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788531468; cv=none; b=Hv6SNj43mVswCG5jjlpFktdghO5T9qLWJfkE+K1vQz+TikvTNEp29DsGYLLzQFuEb4WJbgzKt+jtCl7IpobluC2iWMsBCS2OEPMGANFrCDSHjDHbuwzWfg6hYftDz63FYHwVMISnNcgX9hwDon4MJBCTfJ81dTaGpU/UlxKbElo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788531468; c=relaxed/simple;
	bh=8hRIrkXhsCHuH6/33Sbko533YgmaaqWhPLGLG9ilVQY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AKVjZkEf5emzf7f13fYs/cpVOCeXGleLksWae5/hW+rYnY+w0fZPL8nT4SyYN6Qc3G6u72kLU98GpJ+vgbcfJYz+mitfwhuD6KEWble82WvYHDHqqBMFs4OhUZt213O9MUFVh2zgPD3rK81daFnNL6ZkLr/M2bjTHUV4LH0iKRw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MBLOsdgv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MBLOsdgv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48AEA1F00A3E;
	Fri,  4 Sep 2026 14:17:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788531466;
	bh=CKpbti+kDC+b0CxbSlKMt4z9dBXGZBkI8Ba7PnNyl9I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MBLOsdgvrrsyDt17ftt84VpXoYBtrys2vkF2o7WPE9KG9LpvA+9bpgD5JLwCq2WO2
	 AJ/7o4HeEzOf2jV8ciaV7TKOhzgzzot5DPBBlLdkW6mwvktJ64KBW5VA1oAJg2Kg8n
	 O2HHEPw/zLTdkxX0NL7VL7LIC+t4qlimgS1XgTXogZwoSIjA7eGlUt4r5l10nTAm31
	 V9IJVoc+jmye3SpMGuNjEwYjqdt0GraGcYfHxXmoPwEZgpVmIKR2tFBk2T24Ry/fdp
	 7HVfFGEGR7LLH+Z/JJsqBxS4tHQtox2uwoHF8BaQn2Ox89BAvVajzRGG9enRcHjalh
	 gycWaEkaLb3mQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 04 Sep 2026 10:17:33 -0400
Subject: [PATCH v3 2/3] nfsd: accept a backdated timestamp from a
 delegation holder
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260904-delegts-v3-2-b6062ba75f07@kernel.org>
References: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
In-Reply-To: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
To: Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=9038; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8hRIrkXhsCHuH6/33Sbko533YgmaaqWhPLGLG9ilVQY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmtMGDSaVGepPXMZtNn0ZNA9q1ySp+NfFEPTeh
 hYLqg3T8pyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaprTBgAKCRAADmhBGVaC
 FRtgD/9xDWiIJg0jHDNKAxxjAuqmsAgvXYboe6kibACIxpl2LD+Se0tQtf2wms8asF0TZkyLdme
 ksrSxnsnn6QQYjLwg0l/EGxo7nTkeG9tQ2fCBj0TlNZbyXmn0VuxI5taEReHqfCEBe+JAASD43M
 97iVsQ+3ODJHs3Fz6v6e6Yb26oBxlgtcQO5Vs4ninrcRJI+LSAl/Bf5dMO6s/cwiYMuR0J/O9Qj
 xZPCmWLSQxyNPW0nAZZ4V/ZVZRSES7Td77dhvCfQXUuxLWfiBbCPN73YwTGxFZQ3wnfF5dKF5+4
 yLDKtJucJT5/oxe0hK+0eEPwHRKi/4jAz+AI+2rDP/ND3FWaKd6I3Xwvczfl6Sx73ZHx8k+vsRP
 YZkQ3K0dHfAo0fhtp/aPpAlqziOemXHZ2c3TMMESu8FJwI+3YYHYlCqbC7WTceIlCEbK0BZ3S8F
 e8J77E/r242EQ5CAXXeNpHpwyd2p/qaiRnhUn8PiHJ24G3ucSwLzwSr6KNt6UdkqgoD0VnyPFaf
 FJhJz0IR3Z3z509PLT20DE/XijQeBQ/QLWjEPuJgHzFN8h8Sx5elI/9K4L8QiPuAC1Z+aC5Bc12
 CginHE9leOY5jI9gejTJLWoSGs9d3QyRbEuH+WAgT5DL1LuiDJwZN6RvDG7dWsqAsDMpSTAksGK
 1UQoXBijWpTU5jw==
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
- Compare against the inode before clamping. A file can carry a time in the
  future, set by an ordinary SETATTR, which nfsd does not clamp. Clamping
  first makes an unchanged report differ from the inode and drags the time
  back to "now".
- dl_setattr stops nfsd4_finalize_deleg_timestamps() from stamping over the
  reported times, so only the branch that carries a c/mtime update may set
  it, and only once nfsd_setattr() has applied it. A write that follows a
  no-op SETATTR would otherwise lose its timestamps, and so would one that
  precedes a failed SETATTR. Hold the stateid reference until then.
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
Acked-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 92 ++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 72 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bb74eef43938..edab1144016a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1292,32 +1292,69 @@ nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
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
  */
 static void
+clamp_deleg_time(struct timespec64 *req, const struct timespec64 *now)
+{
+	if (timespec64_compare(req, now) > 0)
+		*req = *now;
+}
+
+/*
+ * Apply the timestamps that a delegation holder supplied in a SETATTR.
+ *
+ * Returns true if the request carries a c/mtime update, so that the caller can
+ * set dl_setattr once the update has been applied.
+ */
+static bool
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
+	 * filesystem. Compare before clamping: a file can carry a time in the
+	 * future, and clamping first would make the report differ from the inode
+	 * and drag the time back to "now".
+	 *
+	 * The times are read without i_rwsem. A conflicting writer must break
+	 * the delegation first, and FMODE_NOCMTIME stops the holder's own writes
+	 * from stamping the c/mtime. touch_atime() and a CB_GETATTR can still
+	 * move them here. A stale read then costs at most one extra update.
+	 */
+	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) {
+		struct timespec64 atime = inode_get_atime(inode);
+
+		if (timespec64_equal(&iattr->ia_atime, &atime))
+			iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+		else
+			clamp_deleg_time(&iattr->ia_atime, &now);
+	}
 
 	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
-		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
+		struct timespec64 mtime = inode_get_mtime(inode);
+
+		if (dp->dl_written ||
+		    !timespec64_equal(&iattr->ia_mtime, &mtime)) {
+			clamp_deleg_time(&iattr->ia_mtime, &now);
 			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
-				dp->dl_setattr = true;
-			else
-				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
-		} else {
-			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
-					     ATTR_MTIME | ATTR_MTIME_SET);
+			return true;
 		}
+
+		iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
+				     ATTR_MTIME | ATTR_MTIME_SET);
 	}
+	return false;
 }
 
 static __be32
@@ -1331,7 +1368,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		.na_pacl	= posix_acl_dup(setattr->sa_pacl),
 		.na_dpacl	= posix_acl_dup(setattr->sa_dpacl),
 	};
-	bool save_no_wcc, deleg_attrs;
+	bool save_no_wcc, deleg_attrs, deleg_cmtime = false;
+	struct nfs4_delegation *dp = NULL;
 	struct nfs4_stid *st = NULL;
 	struct inode *inode;
 	__be32 status = nfs_ok;
@@ -1356,17 +1394,15 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (deleg_attrs) {
 		status = nfserr_bad_stateid;
 		if (st && (st->sc_type & SC_TYPE_DELEG)) {
-			struct nfs4_delegation *dp = delegstateid(st);
+			dp = delegstateid(st);
 
 			/* Only for *_ATTRS_DELEG flavors */
 			if (deleg_attrs_deleg(dp->dl_type)) {
-				vet_deleg_attrs(setattr, dp);
+				deleg_cmtime = vet_deleg_attrs(setattr, dp);
 				status = nfs_ok;
 			}
 		}
 	}
-	if (st)
-		nfs4_put_stid(st);
 	if (status)
 		goto out_err;
 
@@ -1396,6 +1432,20 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	cstate->current_fh.fh_no_wcc = true;
 	status = nfsd_setattr(rqstp, &cstate->current_fh, &attrs, NULL);
 	cstate->current_fh.fh_no_wcc = save_no_wcc;
+
+	/*
+	 * The times are in place, so keep nfsd4_finalize_deleg_timestamps() from
+	 * stamping over them. Set this only once the update has been applied: a
+	 * failed SETATTR that set it would suppress the fallback stamp at
+	 * DELEGRETURN and lose the timestamps of an earlier write for good.
+	 *
+	 * A DELEGRETURN that races this SETATTR can read dl_setattr before it is
+	 * set and stamp "now" over the times just applied. Only a client that
+	 * pipelines the two can hit that, and it lands on the old behavior.
+	 */
+	if (!status && deleg_cmtime)
+		dp->dl_setattr = true;
+
 	if (!status)
 		status = nfserrno(attrs.na_labelerr);
 	if (!status)
@@ -1405,6 +1455,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	fh_drop_write(&cstate->current_fh);
 out_err:
+	if (st)
+		nfs4_put_stid(st);
 	nfsd_attrs_free(&attrs);
 	return status;
 }

-- 
2.55.0

