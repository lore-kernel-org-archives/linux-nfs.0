Received: from mail-pj1-f50.google.com (mail-pj1-f50.google.com [209.85.216.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECE923DB328
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 10:05:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791799534; cv=none; b=H+T1S2F9NFXOkPfcRlC02fMS4eZH0QJB1vftzWS6aZwTX5+iIswMzfnqjhBSuc1S3FTWcTKPvBTC/M3hg0RVCCx3KqcxlDYC6Tvweqj39e3Sv/kVo5xjtBZMm7lhkX038q1f69dGVSlPZoRFdwGqd/tSjPuJVs7pk5V4GD2sNug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791799534; c=relaxed/simple;
	bh=uyGNJ3FiEuYC3WJyQYn43yxW6O4edmrT3VKQ8W0YueY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=M5HKOsl7BTeHYcc/Ehm6F4NR7G7DB1umrafY+82vR2iXta201tY1dAjDu5FDCtK0d4ehIokt6cncHymJmVPXkDhamc9Cazn9Be9YF2Kv0L/eCzH0CRyd7d5Lsqgu2LMuayX2j4ICqmkrEIXgobLrimlHnNDJsDT/F+pnIFws6XQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=jnTN+GzU; arc=none smtp.client-ip=209.85.216.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jnTN+GzU"
Received: by mail-pj1-f50.google.com with SMTP id 98e67ed59e1d1-3ab60ff4273so1348948a91.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 03:05:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791799525; x=1792404325; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HRt+HaFe6x1DJTHDkxIpkrIWPbs1W5ttyA9y04b7R9o=;
        b=jnTN+GzU1A4gVzHV55mhBPu+B3+zpHONE0UHwyXd1kmt6yVnPbJ48vWnWX+QqgFW6z
         KF5wLjPXDJrUccxRieN9Uwqra7+W8G3pULJ88nKBCTVDSCc3+mTX+keWs4oTg0UuRXSw
         LqZFI2qIVjBUXW9WfWhVSZ+wZSKYxlXjUIruD/juCQSCP6DGvegn/Rq6NjEAqlJMyseS
         rgMEtma56cX8t9V2khvRIHYMpccaoyYowmNqT3T3R6GsgHSd+6KikR2wfT9QpQS44Thu
         A1N8LWccBwqQXTD/yyt9U8lrxqA9dF/Omdzf4RzT0jqxR8BtnwhZzphV16A4YgL4t+SO
         YZlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791799525; x=1792404325;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HRt+HaFe6x1DJTHDkxIpkrIWPbs1W5ttyA9y04b7R9o=;
        b=v8HAW+F2YqK+OAs4fI1p2en/eqho8iOh4J/bRI4KHKcClFj2aNutt4TGr02Vk8r7pS
         WpgXjOZJVwWvh2xrSO0Yp6djSvMa4bXEZW8/j+HefS+5DZ2f38Djp2I+aeVAhzPusbMR
         Y3Ij94bW4I0xkI5zB8CPBERSf2HDPBAull7G3C7ixaJTQg5UOGLTfQfjTVkj+SrItMgL
         f8sUmpM9R4pPxvTrku8EgwxiiqHlWQJhpUtlBEly3Q1GTws98jEQNmduCYQ/Q6p1Lp4G
         qvomDY1qoyia6A7kGQPV7iOHJ2P2c+Tye8JoLUgq1fxZoWrHTUHWg4TivNN7DDiDYbqF
         theQ==
X-Gm-Message-State: AFq9FYKd9ry4k3UtaaQuMaZnRmMtBNCJIyv5fWBh3TiJNlylZgudpEmC
	vRi7y60SBj3DUnBEHcDWv1Ra73NZyga+v1n3PJhrFni7XjK+IGurBwiUhCsWJ/LJ
X-Gm-Gg: AYBFou06qLAlJmWAvhHJMzvgoGd0hPOF3yvb9FAb3Is2J3q501HZy2f4OG6/6OG0o4T
	2DdUVNjvyyxaSc4YOd3MmSkPkk/ewU69EAcdbkC4pbVtdQPg8diqGcVxHvlBAm4pQp1YiIWQs/j
	KdBLKUovS1I7ldA3SSQbsUTdOLjaCfJCOm/+6crSrRhVPWzIH/z47kTETB09TIrKIN7riQxfnd7
	d5mNusGWyIvRW8WWvtA+n293AzgIdMcF7e0eeLC2IIPTt1txMyAmUoHtXZ6tPTNgIjeuaI7F1HM
	zdTKPh7Z9WjS1mVr5fSI54bD5wKcrbmsj3jGGt3Jp6zIapgoo0Us71ziInrYtD9YIrCStD32tZR
	r+X72cMaRYedZHgPzVVNlP5E5m/FR7GJb0V6wibVhTYvdHGtV5Jeu9Zgc1rm8Olw64Vz57f6vSQ
	+83fmY0/JKsdEjGFnlPFaAn47zO1sq/CpsfseGQk8Tqqeoc2rNviupseYQIIe6CzWdQOacbeKGO
	zbY2jnkJml0j/OAyQmge7NChw6GaqTRZSF0tecDufLQFavaDP7D1jhs5i1eOQ==
X-Received: by 2002:a17:90b:3b82:b0:3ab:4f1:4f76 with SMTP id 98e67ed59e1d1-3ab3a94f426mr8143729a91.24.1791799524932;
        Mon, 12 Oct 2026 03:05:24 -0700 (PDT)
Received: from muumthf.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ab38f5509fsm16011866a91.12.2026.10.12.03.05.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 12 Oct 2026 03:05:24 -0700 (PDT)
From: Hyunsol Mun <muumthf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Hyunsol Mun <muumthf@gmail.com>
Subject: [PATCH v3] nfsd: pin source client while using COPY_NOTIFY stateid
Date: Mon, 12 Oct 2026 19:04:35 +0900
Message-ID: <20261012100435.144767-1-muumthf@gmail.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <5395aa50-bf30-492b-809d-fc882ea5ac57@app.fastmail.com>
References: <5395aa50-bf30-492b-809d-fc882ea5ac57@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

find_cpntf_state() returns a referenced stateid after dropping the RPC
reference acquired by lookup_clientid() for its source client. A stateid
reference does not retain sc_client, so source-client expiry can free the
client while stateid validation or nfs4_put_stid() still uses it.

Move COPY_NOTIFY stateid processing into nfs4_preprocess_cpntf_stateid(),
called from the READ, READ_PLUS and SEEK paths. Keep the source
client's existing RPC reference through stateid validation, file lookup,
and nfs4_put_stid(), then release it with put_client_renew(). The reference
prevents client teardown while the stateid is checked and released. Only a
referenced nfsd_file escapes the helper for the subsequent I/O; neither the
source client nor its stateid escapes the helper.

An expired client can remain in the client ID table while
force_expire_client() waits for its RPC users. Reject it in the common
table lookup before renewing its lease or returning it to other callers.
lookup_clientid() holds nn->client_lock across this check and the RPC
reference acquisition, so it cannot pin a client after administrator
expiry has started draining its users.

Remove the COPY_NOTIFY fallback from nfs4_preprocess_stateid_op() and keep
its interface unchanged. Other callers no longer interpret COPY_NOTIFY
tokens as ordinary stateids. Share the existing generation, access-mode,
and filehandle checks between the two paths, and retain the existing file
permission checks for COPY_NOTIFY reads.

On the unmodified KASAN kernel at the base recorded below, five
timing-assisted trials entered the widened interval three times.
Source-client replacement freed the client during that interval twice,
and one trial reported a slab-use-after-free in nfs4_put_stid() through
nfs4_preprocess_stateid_op() and nfsd4_read(). A reliable trigger
without timing assistance was not demonstrated.

Timing assistance used a test-only kprobe to delay nfsd_permission()
after COPY_NOTIFY state lookup. The kprobe is not part of this patch;
it did not allocate, free, or modify NFSD objects.

With this patch applied to the same base, the full KASAN kernel built
with CONFIG_WERROR without a compiler diagnostic and booted successfully.

All 25 timing-assisted patched trials entered the widened interval. The
source client was not freed there, no KASAN report or kernel failure was
observed, and all token READs completed with NFS4_OK and 23 bytes after
client replacement returned NFS4ERR_DELAY. Twenty additional trials
without timing assistance also produced no KASAN report or kernel failure.
Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests passed.

Five patched READ_PLUS trials and five patched SEEK trials had three and
four timing-probe hits, respectively. The hit requests returned NFS4_OK;
the other races returned NFS4ERR_EXPIRED. Three administrator-expiry
trials overlapped a delayed token READ: the expire write waited for the
in-flight request, while a second token READ returned NFS4ERR_EXPIRED.
All three removed the source client without a KASAN report or kernel
failure.

Additional client-ID probes during administrator expiry returned
NFS4ERR_STALE_CLIENTID for CREATE_SESSION and DESTROY_CLIENTID. A separate
NFSv4.0 test returned the same status for a new SETCLIENTID_CONFIRM while
an earlier confirmation completed and the expire write waited for it.

A source reproducer, timing-module source, complete logs, and the kernel
configuration are available privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 624322f1adc5 ("NFSD add COPY_NOTIFY operation")
Assisted-by: LLM
Signed-off-by: Hyunsol Mun <muumthf@gmail.com>
---
Changes in v3:
- Rebase onto the refreshed nfsd-testing tree without adding another
  nfsd4_get_client() helper or changing existing kref_get() callers.
- Move COPY_NOTIFY processing into a helper used by READ, READ_PLUS and
  SEEK, without extending the generic stateid API.
- Keep the source client's RPC reference until stateid release, and
  reject already-expired clients before renewal and reference acquisition.

 fs/nfsd/nfs4proc.c  |  9 +++++
 fs/nfsd/nfs4state.c | 87 +++++++++++++++++++++++++++++----------------
 fs/nfsd/state.h     |  4 +++
 3 files changed, 70 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index eb3a3095ea9e..0848baad6842 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1148,6 +1148,11 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&read->rd_stateid, RD_STATE,
 					&read->rd_nf, NULL);
+	if (status == nfserr_bad_stateid)
+		status = nfs4_preprocess_cpntf_stateid(rqstp, cstate,
+						       &cstate->current_fh,
+						       &read->rd_stateid,
+						       &read->rd_nf);
 
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = &cstate->current_fh;
@@ -2621,6 +2626,10 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &seek->seek_stateid,
 					    RD_STATE, &nf, NULL);
