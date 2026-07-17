Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E50BA2931E8
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:34:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262849; cv=none; b=PXrq7lUnBC0rMqvnbRuGSzvhzfwD21imn30Hvv56qXuvSgeI1JJewksUNqixsMvmtFc0XQ+fZmfbDcb390GODV2ikdfP+l9oVq7hwe9d2d7JoRckbIWUH0GuHI2rOJmjskikSIbFquyUx7UyKhcsZxK8E7wOCJTjn2DWp04DEoY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262849; c=relaxed/simple;
	bh=gqrZ8LHDxURxP48rA3fDkIBw+PTin5ruHiHeSyhC09k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eQlbw7kanNfW1Dyg6Mpotm3NEoYnHMXBzMnHdFcPTN2bc3SnN11pPgg6ZfV0Ytw0i2Hm3Rp6wiIdBXdB1JGwjWl2ZoGJCmg35SeSB3dcwbZZu+kWA6yuhfdIudhPdjRnDrCUdefnhjUhmo5sUHA8OS4dNaNrf4bKosCxxJrW87w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=c7sD2ZQl; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SMC1qaGN; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="c7sD2ZQl";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SMC1qaGN"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 27B247A0078;
	Fri, 17 Jul 2026 00:34:03 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Fri, 17 Jul 2026 00:34:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262843;
	 x=1784349243; bh=HU5dDUtUDeyTWTZ94RVGXfZxZ7QLL/6X7fkig8cHrmU=; b=
	c7sD2ZQlhUYaj5JEf5/SAdgc83espqFOECW6MO/E61LJhGpJdmBrCePEioEhvuJs
	AAwOGHt49Mv3Hw59DorttOB9aDBvYrfw56py3+GSWw71IGlaatYqw38gAQloA167
	deuR+i1j00g0KGzxSdrWS/fuPPM+UsEWU5ZVxGD5/8KJ+ydxyxKgzq2lcq5zdVdo
	qALWIGwoSPXfyFLYFn14tZDUuHBXrAFkpCpZMs818r7/sBQZjTyNpVci7u1UmMCl
	uH1J2r9+WJj+jLkE7SPQTWfPZSY20lHj9g3j19JGbijoA2yPrZAl9tjLTNIgyQ6r
	rbSHKRY/8K/83Ntkf076RQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262843; x=1784349243; bh=H
	U5dDUtUDeyTWTZ94RVGXfZxZ7QLL/6X7fkig8cHrmU=; b=SMC1qaGNxyyAdTAY3
	taCgJNtRWfyVE+7ThTFIwMX5RmnEqRxlZ+vgwfSbPl2XnA4FA+HmnOa1GdrD9s9c
	v+U2wdyCATdbL3ZQQw1T6F5rdAoccB4WXOlKGlEenNIX65DKYjDnX2VaqBYkeBAg
	ljxmCIiVNxEGx00cGloIiD8QgKMz7rHGTZYHadDrv18mHPKHGT77QVR20rDs7smX
	robuHwQuEpXdUKVek9SwbZFbR7AV3BRXUbV7Pq8cHyidWiZoqo9mxaAk9nXCYyvc
	OXKZ1VFyAaoNBPMKxYG27vyz8vpClR5ptq9tTaWkMy1+rwawtbpuoZg8be2egRfZ
	xw/FQ==
X-ME-Sender: <xms:urBZauG6vdGqQns9jhN9WHd3x8j0tGPXgxc5Uo6Sm9xo5aQ7vylqRw>
    <xme:urBZajD5iyBFjsEOPqHzPvSgZ-S4SBOmLt443x5E__6sluyGLY1wBlApHxWhqo4Va
    o8qXd1KnDydQ_18gcB6tMb_8nxabmmJm1pLslMmRyysVSS0>
