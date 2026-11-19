Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116205;
	b=uVkiEU/LEYd2WCnCRHUmg8Gs5o+zSQ1KpDX3HGX+qQecH/X1NCJltEFzSlKB4JoEapa0
	 OTQ6Z+JrPErUQjiIovzXBnZOOO+/JccTlDTmS82zuyiBQlWd8mqKtcnNxcjQ5JKEJFb50
	 bAY+QPqEXruOKb+eXmtgaipn6O0FJkdhNoyv7gp/GEaUM3Tv/ArcdLEYfi0XeyCqBp83h
	 8KnjdkqF+GvztrZoa0C7M4yHL4WOqzw4F3uIxY2xVYeG2VErF6DmqAlu+j+hmCSxldvtS
	 q3O5CkiW3lrmXuf3Tp0HZGpfyA6W9p6evSeYtX6EaDSqQKNVKhUSvuS8/JNdmt7ZCLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116205;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=THHg4HUe9eISHV406oySRUlMtrwO/cKvBRCmbtQ4+iA=;
	b=NfcWRH71LGYuKFHIRo4F1dkglPSb4C7h88XZ02qSVYLx8OUepY0qy6mh2kvwcZVv6aar
	 8HYtQbN7+Sv5Ak5qkhNQbP30hffKw/azHMI8KSsyZejsxO8NwXfFYuhFwuy7IRew6qo12
	 0op23MkhviDuc3PipDPVXKNJHILKTkGdjTZFAX/ABYELdwdQI0Xg6XfOwUBJ/4H6Y/iAU
	 1y2FlP+tYoIpS4VvOaJR7dKK2fvM9I9JCq64viTrX7a1XoTb4qoUgNdPfXFz7Zuora2MV
	 h+awaSwwFg13T+Xne258Te0OzHRxXa3Egh9YQQ/WYd1NTGM6si2Nd+xdvdOcDzdKhYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=myMctmyP;
	arc=none smtp.remote-ip=209.85.221.71
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C163606A332
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6C163606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=myMctmyP
Received: by mail-wr1-f71.google.com with SMTP id ffacd0b85a97d-492b5408dedso15957f8f.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116204; x=1795721004; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=THHg4HUe9eISHV406oySRUlMtrwO/cKvBRCmbtQ4+iA=;
        b=myMctmyPMKNu1ZncD7eu+h2+hx3Dm8zMkesA5eIPiIyrPRa5MQP9JwGNwZO7FWilb/
         BWnDmbFli56TnIv9Ona1sSR0ieO795BjlBCgmZRwXajl3ekx5mfSB3Sd+RfsojRrIKQD
         1i6dyt+0GRhvikRTW0clbxlrlfcAwbaPFa47A7dhMPBOmsqWa3ZVmB64fIJl5pQchiQE
         8+p/zh6Sp0rqihX0S3G1/15yZVeU4SBqw8+tVGUGcKhG7IbyE2Bo/mXxYYamSvnfVcao
         q0RiyAz3nfrmlkDNX1LdYrLVn8etG4f6m54/49PoJB/7eLO0FNF+722OFk+WeZd687YO
         tlEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116204; x=1795721004;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=THHg4HUe9eISHV406oySRUlMtrwO/cKvBRCmbtQ4+iA=;
        b=VqwWhGEKeYsKrppwQA+YvlOzUdD2iDmE3oqxVgKovEkfd0x1wflev+nLrUmxvGMk9m
         LzkmXmTEhejOn8jMKHXvxnYRhFFqhcrznQ1dj4KuGjDTY7HE6YU+IFck2CDzuvIls2/b
         H2nHABr398CmnF5ogTZg5qtovyxtqa9o2sUZKZQ2xlY0+uGoFEIl5WPxykZg24aaqUD4
         Cg5JzZrHNDCS3IhqLNz4PUKkBfAT1qzgcQEGwOIsQGFkkrjZ3WXpyxw0kBC41opX9OjW
         DY3q5ClBDh7F6CcxxWWy2DOXeSySTQbXYxxoibrzuuLHyGdICr36/TgF/ppTXHAl0bm9
         dzAg==
