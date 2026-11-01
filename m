Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793548281;
	b=Qw1RGMquo/W4nlOqWY9SgqKVvw8m1eqR9VcIuIzwG9zVudvqVVd51uhg5qvMLC1FCn6s
	 FNTJ53JSYzegLXMPohcbcgUzREucPCEdj18nxxvRrl8MXveC1jTDRafbaPbs0VIUcM099
	 hNRN5/DwUxauikeGeHRhSxkaNPBVFuSYUisCOGfK8AYQ7NmiICaPm8+oX6JLK08BeF01G
	 bZEctMoOC4/Ad6XnLZH93in354X+XeZGRREnn7ucLN55TF1nfPhYELxSrGuFmiJOYuzvb
	 gzkBwVfMkqnzr/fy7Y+uUjcVD5FYjiu3jym/DLRhKmrWbmFojcKghkCdddPtlMmvFrQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793548281;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WVS5Jb6NcVFcvnLidHwSb/0ROGlteL91TOkOg5df6xI=;
	b=zpDP6AfUJWIPlDh7hpiBia7JeRAE0MiROCT4fBu0oej+M2+hagmY3ccE4miwvy83KnsU
	 sPqeJoZG6OnqmMA5v7Hrj3ASne6+OjwmBnlo2/gNYtc6HqKJkRtDlzURIqsNR+5Wrmq+i
	 oH4Kcp3Bm0CEHzbYZJoO6FpT2/f5bDz7HAo+B/rOAuG3MTDv+Ev1wifuss0CljqsTTEFC
	 ilsQEi9EBeTDkaFhHDHIoiZDcMBZZqxyPzNKRcPU6UXWtLsNuLi4uvJIo02Dqo7fWzf95
	 uBnDEQ6MDjfgyONRMuq8sN5YSiwEzSVJG1PTBgiTjHtVnKYLU5pztUGja+93VJZvJng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hGonle5E;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 832D8606A32C
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 15:51:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hGonle5E
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 937C81F00A15;
	Sun,  1 Nov 2026 15:51:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793548281;
	bh=WVS5Jb6NcVFcvnLidHwSb/0ROGlteL91TOkOg5df6xI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hGonle5EgosTef/asusRxLmYAjIxKv8Uc8+FXgOjVAQUyzxA0KmrLAAACqPH3b53n
	 HL0aDIaw78IK5yLetCoOLoVsY78ytM3poaavcA4TCbrORfyfQcs230hKuBa+Mt+CKd
	 PAckqEZwfcsMaW1Rn6Dlu/KQtJ5Cq69C73NMuwRysJMvGr8V+mJ7/j+k3VYmzL7D3c
	 g3Va99JlljFhCXUREO2eZpxXhL6+pVG3pGn3JpSmGB5u8JHEqSHd03SPxQ7j8iUAg0
	 Ufwo8wpgIDfjWmTyqQF/MuMH0ecnlAPGmrJC5GkjU6esWA4iAk9ABkQeKaztgoelY8
	 lHqMuTTeSSS2A==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 01 Nov 2026 10:51:10 -0500
Subject: [PATCH v6 1/3] NFSD: Fix PUTFH wrongsec check when SAVEFH follows
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
Message-Id: <20261101-verofess-v6-1-4d70097db7d3@kernel.org>
References: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
In-Reply-To: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3800; i=cel@kernel.org;
 h=from:subject:message-id; bh=/9md6L7PBJFdrZE/6SODF/WUjcSyUC1/l957VpvKYuw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq51/2M5ksrHBtNjFQ0SU3LhrAjcuLQg9M+NGab
 5D9GoxwYsKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaudf9gAKCRAzarMzb2Z/
 l5mtD/9py4PpLR4do84WVwEQN6J2IPauXEeq3XrI+4oWid8yWLVQNAx4sr7zrfD+DL75ItY6YXs
 7m9f8Km3KYJ0mxBL26jkuu8mJ3/ELFsQtiGin/GU9ZscyV9hvSooiMaDIzO/CKAJsokl48kAJ2E
 rxGDouck851O4rps8BvB7nNkIgsQ2NVTImMQL1vmmZQeI+xu43PxvHOkUWULtv5eG6/2saINBgj
 kCY07LkMFQY9E1SV+6xaSxdJ2ieeFZP6niIWRrxOkp6gvCv1d2P5DVO9ztXR5930fndzYY/GB8t
 caEoPsGVb3WC9faz62W5NKhwD8WRBohZV76SLyxGU9UPNmEDbR45nRACBPA8WAGrrKGHzn5gM6Z
 O97dO5W0UJstDzxzI6dkcfcL3AkhJzZpTEA3K5x+9/7cTVZuWVcgvvxBKiA9Imb+KLCZ/2QrP7H
 UewoKLMd+UEOGNPYvS+PQopcAWehtb3ZfS8vvammYntlzIPMluWgV7puHA2Xsv1zevz3X++MZHe
 eQHWILbGvidP+afh5uQ56FTCXcjfuUQl/C4qNcRqe3qevi25r3OTKn5iGq+2Hoy1233b5zuVNfn
 seAsGJ79WwatcYxvX7/H11XPO+IAWrOpcY7T0tTZnK/8WEvX6WcfVUzZ6bUxRj0OzccghcEQsHL
 z6P/PzEmOZv/DfQ==
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

