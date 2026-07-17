Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9038F32A3FE
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262824; cv=none; b=oeRlJgJp2+9ZEerPrMZdvSSdjrRAhKs9UVj45s0JPYTMdmaVGH/rBGxKQpQ5ZsvEKLopI/4x2nehftOU5C0F9xPQhmEhu/8ZJ6aYSbKoz+cpl3Ibygt9CiNB/5bJVmd2RpbBEy+2fYkywiZmKzUr5csJfcr7Ebfj/sRUrmIiBls=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262824; c=relaxed/simple;
	bh=UVw52gCzKon6IbZGeD6X/feiToU4aAcqlzjlnr+cNKc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tBg8hSzOwePPQJ+IEN40sXyHrpbIi6me81/MSCPsM4OMXy6Uk2Mmc4DBKsGVr/xQ9QIf7HeYYaKZfmiMaqlmpY3wqrl0TnGmLtgKdDXB4BDHq2o6S1He9D1AkZzkwzCszvcX1FZmvUJdrwqOKQvmV9yw1cvgXYZ9rK/kM3D85F0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=WmxQP+oC; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SpZmkIKR; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="WmxQP+oC";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SpZmkIKR"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 0229B7A011C;
	Fri, 17 Jul 2026 00:33:38 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Fri, 17 Jul 2026 00:33:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262818;
	 x=1784349218; bh=ADUn0PC5CG/DLUIL0eBM1CneE2bcs2zv8ljGeSAPpNQ=; b=
	WmxQP+oCelUCYz4yFqDsdgbsIitrEgW5jVgksIOKD3MqNmr+wH5mi3f7thTspBpp
	tt11Fni5F4rYshYKYspuj12DOEV+/21ZAyJprNh6BJLPu8pLqsbXHxjB5Hqe4E8U
	Xa4Kd7gZvV5T525atFo/m7iq/X1QM8JGpH6ENd+8bUn/pTz9kJzh30zLAIsIbeZF
	XKtobLEYjR7iFSDw0gW/D5wZf0OwfwZKsEAk4oALbmpqYXwD1wuBN7lyx3Is16yr
	9742ZeuNqP0oWZg9nptaOu7Nbts4kxDN2SrDcDiQ4lNHe9LV9TCvifi0xjLgWD+A
	2TDEYNFRLVQWMksXrxsiEg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262818; x=1784349218; bh=A
	DUn0PC5CG/DLUIL0eBM1CneE2bcs2zv8ljGeSAPpNQ=; b=SpZmkIKRqstd7vKiY
	BFalWeUSOId8CxtpruY+M8A6eVKNNozD6xSzsg7M6dwHZwUaDijmUj1T0rP0bNYB
	Cld9BQVaDoKmiWdZugrKIxqkTPG2jfPFFojjXLW3q8aAIvR4kfPR8YEe0zPgKcRD
	fE55jpFWmWWPhYLnMPAkWCOst+kJe7xwimIRTrGQ6rZv8z+DAYSg3dct7hztoAkz
	6IhkQu446munAD2S0Ks9tln1kjXFEtxA6+Toqoe58YsDlOCxk7cdPk/CX8cyOc7z
	GeSKSboa7i8gPRdPLG0wLBJBaTOhhYQ5srAvRSp7V2XcXzVCa0/XpMH3lTI1kAES
	TEXNA==
X-ME-Sender: <xms:orBZaiUiY4bJNouDab-782awiPh2ckMH5bS1oTyA8UIA-X_JCV3NAg>
    <xme:orBZaiQJcNBxeVm_stVxNEuySFKtOPeYQ0ukkpNk2pWP-959q-5UedXkq0f9hwraz
    IENgrvnzyl8JmjFGxNgQUuEZmWHX_e8SnzKdoDY09rVqDuF>
X-ME-Received: <xmr:orBZagOX3VWrDJ-kAmEaM_y5K6kdIzr4CMMQS7IxvyhujGGQlcBoN7lFiNclgXeLZ3iD7S-XgS6vf7pvl6hHsdB-n5z4z8g>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzyf8
    Ln+Nw8fodbwZ+VNRKaLfXMphktAkQJB6zBvJbrRVnGa0FPXpy1q2dySMvFXdGtKrWBZw1H
    IjLWvQ6jxVeAYD3bqJ3TymFZFnzM3eJiuGOczGwkDxk/RL/5seBVl6vsuvl3jP9TGrfcB9
    5Tj/DUCCYQfv8k51wq32rliFkm9lw35/hx56/RCxiWQnjy8MV30/5oBTmHMFMULodZRGxp
    sMvxuSnSocXga1Ex06iQQJBFJRnuPiqev8RXtHx288/bi26RLqPUDwLsx/IAkdOYBBZshe
    n8GwoYKvktUSxTW7JlXqDE9PDq91zjW20upwm83N61bA4I2n/qwzesdoIfEw
X-ME-Proxy: <xmx:orBZagRut1nuxZMObBMaQDZ2vln-rBOCvv5IbDBdl8DDFFtFkYRWJw>
    <xmx:orBZaug-F0qVNmKMk2jztoD3Dyobhkk1RxXZSLiCrg8P9LrfpvH8IA>
    <xmx:orBZap9Xeiv8WNmP7IVK78RuO_f1a37eHCCt8PPR_h8b5geBgGTG5w>
    <xmx:orBZalGfbCQ1YHT7Kn-pG6NOMxf-c3WRqwIJZ2TA8KKMgaVI3OekFw>
    <xmx:orBZan0z-BDQkrM9PXwPMqtVH0yP1lFFbo5B4r-Ixq2qto9Br7HIzCvR>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:36 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 10/18] nfsd: fh_want_write) failure need not be immediately fatal for  nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:08 +1000
Message-ID: <20260717043242.1865905-11-neilb@ownmail.net>
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

If nfsd4_create_file() is asked to create a file, then failure to get
write access to the mount need not be fatal if the file already exists.
So we can delay handling the error until it is known if creation was
needed, just like with the error from testing for write permission in
parent.

This is similar to want_write error handling in lookup_open() in
fs/namei.c.

Note that getting mnt write access to support O_RDWR is handled
separately in do_dentry_open(), and op_truncate is handled in
do_open_permission(), so  nfsd doesn't need to be concerned
with these.  It only needs to be concerned with creation, and setattr.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5e56bf6e6bd9..a4838d36885b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -262,7 +262,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
 	__be32 status, create_status;
-	int host_err;
+	int want_write_err;
 
 	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
 		return nfserr_exist;
@@ -349,11 +349,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
 
-	host_err = fh_want_write(fhp);
-	if (host_err) {
-		status = nfserrno(host_err);
-		goto out_free;
-	}
+	want_write_err = fh_want_write(fhp);
+	if (want_write_err)
+		/* Might still succeed if no create is needed */
+		create_status = nfserrno(want_write_err);
 
 	child = start_creating(&nop_mnt_idmap, parent,
 			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
@@ -424,8 +423,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
 	end_creating(child);
-	fh_drop_write(fhp);
-out_free:
+	if (!want_write_err)
+		fh_drop_write(fhp);
 	nfsd_attrs_free(&attrs);
 	return status;
 }
-- 
2.50.0.107.gf914562f5916.dirty

