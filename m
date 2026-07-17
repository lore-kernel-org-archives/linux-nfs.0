Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 354013D9DAC
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280656; cv=none; b=U1AzdJYX6+7Q68w++RaxaXwgMXjhkhz75WDj5Qr7H/LlRm4lXyCwj9bJD53cxFsj7btc/Q4lfALvi2tOAt5dLJyD1yJFVRl230heunNU4Za4BwAB20p/+dOl/chYTnIWpHljNWWGKYZPeHavuBEp2Iv4oNI6GOj0xbEdCWX2Y38=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280656; c=relaxed/simple;
	bh=1XGcYYgO08V6+3wsvZjALQZQRSkksTkUTx7tKd9lvbw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jy7CUrp01FRMeJlJ1mC4D/2yj43mYHAx7ROleR3TJRLdeVd3KSEuus5xd5E9k4qcblNm88AxMyIpbHUfe+pgBW+0Rc160C/Q+KKMJxQ6CbE57wUwM9b/7FIrtAvZzXhmC6ONVw2mYHU/sou9+fzJUN3ONBsI1ymd99M4J0vuoF4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=PBO2vEQc; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eHuPV7yG; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="PBO2vEQc";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eHuPV7yG"
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfout.phl.internal (Postfix) with ESMTP id 43647EC00FA;
	Fri, 17 Jul 2026 05:30:54 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-10.internal (MEProxy); Fri, 17 Jul 2026 05:30:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280654;
	 x=1784367054; bh=Hm1WB/QfGfNUuILJ4U+cIkrJel13v79Ig5A6omWtSM0=; b=
	PBO2vEQcNzk6+LaCtKA7hQNQPTNSPQH3RtaJT2riyySfXchUp6GlyjU093vuQsL0
	Gsz0ojQFy/ZHBCYZCYsv1rdhHay6yzJCmZvlp6XVCmPAqNNJvfOv1riwJ0VIgL4x
	S/rbzXxd0RMBA25BojurnywLEv5q2nn03f40T/uPLUY3hF+6nVLC9YbL0N5R6mDx
	l33ATF1BG0GVzCM1XP6MUsTu8fjhZP6YyRp1eMatKo+wcrb4eQv/cdA/OZtY6l6c
	5NgJkcR6VkaX4yQTZWIRXKV9n5vJDvZ3Yp0nDTMmzBYcUJuzwqkEpHJeGJNCbSy3
	/kRyqWl7Aiw18qOqQyVKOQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280654; x=1784367054; bh=H
	m1WB/QfGfNUuILJ4U+cIkrJel13v79Ig5A6omWtSM0=; b=eHuPV7yGMN52JtraO
	VMRsrC0EtxMVKOxO9R4FJSA5kj8PbjM4LejYs7TmheG3c4lQp7fL93PqQyRDtAo9
	Yr5Q1Ha/qcN1rJ7oUZOod8PJGz2NGQtwWrAXAVIqU9Tx4hGCzW7wYStNBcofiIZd
	COjZW+QnvKTT6XRBq1GNEdrYu4NCoHR7i1vxYFGRhnCE4zuX9zTHqM6zmuuHUl7r
	FWHXPxIW7McNXACYeEivm3/aPa0/yLOvI9H+pKFglRItP9h4cD5MHiQHl0Tssr6s
	gznnQRdHOvrCDs6g4JwtdiZRQp32vhO/GESGzaTGA5rRCTZ/fk62wVlGbbN4DQEU
	Y0U9g==
X-ME-Sender: <xms:TvZZarrxa14tcO2opvKBubeU3kHAQxEm6a_zUV5zXZCu7H85HgkReQ>
    <xme:TvZZapVJDEo26eF5y3i7xxZHcW1FUZDi70_3e94jawBArOYMyqzctBpsO1KTu2uyM
    q1YK1RpfkfNjGX1GmL249Tsh0QIpVBSANKGguJxBp4NI3g5jA>
