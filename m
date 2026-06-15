Received: from mail.synology.com (mail.synology.com [211.23.38.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA597223DFB
	for <linux-nfs@vger.kernel.org>; Mon, 15 Jun 2026 01:15:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=211.23.38.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781486133; cv=none; b=evWPGwfQrtFpIT/yJKmay6pTKjdxaz2mKUxnnvg8bP03S54lZ7Te7NJ2BVRk4AilbCGvxpkDE6/CpJT4v+x+PBB87JWX2gtiRgvPTnTqbhD7LSJppkjO522zRHGOmerP/oStejt5Q9Z2yy+Yhof9pOlyOopJ+EVgSuQ0XhnnMR4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781486133; c=relaxed/simple;
	bh=eT0ZBNc7WvsgxEQExt22iJrLxGEgNsmeLF3mlJuH/sA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=pR2NIKgemQY86mmLVPVYDsEYCsSXShI2+ZNkkaoh6msiBlP1jZxZXaNeB9euNdl3a0JvaQkUYUFcUr/zU4/3d+TV7goz/0dvUndWmkML7LTZJmiMKAPtFbD8sBEw7Q7WelI/MHgPbsQzkxJZF26ObSUHHMc4mO/1wYWFhuw074I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com; spf=pass smtp.mailfrom=synology.com; dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b=kniGLisq; arc=none smtp.client-ip=211.23.38.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=synology.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=synology.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=synology.com header.i=@synology.com header.b="kniGLisq"
From: robbieko <robbieko@synology.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=synology.com;
	s=123; t=1781486125;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=nHOSGYcWMJhfQyeuVFYvSaOPdFc9amNSPIsG3Tj1hiA=;
	b=kniGLisqaRtQ6+gpGzw34WVbVIr1qk//3DoyJaLWm04JGqwkiZCRd3nYvPekw53QBxUSUk
	U+vXFEq9HbdGJZA/OCYgUGXSSWvs2xi3hOchJl6Rry9yYKebNnEP/P+7el+iSpvBaOdZ5N
	8PKqY8ezNX8O9nomiO0qnjvLRSzXqVM=
To: linux-nfs@vger.kernel.org
Cc: Robbie Ko <robbieko@synology.com>
Subject: [PATCH v2 2/2] nfsd: use NSEC_PER_SEC in nfsd4_decode_nfstime4()
Date: Mon, 15 Jun 2026 09:14:37 +0800
Message-ID: <20260615011520.1477943-2-robbieko@synology.com>
In-Reply-To: <20260615011520.1477943-1-robbieko@synology.com>
References: <20260615011520.1477943-1-robbieko@synology.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Synology-Virus-Status: no
X-Synology-MCP-Status: no
X-Synology-Auth: pass
X-Synology-Spam-Status: score=0, required 6, WHITELIST_FROM_ADDRESS 0
X-Synology-Spam-Flag: no
Content-Type: text/plain

From: Robbie Ko <robbieko@synology.com>

nfsd4_decode_nfstime4() open-codes the nanoseconds upper bound as the
literal (u32)1000000000. Use the named constant NSEC_PER_SEC instead,
matching the out-of-range check added for the NFSv2/NFSv3 setattr path
and improving readability.

The original code cast the literal to u32 to force an unsigned
comparison, which matters on 32-bit where tv_nsec is a 32-bit signed
long: an out-of-range u32 wire nseconds (>= 0x80000000) assigned to it
becomes negative and a signed compare against NSEC_PER_SEC (a signed
long) would wrongly pass. Keep that protection by casting tv_nsec to
unsigned long, the same width as tv_nsec, matching timespec64_valid()
and the NFSv2/NFSv3 setattr check. No functional change.

Signed-off-by: Robbie Ko <robbieko@synology.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2a0946c630e1..db17bd3e45d6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -244,7 +244,7 @@ nfsd4_decode_nfstime4(struct nfsd4_compoundargs *argp, struct timespec64 *tv)
 		return nfserr_bad_xdr;
 	p = xdr_decode_hyper(p, &tv->tv_sec);
 	tv->tv_nsec = be32_to_cpup(p++);
-	if (tv->tv_nsec >= (u32)1000000000)
+	if ((unsigned long)tv->tv_nsec >= NSEC_PER_SEC)
 		return nfserr_inval;
 	return nfs_ok;
 }
-- 
2.43.0


Disclaimer: The contents of this e-mail message and any attachments are confidential and are intended solely for addressee. The information may also be legally privileged. This transmission is sent in trust, for the sole purpose of delivery to the intended recipient. If you have received this transmission in error, any use, reproduction or dissemination of this transmission is strictly prohibited. If you are not the intended recipient, please immediately notify the sender by reply e-mail or phone and delete this message and its attachments, if any.
