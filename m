Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793669574;
	b=dVsxOCZIL+Lh5kqXF2bOA0vz0vgIO4gInbss4UHQKNZWJ1hFp7Qw6rEdhkv8F304y1K4
	 tUcHVk/FQ0mT8DJ8XnAtlVewZcEteuAiuSmrGWPrnQkHrzThhDkyqG4t654VorxLREEO2
	 J9PRHtvZE695Ql+pT+yLAm5SMhGDwGYaZKkwuJ8qjC5OOcD818wq3+zuKgKW+b7jt+dZU
	 lJcyqHgukfwEw93SiJGvx/S1M8FI6AOqaORVhgSueozxU60omDSnhxrA/0dw8CJfEjZAe
	 /WKuQXrjx6Mvs7EPKHemaDcL/Ftm/hCqjFa4G1rj8h1etxbrL9COuO6PUQeT1c3gehQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793669574;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=IUtH35o1Q8JE8gPr9CnFG1zcjF8Zy7tULSXewUiocZg=;
	b=yoBuVxLz36CCHXEiST71Xa6gtTJJcq1w49wnYvAcCqSkz/AYBl5C5DSpRHtlO2hK/zjS
	 nmmm2WGzhlBqI7bzl+TBVNIuxINXAaFFwOWlvwDqDePNrkx/3A0poOT8rZiP0H6Brh/tH
	 tUSfWSjDR8iVbbsXBY49XCsYlkwyWks0wnCffltP0ywnO3ZOkCkgmmd0cb2a6tODKhK4O
	 XvdeF2aWw7792pdN2L6ZlW7IS3+t/5FxuV47WymDpbVAr9g7Y1NAEm4xws3svc+Vpf44+
	 F8zv48izA1/4jH8+tSPfu6D+7nBOUpq3bNbVPGZxIZZwfNbsHDE4XAXD8B4wkxtc57w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="RCHAYUt/";
	arc=none smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39450606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 01:32:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 39450606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=RCHAYUt/
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b1ec41d8e9so3925516a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 17:32:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793669572; x=1794274372; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IUtH35o1Q8JE8gPr9CnFG1zcjF8Zy7tULSXewUiocZg=;
        b=RCHAYUt/r/cniqCpTPdj0I1NQyRLE5YpFReUMFM0FiPVRhAi9CO1eqnaqbgt6PheW0
         rstlPpCPUbg0qYrZ4YfI2pPWDb3NtDUe0+4Y/lA1eMkTNbFZX9TOpxsWoxSfX58mE4Mj
         Bs/6fYUBINM6MLDw9sLjHKhHwd6vP5IrKOc3pcqqcrErgtAjPn593+VUAu+FSvB9cS/K
         haPuU439JRSLH+fvXYV1Hsnr9N7iQ3NYFrk5GJNcMHi7uhfRqQroz0Ii/UOF+snQtQR7
         +xp6UibpNVpk89qgXy4ysm2AARSkMSCaawoYD4jmYSgB/AFLOZ/GjUdnCeHuBXQiA/7g
         K1yg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793669572; x=1794274372;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IUtH35o1Q8JE8gPr9CnFG1zcjF8Zy7tULSXewUiocZg=;
        b=JDv/02aPWOvX4tmC9svM9nS5/n+grbAnuoR8rC/3Uz3OTxyCDDoIpC5g4kbmCHq3O/
         a6fC14HEudORrOKK8qyZpEhdHNvmK1o54y+x7AdfrSyiT4ivk6Ty1VSIWtIWy0Bk0Nmz
         V3Q3l56mzIQgSRC5RviYwNdtDA1VtDMf+NWUQLnUzgZDujc4koi0VW4SSRM9cp+3fOxR
         YJPmvzJnMdM6bwBA5ggqFWUgtmiyBW+Me04plcdecDonUMUuIflenOsQ3Ecr5GzGT6VU
         2wnRXYwTMZU/OLwYErU8LT5enFV69qPAqZeuJEQvBZX7VgAI1CJ4Zh6mZspw4hNl/oJv
         2LxQ==
X-Gm-Message-State: APuU4Z9pAzrBK4Q84IB3iCQ/m0gRwIzyPUexgwEcogojea3ZOdcHGSl9
	K+P0cHRo+dzPHurPJQBcV7x31X39JGwL11V3obrfO6vtwzBsjOGUCJCKilrQk4rkj+4=
