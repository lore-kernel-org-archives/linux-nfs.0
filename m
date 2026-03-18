Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D8E73DB630;
	Wed, 18 Mar 2026 14:15:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773843326; cv=none; b=rM48FKMro5K8udDRTe1fCScO6xG6usrj7ljaFdrSSIZueD4xwqZcCTxlVV2P3hnVkZWCWDjHSXjYye2Z0mEXDh9BezdvvczVF1YBKSHITnUJQCvtB1mUMAQ31REHR6CLoHzq/fIxV9DBGBDrzi2zlOlBa0EVEOlp81F9M6YaCSk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773843326; c=relaxed/simple;
	bh=OEHzipv/iWdZfMS+IIvLdOPzhi18PfDoEqdpvV/2ubg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Y50E/FjeTMmPdv826azr6EoQa27EmHtbGO3A82OM1VJyDnmqSr72VHtfA9eI3/h4OUgqwi/IbrCYhfueiwAGsue1s2aCFlUnjPYG/3dt71rh2LC88LC6rVi1lNVPHEhHcOZJzw3IpMG8PIL6yMz9J1EPEqjygqIRWWrjqxp/j14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gZaHtqqX; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gZaHtqqX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA344C2BC87;
	Wed, 18 Mar 2026 14:15:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773843326;
	bh=OEHzipv/iWdZfMS+IIvLdOPzhi18PfDoEqdpvV/2ubg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=gZaHtqqXghAPSV7q1XjSZQF0T3cGsb2NcD+7Ddrkn+RH9iomQaMBug7dLS2n7XMgn
	 GvDA9hl64VINnZ8GzzaHvLVQ9DqmsZ9LLrSqSTQ+L490WP0byMkASwItsOGJWvhiha
	 FxWFTm4rMT5w1xcFFdR9G2zlFoTTmeo64NVOA868u7huRCFb3aL3gE2DmeUFAKXMit
	 OuC1qln4v81QbaeLWDAcK4YCq4qt41puTZ9rUbNOgt2z1MMGZPlFQmVthvzWKaxh2k
	 RwLSrVGq9IkIZOBNvvfY6/QiLBtffjLXckt6ezMLpSm9sqCwHCLdIJU1HKc1qcuS8D
	 YKENLszFiQL4Q==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 18 Mar 2026 10:15:03 -0400
Subject: [PATCH v4 1/6] NFSD: Extract revoke_one_stid() utility function
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260318-umount-kills-nfsv4-state-v4-1-56aad44ab982@oracle.com>
References: <20260318-umount-kills-nfsv4-state-v4-0-56aad44ab982@oracle.com>
In-Reply-To: <20260318-umount-kills-nfsv4-state-v4-0-56aad44ab982@oracle.com>
To: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.15-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=5166;
 i=chuck.lever@oracle.com; h=from:subject:message-id;
 bh=lpRmQEtkNp/H1lpj4og/yKg96iukgZ4qGJu7GzWifSk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBpurN8/LV4nC5sHr7Fry04m0jnoiFJU106lQf1v
 xz4ILeAljWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCabqzfAAKCRAzarMzb2Z/
 l7T6EACiah9b+RFjJkUt5HBheyoLqcuzoaLyaz7EPbplXmVwkzD81Tom4DSnw9hhU2g/06N3KHj
 oghpDCJ5cMTnDRfk+f2OFzydu0WVhwOBpE43Hv4BD+jp1XKUw/oAe1rdca1ILs+1yF+MhJh4fsR
 vCLUl2ECJ0f29YDyHHwuylZ5rrHnyeeECxkNw4iw3zwz4eiv4bO/uBnRlDu9X3Ujy4weh4SkOlk
 K8RTQwtn1xmUogDWIAI+9dKlWQQSMlkXSSgNc3pyabdfSgH7BXVgAoYLzXsnGSpIOVdp61EcUkM
 rDmD5v/qhBGML4AXCg7kDnFtoMKTNOcUJreZ92/57lBCPEmgBTYfz8jD6EThrZjc6mGXvk6TuBu
 eONi/Vs1raUA53R6dJODju+r5I6neznZZzsQ+WtGSt4idqQYqRLA75lGEjUt63MURo5BAyNtCoU
 PX6rrtoiv+ICgP+E0wosAgDv5Mz4QsTwj6SInmbQiz3X33c+/NOHFO3hLIzmta+qahpAV1aXnoQ
 ycFJLj2hrkCQjz1Wuyv75cW0+/wL6kv1+nGqaK1VIylZB1RA+yjpRdHJRhdjkzF75luXUj3q2cj
 fluKbWZRd2sNjtSbZ+WUgRPRWks78jij3iwLmyBoWREdh9Ch21XNZ4VwLGwPc62FXTIOAJA91B3
 87ITdnCSqiq35rg==
X-Developer-Key: i=chuck.lever@oracle.com; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The per-stateid revocation logic in nfsd4_revoke_states() handles
four stateid types in a deeply nested switch. Extract two helpers:

revoke_ol_stid() performs admin-revocation of an open or lock
stateid with st_mutex already held: marks the stateid as
SC_STATUS_ADMIN_REVOKED, closes POSIX locks for lock stateids,
and releases file access.

revoke_one_stid() dispatches by sc_type, acquires st_mutex with
the appropriate lockdep class for open and lock stateids, and
handles delegation unhash and layout close inline.

No functional change. Preparation for adding export-scoped state
revocation which reuses revoke_one_stid().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c | 126 ++++++++++++++++++++++++++--------------------------
 1 file changed, 63 insertions(+), 63 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b9c399b89df..d476192e4b27 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1757,6 +1757,68 @@ static struct nfs4_stid *find_one_sb_stid(struct nfs4_client *clp,
 	return stid;
 }
 
