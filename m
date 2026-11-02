Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627896;
	b=v4/XcXxt2GvAsHVJqE23IPo2yMYPhmrbynLtDKbx9xV2TEMk1pztUmGEKb/4ZwTJSTgw
	 liqXM0pA86z3x4Vfc2LRHJnI4xq06oqfDDK2kfLwOGYgpdrMNw7ZtN7woX/V2HeBT+TqZ
	 QipxZ2/djw3hgnyxlOPAZ2EmUXuLrYuwIxUTdTqSm1ly/BeXlkvIe9tg9i01Wt5lazqyc
	 enOtcYm2gGlabpPMlUBx9IzvNb2nIcWPMNYx0bNS4tcof3aDnGdYCIfCrsOOBRNa82ur8
	 fZmZEH5OyPZ3I8Quhv9VmAlWYfr0TxO61FmlaE7vWTtb6K6dbRpCM7nyTz6ikCo79ZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627896;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WVS5Jb6NcVFcvnLidHwSb/0ROGlteL91TOkOg5df6xI=;
	b=vN7qFpdU3xdGSLCdEBtcAIkN74rixV99RZYLPxDX7fyAl9vvEQmlSYF9UhPY5i0ak1tv
	 sMy+ub+n5AvA07t71A1wWvE9c72OP4/wh27bOINWC+OpJ2t22TUnUUn/kVi26OnOHhVGG
	 8AYiuv9CCvXSyYVxUcTidqkbWhMlhCHk76QelsmO8pSmyuSIsmX+Ri7nicV6ZPSxzBcZS
	 n3IuF96YUtVE+RiPx0qc2pMC23kbbImXmcscZgyF3gMOwfDrf5s+4GvsVZoN1TSyIbwjL
	 6CJ8iAmL3KSX3GZEh8FaWG7teIwS7k8qLvAmfKK962qFETNomxftt7jH4jbhsRQ9W6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kzxEuNuR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 931C0606A339
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:58:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kzxEuNuR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 80DD21F00A18;
	Mon,  2 Nov 2026 13:58:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793627896;
	bh=WVS5Jb6NcVFcvnLidHwSb/0ROGlteL91TOkOg5df6xI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kzxEuNuRJs9TzAEoIxlj9nTATh9seZSvOcbD7WSkdCguka4lv0TPAbdgmFslbb82J
	 hYMPhhdKANhyjtGfSw7Hdg0rm++dxUOT/Ya9PllV4wUaeLrTUi8m+HKilkQoNyk4jm
	 EXldWmPci1eTF3oNANaqgs89Ij28Seu4RK5ie4SbkhqsTXQabzIp8iMLR+RZ3LpjOg
	 aApGzOBJpJP1WVVhvql57UhPXaZkOEyIQHAAI3lkJWb+Zfcb16LPpxQsmi5r1nSmSS
	 oaSRlKdyutKSvoPRyLeUlZEiXQsx12rua/Wcq1cUA6lyKbu0RP4V5I+pvNPb8mc/+h
	 qZgL+RLIAOgEg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 02 Nov 2026 08:58:01 -0500
Subject: [PATCH v7 1/5] NFSD: Fix PUTFH wrongsec check when SAVEFH follows
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
Message-Id: <20261102-verofess-v7-1-d2cc0de4d44e@kernel.org>
References: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
In-Reply-To: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3800; i=cel@kernel.org;
 h=from:subject:message-id; bh=/9md6L7PBJFdrZE/6SODF/WUjcSyUC1/l957VpvKYuw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6Jb1Iw4BCDHK+bd6U7XUn+Am+HOa1h43yjWrU
 cwYpbWoHeWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauiW9QAKCRAzarMzb2Z/
 l52lEACFfN6gEhHF1A316CUys0zAbhscW4UU21JwKuIAdTYEocWCvxgMneL8olx5fatlFpXx6Jb
 lnYPHr81Ep8pHFNhnQMWBCc+SDzs7QxoAq9sJckjLR6n0aDnrVp4gkluVDlumjxUpwPRnzaT4oo
 TaCt+KFiv64FEDzAFVJLrx/qzXcTeaw5HogRhG+dNJdgFlkHp3l7G2y0LXLiwob5k3pE4cYEJBE
 9VkOK6cWCREXmMlQmnJrpjp14wCeeVzVyzauMj8Q8nuM07bplll85sr1mAlaAXsYlV4dWH0wtAp
 J1m5yHgRaFAYwtehcwlr6UuW+t42ZyW+mLUlYOwCRPe0mSQHGRT8EVifNhYrPw5p2AVr/T6bvIj
 bx/P/volxsXvwbBF9sMUi9UuW8yVLKmSPuecbtIDpSS4samXkA5tmlKuG3dzKig8lpR53tzZmdp
 JqKC9G7gXV9O5uSn7KK1XYNXCzT/5E7gjA4xfNcwRjTGjQ3m21ZEbGoYfJIvxUNTbRng/ykTuzc
 a8DaKGIioO8j5eISCa37QlugOhQNn2rS8kO0sP7aOYT2KX3Xtm/kXOLSbEix7SQ9H+BvbGOx/sE
 qFhGTrE5INBjQBtr1YqWYtJfFn6jK2ketyqQ6AkNilxlegzmfoB3JJ+t7gtvP1SWrbn7WxAgCBG
 5SEx/l0Plvhnlew==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: VeroFess <coderzeng@gmail.com>