X-ME-Received: <xmr:TvZZaiCNduVhduNXXv4V1JaxbqeX6V9yg74HjbdJ1Zxj-uQJ_ljtiZCwFXbFHY-UKY85AcuZSDPkLtfCs7W5GrxhXVFa6p4>
X-ME-Proxy-Cause: dmFkZTEApqFO5jAKqrP3EdbU0Ae0MCQnQFfvSrW+r84mL3qL2UFfbuf83R37o+6oMtcUaH
    6DPJoG+34uUdqXbvR7Bw2l/P4dHaUP7HQXwsVpft7xVFNPuQCF7CPPRrJ8RbY/S97ZLP41
    U7XX1t/FfVPe+wX4TXpm1uyeb7KPzLLiiaQZAxoL0T352PWKJdXBYkCUMqwJ+Qc6GUYgZ3
    Uoo8xLxf76by20kMmFLftmzj5U0bznLrEBN2m623yRBHfn2OKPGMWK6sTxb/HqvCRKz8H9
    PuQ4+q7R9RbgvgWOq6XwvxxK5Vgvb3Gcdtw7XfnM+DdDvQvzx8yPyLi9NGYtfL0WuGqtlO
    S25GYzV9klBtJsk/xKcR6LSvJ3b88lCw8CFTmXJSWELiUs73vrwbgvRY/DTykYrjQprMbD
    rjbalFFEEl6aMCtoGiDQZSc80U7XNOuK77sNuEXNW5StH1tTEG+OrlI0NS2TxoBwOybnnI
    lf/+UGvh7p3vFdGiLpCX7FP2mlyXLfackTYRZsPqjjGtj55WuX3gijRoCs5m4HGIhy0+Up
    zvFOQJKsUodRymSBW/XxKsVmPLVHlfCJW4IgMf7IYQCQjuSiYiJvz4k6Q/OUQ5foeIkayl
    1DhT0T/lVCySMU5/2YFsUsrFVI4donDhNuzgKzc+M4DA2Sh+MRBMXRFI+XzQ
X-ME-Proxy: <xmx:TvZZal1GsvOMx6O7HiMm_LkgPi2KCiXeSnGvRcxXEuF8_iHIWDC4NA>
    <xmx:TvZZas1SUdg0GdQfHLxu6ySIkljtprwOvZQoKBa-rqYVwcz_Dcsqow>
    <xmx:TvZZaiCOMNWuN2pzzl1zWTV2hNq1xU-cPVlzfGK67tZ8lYnUYiqKwA>
    <xmx:TvZZaj665Th1ZacB50aw6LevHaelTerq3UXyvZ2WwxOnnbSyRwT_fw>
    <xmx:TvZZalJvk2cn0VNRC8V9wSiTv86dMgifZswu_fruVQvp301es5k4BhuO>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:52 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 09/18] nfsd: nfsd4_create_file(): Move NFSD_MAY_CREATE check earlier
Date: Fri, 17 Jul 2026 19:27:57 +1000
Message-ID: <20260717093001.1972119-10-neilb@ownmail.net>
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

We only need NFS_MAY_CREATE check if the file doesn't exist, but it is
nfsd-specific code as it needs to check NFSEXP_READONLY and I want that
to be separate from vfs-specific code, which eventually all be provided
by the VFS.

So move that check earlier, but hold the error status until needed.

The if/else chain here looks a bit clumsy, but it will make a later
patch cleaner.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8840f6dd8a0a..5e56bf6e6bd9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -261,7 +261,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct dentry *parent, *child = ERR_PTR(-EINVAL);
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
-	__be32 status;
+	__be32 status, create_status;
 	int host_err;
 
 	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
@@ -347,6 +347,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		iap->ia_atime.tv_nsec = 0;
 	}
 
+	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+
 	host_err = fh_want_write(fhp);
 	if (host_err) {
 		status = nfserrno(host_err);
@@ -360,16 +362,17 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 	}
 
-	if (d_really_is_negative(child)) {
-		status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
-		if (status != nfs_ok)
-			goto out;
-
+	if (d_really_is_positive(child)) {
+		/* No creation needed */
+	} else if (create_status) {
+		status = create_status;
+	} else {
 		status = nfsd4_vfs_create(fhp, &child, open);
-		if (status != nfs_ok)
-			goto out;
-		open->op_created = open->op_filp->f_mode & FMODE_CREATED;
+		if (status == nfs_ok)
+			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
+	if (status != nfs_ok)
+		goto out;
 
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
-- 
2.50.0.107.gf914562f5916.dirty

