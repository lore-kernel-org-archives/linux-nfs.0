Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06715324B31
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262804; cv=none; b=r8O0nFMOdd4IlxdkvUXgc+63seOoKSx3QnLC2p76aRjm092htIpTgOgFPKWlDj4c4zJkCsXBFuPaAYWkO7bs6CwNwao5SXdRo+uoRfWxyTGm0xaMNs+7dTcTc8JyvN7CKAkqAwAUyWvY9y7wY1FsFqF/feV5ntOKposUs7oFADI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262804; c=relaxed/simple;
	bh=gBCyM4qgtkiDq2oBE6UW8MiGPhzRYfuho+7enYz5QjU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jDJg7epc5boSafSkYd+1DzEML92frgUB0Jhn9JQgU/xwQSkyBQAa7TxbAyr4u+xH+4i3atqUC6VtkT4k4WmDWk6qzEYlheGg32lCU7Ctn6gr56hPc1eIXKUGO32CxyXsrZDs1ZvbOclkL4M5W4SQXqhNTw+YgnoGNe22VbPiRu4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=EUyodZN5; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SD8QjQuz; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="EUyodZN5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SD8QjQuz"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id A64C57A011B;
	Fri, 17 Jul 2026 00:33:19 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 17 Jul 2026 00:33:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262799;
	 x=1784349199; bh=u1YYFvWTOLVn8e2oS8UJ5CxZt4tXM+/jUW+bA8Nf32E=; b=
	EUyodZN5xH+0ljDNBqBI9oJuJM4uoAvlqDfjH6UgXrYArmon2YDDGo8D7BL1gSEQ
	OQLscAtX3hALhSbkFCP2iIB2cDHVcJg9H4h5E6A/C5jCk0G0U3ubwfX257g1EMt8
	D9OZpwhJzQtdQHfie4oFNn5i7+sR64RUBwln+ZboBvYsHw5DBkWXsag6Igsjwb6i
	3/BQQZIO9JxiBwSHsyYwiA9NqYqplpjHaLhtwDJCKj79WrDM79i+ikMe2qqMcpLj
	CebTC227tIQ+bXldmsFCaBDuxh4JzV6Xj4r4fSEPkABsCRQnZ+78ajRABLUZXhOr
	9rrzWEW9M9o501MdU+eoJg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262799; x=1784349199; bh=u
	1YYFvWTOLVn8e2oS8UJ5CxZt4tXM+/jUW+bA8Nf32E=; b=SD8QjQuz/fQxPk0DU
	y/30F+v9bOQTCszmz5T4TMbOOnbTkL7xupWJJSJa7uKBgxDk4WYaAnqO62oA3Wbh
	O1oFvZlPwAzaMhuqnpAOVLqaVwZVCwMei82S+ixNHvy35Zn41xkxO8vBRbkBQyIz
	AfF0/eNX0nkAQ8k9uPjNagfZHIQ7bM1U/ByfsL9Ro7m6hxzhV06rZ8JPCsnUq8xd
	XSkrphK7K2SSW/kbeDNQrPIz9CXyDa7QC0lHmfzyR2EjFl4d0UAHe5xBtbAj65Fs
	22eWDDGdBqr/Q+yqVKD7hzO6lhykzJ8uk24d8tRbzLEXBv4uawbkS2eEYFIXaexj
	SO+rg==
X-ME-Sender: <xms:j7BZasI4Slr2el-FhEaJeZapQ-ndj4-Cw2TauqK-rvrLQyNtwHKhXA>
    <xme:j7BZav234aYb5tnmzdW3JuEbWxleD7sYEXhYV-0mjYLfjx0TEz8XRu5yxi-KDGxV9
    ciGzvmdMr2bbvky_ZpXYtQQyvi98ZMn6Gjard8Kj3yb_DdA>
X-ME-Received: <xmr:j7BZamj_ZyWV-G0W48Z0D2MLY9ToN_7kXa2Q8U-6menjO7pIeC6cLzDi4huZJmipH2iz5VFvnBmmK5-9l9pvt7WLoZiT5T4>
X-ME-Proxy-Cause: dmFkZTEM58T6k0FdKde3vqXstJh4TNGQx0aMkXSf6W/Bm65owkFToMup52zfElxqwg8+mK
    qceVNcN+nXpnr9GL6vAG/PisJgB4fMGdXB4wRESqVAnXADljTNPDP3I3NSrU7YgMBk0Q9o
    6yR8EaQKD7SmBxaw9WuXnA5jauv4ECI4pSpLMKqki9gz5w9ejvx9oB+y/MDPi8NaHr8xd9
    YCkKinrFCYly+TDzg6lIHRyvqsE/SorLMIXYb7WoKI5I3R/fRnuPAyuaHR/+mCKvWPWY0z
    bMHH30Zsk3wESgY7pWozq9NE0B1RkGrQNoJNby3C8DesCkKaupJuCL44Ugwifo+9F4PhYU
    LZ6oanuw1M4sShDfHgw42Cdr+arx47ozTPQXn4ch/2s86fo1SjrTQfrURkK6mKrjPqCAv7
    DCI6PwaGFQ8tQatYIktGWhysXQFN/aPRpJ1aXM6iporGaXRdqByEP/L37h2UV5fuI9X9C1
    xYNtyw9Q8htHzTqt4+Majxsjs+dogsSXgMsVinVuK8zi9BT9XXVMDximhLr2YtkghToqFL
    +6t8HMCKrOur3wX03X7750RCuV1i1ELCpFRGWo9I98cHYdoHNNdHCC/IQHdlO316NjLLaq
    ly6dHkylVIaB6NFo5NLuyihCkQSGJdcWr6jXETBfF5uInF+jQRTrZ1wD/h4w
X-ME-Proxy: <xmx:j7BZagWfjOR8gS_u3MunzZYge1t0BeIUhit9YMyvWBFDZT36ieSXHA>
    <xmx:j7BZalUC0Ptd0j_Q7E5hvy5FZdZ8Smc6AarPKJ5yNw1edB5iiJEVVA>
    <xmx:j7BZagh7NYW3AoU9kwne03FVjD0qSeNljREIxc2M5l9y5E178-ZX_w>
    <xmx:j7BZagYJty28t46JiaUccWJv8Gu1CsMEzAXbYAIi-RjNKk-wbAXNhA>
    <xmx:j7BZalrQZdHZz4Hu5fyxKizNDkWqKIyzwuenIkSwhzg1iAHX9UJyh8en>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:17 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 06/18] nfsd: move more nfs-specific code into preamble of nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:04 +1000
Message-ID: <20260717043242.1865905-7-neilb@ownmail.net>
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

