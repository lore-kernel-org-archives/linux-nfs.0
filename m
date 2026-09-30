Received: from mail-pz2-f37.google.com (mail-pz2-f37.google.com [74.125.228.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 421C83B47C3
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:39:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790746770; cv=none; b=SecS9R8tlmERdcKVqWaL4+DYbLgh3pxcZA+c04TtH3SMRCZZghshpk6hs4sztocxiKttxN60iQZmN+Enifr4BnlP9kP/gWT+SSRcgueyTvTVbKJ1cvnzM7U55jXYrxA/crlV4XO1cPsgy3XHvZt2sQ1P79mXtBr0ChqU3R1fZY4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790746770; c=relaxed/simple;
	bh=cgKlyO5va1XPqgUqKB1nugrJWMtQJxKsstV8QkaKwBs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hC6th2OS4g4e26I5mVhP9aVigu5fJOZ/go1YtgbaTUo36hDEawjzQzPi1TgpUjZr15xbUE11zCQEKbqrcm0zv2hVMqdpik9QAFbOxq0cdv1M9/Qt0GzYoT2Yf1YgeSre9u07uH/4uHiiN82q2dGu+nSCrROo8twnVt9dh66PJgQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=be3lGTgl; arc=none smtp.client-ip=74.125.228.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="be3lGTgl"
Received: by mail-pz2-f37.google.com with SMTP id d2e1a72fcca58-8864c6bd0d5so472598b3a.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:39:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790746767; x=1791351567; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=mZRpH3acrNVp2kKS0I6cdrEthFk86GoDsOi+U71Wbas=;
        b=be3lGTglqUPOQC2O7NwEQiRT1PrW/n7B0d0QghT4UU54y5MnJiTbkjQ6xXat/aVBB7
         SoARAXqOHTkiFifO6JnuWwXcFoeEG43lyh16GgkW0/9Kygt48mVBJBOWLwUmBarNms5M
         dWV8RlzJFGhYMjZ7fkuadzdx1ZwqmX0qjc3OlaG//bBPBu3v/Pao9SopLbQ0siXSr8By
         yzsyZQYkgwb2cKGl3qzg2RyX0ao4pZ6cgsr7tbgY2sSHrVszO7fC0gK939T7qDk0p5db
         Y2WleED7AMvi+oqUGGnJHrXbgp4ulYbwAwpYqMEIAjI+eYNrj+tokpZeMIS89W091k0R
         J3qg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790746767; x=1791351567;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mZRpH3acrNVp2kKS0I6cdrEthFk86GoDsOi+U71Wbas=;
        b=id7O4HkC1vFk3ij0AJytMpkZIJc8BpmVYcgLvA8OIbH2XO/cNBIzTb7WO+eIyDlxvi
         /ZgHoNohQibQmr8DY3fr5iX4hgUBAMmri+56PnvoUxUWPBR934kQTAWhJmfSODydDIwe
         U4d3NFalszDxJTptBqolsZgtBUNB/9h4uKXqxTfKIXU5V7saETx/IQf5j85ifnJSKdsg
         mko6kbI48UOS51/xCMgNpC+FAOWTpK7gnJLUDbvceMkZXS95qTTGOMIjuBH7ngskK0l/
         icTWH28fxVTUf9rVTNvPHSVMGO0T021qLSoQkW0yJ8FO3/To5p0TB3zYxK1AMO1RUBwz
         hDTg==
X-Gm-Message-State: AFuF++kVQDPQ+dsWCvlPSXVwTL/Oujx/+G6m0IBWXd1WgL9Nxlix2/gO
	PWaMtjhWrTJmAG0RQRX8id5vVmBpYVzzRdCpYMVSOUugUWs2HAXPiBn95LwyTEsUpLE=
X-Gm-Gg: AYBFou3QUiABTaY5mIxurzPd6rfHx9slgTi2cwyudYk0CLeKydTIo5h3RWAOc36hagk
	GFP8Oite0NPKzYKR0+2YRsoa+BE2MUmN/y1Hs4YD60PGC6RBsXSlFxrvYWETk0QEfvC/pSuLHFd
	e7IMgVnVSXTNFS3nUMNeGrcizWlyb1KAsuvuBa5UGZLt5gXM34r3+Vd1NvkdFXvQ/pZhe36B7/I
	AbLWiwWW7Cjtt5A+cDElb0RfrDluWpcXcUFeGSPLwPTl7oC5I4kFlpu8mBiKbl8GqIQP6ke5o5e
	TbAi6TxmjB2qyO2WAdDZusEVzXcpSiAOZUlG2Y2zdOfYl0t1zjlobQcov83WWXX5HNYi8I9BqNx
	694JwTeOzUlxS6jsiWoOonqFVOYWcgt2yHP7QYVfYrbR0wi4TFO7ruA2BllEpQDNH6x19Tjo/D5
	GI62nHWDdV4dMPloQ4POKTv3ywfx8vwreC5Ui1HHpnhnGWiMdurA6CDnot3+YjE/Z/jb4tYhSMR
	1AJA5YceaoVckHBgbjH+GV/ce26pRgHRcgfhJLIVS0/JgbuMSUzSqSpPwxlSQ==
X-Received: by 2002:a05:6a00:ac8a:b0:886:4ca4:a3e7 with SMTP id d2e1a72fcca58-887472cef3fmr209042b3a.6.1790746767197;
        Tue, 29 Sep 2026 22:39:27 -0700 (PDT)
Received: from muumthf.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-8872587f6bcsm217544b3a.22.2026.09.29.22.39.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:39:26 -0700 (PDT)
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
Subject: [PATCH v2] nfsd: pin source client while using COPY_NOTIFY stateid
Date: Wed, 30 Sep 2026 14:39:15 +0900
Message-ID: <20260930053915.299362-1-muumthf@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A COPY_NOTIFY token can resolve to a stateid owned by the source client.
find_cpntf_state() drops its source-client reference before returning
that stateid, so concurrent source-client expiry can free sc_client
while stateid validation or the caller still uses the stateid.

Add a local nfsd4_get_client() helper as the counterpart to
nfsd4_put_client(). Return a paired client reference from
nfs4_preprocess_stateid_op() when lookup crosses through COPY_NOTIFY
state. Keep it until the caller releases the returned stateid; internal
and error paths release it locally.

An unprivileged NFSv4.2 client with access to the exported file can execute
the OPEN, COPY_NOTIFY, source-client replacement, and token READ sequence.
Four hundred natural trials reached the protocol path without reproducing
the report, so a reliable timing-assistance-free trigger was not
demonstrated.

For deterministic validation, a test-only kprobe delayed nfsd_permission()
after COPY_NOTIFY state lookup. The module only widened the race window; it
did not allocate, free, or modify an NFSD object. Validation used the
nfsd-testing base recorded below. On the unmodified KASAN kernel, five
trials registered four delayed calls and reproduced the source-client
use-after-free in nfs4_put_stid(). With this patch, five trials registered
five delayed calls and produced no KASAN report or kernel failure. Three
token READs returned NFS4_OK with 23 bytes; two returned NFS4ERR_EXPIRED as
client replacement won the race.

The full KASAN kernel built with CONFIG_WERROR without a compiler
diagnostic. Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests passed.
A source reproducer, timing-module source, complete logs, and the kernel
configuration are available privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 624322f1adc5 ("NFSD add COPY_NOTIFY operation")
Assisted-by: LLM
Signed-off-by: Hyunsol Mun <muumthf@gmail.com>
---
Changes in v2:
- Describe current timing-assisted baseline and patched results.
- Add full-build and NFSv4.2/NFSv3 smoke-test results.
- Keep nfsd4_get_client() local to nfs4state.c.

 fs/nfsd/nfs4proc.c  | 31 +++++++++++++++++++++----------
 fs/nfsd/nfs4state.c | 34 +++++++++++++++++++++++++++-------
 fs/nfsd/state.h     |  2 +-
 3 files changed, 49 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7df60abfb..d5b5f59f1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1144,7 +1144,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* check stateid */
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&read->rd_stateid, RD_STATE,
-					&read->rd_nf, NULL);
+					&read->rd_nf, NULL, NULL);
 
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = &cstate->current_fh;
@@ -1342,6 +1342,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		.na_dpacl	= posix_acl_dup(setattr->sa_dpacl),
 	};
 	bool save_no_wcc, deleg_attrs;