An AUTH_SYS NFSv4.0 client can read or write a file on a sec=krb5p
export using another client's valid OPEN stateid by inserting
SAVEFH between PUTFH and READ or WRITE.

PUTFH resolves the handle with NFSD_MAY_BYPASS_GSS and defers the
security flavor check to need_wrongsec_check(), which looks only at
the next operation. SAVEFH carries OP_HANDLES_WRONGSEC even though
it only saves the handle, so PUTFH skips NFS4ERR_WRONGSEC. The READ
or WRITE that follows then reuses a cached nfsd_file.

With these export options:

  rw,sync,no_subtree_check,fsid=0,sec=krb5p,secure,root_squash

a Kerberos privacy NFSv4.0 client held an OPEN stateid. With the
same stateid, PUTFH; READ over AUTH_SYS was rejected, but PUTFH;
SAVEFH; READ and PUTFH; SAVEFH; WRITE succeeded, and the Kerberos
client subsequently read the changed contents.

SAVEFH leaves CURRENT_FH in place. When deciding whether PUTFH must
report NFS4ERR_WRONGSEC, look past SAVEFH to the first operation
that uses or replaces CURRENT_FH. If another PUTFH replaces it,
leave the earlier PUTFH unchecked, as RFC 8881 Section 2.6.3.1.1
requires. Drop OP_HANDLES_WRONGSEC from SAVEFH, which performs no
check of its own and is never consulted once it is skipped.

Fixes: 68d93184352f ("nfsd4: fix wrongsec handling for PUTFH + op cases")
Signed-off-by: VeroFess <coderzeng@gmail.com>
Tested-by: VeroFess <coderzeng@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d0290fce9187..50f38d6e147b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3237,32 +3237,39 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
 	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
-	struct nfsd4_op *next = &argp->ops[resp->opcnt];
+	struct nfsd4_op *next = NULL;
 	const struct nfsd4_operation *thisd = OPDESC(this);
 	const struct nfsd4_operation *nextd;
+	unsigned int i;
 
-	/*
-	 * Most ops check wronsec on our own; only the putfh-like ops
-	 * have special rules.
-	 */
+	/* Only put-filehandle operations need a deferred WRONGSEC check. */
 	if (!(thisd->op_flags & OP_IS_PUTFH_LIKE))
 		return false;
+
 	/*
-	 * rfc 5661 2.6.3.1.1.6: don't bother erroring out a
-	 * put-filehandle operation if we're not going to use the
-	 * result:
+	 * RFC 8881 Section 2.6.3.1.1.1: SAVEFH does not count as the
+	 * next operation.
 	 */
-	if (argp->opcnt == resp->opcnt)
+	for (i = resp->opcnt; i < argp->opcnt; i++) {
+		next = &argp->ops[i];
+		if (next->opnum != OP_SAVEFH)
+			break;
+	}
+
+	/* RFC 8881 Section 2.6.3.1.1.6: nothing uses the filehandle. */
+	if (i == argp->opcnt)
 		return false;
+
 	if (next->opnum == OP_ILLEGAL)
 		return false;
 	nextd = OPDESC(next);
 	/*
-	 * Rest of 2.6.3.1.1: certain operations will return WRONGSEC
-	 * errors themselves as necessary; others should check for them
-	 * now:
+	 * RFC 8881 Section 2.6.3.1.1.2: a later put-filehandle operation
+	 * replaces this one. Other marked operations check WRONGSEC
+	 * themselves.
 	 */
-	return !(nextd->op_flags & OP_HANDLES_WRONGSEC);
+	return !(nextd->op_flags &
+		  (OP_HANDLES_WRONGSEC | OP_IS_PUTFH_LIKE));
 }
 
 #ifdef CONFIG_NFSD_V4_2_INTER_SSC
@@ -4047,7 +4054,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SAVEFH] = {
 		.op_func = nfsd4_savefh,
-		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_SAVEFH",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},

-- 
2.56.0

