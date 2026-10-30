Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793395669;
	b=4hxYe8uoJMpWnFvoItySWKOiveXSur5Sy1eVeHd7P/zKwt8TWEPlwjrWszmUM5S2MKJc
	 gbyT1mXg2Y3yV/qXySG1SqHFYIichAgiMKG0Rl+hGEFNf9Zq/b6WjS0rVH1wf2MmT1l5X
	 pMkmtH4oybQp1GsLFmhq0JKm2czkG81OaDjDtR9p6i8m4nCu+sxFL9qNUfsihuvlluoZ4
	 4mqvZQkudcr7iNvoc4etPe7Ki+5vIWnE7vDyF0k2g8frErSZJqTMkSLU9ouiOzdWCLbwk
	 5y0jx3Y5ps32SPzphtNc/ObgN+Prusi86JkpH6S3ioWrg/PbfeFzQ0rvjdV29Q31WEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793395669;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=svknQMt4zOnluj8TW5toKHcrzxHGfxqZuvYWb715f/0=;
	b=JnqFCryujohpKoOThOUk9pe/n27lAtSkFAAMIwSlIh8PFHl/ofb8rvDt8KK2kOpcczyq
	 ebMaBYmcQXzqxslLCk9fTDbwIcQvG9C+RAT5eKve5Is16dLD6yD+4SeCBjWk33keuLTLO
	 w625HE1m0iUOC9sWk6PlI3sbwTBAT3OT4ibyOJUASfkKGHbbJ8+3QXMyb9EFv17qDQRfy
	 1AWfhH7V016uNLTWupQWj2YHpnkVqcfnxkgL+v0BBQIe4M5kyKYM1jT/f9CBA+9Q1BH/n
	 sYa2B/qKuNvrohQ6uFKO6oMVzklR0RlpGjVzMpKDNX/ySxpJAAKxt7Dkes6JhoPbc7w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QtQ6RWQi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8BB3360A2607
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 21:27:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QtQ6RWQi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F0E21F0093A;
	Fri, 30 Oct 2026 21:27:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793395669;
	bh=svknQMt4zOnluj8TW5toKHcrzxHGfxqZuvYWb715f/0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QtQ6RWQiro29ILD00KtyvYyS41NJTUbHE9lD6wmGRsO4MfeolNM1J9U6LcRtvVmrg
	 4lDTiDeeupqk6A5V60L8GqELoHjm56nOB/y+R+U95uEX7VDS1/OleWXLSwdPh3lu7G
	 aERRoOV+/OnHR5wzJgKlJqJpO4Q9VCC0dL9BJDTtYHqSpgQ4JhvO9num17bV0C6fsK
	 gkleV4FNIn5Z9q8R24dXqmJJX0bi0qgN6C9YxxD/vlsIOHcbrKl/1fBwMWGDErdD2R
	 KzG8Gviu5LSmVBcRTSo1mg80EhDiQa/MgAjgqinEzJXfz3lXZe6Z2W9TwZhGYKcuZE
	 cnr6kMX7Dsb8A==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 30 Oct 2026 17:27:35 -0400
Subject: [PATCH v5 1/3] NFSD: Fix PUTFH wrongsec check when SAVEFH follows
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
Message-Id: <20261030-verofess-v5-1-242eea2991f3@kernel.org>
References: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
In-Reply-To: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3833; i=cel@kernel.org;
 h=from:subject:message-id; bh=WaOWnEn6YpiGr50v0gdh3r43pHXtMbJJFhl5Etp+Fq8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq5QvSAOJYSPu7A8NSPgrI0LvgN6zsTPH9kpGxt
 5tcnZSxIY2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauUL0gAKCRAzarMzb2Z/
 lxO5EACsh66a0mkxUV/ZHEhgVJMhxnXq608I+zhVtv6acwo2qt2Yxm4b1thdBsRkn4lokSmbnMl
 qOAbolSQcTqYdAU4DCpB/4pJQ3pDU4N7eA2IR9GkbsJys+MdZJ9YbusUDBcta5qHVTU6MQ8B1i+
 15cJDQe1fvwNctD2bT4iENrtQ7TbbUek980gPRo6tFrm/whjqZ8sfsor3uBTvG3q19P4dPgoyaT
 m/jx+XsD2XM5PyzSDGtNuo33VvACluCsAXjVs1MpXLF9CRP5AUVKxsYv5FY41n2uF5GcZbzMkfv
 n2njVG+AkwN1/iB8IQTDonJfjUZKC6/NQnsVPJb5561AvUPGrwnUSz++gZjvd3FZO/D2XlxiFQi
 9P7XC1afeGJ+S8FdTgk44I6K0txR+KjywZFlMgA4atihE45vvsqtEIcPaOh7GOJYL2JTsLVwp3Z
 2pUjiIj1V/AAIB7Cjj2ZhC8yAdl3dyZn+NISA4/O2yYl8Bx6tQA4Fyd/+2pXBYqEFfhQZwaGPGm
 Gmi6jBtI3oiYHjWDZnNdupdxa9Obh3HOYVAXnM96nwnYSl8cKJ86Aq4N1hofTc24/ZwHIYaWSLA
 ApgDip89lq+qWzaVU+m4oqZjJ2V7NQfh4PpqYh1d0Us+of0xEfnBQpoJU0UbU4IIsutlC/QPKmc
 JIXNxtmYHNhWnNg==
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
Link: https://patch.msgid.link/20261029063917.138184-1-coderzeng@gmail.com
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