X-Forwarded-Encrypted: i=1; AL+hErF9yhTwMvIGkl7eXa7IYEHEQy35GII+RczRa9ciodcVf+8QUb82aIbFotelIeDQUFUaq3mO469aZmA=@vger.kernel.org
X-Gm-Message-State: APuU4Z+WL7dpLS2+ZP8F3l2455F/edGxPxX1sk6QEJxFNn6m3/YG2IQk
	k8qDSeF0oGII4bRmI+IJwxOrKALiV7H1CUt6pfEpZ2fZbmL3O4fb50mLbZnoUum5IO23oSmfKg=
	=
X-Received: from wmrn31.prod.google.com ([2002:a05:600c:501f:b0:4a1:f37f:7f0b])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:4e0c:b0:4bb:875b:f23f
 with SMTP id 5b1f17b1804b1-4bb88827f0bmr10837735e9.33.1795116203562; Thu, 19
 Nov 2026 11:23:23 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:22 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.809.ga0b61035b5-goog
Message-ID: <20261119192322.2691590-1-dmnk@google.com>
Subject: [PATCH] nfsd: restrict nfsd4_spo_must_allow() to bounded cleanup compounds
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com, 
	Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

nfsd4_spo_must_allow() scans all remaining operations in an NFSv4.1+
compound and latches cstate->spo_must_allowed = true for the entire
compound whenever any later operation appears in clp->cl_spo_must_allow.

Because check_security_flavor() returns nfs_ok whenever
nfsd4_spo_must_allow() returns true, an authenticated SP4_MACH_CRED
client can place operations that are not in cl_spo_must_allow (such as
OPEN, READ, or WRITE against a sec=krb5p export while using krb5i
machine credentials) in the same compound as a permitted spo_must_allow
operation such as CLOSE or TEST_STATEID and bypass NFS4ERR_WRONGSEC.

Remove the compound-wide cstate->spo_must_allowed flag and validate that
the entire compound matches a bounded SP4_MACH_CRED stateid management
or state cleanup compound (2 to 6 operations, bounds-checked against
LAST_NFS4_OP and free of decode errors):

- 2-operation compounds ending in a cl_spo_must_allow operation (such
  as SEQUENCE + TEST_STATEID or FREE_STATEID); or
- compounds starting with SEQUENCE + PUTFH, ending in a filehandle-using
  cl_spo_must_allow operation (CLOSE, OPEN_DOWNGRADE, LOCKU, or
  DELEGRETURN, excluding ALLOWED_WITHOUT_FH operations so no trailing
  I/O operations can follow), and containing only legitimate cleanup
  companion operations in between (LAYOUTRETURN, delegated-timestamp-only
  SETATTR, and non-ACL/non-security-label GETATTR), preserving Linux
  NFSv4.1/4.2 CLOSE and DELEGRETURN compounds.

This issue was discovered by an AI-assisted code review tool (ARTIST)
and validated in QEMU against an unmodified v7.4-rc3 kernel without
kernel modifications or error injection. A standalone reproducer is
available on request. The fix was build-tested with KCFLAGS=-Werror and
checked with checkpatch.pl --strict.

