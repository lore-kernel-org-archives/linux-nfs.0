Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192828;
	b=MMD3Cr23zUaeaZHmWj1++X2As4Bhb2edTBRkMyRYWmAKJCgxqNr8v0zYh0fbjybydCuo
	 Hb9rbOmOaJ/Rm9WAt7KFlEJekIZU7dN4iDYURT9vEUneUrOWcfl3TuVV2xdCMb1GUIte9
	 B874v74fs5zi5hLUYe7ccvkf0dtEKpoInq8nQE6C2p7VS8xPXffo0JtxAnwRyR/g26BI6
	 Erw12jvqqi44vAgHKxKRw0OscAYU1PqXT+KCtpspPTvFyF2mk6qow4rtn/nmODkvxDDNb
	 fELqfKAYJ1No+XioFK6ZJMESC3cGulSFwreYIIw2aqvlupkW9sXMTltNhoTLV3/4hWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192828;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=2mTPj4QwnrCbCyi+IrxgvrfGFJipe4SXwhCHdFCEAvc=;
	b=I5nsPMVc5ffLj8xDAp88zRh2lX2DALklzvbp3zkAl+wmrV2+92J2nZxmpLgeTZW5C/fR
	 HDfjSvqBsH6uJSU4Lj58hm2XjxTpIAI4oUr5K/NMZHxnFmfUFu7z0mt37W0qxt9USHVti
	 TUwV1Quy/fl+oA9QW1JpZoueODIXHddPHEs09BZeCdKDav3swOn6Zete83FInM0MGRcw9
	 vk64cjUV84qg/ZRr3cuX2VX+AWAww82UljCgFKeCs2JI/nXQfEXSND9LjC1Sytzdcia3e
	 a1jl48H4cCT4PuCcPgUbvg48CBK5k9Ik5F1/8wJi/ljFMzMxIYWvYqktyp47Jzxu9+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dGyhzb+2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 509B560A3827;
	Fri, 20 Nov 2026 16:40:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dGyhzb+2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4C1D1F000C0;
	Fri, 20 Nov 2026 16:40:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192827;
	bh=2mTPj4QwnrCbCyi+IrxgvrfGFJipe4SXwhCHdFCEAvc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dGyhzb+2ym6tYGrlCUspkmBARHn3bLRdlHPGg24Uw6Jt9bdhXqXP7ZBt5pbicQ+LE
	 8bQ/fkO68bevdMJUA7jn4LRKIBjImmUfloQFfWPtyj29L0LSS/sN4VQeWjiOcWNuEq
	 L4kuG88KReWtP53uxymFZ7YrXQlEbK88ykP1j87JwNNMy9k7R4ibvqZ318Ndtpi3Tp
	 JRdNptagskJdBKMIftJmENgaJ9DyigW52MlEwXVL5k/ycLivdCCAAVtE70f577j59b
	 TEeDB8zkn/unKLk1l81AQ4TmvI54EkhOKDeXgIiFnRjW/PvyYmaTwtbgXBcyoVMUI1
	 3jnNLJ5OPw/vA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:17 -0800
