Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.72
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116219;
	b=pDKRGjt2e74m+U6KFJNl7uHW9CwD0rdwg8IgyWL1Zj3ijqdycH8VzdXgORb4GyGckLwT
	 NoF4FWQMjBVdyr7RfKIHXncEpV9bYSVnIFoAQoFm+TXFf1ib8whhDHn02lzz25T/IF7HD
	 h7SK3U/fyI+YHNxOnsLE1WlQqEB0dOEkyoSdI75czOYHLoUl7DiS9d+Pjj/As20SQg1M+
	 BeJOJmIlp5rErOkN1trnmuiBk1DeslC0WEme/+vLk2ZU6/AVdqTQ2k2PpYfgj3tGbcCY4
	 dDOmhXzCoB+AlzugWdKkoDqiFafDsAUpGBFxnof0rG21zvduGsXK//g7yGrM9IC/50Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116219;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=3ZHyNRe+Mfv05RQ57vLWJy+Mrx7YIm+0I1diPr9nzeo=;
	b=JBbSAAhaMZA52f5+va21RlmDOofjDludGYsP7/OwN0A3XUtZzotzHN+JnU9/IFGguHHj
	 qLH2jTLjZXmW2XDbaMSpW0ql+UEsUGzfQmBqaE4x3GxfTUuC881QGDC/7VgNO1bo9QhRr
	 da5mazzOSDqy4HyJsq6r8c4M9b5clxUVzwJQndyH0T8JN48GEw+ebrTCaRCNTt6j24HkK
	 4RpqSojy6+L7o5NaDkZOwyqbNcd2ot0gpJYrBirY5FB0Jej+R5+0qw1bgnLxJhD2iAbRa
	 Hh9ZO5io3aFgGhdk1ZiMiZaBfejVYxx+zIvURxiSH/ZsHlTln1hek9E9frcPciuKbIg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=a7br0hUZ;
	arc=none smtp.remote-ip=209.85.221.72
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAB97606A331
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AAB97606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=a7br0hUZ
Received: by mail-wr1-f72.google.com with SMTP id ffacd0b85a97d-48fcb657f32so18529f8f.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116217; x=1795721017; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=3ZHyNRe+Mfv05RQ57vLWJy+Mrx7YIm+0I1diPr9nzeo=;
        b=a7br0hUZZAAOec4xkxj+NBeC+qLB4ygwQ8BB3DZkJpYrPoHDi6AgStIKthczFbfCw1
         z+zGDlr07L4BvRPrnK7PcceXwemnCml4rRM8vbePnnTsSEzI7hmZw7qiKuRSYU5Y1DjZ
         1WxyqeAAqMzeNOHNbD05lL3COA3aEZyxsf4GTp0mAUrEqPReT7oH5VpuXyp7lxwGnD4O
         Ka9E5dA3kFZpbsqKtpW2sGbQBgYtfj0FqvjxSWQLUsDwGdYYZHb66q+uwYeGShpGF6ur
         EVlhjYHmjToJ+sRxvAV/C2vUtGLbbeNg7hyPOPw9JqOnPnaxsLi/ux4sw2wj7FghjLsC
         vMKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116217; x=1795721017;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=3ZHyNRe+Mfv05RQ57vLWJy+Mrx7YIm+0I1diPr9nzeo=;
        b=GkNVv623AzGLlB4S70njV5YChKMI5VfRsHApws5eScw8qAiSWMp1jucRwnw9kju1j3
         JllkGfs0BDHxJLH/9P/74lpxwb6VFIbvIf8SLLkfmHQHOtFkWwYf3FcRDUhCBwcVV+KD
         H1WysTasypjhI8mQeQAMLf/nhQfI26jqZKjlJgsbknb+O2oRq8Tx9p7sDEYjzHRB8gC4
         jqM9easEsT1+wI7URuUHnpS6AyIisnr91JGOtcptGYNJVtnqZUhu7685Y/ZKFan81plV
         RUwsFDXco+tjP4DrnFh1NDAEQ52d0i0n+jkNvaQrjKpoyIvgByS11TNEG6BatcDOntD3
         Bo/A==
