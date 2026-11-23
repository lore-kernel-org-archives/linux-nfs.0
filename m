Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438774;
	b=vqZ6dcgsTw0j/lVjkpbL0svYY81Pwx8zIxjywHNJ9JVRXLgTF0HiR8XDvzqCVV+ugdmk
	 om9VibLX/nWI5w3k2hxgaGXA62H+EMWeJVYbDTSB4txhpxg+v0vMbBQKtynnuzd6KdqRS
	 wr3qIVYm12QegVRXvZ0ObmR/X0RzVTWxpnB6iXdJmmoniGbTaWIumXpnow7Zhj+z/vKtO
	 NfZJAiyTuH1zmQqs6fOYNCkBtWTQ8igGPfW3gpoAGDchMyKkLcMHw5iSQV3hE+PCByocF
	 6OrPKeFnOaHxwbOuG5IUQ0mJKwwmL9w8vJbIjMEydjlzCf5GISpDpyZuPuJFbCGzjSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438774;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=O+/1Il2aQT9ObY+znQIt+25vqWPop1IVU2Qf+RIuDKQ=;
	b=USa8DX5xyVM5qX9jZtF8WdHOG9XcoK2XXnhjaAyfHjpqNSU1zS7KRgd7tjJjED6gSQX/
	 fwyJYLF2hbTPnLZ9tNFUSb0MyfCyiw7DF/qCirilTVEjJ32s+SuNWkbl5nPAHq9ZJJQyX
	 4/yDabNdyaOjkc12qn94em5GLIGP10WOOydrrpkKOMcXOuTip2mQKtJcwE4mTX1IA0aFQ
	 Rk455QR4tO/NalcuQorIUx3tTzhqGcWIzG3oFXbmgteAh5PnrCm+v6XqVNtITvK5jKYQM
	 D6ltjTpi4sA8dXkU/OcPF2HNEvu7Z+6x7bhOyHaDBnB7rqH8MiSKVs5D8+8vAj78sYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="SnTW/wm+";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 777DF606A699;
	Mon, 23 Nov 2026 12:59:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SnTW/wm+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B22C1F0156B;
	Mon, 23 Nov 2026 12:59:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438774;
	bh=O+/1Il2aQT9ObY+znQIt+25vqWPop1IVU2Qf+RIuDKQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SnTW/wm+fAqCjt+LbKe86AdW29wKBEME9SK78dSKsQYXURT4xJubDv6dSgSx8oInS
	 HuHr91kapv6330xax0cyAK0tO3jpwQWJi+cO3BzlY0+pP7zW5YUvpXSKfFU99IyXi4
	 xUrGoiYFHtZVonfK8oJrWiOyUpE6nK3aX1Yfzl/W7mZSmSeIACLdVuhSbpm9zux/SA
	 jBetyVyPjXoBHYWo624Dtm3nA1Oqx/NgC5l2+vM8704KmGilgputVVlE4cw3EObPEQ
	 JlZr7gOtKTm3dLOIjtI9sX2mR/mEUhArKlWiItl64l/Kx1uoqeuKKMlcg8KnC9xpkl
	 +7QD9OL1d9uXQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:14 -0800
