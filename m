Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256654;
	b=AT+ho4mAj6hNIP2g6/l6JrLvgEAcC4UIu2SYtZ9W1zv1C1h/mXvaIiV4X/yM8Fjml4lz
	 QnOjkhium7lihIlcWbQMXC84ZsnqWDvSHKtR3awrAlCGY3naqZqa4ROsbadIzrIZFOd1W
	 xGSuNw0on457U6HpXo8gfvnY2Q6HCq7klSu5AjED2I2+PvqFhrqGdbahRIS+iWK5f49nP
	 8GO5F5eJ3F2I8aw6N5RWoMRk6qCsb144UrnsJCb6F3JTVPmCfTSS/45jfH8kdg3Yk/GAN
	 GOd3sLiwjss3aiu3vISHHyK4HivIV1UPFIt8vNsuBHRXQQpE4p8QvatfruJBXCdAcPw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256654;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=imfBr8saIBZy4Fb6q0puOlwpVSTniwryAgKU+AP8bPU=;
	b=dQ6JhkOsJLNmUqZKHwQU5M40K+mMNfCqpGGv+SIth7wXJg5c1AIiceheA4MzlH3OElpB
	 OeoETiIlTM8idCjcGRojPXiz8qQofZzTcd0qBTtO42dwE6vHeJLroSSFgUDpaAqlDFeSr
	 JSEK3xa9aW48lDzSUbXjkcdV7PTSV9tcQeS+EgDKJDLcPBqvTc0Ty/6WSE2XpZxbvC9vj
	 6zeUyY11cxkATyaxt1L2lyEVQwrzUgI4iSit/XBSb2v1q2kt3JIIjlm7waWquI4frRN6R
	 9rYxqqj8aZEUuvXKfquj3xUwH9wxOV0xrZXuk4tUpdAGA2ueLN1/14HK6w6ooSorcig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=og6Ql0gb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AE7B606A339;
	Mon,  9 Nov 2026 20:37:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=og6Ql0gb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E36511F008A1;
	Mon,  9 Nov 2026 20:37:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256653;
	bh=imfBr8saIBZy4Fb6q0puOlwpVSTniwryAgKU+AP8bPU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=og6Ql0gbG9Exen1hU3DJekPx6c5qAJkrmD1a/wFZqHpVs/I0EZOmWrFARdV2sve2h
	 wWOim8iRIezjhnWkxRMhooABdBKOFq7QXlwKJSDu6y3Biif44YvsW2uTG6i0d77oPN
	 lLna7ughlJBq7aEd+dnj+llxmVj0wUrhT/L8OCq9uGyqjFHC6pa+DmroaT8i8cWuRM
	 VKow/OUDG47Pt93UVyTqO4bWYFNgAhrvThLaGms/az4HjDqt6tzpiTzOCy9hSbhyDS
	 VARqUoWY5Cxf9rPJrc1O8sEmzT34S8DEyZkaMwqH2K/rDtPN72xOMB6IEIySp8NlSg
	 sA91CkDbT9wpg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:45 -0500
Subject: [PATCH v3 4/8] nfsd: don't vet delegated times against an
 exclusive-create verifier
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
Message-Id: <20261109-deleg-cb-getattr-times-v3-4-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4215; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=rH+HliFi3LmU8szYfq96ZDXc+MlrbyiYsYj8e/W+FoE=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i8A3FZopK4gF+hrVxEXIyD3g3xRAEMhe0e1s
 47dfFT05PGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIvAAAKCRAADmhBGVaC
 FcmKEACi+fOKN80MFuW2Nj5MYlCwJKGLqwI8kg2suGuE+o5dGSmSqEEFhuErWmURP3iW9YuPymo
 Ydb/fNI6GOB9t8LsZbYSDaa4BM5FJMTnTjND5EHxTPw9pXHzRXI5/pRySlFp7CHpYg1O4hyqgrc
 63c8g2r8FMeA5ezOLlaMI0OHaFilphmPKhS+YQTJoCbyt4+Y18SUwBvd3KH9Vb42OsODBSfK6e3
 Y3brhMh1gqVU3rjvxaCb33mg3CbWJsF7N5LN/5e2PcpCVzX04WhtOTMg7bQdVIkEtkl8EF0nxFs
 m/++WLXHveYXdfgqIh9X0033wY3KsoSS6pWN9Dfqo/huI6Smo/q7CeSk7z6QvWI2bTKFNkV/s9e
 SVsS5xed3PMUI3YF/FFzUva19bAE1CNwf/cMbUaupeH7GH/JbUU+qFSUu/9Z04aPCgF74qbsh1F
 zkipI+w7B8SNp/47/F+QoR4E6Sznxzf+kICpQY6PCYn8U+cgaScX3V9pV/bEhwVirOcKqr3S3kp
 dZ5PduHwiT1KGTcWPw1OrnkTj2/72JHceN3iNTittm6pPVoxa3bjayvNOwjy7hntefesTtNIubv
 v+5EkkvkrX7csv3yqHdydcOYkBsI96mn5eUjFC0h4BoBIVoXKrtUNEJkO+382AnClM643trRXxm
 cbGzulawX6Di5Xw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