Fixes: ed94164398c9 ("nfsd: implement machine credential support for some operations")
Cc: stable@vger.kernel.org
Signed-off-by: Dominik Maier <dmnk@google.com>
---
Note: Based on nfsd-next commit 18b212a69f92 ("nfsd: bounds-check opnum
before testing spo_must_allow").

 fs/nfsd/nfs4proc.c | 83 ++++++++++++++++++++++++++++++++++++++----------------
 fs/nfsd/xdr4.h     |  1 -
 2 files changed, 59 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ccef2c6..199a931 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -4282,45 +4282,80 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
+static bool nfsd4_spo_cleanup_companion_ok(const struct nfsd4_op *op)
+{
+	switch (op->opnum) {
+	case OP_LAYOUTRETURN:
+		return true;
+	case OP_SETATTR:
+		return !op->u.setattr.sa_bmval[0] &&
+		       !op->u.setattr.sa_bmval[1] &&
+		       op->u.setattr.sa_bmval[2] &&
+		       !(op->u.setattr.sa_bmval[2] &
+			 ~(FATTR4_WORD2_TIME_DELEG_ACCESS |
+			   FATTR4_WORD2_TIME_DELEG_MODIFY));
+	case OP_GETATTR:
+		return !(op->u.getattr.ga_bmval[0] & FATTR4_WORD0_ACL) &&
+		       !(op->u.getattr.ga_bmval[2] &
+			 (FATTR4_WORD2_SECURITY_LABEL |
+			  FATTR4_WORD2_POSIX_DEFAULT_ACL |
+			  FATTR4_WORD2_POSIX_ACCESS_ACL));
+	default:
+		return false;
+	}
+}
+
 /**
- * nfsd4_spo_must_allow - Determine if the compound op contains an
- * operation that is allowed to be sent with machine credentials
+ * nfsd4_spo_must_allow - Check if compound is allowed with machine creds
+ * @rqstp: RPC transaction context
  *
- * @rqstp: a pointer to the struct svc_rqst
+ * Validates that the NFSv4.1+ compound is a bounded SP4_MACH_CRED state
+ * cleanup or stateid management compound and was sent with the client's
+ * negotiated machine credentials.
  *
- * Checks to see if the compound contains a spo_must_allow op
- * and confirms that it was sent with the proper machine creds.
+ * Return: true if the compound may bypass export security flavor checks.
  */
-
 bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
-	struct nfsd4_op *this;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
-	struct nfs4_op_map *allow = &cstate->clp->cl_spo_must_allow;
-	u32 opiter;
+	struct nfs4_op_map *allow;
+	struct nfsd4_op *last;
+	u32 i;
 
 	if (rqstp->rq_procinfo != &nfsd_version4.vs_proc[NFSPROC4_COMPOUND] ||
-	    cstate->minorversion == 0)
+	    cstate->minorversion == 0 || !cstate->clp || !resp->opcnt ||
+	    argp->opcnt < 2 || argp->opcnt > 6)
 		return false;
 
-	if (cstate->spo_must_allowed)
-		return true;
+	if (!cstate->clp->cl_mach_cred ||
+	    !nfsd4_mach_creds_match(cstate->clp, rqstp))
+		return false;
 
-	opiter = resp->opcnt;
-	while (opiter < argp->opcnt) {
-		this = &argp->ops[opiter++];
-		if (this->opnum <= LAST_NFS4_OP &&
-		    test_bit(this->opnum, allow->u.longs) &&
-		    cstate->clp->cl_mach_cred &&
-		    nfsd4_mach_creds_match(cstate->clp, rqstp)) {
-			cstate->spo_must_allowed = true;
-			return true;
-		}
+	allow = &cstate->clp->cl_spo_must_allow;
+	last = &argp->ops[argp->opcnt - 1];
+	if (last->status || last->opnum > LAST_NFS4_OP ||
+	    !test_bit(last->opnum, allow->u.longs))
+		return false;
+
+	if (argp->opcnt == 2)
+		return !(OPDESC(last)->op_flags & OP_IS_PUTFH_LIKE);
+
+	if (OPDESC(last)->op_flags & ALLOWED_WITHOUT_FH)
+		return false;
+
+	if (argp->ops[1].status || argp->ops[1].opnum != OP_PUTFH)
+		return false;
+
+	for (i = 2; i < argp->opcnt - 1; i++) {
+		if (argp->ops[i].status ||
+		    argp->ops[i].opnum > LAST_NFS4_OP ||
+		    !nfsd4_spo_cleanup_companion_ok(&argp->ops[i]))
+			return false;
 	}
-	cstate->spo_must_allowed = false;
-	return false;
+
+	return true;
 }
 
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ec19899..73aba10 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -61,7 +61,6 @@ struct nfsd4_compound_state {
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
 	int			data_offset;
-	bool                    spo_must_allowed;
 	bool			slot_owned;
 	size_t			iovlen;
 	u32			minorversion;
-- 
2.56.1.750.gf70dc682cf-goog