Subject: [PATCH v2 11/11] nfsd: take the write delegation grant stat before
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
Message-Id: <20261123-delegts-fixes-v2-11-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6684; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ksD3nxZBGeeaSY423lHGGZq5+SAuasr1jdPGGamS6IA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDimpWp+JUcHzcTxvi9a1w8hev2KSFp2zS5um
 iHvcAG4FSuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pgAKCRAADmhBGVaC
 FTbLD/4lufG2OGl2BEzyqnxSuKTA3dR5mgIDBFbILfucoVCiq/SBLjfaPFelcr7KmjTvL5Z71dL
 gpdWg+BNksLmDX3h1aR5xEbuUu4GuTVUTUmI7ruLaSFonnHIZLJML8O3rGUGGeXFcYvRYiEZPhq
 mrXpx45N8IQsIV7WxPQqctc82X7OZor2Ah6p7HVIHIDLnWCMNAf7HYDbliOca+wZmRX5Z2+e0oZ
 YM790ObpRwNi2gS2C9rDSq0ZLyiCX1MePeld5bi02c8kkG+qemFdhbY8uvMFugkDLBXi2CkSBS4
 /VZ1OepXJRcpmaQtLATrGQeDco8+X4MAvhhVbmq/eFI1MxVk8+GGxsHHl/sbjVxp0HG+xYrHf0o
 Ot7dmoIL30GBWbJHACIBW9mvuL9Tw4rtkS5gyq/3k0dX+IDV0NlhcK+0pjPj7oEdB5nvlTTLrZf
 ZvpWg7N1mE2hYz0tq1LLN+SPTDGpFuVP/eAuEvdpFGdXCxB3Boi7S2IDp1RLn0PKdK6uPjYVPEE
 jwInvADg1h9SXXL3DBgR1F2j43OyJeD9pLcn7BhTUOprN2hLodzJ8jttIsED5RDo+EH8j9005oB
 WV71FyxxE6IaxjN3n697VMP1QeTGCIYENUvCHDcEy8RacfoU/AdYJ0zNkLDEiie2ZGR7m2utVgo
 rgYjaekyR8kDBOg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_open_delegation() sets ncf_initial_cinfo and dl_[amc]time from a
stat taken after nfs4_set_delegation() has hashed the delegation. The
window between hashing and the stat is not reachable today. A CB_GETATTR
sent in that window does not carry a referring call, so the client
replies with NFS4ERR_BADHANDLE and the waiter never compares the zero
ncf_initial_cinfo. But an upcoming per-delegation timestamp record must
be initialized before anything can reach the delegation.

- Pass the current filehandle into nfs4_set_delegation() for the stat's
  export, and move nfs4_delegation_stat() above nfs4_set_delegation().
- Take the grant stat after kernel_setlease() and the conflict checks,
  just before hashing. Don't grant the delegation if the stat fails.
- The stat can sleep and so widens the window between the unlocked
  fi_had_conflict check and hashing. The check under deleg_lock that the
  previous patch added still catches a break in that window.
- Stat again after hashing, and decline the delegation if the change
  attribute moved. The holder's WRITE through an earlier open doesn't
  break its own lease and can land between the stats, as can a foreign
  write whose break raced past the fi_had_conflict check. A plain write
  delegation synthesizes change as ncf_initial_cinfo + 1, so a stale
  ncf_initial_cinfo could report a change attribute below a value that
  clients already saw. Compare with the grant stat's change attribute,
  which nfs4_set_delegation() returns, rather than with
  ncf_initial_cinfo. Once the delegation is hashed, a GETATTR whose
  CB_GETATTR reports a modified file can advance ncf_initial_cinfo.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 93 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 63 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9ea3b0e9b7ec..87ec545ebc48 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7277,11 +7277,35 @@ nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
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
@@ -7425,6 +7449,25 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	if (fp->fi_had_conflict)
 		goto out_unlock;
 
+	/*
+	 * Anything that can reach the delegation once the delegation is
+	 * hashed may read ncf_initial_cinfo and dl_[amc]time, so set them
+	 * before hashing. nfs4_open_delegation() stats again after hashing
+	 * to catch a write that lands between the two stats.
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
@@ -7488,29 +7531,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status,
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
@@ -7579,6 +7599,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	struct svc_fh *parent = NULL;
 	struct nfs4_delegation *dp;
 	u32 held_type = OPEN_DELEGATE_NONE;
+	u64 grant_change = 0;
 	struct kstat stat;
 	int status = 0;
 	int cb_up;
@@ -7613,8 +7634,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
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
@@ -7632,12 +7653,24 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 			nfs4_put_stid(&dp->dl_stid);
 			goto out_no_deleg;
 		}
+		/*
+		 * The holder's own WRITE through an earlier open doesn't
+		 * break the lease and can land after the grant stat, as can
+		 * a foreign write whose break raced past the fi_had_conflict
+		 * check. A plain write delegation synthesizes change from
+		 * ncf_initial_cinfo, so ncf_initial_cinfo must not be stale.
+		 * Compare with the grant stat's change attribute, not with
+		 * ncf_initial_cinfo. A GETATTR can already have advanced
+		 * ncf_initial_cinfo past the grant stat's value.
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

