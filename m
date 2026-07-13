Received: from fhigh-b6-smtp.messagingengine.com (fhigh-b6-smtp.messagingengine.com [202.12.124.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49B7C35FF6C
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2026 06:23:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783923811; cv=none; b=iStO2c5XF5VL+8TQmbUP8jFg8XsSiAKk5lesKNT/mnIHCFXwbeiJjxii36zTkRRSCtDi1EWvXNfvUEhVvy4ipRueSh9jPAuPX8gv9hLL3wT1WqsfAr9bVAtYKTF3Z/fCV3AmZ2DmQ2/eiTWHUXpC/mbNZDIIu40uRbGD6EwZjio=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783923811; c=relaxed/simple;
	bh=mg3BG32e9h9jSG/QkE1qCe+KoIWSJNZcIJ1T20O27nw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=r2MY7DnFLzGzvT+MOFD58sb1CmrdRPewSqWRRTyQIM0FO6Dpq+7Rz9MnqliS5ijieoRxe3Du7TBMl//bfbt0DcB+UDUyi2+aNkX+WNqu0Awgg3UoRr1V6xnrO5KtMXbykOm9xYekabikwp7IxfGePdT61XANZmy0XwjfPOXO4uk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=aB9fm22o; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=D/ErcpCv; arc=none smtp.client-ip=202.12.124.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="aB9fm22o";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="D/ErcpCv"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 9F6377A0048;
	Mon, 13 Jul 2026 02:23:29 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Mon, 13 Jul 2026 02:23:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1783923809;
	 x=1784010209; bh=q85F33wpbzNtH4KhVQgI3nijbsCkP8/Xdc5e/6EwE6k=; b=
	aB9fm22o0mVfSskV8Ao3uTesMO2Z1N5BPYm74z7VcsoqPuVpb2dIfrqgENpIuFii
	76DjppA8y9xyU5jxxINTj0OOvQqYAsOYK7YV1ug7g1XYtoYD4gn43ixQCsUPuf+Y
	JyETBj296QE1SPZnjOUzuSxWCHe2uIjw4/DN3Oyn5WNVy14TOLZ2QFECoz3WVisb
	Lga5UelWqfqJTOC9s/dtN2B+MgSifQxilzPw4ofNKsQxpRi3praQBMeP3kjp1Owq
	FCa5/Lzn9pDouJiT5hdSd2yc/L17jWYDRnHTzXfaNedBh2s4TmpNjJ8jKzo0bPCw
	zchb0JGR/wtDj456/bKORw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1783923809; x=1784010209; bh=q
	85F33wpbzNtH4KhVQgI3nijbsCkP8/Xdc5e/6EwE6k=; b=D/ErcpCv5BsgGYCFp
	BGr8d72faUUZjEx37BCccMvOsx3MYEJ8ji5MuzdSyYS4D0MBbCjnIFKIaW/LAzeQ
	0n3p3t4cmtMPajWbEKpVWJ/0kRCUdHNAsodSMflBQnjuPD8vZDGVytqrQK7vSULf
	LW01L92RXvRfkXzMrcdrD8gRcnGlc5f0jH/WIAuuT8i1umJAcvC1EMcpvM1f0b1Y
	NQDmdEgqe4/T0v1mhaWzSeonNKcE/tvCyzSdb8TWJTP8Hurx9GUACJPAHJzgMBpj
	fwC/J2P1VSp1mcibtlKUXciwbWykSJOlEGhHsTuHKPkFH+e+Lb6MgT3AIey13R8V
	KtVYQ==
X-ME-Sender: <xms:YYRUakFgeM6iUmcaFEc4v2Uv5mD_jofySUhyYUGL1pc_uiS6LF7XsA>
    <xme:YYRUahCjGCEEjrt0NqAhOxhevaPuRQym1xwYJWYRNTloO5XkaNLtlYi0IKhM6muIX
    etM-7WF-wu0nmRvRRM0kcqCrXHid2IHEPFF4_jeTQYFEE4uSQ>
X-ME-Received: <xmr:YYRUan8ogbVq-3mNHiE69QJkP98EJR7iM5C9snZPsh5BI3R1RYh6Thb5G2N9dUa1wRTmI5sS2URHJHwDu1Tvojxjsrr7h4Y>
X-ME-Proxy-Cause: dmFkZTEZB/Kbgph/UP+qlRun0nbKeFX2X/79iTN2dqaSsx/s4vwTngk08Ly5MOqpQNgv+k
    CvuEnOGFE0d6Ev3uXjO6b4oysisaasspM7JTzT6meQcgCVImGZiIOsOPRJOwgQC86kMFRj
    lyOi5olcj5Md2Szvw6Zlspslnw25Wy4KBGmGF/EqVYDqMTHhjJMFdcRqo9oxC2g/yR1fQp
    Z7I/dsqPlPjX1oBTZb4S78ele8cr/9kae0rQPXCj0X/9Zm6b0UB/039FfFdWLRTxQlVexZ
    YfhdHbsjogzRhQd5xB8YZ26QTIU3yW+3ERF7FRscMY/Sr7rlpF51DuHkVdM7rjMRBeMXQ8
    L4aW3DTcj4qyov9aFQ2khsIMnPf53GQkv7Xhy9nku60Md0zsorHgWeSA0kJiOgqIg4esUB
    hM1ohzCB21G0DX/7gct6vvuy0R9GlLQv+5IP6sEHwPf6g92nA6n461JUoVODK3Zq/Fmwsy
    0a4aL3q8jhhX1Wl3qhiyrrsg4qCVXF3QUYku0+qav75OtY/5M4KsgCUT2fDzEqo3NbWNrV
    AvQ7Osk1mYRf71is9CvzjzLqdiHxgmppccQG5eBlLYQUjUQ1/m3B3AlAHrzQ4d+JKHsQpF
    O6l9bDoEYaqxQFfTYCnHA/+oBwOTLw0E8SHLHAuIq44vYqeju0B1hTOyMcuQ
X-ME-Proxy: <xmx:YYRUatDHYa17diAkmpmeRHuKJx9_QoarmMfShfsLbM5hK9rtAnJbPA>
    <xmx:YYRUasTCXKYTIVrvYre-EDY9FChkd3kKpi3El_7a5b0FOH-9Egd9KA>
    <xmx:YYRUakskW0CqpvFEA8OSwrxFTmjnEleV9_PTsTGSD_QkskFtdzzFVQ>
    <xmx:YYRUao1MltZQy3dIGURFNEaFaQXNTass9vyNKRjX-6FMjz8LUWrwiQ>
    <xmx:YYRUapmsIYmeqQmEydpMuDC-mD6yKsWKxtKyes35ERKiENarcocwRjl8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 13 Jul 2026 02:23:27 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/17] nfsd: reduce range of directory lock in nfsd4_create_file()
Date: Mon, 13 Jul 2026 16:15:34 +1000
Message-ID: <20260713062219.6399-12-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260713062219.6399-1-neilb@ownmail.net>
References: <20260713062219.6399-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

We only need to hold the lock taken by start_creating() until the create
has been attempted.  Holding for longer can serve no purpose.

The lock is currently held across the setattr call.  This might be the
intent but it serves no purpose.  Holding the lock prevents the name
from being removed or renamed, but it doesn't prevent a GETATTR or a
racing SETATTR or an OPEN.

Calling end_creating() puts the reference to 'child', but we can still
use the reference that was stored in open->op_filp.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index abe27a4841eb..a1dfe0a31ad7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -368,7 +368,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (d_really_is_positive(child)) {
 		/*
 		 * open the file so that we consistently have a valid
-		 * op_filp.
+		 * op_filp and consequently a valid ->f_path.dentry.
 		 */
 		struct path path = {.mnt = fhp->fh_export->ex_path.mnt,
 				    .dentry = child,
@@ -402,9 +402,12 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (status == nfs_ok)
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
+	end_creating(child);
 	if (status != nfs_ok)
 		goto out;
 
+	child = open->op_filp->f_path.dentry;
+
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
 		goto out;
@@ -454,7 +457,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (attrs.na_paclerr)
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
-	end_creating(child);
 	if (!want_write_err)
 		fh_drop_write(fhp);
 	nfsd_attrs_free(&attrs);
-- 
2.50.0.107.gf914562f5916.dirty

