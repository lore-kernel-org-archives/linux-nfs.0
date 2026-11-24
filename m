Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549768;
	b=hoF0yMcMKUBDC8hCYQenixY/KWVPsyLrDm3uSA8nhaOKfXlhWlFtlbrCU8y/CBIbd/yR
	 fZJqXOeRkSYaZW79SvAQLdk3bNxg2JmB9Z5VLKaWTLMMgSP18w54bOrzD349OVJr8cKmJ
	 KH3IP+0XNCrN+bbTcm0nmKrfc0vRAj2A3H5GqHiGTDVJGRFsiBYp62mOEHXzP03/CFdGF
	 d5Y2PrZEBFgs7SfZb/Yk9YA/EUccny9r1QRYTK6NYCx82/CiHDm49MjREY/C/E0x2Edzn
	 gSn7+dW7jRIUhZxGJf4LuY2wEMD9AYOTOOsGb1jt0JVPWb541JkvY4rri0KCL59ryWg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549768;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=w765RhlKEmCXpEzT8vMU4vI+1OfdgcEXrElMay742ug=;
	b=bKeN+/LUS3mqPvloh0pQ4rUxMxtrEY2gJjGJsbqAZCovpa3UaRe9JF4BAvVYIzO47PBK
	 cHbJZ1VU2FYkYB4PxG3/j22VarucGx748rs6pfUP0KOSoFv+kdhZNmNwKEczEdwGKi0Hq
	 Z/HmD6RXg6yoFKXkVy6wsab6smETjT/jGb24EUE3kx0hEv1dsNN+OWWH8gAdxmZVcdTDx
	 FGSICohzpiujNXlX4pS8KwLsOHTGqFYVk3D5LgY2w/ype7e36/XzFeF24Vz7sg6bCK/ff
	 GSScTXVLPEvZtgIP41ahh7csWS7MLkAGqbMk4l/YtK0i5+HKqS9VBGIx7ywuxIuc9og==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YV+HCMps;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6197E60A2627;
	Tue, 24 Nov 2026 19:49:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YV+HCMps
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8774D1F000EF;
	Tue, 24 Nov 2026 19:49:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549768;
	bh=w765RhlKEmCXpEzT8vMU4vI+1OfdgcEXrElMay742ug=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YV+HCMpsRkRRHlZlQMa4BVjkHNR/NS3wCCQDCposdggL1AyudNiWUv+vlOwjlt1dx
	 uCOCQkwruzWe3Lypu/HMXBpEY7NdMds9y5YoB/mE2mNKM5DYfUZV5x8QLBp/ysmxKD
	 hQQOo8eFvjrgBY7/KyzVwkGf6hMKDHUeK/VU7ibCOyX048nRUelbtl+oWTuKUorbeK
	 dlhEkQSqJ8dksFV7TiZHxCVw37lvTCq/epBBB288rZ0CuUPgOJHUwSFHMhDZxFO4Yf
	 HZD1WF3RQSwtJBQQXQ0VPLE/gDJ6YRbEd/0fas9rLa0Ueg5dBdTX3QDw0QFgQQr5qV
	 1Pl64+LFCRQnQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:50 -0500
Subject: [PATCH v3 11/12] nfsd: take the write delegation grant stat before
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
Message-Id: <20261124-delegts-fixes-v3-11-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6691; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Vr/BMOfSSWkxdXeTqrQFN4dfXAVHjfDWDW+MDNe8ZNo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo376Ivjn9OW3V0F8eTbuf/Ho+uH/gpszqnZ
 BXAgA8E8rGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNwAKCRAADmhBGVaC
 FVdLD/4xQsBM/s0gUy+RO09Go2V6XIfJzJig8ZN0rF30mSS/I/2fxgN6/DpmS9Q6igVJe1q0fJb
 DDbSGMIuSlg1FKKDXIqben2gZzWrWd3vrD4aqzs0Y1LM+oOGCsrspE1DemRT4eD+4X95cdfoxQH
 n2jK4iZqDYR+4mnhyss5l6uOrIgwmPH9Z1nt3Ubu0TqMGqeY+HVVwubnHZ8keOQaRErke8mtV/K
 jbOfAnwD+4p66BtsLZeyPRRueUd/d2cF5m0ohzA1o3S5vBo3Z2pATyHlim5mNsmlmSAkVm25gai
 Q4unCpzJq+d/CvXZ6Kn41U3ZrlFpuaDLn3GME8Rq3iNXp6zSIJNBE5bbGRNCrTU4qqzBa5rorZ2
 vQ3pO2S91d085xoTNuqmA/EHxjC0Kmos9YWZdHksWAtOKefXGP3KMX/BR8AeQ/AeXKLpej8UY8z
 4ik1hjqbLnfjTBwPJq9DSU2ye2NigC3l08faqZItvAJnAltlC+2keJePWFlYbgEL4AAeENiMEe7
 5rx/qPy5yDmlhMsTrApVQCYma/fI15VG4D4/dNHbU0fFciPr8AyctOaSDb0lC5ULzjfP2l6FycA
 D8uZapNCGTU5e58ZbUNvR8hq60sd7yGwysU+VVn4hnS46YPBwcfOlu/2o45ut9BO7Oq6SldJAzZ
 hjqgTV/GzBUmjmw==
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
index 3491b2b86a3e..6bb3ce974c9c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7286,11 +7286,35 @@ nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
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
@@ -7434,6 +7458,25 @@ nfs4_set_delegation(struct nfsd4_open *open,
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
@@ -7497,29 +7540,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status,
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
@@ -7588,6 +7608,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	struct svc_fh *parent = NULL;
 	struct nfs4_delegation *dp;
 	u32 held_type = OPEN_DELEGATE_NONE;
+	u64 grant_change = 0;
 	struct kstat stat;
 	int status = 0;
 	int cb_up;
@@ -7622,8 +7643,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
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
@@ -7641,12 +7662,24 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
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
+			destroy_delegation(dp, false);
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