+	struct nfs4_client *stid_clp = NULL;
 	struct nfs4_stid *st = NULL;
 	struct inode *inode;
 	__be32 status = nfs_ok;
@@ -1358,7 +1359,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 		status = nfs4_preprocess_stateid_op(rqstp, cstate,
 				&cstate->current_fh, &setattr->sa_stateid,
-				flags, NULL, &st);
+				flags, NULL, &st, &stid_clp);
 		if (status)
 			goto out_err;
 	}
@@ -1375,8 +1376,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			}
 		}
 	}
-	if (st)
+	if (st) {
 		nfs4_put_stid(st);
+		if (stid_clp)
+			nfsd4_put_client(stid_clp);
+	}
 	if (status)
 		goto out_err;
 
@@ -1439,6 +1443,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_write *write = &u->write;
 	stateid_t *stateid = &write->wr_stateid;
 	struct nfs4_stid *stid = NULL;
+	struct nfs4_client *stid_clp = NULL;
 	struct nfsd_file *nf = NULL;
 	__be32 status = nfs_ok;
 	unsigned long cnt;
@@ -1451,13 +1456,16 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	trace_nfsd_write_start(rqstp, &cstate->current_fh,
 			       write->wr_offset, cnt);
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-						stateid, WR_STATE, &nf, &stid);
+						stateid, WR_STATE, &nf, &stid,
+						&stid_clp);
 	if (status)
 		return status;
 
 	if (stid) {
 		nfsd4_file_mark_deleg_written(stid->sc_file);
 		nfs4_put_stid(stid);
+		if (stid_clp)
+			nfsd4_put_client(stid_clp);
 	}
 
 	write->wr_how_written = write->wr_stable_how;
