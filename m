Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB9CA3BC673
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280643; cv=none; b=EaYh9Wf4IuKvem+J/0eXUHSjtENUUCEWmMFzglbmKTlmGkSJpuWb/W71s75HyJEquT67wdZ7v3uR+5KihfJaH8whWaIbbM+ZHcQZYPBFnGYl3xAHHGkGtWwzdrEKLcC5OwrJc6AqeNNB8bE4B9k3P3hbUWTHmcUgGP3pUiBwK7A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280643; c=relaxed/simple;
	bh=gBCyM4qgtkiDq2oBE6UW8MiGPhzRYfuho+7enYz5QjU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aHzW5dNVLeYNVKfyoaepttdWRqkkv2KeFIt2QrQenjAmhAfK8/DxGvnYIaHia/z/Pzb6t4Co2IDqn8VZrDgJHZHOKr3fk/SO1Kd7T92YYyIOSiwx0tJDscXls0UPQqKMO6DmvXjnNkvfiPad3snvwWa70Errk/M2PAX9BjjF0NE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=JRbk9qXR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Tiypnwf3; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="JRbk9qXR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Tiypnwf3"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.phl.internal (Postfix) with ESMTP id BCDB81400075;
	Fri, 17 Jul 2026 05:30:40 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 05:30:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280640;
	 x=1784367040; bh=u1YYFvWTOLVn8e2oS8UJ5CxZt4tXM+/jUW+bA8Nf32E=; b=
	JRbk9qXRkJc9qZWysyfe8DLi9yBGaM9BYI44nS6/DaUVsecGIGqyuKTTl5NwXSQr
	CkRS0lWUmML+Da7iZNoORsodnpMhf7OiG/dHcFQ2uf9n7JxYBYYCHmFaYUANwhOZ
	99jKamzWXKv+1pScE7tSVfFNu6PAC7xko1DTXSf2Pv8O68HBTXvv8rXAZUBXa6Qe
	Kpkrtafv2hi1Hfnu6wUzPqGvKGUERgadBt4zSmE1/tPmf4hJ67SGbwD74rugYT33
	KTBYYfz7eSKg1+2jn/aIhLNchtcxFqAbMEs+4XfJESE/Q1IYgefsd8Hpq4dZrfSH
	9nVByMLVDcCbNv5k63CoWg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280640; x=1784367040; bh=u
	1YYFvWTOLVn8e2oS8UJ5CxZt4tXM+/jUW+bA8Nf32E=; b=Tiypnwf3r0d2fvfHk
	OQYiPYDg90IeitHeVZRKSkmFXA6bmvrqXKtAiefzb3MuZ4pbZTazEPzzTeIEbAeG
	89NtesbZKOpX3RGjiA6MSE7OtytjXclQ+Y/+I2dmkz8n4QBTGU1qUavzT68b1oUB
	drg8TIgTNE2tWKzwuszVTQkjNLHoEPiofxxOb1GlEP/f58rc8QTDHR9DQSLjkUrk
	hWbtGbl5pZ35Ig2fVUPPqe2d0JTi9eFiRuRhJ6X+wNRW0AOb4WpG3pJuLZnz45vn
	X3U40orLklLn3tVOmC/2uzlqyR29aZbjlbHEzjQHGCu1YuQaf3AFD0HLItZ0eKuF
	oyVtA==
X-ME-Sender: <xms:QPZZalx5-ed4revFuYogN7AIxmmPUaEyC7NcAyHmzi0QlepTzIHzXQ>
    <xme:QPZZao-VgohkzbfeVu6rT38ne3dbbAzIF174k8Rv2WxfmRVKZTIPi1Mmw32MKij-m
    zjQLBe08vJap24g3P0lo-mcCUcSIpAmVEhiJB0eBJx4m65wUQ>
X-ME-Received: <xmr:QPZZapKCj5yI1MRBqbmBInCy3neq0idS-HGlXk8d24d2s1G40etP8aGi8A0tzrk7_vcYx1oYaMpfeut88hmEc2MwYkWIX6c>
X-ME-Proxy-Cause: dmFkZTEWR11FIoOU7sLBysZ6MvBVA6kk3IPNP6YE/I53vP2pOfWKjkNlUeP+s2aJ83e6ID
    9m5wdHpLp28Kbqr8S3EO34JWG8UQDO4OgJ4NECiBfpWV6/jtmGuQ29O/t0+yaCKFdVxjCu
    2+c4BPeFMmJNt9nQnqio9kGZURKlbZ6guJLeRZWGYbJgs6hFz2+k5Vp9dQmxbocHJRb2ez
    Rbo/Hi+fKrHwlrp8u5Xo7hQobz5byTQlnnJy3OJdwVQ9MBNgzPG4Dhv4z9o9/FFJjSh/xM
    dEhm7ru3yn9Nb2b0YE3EpvHOTNLm1T0bZE13FeDcU/3CmDxuC4iGIdb4w2ViFywDYdLikU
    ZdPRWsTwkhJIxPXLB/eGhv9dtd4cpbBMwQNO/Ygz9yyMoq+EL4jkCmZbHgqflzDl+zBWIm
    JelQBV5N0XAGeh+FNv4QBmex3LXnN+Fh6/FeMmkkOKxqh5LFmHoMoV2wR1SWLPKKiGEGPZ
    5AE3ldfC5uxo9Aa0pG2C3nJTxavizcHPSGo70v8SKASFKIZqbUmxyzWhhZqiIM5QHdWUBe
    H1KAu32NhrMNTm5N/w0cR4Go5lC4zTnjv6YfrOyeA7k2BjVuO8lZEcQtfO41PFL3u8qozJ
    X7/Tq13LckVg3ALPnyvhxUeh8MCQP8iNXntXvhB5UY2VEXdrOC/atgMw8SfA