X-Forwarded-Encrypted: i=1; AL+hErEICH9wgvFauxgULf+HZ5R+WautFCL6ebtEz5HwofYqZ3I+ReZjH+0vWYReIi6xkV2/1CYJEH1JewE=@vger.kernel.org
X-Gm-Message-State: APuU4Z9knA6bw7akEX6RU1HDcJhrCGoq61hZzt30VcA5D2f2455YpCkb
	+WEBqRPNz3rFGzNxFGUvV8U1f0kt3lFrc/5iA6Lbs0Sr26v5CqbUp/QV4n3S9H+RXOSeqIjU6Q=
	=
X-Received: from wrqd17.prod.google.com ([2002:adf:f851:0:b0:4a5:c04a:462])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6000:2385:b0:497:9e2a:b1e
 with SMTP id ffacd0b85a97d-4abb36787a4mr823728f8f.9.1795116217025; Thu, 19
 Nov 2026 11:23:37 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:36 +0100
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
Message-ID: <20261119192336.2697518-1-dmnk@google.com>
Subject: [PATCH] nfsd: only set NFSD_MAY_BYPASS_GSS for RPC_AUTH_UNIX in nlm_fopen()
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com, 
	Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

As documented in nlm_fopen(), NFSD_MAY_BYPASS_GSS is intended to let NLM
clients using AUTH_SYS (RPC_AUTH_UNIX) lock files on Kerberos NFS
exports, whereas NLM clients using AUTH_NULL (RPC_AUTH_NULL) are only
meant to bypass authentication when NFSEXP_NOAUTHNLM (no_auth_nlm) is
enabled via NFSD_MAY_NLM.

However, nlm_fopen() has historically passed NFSD_MAY_BYPASS_GSS
unconditionally, and check_security_flavor() accepts both RPC_AUTH_UNIX
and RPC_AUTH_NULL whenever may_bypass_gss is true on an export with a
pseudoflavor >= RPC_AUTH_DES. Since commit bb4f07f2409c ("nfsd: Fix
NFSD_MAY_BYPASS_GSS and NFSD_MAY_BYPASS_GSS_ON_ROOT") restricted
may_bypass_gss to exports with pseudoflavor >= RPC_AUTH_DES, default
auth_nlm rejects RPC_AUTH_NULL NLM requests on sec=sys exports with
nfserr_wrongsec while still accepting RPC_AUTH_NULL NLM requests on
sec=krb5* exports even when no_auth_nlm is not set.

Only set NFSD_MAY_BYPASS_GSS in nlm_fopen() when rq_cred.cr_flavor is
RPC_AUTH_UNIX so auth_nlm and no_auth_nlm behave consistently across
sec=sys and GSS exports, requiring no_auth_nlm or an explicit sec=none
export flavor for RPC_AUTH_NULL NLM requests.

This issue was discovered by an AI-assisted code review tool (ARTIST),
validated in QEMU against an unmodified v7.4-rc3 kernel without kernel
modifications or error injection, build-tested with KCFLAGS=-Werror, and
checked with checkpatch.pl --strict.

Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/nfsd/lockd.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index f24e45d..2683939 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -41,8 +41,8 @@ static int nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f,
 	fh.fh_export = NULL;
 
 	/*
-	 * Allow BYPASS_GSS as some client implementations use AUTH_SYS
-	 * for NLM even when GSS is used for NFS.
+	 * Allow BYPASS_GSS for AUTH_SYS as some client implementations use
+	 * AUTH_SYS for NLM even when GSS is used for NFS.
 	 * Allow OWNER_OVERRIDE as permission might have been changed
 	 * after the file was opened.
 	 * Pass MAY_NLM so that authentication can be completely bypassed
@@ -50,7 +50,9 @@ static int nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f,
 	 * for NLM requests.
 	 */
 	access = (flags == O_WRONLY) ? NFSD_MAY_WRITE : NFSD_MAY_READ;
-	access |= NFSD_MAY_NLM | NFSD_MAY_OWNER_OVERRIDE | NFSD_MAY_BYPASS_GSS;
+	access |= NFSD_MAY_NLM | NFSD_MAY_OWNER_OVERRIDE;
+	if (rqstp->rq_cred.cr_flavor == RPC_AUTH_UNIX)
+		access |= NFSD_MAY_BYPASS_GSS;
 	nfserr = nfsd_open(rqstp, &fh, S_IFREG, access, filp);
 	fh_put(&fh);
 
-- 
2.56.1.750.gf70dc682cf-goog