Subject: [PATCH 11/11] nfsd: take the write delegation grant stat before
 hashing
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
Message-Id: <20261120-delegts-fixes-v1-11-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6382; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8Gfj+M4jOn3l7mk6iwD2LfaxxFQtn4w1mC47bcTIQfM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfy32GlpnFiRCNBrB8VP2aWfDUtgkTYHN4X6
 eHuPIoDxTaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38gAKCRAADmhBGVaC
 FaT+D/435SdQMbNA98kiYHcl6uVGpw4uHNrENqXppOmVa2g77KLOpMXYkmKXfW0cD0kn9WQiliV
 VIczpilpCV7H9ZGISXGkoJVRuWJXesASxGyCJkz0kCLin9Cn4Gm+IybzXtLYHeWaiCmi+gUU/0K
 4R5rtlwDVjwtxQkPlECYqf++gFOdaCyd51ledf8sJYVilFXBsSYfgO4OMxsx8uSxUIW3F0hE5nF
 2pgYgSP9SVDMwkk3JDpFF0C58Qd5L7Q7FXkTdRYLhPuWjJSVa9D5V28yC2My6vckHQ47UmTWUzP
 y/3xt1gp8pxntFSSDPtzLj98QYAD11npriL9DfuKXAGKub2lIInOVh0pPV3apvFHBv87FXfha3W
 iAawsYorSX6UbZc2aETEOu72696+6m1xt4LTmMCCiVtu+ItEbwo4wyFWfgtRwjI785uo4ouHnfO
 thaynX/oi8ar+ZAVpBTH/fhq3Q0vopTY104yjMs3WeJVn2tq2jespwXEPG692UjQPjykh5B3Il7
 GgOaRtJasbofXBLjFFY2Xnoqh7oPNDAYogqjkkoGMDWzJ5uSV44Bzic9q3ZbvLXW3f66PefPmdH
 5AMHRu+16ZE4T6aRbgtfnyOhrm1/42fwjfzuwrw30Azuk6hKn2MmJssRLnJNaOrVddEJ2PblRbG
 ip5iZFx7zky2+6w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_open_delegation() sets ncf_initial_cinfo and dl_[amc]time from a
stat taken after nfs4_set_delegation() has hashed the delegation. The
window isn't reachable today: a CB_GETATTR sent in it carries no
referring call, so the client answers NFS4ERR_BADHANDLE and the waiter
never compares the zero ncf_initial_cinfo. But an upcoming per-
delegation timestamp record must be initialized before anything can
reach the delegation.

- Pass the current filehandle into nfs4_set_delegation() for the stat's
  export, and move nfs4_delegation_stat() above it.
- Take the grant stat after kernel_setlease() and the conflict checks,
  just before hashing. Grant no delegation if it fails.
- The stat can sleep, which widens the window between the unlocked
  fi_had_conflict check and hashing. The check under deleg_lock that
  the previous patch added still catches a break in it.
- Stat again after hashing, and decline the delegation if the change
  attribute moved. The holder's WRITE through an earlier open doesn't
  break its own lease and can land between the stats, as can a foreign
  write whose break raced past the fi_had_conflict check. A plain write
  delegation synthesizes change as ncf_initial_cinfo + 1, so a stale
  value could go below one clients already saw. Compare with the grant
  stat's change attribute, which nfs4_set_delegation() returns, not
  ncf_initial_cinfo: once the delegation is hashed, a GETATTR whose
  CB_GETATTR reports a modified file can advance ncf_initial_cinfo.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 91 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 61 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ea940d8759b0..2e1abc6b3af4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7276,11 +7276,35 @@ nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
 	dp->dl_recall_grant.valid = true;
 }
 
+static bool
+nfs4_delegation_stat(struct nfs4_delegation *dp, struct svc_fh *currentfh,
+		     struct kstat *stat)
+{
+	struct nfsd_file *nf = find_writeable_file(dp->dl_stid.sc_file);
+	struct path path;
+	int rc;
+
+	if (!nf)
+		return false;
+
+	path.mnt = currentfh->fh_export->ex_path.mnt;
+	path.dentry = file_dentry(nf->nf_file);
+
+	rc = vfs_getattr(&path, stat,
+			 STATX_MODE | STATX_SIZE | STATX_ATIME |
+			 STATX_MTIME | STATX_CTIME | STATX_CHANGE_COOKIE,
+			 AT_STATX_SYNC_AS_STAT);
+
+	nfsd_file_put(nf);
+	return rc == 0;
+}
+
 static struct nfs4_delegation *
 nfs4_set_delegation(struct nfsd4_open *open,
 		    const struct nfsd4_compound_state *cstate,
 		    struct nfs4_ol_stateid *stp, struct svc_fh *parent,
-		    u32 *held_type)
+		    struct svc_fh *currentfh, u32 *held_type,
+		    u64 *grant_change)
 {
 	bool deleg_ts = nfsd4_want_deleg_timestamps(open);
 	struct nfs4_client *clp = stp->st_stid.sc_client;
@@ -7424,6 +7448,24 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	if (fp->fi_had_conflict)
 		goto out_unlock;
 
+	/*
+	 * Anything that can reach the delegation once it is hashed may
+	 * read these, so set them first. nfs4_open_delegation() stats
+	 * again after hashing to catch a write that lands in between.
+	 */
+	if (deleg_is_write(dl_type)) {
+		struct kstat stat;
+
+		status = -EIO;
+		if (!nfs4_delegation_stat(dp, currentfh, &stat))
+			goto out_unlock;
+		*grant_change = nfsd4_change_attribute(&stat);
+		dp->dl_cb_fattr.ncf_initial_cinfo = *grant_change;
+		dp->dl_atime = stat.atime;
+		dp->dl_ctime = stat.ctime;
+		dp->dl_mtime = stat.mtime;
+	}
+
 	spin_lock(&nn->deleg_lock);
 	spin_lock(&clp->cl_lock);
 	spin_lock(&fp->fi_lock);
@@ -7487,29 +7529,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status,
 	}
 }
 