+	if (status == nfserr_bad_stateid)
+		status = nfs4_preprocess_cpntf_stateid(rqstp, cstate,
+						       &cstate->current_fh,
+						       &seek->seek_stateid, &nf);
 	if (status)
 		return status;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 920967dd6f84..26d2d56a51e5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4070,6 +4070,8 @@ find_client_in_id_table(struct list_head *tbl, clientid_t *clid, bool sessions)
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
+			if (is_client_expired(clp))
+				return NULL;
 			renew_client_locked(clp);
 			return clp;
 		}
@@ -8528,14 +8530,53 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 	return 0;
 }
 
-static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
-			       struct nfs4_stid **stid)
+static __be32 nfs4_check_io_stateid(struct svc_fh *fhp, stateid_t *stateid,
+				    struct nfs4_stid *s, int flags, bool has_session)
 {
 	__be32 status;
+
+	status = nfsd4_stid_check_stateid_generation(stateid, s, has_session);
+	if (status)
+		return status;
+
+	switch (s->sc_type) {
+	case SC_TYPE_DELEG:
+		status = nfs4_check_delegmode(delegstateid(s), flags);
+		break;
+	case SC_TYPE_OPEN:
+	case SC_TYPE_LOCK:
+		status = nfs4_check_olstateid(openlockstateid(s), flags);
+		break;
+	}
+	if (status)
+		return status;
+	return nfs4_check_fh(fhp, s);
+}
+
+/**
+ * nfs4_preprocess_cpntf_stateid - prepare a COPY_NOTIFY stateid for read-side I/O
+ * @rqstp: incoming request from the destination server
+ * @cstate: current compound state
+ * @fhp: filehandle associated with the requested stateid
+ * @stateid: COPY_NOTIFY stateid provided by the destination server
+ * @nfp: returned nfsd_file reference
+ *
+ * Keep the source client's RPC reference until the stateid has been released.
+ * Only the file reference escapes to the caller, for READ, READ_PLUS or SEEK.
+ */
+__be32 nfs4_preprocess_cpntf_stateid(struct svc_rqst *rqstp,
+				     struct nfsd4_compound_state *cstate,
+				     struct svc_fh *fhp, stateid_t *stateid,
+				     struct nfsd_file **nfp)
+{
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nfs4_cpntf_state *cps = NULL;
 	struct nfs4_client *found;
+	struct nfs4_stid *stid;
+	__be32 status;
 
-	status = manage_cpntf_state(nn, st, NULL, &cps);
+	*nfp = NULL;
+	status = manage_cpntf_state(nn, stateid, NULL, &cps);
 	if (status)
 		return status;
 
@@ -8546,14 +8587,18 @@ static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 	if (!found)
 		goto out;
 
-	*stid = find_stateid_by_type(found, &cps->cp_p_stateid,
-				     SC_TYPE_DELEG|SC_TYPE_OPEN|SC_TYPE_LOCK,
-				     0);
-	if (*stid)
-		status = nfs_ok;
-	else
-		status = nfserr_bad_stateid;
+	status = nfserr_bad_stateid;
+	stid = find_stateid_by_type(found, &cps->cp_p_stateid,
+				    SC_TYPE_DELEG | SC_TYPE_OPEN | SC_TYPE_LOCK, 0);
+	if (!stid)
+		goto out_put_client;
 
+	status = nfs4_check_io_stateid(fhp, stateid, stid, RD_STATE,
+				       nfsd4_has_session(cstate));
+	if (!status)
+		status = nfs4_check_file(rqstp, fhp, stid, nfp, RD_STATE);
+	nfs4_put_stid(stid);
+out_put_client:
 	put_client_renew(found);
 out:
 	nfs4_put_cpntf_state(nn, cps);
@@ -8603,32 +8648,14 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				SC_TYPE_DELEG|SC_TYPE_OPEN|SC_TYPE_LOCK,
 				0, &s, nn);