@@ -1484,12 +1492,12 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
-					    src_stateid, RD_STATE, src, NULL);
+					    src_stateid, RD_STATE, src, NULL, NULL);
 	if (status)
 		goto out;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-					    dst_stateid, WR_STATE, dst, NULL);
+					    dst_stateid, WR_STATE, dst, NULL, NULL);
 	if (status)
 		goto out_put_src;
 
@@ -1954,7 +1962,7 @@ nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
 	/* Verify the destination stateid and set dst struct file*/
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &copy->cp_dst_stateid,
-					    WR_STATE, &copy->nf_dst, NULL);
+					    WR_STATE, &copy->nf_dst, NULL, NULL);
 	if (status)
 		goto out;
 
@@ -2498,12 +2506,13 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_copy_notify *cn = &u->copy_notify;
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfs4_client *stid_clp = NULL;
 	struct nfs4_stid *stid = NULL;
 	struct nfs4_cpntf_state *cps;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&cn->cpn_src_stateid, RD_STATE, NULL,
-					&stid);
+					&stid, &stid_clp);
 	if (status)
 		return status;
 	if (!stid)
@@ -2536,6 +2545,8 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_put_cpntf_state(nn, cps);
 out:
 	nfs4_put_stid(stid);
+	if (stid_clp)
+		nfsd4_put_client(stid_clp);
 	return status;
 }
 
@@ -2548,7 +2559,7 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &fallocate->falloc_stateid,
-					    WR_STATE, &nf, NULL);
+					    WR_STATE, &nf, NULL, NULL);
 	if (status != nfs_ok)
 		return status;
 