-static bool
-nfs4_delegation_stat(struct nfs4_delegation *dp, struct svc_fh *currentfh,
-		     struct kstat *stat)
-{
-	struct nfsd_file *nf = find_writeable_file(dp->dl_stid.sc_file);
-	struct path path;
-	int rc;
-
-	if (!nf)
-		return false;
-
-	path.mnt = currentfh->fh_export->ex_path.mnt;
-	path.dentry = file_dentry(nf->nf_file);
-
-	rc = vfs_getattr(&path, stat,
-			 STATX_MODE | STATX_SIZE | STATX_ATIME |
-			 STATX_MTIME | STATX_CTIME | STATX_CHANGE_COOKIE,
-			 AT_STATX_SYNC_AS_STAT);
-
-	nfsd_file_put(nf);
-	return rc == 0;
-}
-
 /*
  * Add NFS4_SHARE_ACCESS_READ to the write delegation granted on OPEN
  * with NFS4_SHARE_ACCESS_WRITE by allocating separate nfsd_file and
@@ -7578,6 +7597,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	struct svc_fh *parent = NULL;
 	struct nfs4_delegation *dp;
 	u32 held_type = OPEN_DELEGATE_NONE;
+	u64 grant_change = 0;
 	struct kstat stat;
 	int status = 0;
 	int cb_up;
@@ -7612,8 +7632,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = nfs4_set_delegation(open, &resp->cstate, stp, parent,
-				 &held_type);
+	dp = nfs4_set_delegation(open, &resp->cstate, stp, parent, currentfh,
+				 &held_type, &grant_change);
 	if (IS_ERR(dp)) {
 		status = PTR_ERR(dp);
 		goto out_no_deleg;
@@ -7631,12 +7651,23 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 			nfs4_put_stid(&dp->dl_stid);
 			goto out_no_deleg;
 		}
+		/*
+		 * The holder's own WRITE through an earlier open doesn't
+		 * break the lease and can land after the grant stat, as can
+		 * a foreign write whose break raced past the fi_had_conflict
+		 * check. A plain write delegation synthesizes change from
+		 * ncf_initial_cinfo, so it must not be stale. Compare with
+		 * the grant stat itself: a GETATTR can already have moved
+		 * ncf_initial_cinfo past it.
+		 */
+		if (nfsd4_change_attribute(&stat) != grant_change) {
+			destroy_delegation(dp);
+			nfs4_put_stid(&dp->dl_stid);
+			status = -EAGAIN;
+			goto out_no_deleg;
+		}
 		open->op_delegate_type = deleg_ts ? OPEN_DELEGATE_WRITE_ATTRS_DELEG :
 						    OPEN_DELEGATE_WRITE;
-		dp->dl_cb_fattr.ncf_initial_cinfo = nfsd4_change_attribute(&stat);
-		dp->dl_atime = stat.atime;
-		dp->dl_ctime = stat.ctime;
-		dp->dl_mtime = stat.mtime;
 		spin_lock(&f->f_lock);
 		if (deleg_ts)
 			f->f_mode |= FMODE_NOCMTIME;

-- 
2.56.1

