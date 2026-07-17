Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF5513BE647
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280683; cv=none; b=sL3IgAolosHdD1On90MU0N5/ENSTuaPu75mNWbQdRHLdHwg1+dpQFWWmTbW5yNKN5FK6z7AgVEDn0cXGkEWiIvdNpKXN48k/3fVziDVeMePtAPoGCN+5/7+Cq5dX/RPGUqjSFKtWrTsuft6UFsksLQB7mR4F6s3lztvPUntizrw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280683; c=relaxed/simple;
	bh=gqrZ8LHDxURxP48rA3fDkIBw+PTin5ruHiHeSyhC09k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dSjpHZkqX7VeH8YyTJPNhCbKrOxusfk6z/FOMUlem2t3UYTfD3VYu1ORaT5oUO3XQx2IAJkHW58MpF0XGzdDB3TwZN1lyBQLofabUUo0nGjYmSPXMLYKPdzqqqieiRHMY8XZrFri2RhEx0ulf3iJuMJMG2VA+ezf6J90CL1S3Ao=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Znie/tgq; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=EVWJfN5Q; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Znie/tgq";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="EVWJfN5Q"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 4AFCC1400024;
	Fri, 17 Jul 2026 05:31:21 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 17 Jul 2026 05:31:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280681;
	 x=1784367081; bh=HU5dDUtUDeyTWTZ94RVGXfZxZ7QLL/6X7fkig8cHrmU=; b=
	Znie/tgqlsbpoga/DNuxhGU7ngLatkLZU+P7J9YdBEkshq0tigwucfCkzjg6Wf0x
	kP53Vx4gZQSeSHjc+Svz0/5ZEZ5pGxhRAo7Knv2upjdDlPXcWx6xFQ3P3bssVMFC
	kVpP53yGfPuZXZnb658VpoIlZ5LNvD6oQFWIbGiSTl3cHhsWQcmS4c5WqdbsHiPx
	UrS4pqnWEChbWrAqnQhKt/jtyf3MghXE14FaWilIYcbbrlqTV5Qxl2i9e0vzBnao
	snZ0k63Ie2BDOz7ANruaoHwi76soF1B4T1I/ae4syjBLL6OjY3SDfR2lXHG7nJnz
	WUMTFRA1wevlBllmH6FqbQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280681; x=1784367081; bh=H
	U5dDUtUDeyTWTZ94RVGXfZxZ7QLL/6X7fkig8cHrmU=; b=EVWJfN5QfGv+U8oNZ
	FO0keBmWcYBlY6uBSMvrEtHq0WN/bdI5eBBcLFSBXhRxADawktnK5SNvBCxNs2fH
	qZk1bjRl9fGDDPpT8RwhG/xsDxSip5vxHgQ7SOLw8E9FGWXNuubtASD2cfg7I3jb
	RM4U1cjop/WviQTifn7yfgkqKnWwK9uGQeBmyREftD6nkXyx5RYltOL/gt5xAD7M
	+FqIxoDzhKQbnZGWlcsy5vo/1GwhMYCyt7YnG6+e+muDDmdKDMkMTNMJSSiQVV2m
	+7mcc7gIYGGyrJzNHiBkLcQTfrogvBJP4W/dwoHc49Bie5l+/Aj/HJzAwaMsJUV1
	oUiyA==
X-ME-Sender: <xms:afZZapnSCzuDK4tug-zb6UxTSUCfaFzzpwZK4bPr1t1SRC203uk2bw>
    <xme:afZZaohiu42HdD6hPSMQkRb_jOd3WUYN9VfmAizsq8BY-36PPXXi389NinuUI6_XX
    aTFaqngvmfZwHWbDOztfk28jDBQVq3JgNrjTzfVhCV-sA4W8A>
X-ME-Received: <xmr:afZZapd-csGqxO9Ur6K3tkCRhmfj4kXNwBbfz6ossKv6tWiD3m6Rp09Yxm1MPrsCw5jhIlM3aZ8qUdHwlMVclp4ZlN-uu-I>
X-ME-Proxy-Cause: dmFkZTEApqFO5jAKqrP3EdbU0Ae0MCQnQFfvSrW+r84mL3qL2UFfbuf83R37o+6oMtcUaH
    6DPJoG+34uUdqXbvR7Bw2l/P4dHaUP7HQXwsVpft7xVFNPuQCF7CPPRrJ8RbY/S97ZLP41
    U7XX1t/FfVPe+wX4TXpm1uyeb7KPzLLiiaQZAxoL0T352PWKJdXBYkCUMqwJ+Qc6GUYgZ3
    Uoo8xLxf76by20kMmFLftmzj5U0bznLrEBN2m623yRBHfn2OKPGMWK6sTxb/HqvCRKz8H9
    PuQ4+q7R9RbgvgWOq6XwvxxK5Vgvb3Gcdtw7XfnM+DdDvQvzx8yPyLi9NGYtfL0WuGqtXx
    c4zHB7al7x8O56U77rVaXWyvBiSkz1WttBYLVeemDN1G1Ou5f59RWO3Vxi69hFYH/vclrt
    CPbpCxNdKVj+mXMS4VXUm4rb6KDZNyTx68Hhv9TN/yKoQrxHSD6iSbJyCwVUvIBhYysTym
    cKIt7gn2khAitUuSmdXsMs1fwWjOccWLuNfwnz+bC6J7nAUCLBHN1nx17fdx+S4mTZYqyv
    6Ud6U4aipnsT4Stj4mKDLLRlt0b1oFGTMmO7RC9kUakfRziLsGC+JJRyKjRhcVUFsFpFOy
    /WAdqXHcW/wpwDaHXD3wqL/KQndYNbQudQn2ybc2qP8iHCqomv9TzitDXp1g
X-ME-Proxy: <xmx:afZZaggAncQcpJX5GiNxcNfKTDbZq6IZBeO_w_vEhaygR-dcN4N7uQ>
    <xmx:afZZapwCtiISHEjHcAhEcMrL9XTO2m4RsohsDaQY-YOH7MJclFXq4A>
    <xmx:afZZakNj14wFwRMQdfxn9EX2hOJXPWR03yNmpnYN3CJijSnOtP3Y1w>
    <xmx:afZZaiXsryRAy6ttL0E8DSyKWBqW83Rh_opHrmPqf9gKPxJTw2DQCQ>
    <xmx:afZZattP1gIz_FmQ_ir7-6KVXsXTsmWagXsWS87R2qPCJuRcXXjOBlBk>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:19 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 15/18] nfsd: reduce want-write range in nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:28:03 +1000
Message-ID: <20260717093001.1972119-16-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
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