@@ -2612,7 +2623,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    &seek->seek_stateid,
-					    RD_STATE, &nf, NULL);
+					    RD_STATE, &nf, NULL, NULL);
 	if (status)
 		return status;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bbc16dd22..43906f87e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2805,6 +2805,15 @@ static void __free_client(struct kref *k)
 	kmem_cache_free(client_slab, clp);
 }
 
+/**
+ * nfsd4_get_client - acquire a reference on an nfs4_client
+ * @clp: the client to be acquired
+ */
+static void nfsd4_get_client(struct nfs4_client *clp)
+{
+	kref_get(&clp->cl_nfsdfs.cl_ref);
+}
+
 /**
  * nfsd4_put_client - release a reference on an nfs4_client
  * @clp: the client to be released
@@ -8504,7 +8513,8 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 }
 
 static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
-			       struct nfs4_stid **stid)
+			       struct nfs4_stid **stid,
+			       struct nfs4_client **stid_clp)
 {
 	__be32 status;
 	struct nfs4_cpntf_state *cps = NULL;
@@ -8524,10 +8534,13 @@ static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 	*stid = find_stateid_by_type(found, &cps->cp_p_stateid,
 				     SC_TYPE_DELEG|SC_TYPE_OPEN|SC_TYPE_LOCK,
 				     0);
-	if (*stid)
+	if (*stid) {
+		nfsd4_get_client(found);
+		*stid_clp = found;
 		status = nfs_ok;
-	else
+	} else {
 		status = nfserr_bad_stateid;
+	}
 
 	put_client_renew(found);
 out:
@@ -8551,6 +8564,7 @@ void nfs4_put_cpntf_state(struct nfsd_net *nn, struct nfs4_cpntf_state *cps)
  * @flags: flags describing type of operation to be done
  * @nfp: optional nfsd_file return pointer (may be NULL)
  * @cstid: optional returned nfs4_stid pointer (may be NULL)
+ * @cstid_clp: client reference paired with @cstid (required with @cstid)
  *
  * Given info from the client, look up a nfs4_stid for the operation. On
  * success, it returns a reference to the nfs4_stid and/or the nfsd_file
@@ -8560,10 +8574,11 @@ __be32
 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
 		stateid_t *stateid, int flags, struct nfsd_file **nfp,
-		struct nfs4_stid **cstid)
+		struct nfs4_stid **cstid, struct nfs4_client **cstid_clp)
 {
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct nfs4_client *stid_clp = NULL;
 	struct nfs4_stid *s = NULL;
 	__be32 status;
 
@@ -8579,7 +8594,7 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 				SC_TYPE_DELEG|SC_TYPE_OPEN|SC_TYPE_LOCK,
 				0, &s, nn);
 	if (status == nfserr_bad_stateid)
-		status = find_cpntf_state(nn, stateid, &s);
+		status = find_cpntf_state(nn, stateid, &s, &stid_clp);
 	if (status)
 		return status;
 	status = nfsd4_stid_check_stateid_generation(stateid, s,
@@ -8605,11 +8620,16 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		status = nfs4_check_file(rqstp, fhp, s, nfp, flags);
 out:
 	if (s) {
-		if (!status && cstid)
+		if (!status && cstid) {
 			*cstid = s;
-		else
+			*cstid_clp = stid_clp;
+			stid_clp = NULL;
+		} else {
 			nfs4_put_stid(s);
+		}
 	}
+	if (stid_clp)
+		nfsd4_put_client(stid_clp);
 	return status;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1a0da82cb..7910dabb4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -911,7 +911,7 @@ struct nfsd4_async_copy;
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
 		stateid_t *stateid, int flags, struct nfsd_file **filp,
-		struct nfs4_stid **cstid);
+		struct nfs4_stid **cstid, struct nfs4_client **cstid_clp);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 			    stateid_t *stateid, unsigned short typemask,
 			    unsigned short statusmask,

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.50.1 (Apple Git-155)