+static void revoke_ol_stid(struct nfs4_client *clp,
+			   struct nfs4_ol_stateid *stp)
+{
+	struct nfs4_stid *stid = &stp->st_stid;
+
+	lockdep_assert_held(&stp->st_mutex);
+	spin_lock(&clp->cl_lock);
+	if (stid->sc_status == 0) {
+		stid->sc_status |= SC_STATUS_ADMIN_REVOKED;
+		atomic_inc(&clp->cl_admin_revoked);
+		spin_unlock(&clp->cl_lock);
+		if (stid->sc_type == SC_TYPE_LOCK) {
+			struct nfs4_lockowner *lo =
+				lockowner(stp->st_stateowner);
+			struct nfsd_file *nf;
+
+			nf = find_any_file(stp->st_stid.sc_file);
+			if (nf) {
+				get_file(nf->nf_file);
+				filp_close(nf->nf_file, (fl_owner_t)lo);
+				nfsd_file_put(nf);
+			}
+		}
+		release_all_access(stp);
+	} else
+		spin_unlock(&clp->cl_lock);
+}
+
+static void revoke_one_stid(struct nfs4_client *clp, struct nfs4_stid *stid)
+{
+	struct nfs4_ol_stateid *stp;
+	struct nfs4_delegation *dp;
+
+	switch (stid->sc_type) {
+	case SC_TYPE_OPEN:
+		stp = openlockstateid(stid);
+		mutex_lock_nested(&stp->st_mutex, OPEN_STATEID_MUTEX);
+		revoke_ol_stid(clp, stp);
+		mutex_unlock(&stp->st_mutex);
+		break;
+	case SC_TYPE_LOCK:
+		stp = openlockstateid(stid);
+		mutex_lock_nested(&stp->st_mutex, LOCK_STATEID_MUTEX);
+		revoke_ol_stid(clp, stp);
+		mutex_unlock(&stp->st_mutex);
+		break;
+	case SC_TYPE_DELEG:
+		refcount_inc(&stid->sc_count);
+		dp = delegstateid(stid);
+		spin_lock(&state_lock);
+		if (!unhash_delegation_locked(dp, SC_STATUS_ADMIN_REVOKED))
+			dp = NULL;
+		spin_unlock(&state_lock);
+		if (dp)
+			revoke_delegation(dp);
+		break;
+	case SC_TYPE_LAYOUT:
+		nfsd4_close_layout(layoutstateid(stid));
+		break;
+	}
+}
+
 /**
  * nfsd4_revoke_states - revoke all nfsv4 states associated with given filesystem
  * @nn:   used to identify instance of nfsd (there is one per net namespace)
@@ -1787,70 +1849,8 @@ void nfsd4_revoke_states(struct nfsd_net *nn, struct super_block *sb)
 			struct nfs4_stid *stid = find_one_sb_stid(clp, sb,
 								  sc_types);
 			if (stid) {
-				struct nfs4_ol_stateid *stp;
-				struct nfs4_delegation *dp;
-				struct nfs4_layout_stateid *ls;
-
 				spin_unlock(&nn->client_lock);
-				switch (stid->sc_type) {
-				case SC_TYPE_OPEN:
-					stp = openlockstateid(stid);
-					mutex_lock_nested(&stp->st_mutex,
-							  OPEN_STATEID_MUTEX);
-
-					spin_lock(&clp->cl_lock);
-					if (stid->sc_status == 0) {
-						stid->sc_status |=
-							SC_STATUS_ADMIN_REVOKED;
-						atomic_inc(&clp->cl_admin_revoked);
-						spin_unlock(&clp->cl_lock);
-						release_all_access(stp);
-					} else
-						spin_unlock(&clp->cl_lock);
-					mutex_unlock(&stp->st_mutex);
-					break;
-				case SC_TYPE_LOCK:
-					stp = openlockstateid(stid);
-					mutex_lock_nested(&stp->st_mutex,
-							  LOCK_STATEID_MUTEX);
-					spin_lock(&clp->cl_lock);
-					if (stid->sc_status == 0) {
-						struct nfs4_lockowner *lo =
-							lockowner(stp->st_stateowner);
-						struct nfsd_file *nf;
-
-						stid->sc_status |=
-							SC_STATUS_ADMIN_REVOKED;
-						atomic_inc(&clp->cl_admin_revoked);
-						spin_unlock(&clp->cl_lock);
-						nf = find_any_file(stp->st_stid.sc_file);
-						if (nf) {
-							get_file(nf->nf_file);
-							filp_close(nf->nf_file,
-								   (fl_owner_t)lo);
-							nfsd_file_put(nf);
-						}
-						release_all_access(stp);
-					} else
-						spin_unlock(&clp->cl_lock);
-					mutex_unlock(&stp->st_mutex);
-					break;
-				case SC_TYPE_DELEG:
-					refcount_inc(&stid->sc_count);
-					dp = delegstateid(stid);
-					spin_lock(&state_lock);
-					if (!unhash_delegation_locked(
-						    dp, SC_STATUS_ADMIN_REVOKED))
-						dp = NULL;
-					spin_unlock(&state_lock);
-					if (dp)
-						revoke_delegation(dp);
-					break;
-				case SC_TYPE_LAYOUT:
-					ls = layoutstateid(stid);
-					nfsd4_close_layout(ls);
-					break;
-				}
+				revoke_one_stid(clp, stid);
 				nfs4_put_stid(stid);
 				spin_lock(&nn->client_lock);
 				if (clp->cl_minorversion == 0)

-- 
2.53.0