X-ME-Received: <xmr:urBZah-UfT6yvJIVyMTS6_zPBHeIurPWRxk6L_N8C79MgwlxG5BdlJtZEAeROGJ9nky-umGyCbg-23FNYk1pETpWKDXd1ok>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzyTI
    NYs1s+ybuxBE165L30S4dNium2JC1FUGgP039hQ1A3aVAJ0MJOtrcfEq3AeVbFdetC6W8/
    xxaYJv0kkknFjllJoiTPTOt9JSApWbKPF3L4/gLkkanlBgNo23a/K91mJyefieMreXk7dY
    QKuliwZEu17qq7eGmvqjZhL7Zr32obztv5oyHBNGghUISfELv3R/1V6B4DDyi1IJusyvxF
    6sRr0SHJqB4KM2iZB4dVR5KSHnrz5oIvmTuSU/uy5uZoU3EzVtUVnZtrQ9ffyYtZH66OqK
    NQRINiI+atchcMSTnALBhWAqgUAPHd96BPE3HRUM4G2XgSpY1VD5GnEL1KRw
X-ME-Proxy: <xmx:urBZavBaDcFSQ29uE251ar-0RRtkMiDDbasCuaj4TwRqtus5g0sgvg>
    <xmx:urBZamQnGY6rxbK_DareXn3WTgtmP1Ov6sCS0JcbHILaNCvv_x29QQ>
    <xmx:urBZamu8ebEYsEjR0_p-XUa14jCTPR9HhECwmbme8lEM_FExwUBiuQ>
    <xmx:urBZai3SyXoL3H5vTwckEeczI_lNUXv1dOVYkcZgCG8ncce_rJY0cg>
    <xmx:urBZajmPBhhVmTcuZ21wKcqlumvSx2IsNaEq3kJ4_ZveGtSv5cUIMIm_>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:34:00 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 15/18] nfsd: reduce want-write range in nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:13 +1000
Message-ID: <20260717043242.1865905-16-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfsd4_create_file() needs write access to the mount for two purposes:

1/ to create/open the file.
2/ to set attributes on the newly created (or pre-existing) file.

Currently this is all handled by holding the write access across the
open and the setattr.  A subsequent patch will necessarily change how
write access is gained for the open.  So we reduce the range for the
first want_write, and add another one to cover setattr.  If we failed to
get write access, it is only fatal if there were attrs to set.

We call nfsd_create_setattr() if at all possible, even when no attrs, as
it also calls commit_metadata and we need to be certain that the file
creation has been synced.  If the mount became read-only since the
creation happened, we can safely assume that the sync happened as part
of that.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7a67e1385b76..ec925f60b2ae 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -342,6 +342,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
 	if (IS_ERR(child)) {
 		status = nfserrno(PTR_ERR(child));
+		if (!want_write_err)
+			fh_drop_write(fhp);
 		goto out;
 	}
 	path.dentry = child;
@@ -376,6 +378,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		}
 	}
 	end_creating(child);
+	if (!want_write_err)
+		fh_drop_write(fhp);
 	if (status != nfs_ok)
 		goto out;
 
@@ -419,7 +423,16 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
 		iap->ia_valid &= ~ATTR_SIZE;
 
-	status = nfsd_create_setattr(rqstp, fhp, resfhp, &attrs);
+	/* We will need write access to set the attrs */
+	want_write_err = fh_want_write(fhp);
+	if (!want_write_err) {
+		status = nfsd_create_setattr(rqstp, fhp,
+					     resfhp, &attrs);
+		fh_drop_write(fhp);
+	} else if (nfsd_attrs_valid(&attrs)) {
+		/* Needed write access */
+		status = nfserrno(want_write_err);
+	}
 
 	if (attrs.na_labelerr)
 		open->op_bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
@@ -430,8 +443,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (attrs.na_paclerr)
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
-	if (!want_write_err)
-		fh_drop_write(fhp);
 	nfsd_attrs_free(&attrs);
 	return status;
 }
-- 
2.50.0.107.gf914562f5916.dirty