X-Gm-Gg: AYBFou1NjfSRo/0Aq5KvCbmG65OXiYDCDlyYx/SjlRmgLm70RlGPcceIHISWLUk/P6S
	0HbwKl6fic01ETpCxmEYy7xnIhcTzWftmdPXoq/TUlt/zQHsd+QgbrqQgKtRkIyiPqJPqTnu3ec
	FRF1BbAjrAbwephyAE81gLtZyVs3GHUJW80gdN+HkfyG0bJszRlGeS9BcQ6hqHY+sGg6uUbxj67
	vbdzbWd/ZCslunnq+OM5QB4IU8MNXYRPBmKIJT6P3IANKdZ5+q7RtzQrnEF9a4kd0SSEs+KYbHz
	nK1VOFRqdiDMvsdSe/l3gUJ/TWq0+59QZdqN8HddFPPFcjhZIb36stBJOB+HuxWsdtL3AjNOsZ2
	lRV7/YrEettJDX6mRTlQTdwBwdQCv3GaUgBHf8Ga9m78IpeO2+tXAWyp9m16rf/CgPxgVBIuA6B
	IGYbmOHsVtK1a/isF7uRe638VuVYqwFSljA1dEb6m8cWo4ewovPEzbwOsQ7O6VSqSIru5F4mLZ7
	N+JMq+603MpOjHmIbBwr/sKwGyJc+mttHPYczVEdgJcI7ZO/9C90d442+hSVi8ZjIDPTwJD96AP
	4SDO0ckLH96YjeVlrzWeV1F3bVABlAf015u3ltiCfJ5iZG0Ex/cdQIXuNAoin+59ak93Sw4G
X-Received: by 2002:a05:6402:a4ec:b0:6af:a64f:bd44 with SMTP id 4fb4d7f45d1cf-6b4d62c35c8mr5984059a12.45.1793669572524;
        Mon, 02 Nov 2026 17:32:52 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b4ec91e2f2sm3776583a12.0.2026.11.02.17.32.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 17:32:52 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org
Subject: [PATCH 2/3] NFSD: Apply the entered export's credentials after LOOKUP and RESTOREFH
Date: Tue,  3 Nov 2026 09:32:36 +0800
Message-ID: <20261103013237.1174538-3-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261103013237.1174538-1-coderzeng@gmail.com>
References: <20261103013237.1174538-1-coderzeng@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

LOOKUP verifies its parent filehandle before selecting a child export.
After the crossing, the task can still use credentials mapped by the
parent export. RESTOREFH likewise restores a saved filehandle without
restoring its export's credentials. The requester must already hold an
OPEN stateid for the file: with a cached stateid, READ can retain root
access after the export enables root_squash, or fail even though
all_squash would allow access through its anonymous UID or GID.

Verify the composed filehandle when LOOKUP selects another export.
After RESTOREFH, install the saved export's credentials and propagate
an error from nfsd_setuser(). Keep the existing deferred flavor
decision for RESTOREFH.

The credential mismatch is old; it dates back at least to Linux
2.6.12. Maintained LTS branches with these filehandle paths also need
the correction.

Signed-off-by: VeroFess <coderzeng@gmail.com>
---
On nfsd-testing with all three fixes, crossed and restored READ used the
child export's root_squash or all_squash mapping, including anonymous
UID 2000 and GID 2001. In a separate fault-injection build of the same
NFSD code, RESTOREFH returned NFS4ERR_DELAY before GETATTR. This patch
also built alone with W=1.

 fs/nfsd/nfs4proc.c | 4 +++-
 fs/nfsd/vfs.c      | 5 +++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 43c2aa9..218cedb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -49,6 +49,7 @@
 #include "xdr4.h"
 #include "nfs4ctl.h"
 #include "vfs.h"
+#include "auth.h"
 #include "current_stateid.h"
 #include "netns.h"
 #include "acl.h"
@@ -859,7 +860,8 @@ nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid_t));
 		SET_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG);
 	}
-	return nfs_ok;
+	return nfserrno(nfsd_setuser(&rqstp->rq_cred,
+					cstate->current_fh.fh_export));
 }
 
 static __be32
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2775911..0547029 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -351,6 +351,7 @@ __nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 {
 	struct svc_export	*exp;
 	struct dentry		*dentry;
+	bool crossed;
 	__be32 err;
 
 	err = fh_verify(rqstp, fhp, S_IFDIR, access);
@@ -363,9 +364,13 @@ __nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
 	 */
+	crossed = exp != fhp->fh_export;
 	err = fh_compose(resfh, exp, dentry, fhp);
 	if (!err && d_really_is_negative(dentry))
 		err = nfserr_noent;
+	if (!err && crossed)
+		err = fh_verify(rqstp, resfh, 0,
+				access & NFSD_MAY_BYPASS_FLAVOR);
 
 	dput(dentry);
 	exp_put(exp);
-- 
2.43.0