X-ME-Proxy: <xmx:QPZZaucz73aVEw_6qBIa8GgtvBkLO6bFAdkbD0zb2BGWurAnlHMZpQ>
    <xmx:QPZZao9y5B0jt1gYLUrCBrORY0gHCxBwKr8ynM1JP1ODtzCCZ8x-Ig>
    <xmx:QPZZarpfNSYVuKyN7mwbxJbLBPnKvPYv_l5JEqSNR_qulp4YacFhew>
    <xmx:QPZZatBUO9JjB4P-X-MOFQbGo8Yq-0ZlWBl2xrcUhl7v-FM6hIG3ug>
    <xmx:QPZZanQVmAU-f0Y51vMqkyBY2CkAip3f0MV8Y5gm02VJ2vFylJ2qDH9D>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:38 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 06/18] nfsd: move more nfs-specific code into preamble of nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:27:54 +1000
Message-ID: <20260717093001.1972119-7-neilb@ownmail.net>
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

Do NFS-specific prep before interacting with the VFS.

We now add the verifier to iap early so it applies even when an
EXCLUSIVE4_1 replay is detected based on that verifier, so we will set
those attributes again.  This should be harmless even though it will
update ctime and i_version, and so will update the changeid seen by the
client.  It shouldn't matter because the resend implies that the client
hasn't seen the file or its changeid.  If some other client happens to
have noticed the file, it might see an unnecessary changeid up, but that
is of no consequence.

Note that ctime would have been updated anyway if the client has
included other attributes like an ACL.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 55 +++++++++++++++++++++++-----------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d5c5f440481e..2b9fad28a9ef 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -297,6 +297,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dput(child);
 	}
 
+	if (!IS_POSIXACL(inode))
+		iap->ia_mode &= ~current_umask();
+
 	if (!is_create_with_attrs(open)) {
 		/* No attrs to check */
 	} else if (open->op_acl) {
@@ -316,6 +319,30 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_pacl = NULL;
 	}
 
+	v_mtime = 0;
+	v_atime = 0;
+	if (nfsd4_create_is_exclusive(open->op_createmode)) {
+		u32 *verifier = (u32 *)open->op_verf.data;
+
+		/*
+		 * Solaris 7 gets confused (bugid 4218508) if these have
+		 * the high bit set, as do xfs filesystems without the
+		 * "bigtime" feature. So just clear the high bits. If this
+		 * is ever changed to use different attrs for storing the
+		 * verifier, then do_open_lookup() will also need to be
+		 * fixed accordingly.
+		 */
+		v_mtime = verifier[0] & 0x7fffffff;
+		v_atime = verifier[1] & 0x7fffffff;
+
+		iap->ia_valid |= ATTR_MTIME | ATTR_ATIME |
+				 ATTR_MTIME_SET|ATTR_ATIME_SET;
+		iap->ia_mtime.tv_sec = v_mtime;
+		iap->ia_atime.tv_sec = v_atime;
+		iap->ia_mtime.tv_nsec = 0;
+		iap->ia_atime.tv_nsec = 0;
+	}
+
 	host_err = fh_want_write(fhp);
 	if (host_err) {
 		status = nfserrno(host_err);
@@ -335,23 +362,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
-	v_mtime = 0;
-	v_atime = 0;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
-		u32 *verifier = (u32 *)open->op_verf.data;
-
-		/*
-		 * Solaris 7 gets confused (bugid 4218508) if these have
-		 * the high bit set, as do xfs filesystems without the
-		 * "bigtime" feature. So just clear the high bits. If this
-		 * is ever changed to use different attrs for storing the
-		 * verifier, then do_open_lookup() will also need to be
-		 * fixed accordingly.
-		 */
-		v_mtime = verifier[0] & 0x7fffffff;
-		v_atime = verifier[1] & 0x7fffffff;
-	}
-
 	if (d_really_is_positive(child)) {
 		/* NFSv4 protocol requires change attributes even though
 		 * no change happened.
@@ -400,9 +410,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 	}
 
-	if (!IS_POSIXACL(inode))
-		iap->ia_mode &= ~current_umask();
-
 	status = nfsd4_vfs_create(fhp, &child, open);
 	if (status != nfs_ok)
 		goto out;
@@ -416,14 +423,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	/* A newly created file already has a file size of zero. */
 	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
 		iap->ia_valid &= ~ATTR_SIZE;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
-		iap->ia_valid |= ATTR_MTIME | ATTR_ATIME |
-				 ATTR_MTIME_SET|ATTR_ATIME_SET;
-		iap->ia_mtime.tv_sec = v_mtime;
-		iap->ia_atime.tv_sec = v_atime;
-		iap->ia_mtime.tv_nsec = 0;
-		iap->ia_atime.tv_nsec = 0;
-	}
 
 set_attr:
 	status = nfsd_create_setattr(rqstp, fhp, resfhp, &attrs);
-- 
2.50.0.107.gf914562f5916.dirty

