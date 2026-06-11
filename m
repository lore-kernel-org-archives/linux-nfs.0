Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 574C04C957F;
	Thu, 11 Jun 2026 17:50:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781200261; cv=none; b=orPaTLAcQZgvpd4LhbOi0hlDb0sUSbcDgKaOtGwXw4vLLDox2v5X5PwFd5/eM2vudmVYS4xw47UzEMHhibQo0cWJACAzOkhmCS94kz/gKN+4kViMGP8W0ylAxI6cmUBBzQRW45Mxv0q5ebe9u9mG0ThAUVbYJJy8rk1MPs6+FP0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781200261; c=relaxed/simple;
	bh=SeZUHcpxYlvG88yAy9B42bUe1TCQHy1VujzGUXl1RxQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GyhGO0cpxcbEa1PJ095YBlfwjR7lS2zofX98CVvg7QqO9vav+gP4Kp8WaIsWkW3BEQF6LR43w0OI3Skf2mmCU92eT+pD8K9K6GYt2QNJfWV6JLpYs9UfVcpx3NxAtjNtDD8t3X7l3pZH2IzOihBwtFb+SNO8DSFyUR2UgZDF/uk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mP/C6hjg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mP/C6hjg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1EF951F0089A;
	Thu, 11 Jun 2026 17:50:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781200256;
	bh=dmd0f6pbCz4d5WUptOFm0ECwKoGxHEd52JM8lI1jNZ8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mP/C6hjgRsLe/7m4DiopSQa/UmIq+nSvRbwcLAdCwsr1ruOw7Eo7Rfpg/6YWwc2DY
	 qBsjF/vX6YsfSbK3HvyPiJ5lyQOYXgYvYUNV0lZpPn2e/t24kbmyZYA9ajLlnerGVx
	 sGGG1YYGKkxsXl3Hpi7mp55FoHDnoFfFYtIanOVYL16pMAGeF2mRSykI02RbSn2E1f
	 s2+119KeywAnGRNtfcxAZb7mTFV3KKFedpAGLgNRkyGWOi0iLIMzLTkCVZ5AajoA3f
	 XndOavrb1YAa+Zjz+A8dIs5T7y/CR3N2eQbd1laSioqkc6bIARYfL87eKSwPyNvbqh
	 70EGo/KTvBhTA==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 13:50:19 -0400
Subject: [PATCH v6 13/20] nfsd: allow nfsd4_encode_fattr4_change() to work
 with no export
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-dir-deleg-v6-13-4c45080e5f3f@kernel.org>
References: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
In-Reply-To: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=846; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=SeZUHcpxYlvG88yAy9B42bUe1TCQHy1VujzGUXl1RxQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKvViloBuCoWXKJAgwh5cjzQvC5hw5bEcN9rRM
 CEJat0HYS+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCair1YgAKCRAADmhBGVaC
 FcdrEACDmx4r+qzIF8nMXEnogkt5PnwCsrUgUash/2mQZ2LFdoECpmj3B4iNC68R8L+nn5bLzCS
 Rax9muOfzwTWNx8J7OGz4jlUbI3gZDwdhCYqMFLGINmW4m2mnmeFtQNV5J4POK0XqiHzqKpTHFy
 n3ApKUNgZ9H2B6vsrLy11lsHvs/SrJqtpp2AcWlXwIVuYY7RYz8201Q9ZFBLd/+cRxXOH2LeZ00
 CkHhf+YY9v2KeVHc9nGX+sCaWOCKIXj8azHqacnIs34+NC1Vf8XuQspi8TE8vntR4vCRHZXfHUI
 0sLZ7CGTAr29FIR4ha/Q3kz8v8SrGPxJHppDeVauInwKEpVDXJK44OdDa6cVbJ0T5ZBXH807VAU
 EH77GFU4h33fXfwyHpAariUxefYFndfqQTNsNgWGxxLYzdYZpGiUMHkbClyzXd9A8b1wAoOk2+L
 uvGggdRaF9MwdjRa+NypmNU1eajvEeEKGTerkxuyFDNwjFPXVNSpjNYh3O5lRkeBfIZ6lg6lRPv
 E2rt2lWRTmBPA7NvU4fbhBNz9MZUBCKc9418G/uBG+1zgmpcWvbtDguwRNo8YL5cJVBReIReYYA
 pkUufxkhjSv/GLlmDt6yBv2Ywby3xlaT/Z7zxF7Zm+TWl98GKfP+SRfvKyGQip5fVO+bXGQcSp9
 YwH4bCTdfe1/gng==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

In the context of a CB_NOTIFY callback, we may not have easy access to
a svc_export. nfsd will not currently grant a delegation on a the V4 root
however, so this should be safe.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7d162e5fb6ec..18adab1d7ca2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3273,7 +3273,7 @@ static __be32 nfsd4_encode_fattr4_change(struct xdr_stream *xdr,
 {
 	const struct svc_export *exp = args->exp;
 
-	if (unlikely(exp->ex_flags & NFSEXP_V4ROOT)) {
+	if (exp && unlikely(exp->ex_flags & NFSEXP_V4ROOT)) {
 		u32 flush_time = convert_to_wallclock(exp->cd->flush_time);
 
 		if (xdr_stream_encode_u32(xdr, flush_time) != XDR_UNIT)

-- 
2.54.0