An exclusive create stores the client's verifier in atime and mtime
until the client sets real times. A delegation granted on that OPEN
records those as dl_atime and dl_mtime (e.g. 4777.0 and 681509.0), so
vetting the holder's times against them always passes, including times
older than the file itself.

When the OPEN did an exclusive create, use the ctime at grant, less 1ns,
as the floor for atime and mtime too. Vetting rejects a time equal to
its floor, and a holder time equal to the ctime must still replace the
verifier. Do this for both write and read timestamp delegations, and
set a read delegation's floors only when the stat behind them was
done. Move nfsd4_create_is_exclusive() to xdr4.h so nfs4state.c can use
it.

Fixes: 7663e963a511 ("nfsd: track original timestamps in nfs4_delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  6 ------
 fs/nfsd/nfs4state.c | 27 +++++++++++++++++++++++----
 fs/nfsd/xdr4.h      |  6 ++++++
 3 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4e5d5852bf57..25613c1ffaaf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -245,12 +245,6 @@ static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate
 			&resfh->fh_handle);
 }
 
-static inline bool nfsd4_create_is_exclusive(int createmode)
-{
-	return createmode == NFS4_CREATE_EXCLUSIVE ||
-		createmode == NFS4_CREATE_EXCLUSIVE4_1;
-}
-
 static struct file *do_lookup_open(struct path *parent,
 				   struct qstr *name,
 				   unsigned int oflags,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 35712e129b7a..4566fa86f82f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7466,6 +7466,26 @@ nfsd4_add_rdaccess_to_wrdeleg(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	return true;
 }
 
+/*
+ * An exclusive create stores the verifier in atime and mtime, so the only
+ * real floor for the holder's times is the ctime. Vetting rejects a time
+ * equal to its floor, but one equal to the ctime must still replace the
+ * verifier.
+ */
+static void nfsd4_deleg_set_time_floors(struct nfs4_delegation *dp,
+					const struct nfsd4_open *open,
+					const struct kstat *stat)
+{
+	dp->dl_atime = stat->atime;
+	dp->dl_ctime = stat->ctime;
+	dp->dl_mtime = stat->mtime;
+	if (open->op_created &&
+	    nfsd4_create_is_exclusive(open->op_createmode)) {
+		dp->dl_atime = timespec64_sub(stat->ctime, ns_to_timespec64(1));
+		dp->dl_mtime = dp->dl_atime;
+	}
+}
+
 /*
  * The Linux NFS server does not offer write delegations to NFSv4.0
  * clients in order to avoid conflicts between write delegations and
@@ -7556,9 +7576,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 						    OPEN_DELEGATE_WRITE;
 		dp->dl_cb_fattr.ncf_initial_cinfo = nfsd4_change_attribute(&stat);
 		dp->dl_cb_fattr.ncf_srv_cinfo = dp->dl_cb_fattr.ncf_initial_cinfo;
-		dp->dl_atime = stat.atime;
-		dp->dl_ctime = stat.ctime;
-		dp->dl_mtime = stat.mtime;
+		nfsd4_deleg_set_time_floors(dp, open, &stat);
 		spin_lock(&f->f_lock);
 		if (deleg_ts)
 			f->f_mode |= FMODE_NOCMTIME;
@@ -7567,7 +7585,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	} else {
 		open->op_delegate_type = deleg_ts && nfs4_delegation_stat(dp, currentfh, &stat) ?
 					 OPEN_DELEGATE_READ_ATTRS_DELEG : OPEN_DELEGATE_READ;
-		dp->dl_atime = stat.atime;
+		if (open->op_delegate_type == OPEN_DELEGATE_READ_ATTRS_DELEG)
+			nfsd4_deleg_set_time_floors(dp, open, &stat);
 		trace_nfsd_deleg_read(&dp->dl_stid.sc_stateid);
 	}
 	nfs4_put_stid(&dp->dl_stid);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ecab2249e9bd..feda5464f260 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -280,6 +280,12 @@ struct nfsd4_open {
 	struct svc_rqst *op_rqstp;
 };
 
+static inline bool nfsd4_create_is_exclusive(int createmode)
+{
+	return createmode == NFS4_CREATE_EXCLUSIVE ||
+		createmode == NFS4_CREATE_EXCLUSIVE4_1;
+}
+
 struct nfsd4_open_confirm {
 	stateid_t	oc_req_stateid		/* request */;
 	u32		oc_seqid    		/* request */;

-- 
2.56.0