-	if (status == nfserr_bad_stateid)
-		status = find_cpntf_state(nn, stateid, &s);
 	if (status)
 		return status;
-	status = nfsd4_stid_check_stateid_generation(stateid, s,
-			nfsd4_has_session(cstate));
-	if (status)
-		goto out;
-
-	switch (s->sc_type) {
-	case SC_TYPE_DELEG:
-		status = nfs4_check_delegmode(delegstateid(s), flags);
-		break;
-	case SC_TYPE_OPEN:
-	case SC_TYPE_LOCK:
-		status = nfs4_check_olstateid(openlockstateid(s), flags);
-		break;
-	}
-	if (status)
-		goto out;
-	status = nfs4_check_fh(fhp, s);
+	status = nfs4_check_io_stateid(fhp, stateid, s, flags,
+				       nfsd4_has_session(cstate));
 
 done:
 	if (status == nfs_ok && nfp)
 		status = nfs4_check_file(rqstp, fhp, s, nfp, flags);
-out:
 	if (s) {
 		if (!status && cstid)
 			*cstid = s;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 910f4eac71d0..79dfa47b82db 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -914,6 +914,10 @@ extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
 		stateid_t *stateid, int flags, struct nfsd_file **filp,
 		struct nfs4_stid **cstid);
+__be32 nfs4_preprocess_cpntf_stateid(struct svc_rqst *rqstp,
+				     struct nfsd4_compound_state *cstate,
+				     struct svc_fh *fhp, stateid_t *stateid,
+				     struct nfsd_file **nfp);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 			    stateid_t *stateid, unsigned short typemask,
 			    unsigned short statusmask,

base-commit: d918c664efd5ec6a7309e98f567fb018bcde0e11
