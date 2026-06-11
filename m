Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C68A63955FE;
	Thu, 11 Jun 2026 20:01:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208078; cv=none; b=cN+7FaWqt50D8l8J/r8tZ9HEVJ3J8KiOffeTtj7LrRUSB9WRYjnGydeUfwo2p8lrLBp7TpJD9SuY5zeKBeSy/Jsfd2dHkZkxw3ZwqQ4R7O+u0rPmjg8RbdFozi/KH534S2CjPVno5fFd1SwmhL/85QvN23tSFyoU2OPFruik94s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208078; c=relaxed/simple;
	bh=hRhpof256WQKvwovAWbRm1MWiOD2BnEzRGWngsNI+JE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=T7qoXQ6IAtL2Ke0Z9vbwqwUxLqmmr21qZzemRz3wtYJZyqtcJvleQr4XwCl3oOoWBSpLWsbloscuHYnZ1jSwJgcB5v+vImbsfdJZ+QOv5zRGhkyp9ul8tLPbFcMpb9fQb+YEJd5qR03UlPCMUHZTj/PiilDy8VUVdGbf2Gk4czI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZO1bkvSj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZO1bkvSj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9ABB1F00A3A;
	Thu, 11 Jun 2026 20:01:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208077;
	bh=/VBdGVg26zQKWyJI8yfnf2xCXui05mQvSa45bIwcNzA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZO1bkvSjqlkbx2k2hOFjcMX8mlrQmO2ZXn0vvGvHuONuQsFVHEDFpEzeqXl8pGetC
	 yEqxk1buHa2JyzwXFFcpsxzHoihoH/X2mgLDPajawsSxsTxKYLln/bSDQ4+NHkJCif
	 XnmxUcsaAn4In9AFo6dLJ9m51I1OnoEpQFKiDzwkbU8oUV1DrMQu10QtyPw4NDIyY8
	 RkFwE1mannUOfYVhXVepYidkIQc84Ys/h2Cj2wsZi/3pM6fzvsdkDk+gqV+BfRzByZ
	 CGvcmVWbPvCwlDmW9Dr8YmjKCv9+6rwX69EaDHWcwsHsQa7AFAxeyefHyq3zGD/3JM
	 sAVZF9XYKuAtw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:00:54 -0400
Subject: [PATCH v2 11/21] nfsd: add fh_want_write() for early-verified
 SETATTR in nfsd_proc_setattr()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-nfsd-testing-v2-11-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1192; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hRhpof256WQKvwovAWbRm1MWiOD2BnEzRGWngsNI+JE=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxP/gLGaU2IFHxNwBbFEr3U0T3lIyZkYEDGAZ
 e3v3CKxJB2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisT/wAKCRAADmhBGVaC
 FY05D/40yrk222sfmHE2k8hMfx24c6ZGR5VeGAbXiFDXyLbqjtemUTqH5ssvEZxa56mIQswj5gr
 3t6tDImwm2rHlqMQxyy9enNHfI9OWsNEGi4ID/WLt0KDsyGQqWy6My36wZSPK7afJhyJV9ckP5B
 2yWFdiepNrAZ/Rxa51za5jMzYMxbFpxRGpcFb+L9CGfUb0Ov06Oxl5YHIt/3y2N//ohD76HS2G8
 tuon71so/ZdNAhWWhr/3/RNFTIdTUP8PQdeQWE+BMRTDdUm+FpyaCw4OSFU+W29xeShV4WyTf6K
 UEsKta0/9cMjIk2FcG6ELECyGkL7U/OQq3hwyKBMNIknlVlm02uPQLuxTRRQcjujU7KtrPR/IXb
 K7Nsklsn5V4+F+c+ptSk2kt8T3U3cv29Y8oEvaYF5+E6cxjeoqh8dpBrvabgHQXgBOksjMaN2Ob
 tSyEoQr113hvTbZRUU103z/76Xueeyo772zgREZj7TP71VWDleYXRxb1DMb8kB8HDJKYl/0MTK0
 T/BQ5DBGG8HWaQYMY7ld38UchBxzwz1tSYxgoMmnlLz3zjZIY3B0fIbCrxpcTqKB9b5W2YJyoWM
 xz5Y/JUst9Gzz2+MDhVWWw+vjFtN4jGa1dDIvue+04LF/K0b/JIBB8qYZcimc9AbICBJM/Yhl3y
 6Mit0sh2N0XHRlw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The BOTH_TIME_SET branch calls fh_verify() early so setattr_prepare()
can inspect the dentry. This causes nfsd_setattr() to skip
fh_want_write(), so notify_change() runs without a mount write
reference.

Add the missing fh_want_write() call after the early fh_verify().

Fixes: cc265089ce1b ("nfsd: Disable NFSv2 timestamp workaround for NFSv3+")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsproc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 8873033d1e82..a73d5c259cd9 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -82,6 +82,7 @@ nfsd_proc_setattr(struct svc_rqst *rqstp)
 		.na_iattr	= iap,
 	};
 	struct svc_fh *fhp;
+	int hosterr;
 
 	dprintk("nfsd: SETATTR  %s, valid=%x, size=%ld\n",
 		SVCFH_fmt(&argp->fh),
@@ -117,6 +118,12 @@ nfsd_proc_setattr(struct svc_rqst *rqstp)
 		if (resp->status != nfs_ok)
 			goto out;
 
+		hosterr = fh_want_write(fhp);
+		if (hosterr) {
+			resp->status = nfserrno(hosterr);
+			goto out;
+		}
+
 		if (delta < 0)
 			delta = -delta;
 		if (delta < MAX_TOUCH_TIME_ERROR &&

-- 
2.54.0

