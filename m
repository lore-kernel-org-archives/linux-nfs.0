Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4ABAD4A2627
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:20:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294002; cv=none; b=DzOs5VDluPKTEfdoEUX27xbnksNRqpcQX/j8UtxrQUKeUKyC/69NBvU81sesTtVOwcRBXw1leozmzLQXhklaueGc5UYp+7kcQ+i4owaP7iZIapGW8qKik58M5pV1zzB4h3evIp4Ic+HorEfv2T8WLQNrjf2xjOwwiVFq2f5xSOQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294002; c=relaxed/simple;
	bh=JwNIkG3ZBXD+AzbpTJ7LTqc6uS/Lf0D6mI4JcTE9p9o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pr8cI3QNsqKqo4MQeAhdSlZz6/pk8wNV6ywpss9P6wBmphPd59fwzj2+1tEgJdEsc77NuHjIodncnWuUUy3Y5OnE1uA9S3fiRAVktVFkZ1NwFMHJtNgeRrMmes/VeBJ4SX+/FC83MFitPOf0o8HliwDWnid5D+/yr6CKfaQXI+g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TGaQJbTW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TGaQJbTW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 698401F000E9;
	Tue,  1 Sep 2026 20:20:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788294001;
	bh=BPPQeO90hOy+aB5YEgMXndU1UOIVREPLenZhAfgb9Es=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TGaQJbTWXDTYYfY+C4KC6y+xSTy87kRRvXH8bJmoYXRzZVB60kyTuc9mVUeT4gD3N
	 EkYmPwYd7T23vJIP5jp3tES63KJDJx6Ty2ma108IHWnpgXvpN9R+Ze3VgLiypl44w9
	 pZO747mH26qmjnlxbZvvUcO5v7E6HX94JyY8Dm+vd7pxEM1Ie6Lc/1iQhrLCuu3WSQ
	 XI0ACil25kcf/yiNb42/Kwe+HNEmgMxwY7LALR9bU+i9uVBwoFf8Yovu0hVbNSZuSN
	 oHb6IFAZzni8GeEguTK3+zBhlYdwzwOKnD+QhnAiBmQ2d8O+2zfq0yovFcmmquzYIy
	 DCK2Eb84+FmMg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:44 -0400
Subject: [PATCH v2 4/8] NFSD: Reject an oversized principal hash from
 nfsdcld
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-4-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1567; i=cel@kernel.org;
 h=from:subject:message-id; bh=JwNIkG3ZBXD+AzbpTJ7LTqc6uS/Lf0D6mI4JcTE9p9o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNrYVKTC/Pk0SGpwIrNcygUTJNpOv2ltBe2g
 RcuEyrB8J2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 l0cmD/9PRrT7avVsvkBDw+p+w4odkXeFyVvOO48ksZ2/NdWqfG8lhjWLWUyqKyMX9dGMPt3Qh+8
 tNHMxFHs7Z7KOjdK0GmIzVqsxzgsOZNZDwWgqlUuvyToTIJF7JYp3qetMEKTaIIp1lIv4qZUrad
 MLwBcMeWhvExpqBwf/MuuYlGVO/Nl4egcQ4Sko+vSaDP1LThqSn8TgblcQNz6vp0UXFVUMwB8Y2
 2q3lwGTfjorFX0Ae5m0tpzByUQgrkeYK5zJ/mF2BSUiTxnH8J/dJwazKp4adfqJSCiKhxDZPbNU
 A+kGA04ZlI/JUsv4uQfhmpEmvKXI2J/dpJza4JO7odGuHHRnpsMeCgm+64z5+tP8Di7PuIvF59G
 iEe7IxAekiaYGDX40+jPeD7M0M2x+F1qTJRrfdI+qcoM/Q1YGZERC3VMYe/vZcBTpGZvyQqKqGO
 zeejtmKyza+eni9kKDbZQrc8OxjJzMUDLr3TquSNGrDkuzkFWWcyTUUQIhobiMKx/C+NC7yQOGn
 Ag7epjuuHmtMVWF/u3WoLiP1aECH2ldpFpWPpyQ1N/F3m9BGOb5526Ke6QQ1D0FN8Jv5xb6PlSn
 3Wn3ERQD9q4x369ZtirqjS8SkwqwVQ3j747vOv/6PMUkehJG01AV/PDG2zlj7s7wrIuoIvfr8zm
 jcB2HIdqP+NfcOw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

__cld_pipe_inprogress_downcall() takes the principal hash length
from the daemon's GraceStart downcall without checking it against
the cc_princhash payload it describes, which holds at most
SHA256_DIGEST_SIZE bytes. The length is stored verbatim in the
reclaim record, and nfsd4_cld_check_v2() later hands it to memcmp()
against a digest array of SHA256_DIGEST_SIZE bytes on the stack. A
length up to U8_MAX reads past the end of that array, and the stray
bytes can only make the comparison fail, denying the client its
reclaim. The pipe is mode 0600 in rpc_pipefs, so the trigger is a
broken or hostile nfsdcld rather than an unprivileged task.

Reject a length larger than the wire field, as the existing check
on the client name length does.

Fixes: 6ee95d1c8991 ("nfsd: add support for upcall version 2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 999694db9981..8af935ed0c4e 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -730,6 +730,11 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 			name.len = namelen;
 			if (get_user(princhashlen, &ci->cc_princhash.cp_len))
 				return -EFAULT;
+			if (princhashlen > SHA256_DIGEST_SIZE) {
+				dprintk("%s: invalid princhashlen (%u)",
+					__func__, princhashlen);
+				return -EINVAL;
+			}
 			if (princhashlen > 0) {
 				princhashcopy = memdup_user(
 					&ci->cc_princhash.cp_data,

-- 
2.54.0

