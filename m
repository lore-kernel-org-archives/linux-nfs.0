Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0273D3BC673
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280638; cv=none; b=SoLQ7NrGlXBkk0EhZ6dVeoUUWfG5N88aO5JHQ+pV4716vP2AFgyCFwC9lzwW2KLm6WTFdH1aw0LZMYwU8XpB72uKKpg3OaGBLEtl1ZZmvXICqdEaNZdcGppDm8ysVZVjJr4jomb9E7s21sPiO91+5ZN5oEIEP1RcJlvsXSclGnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280638; c=relaxed/simple;
	bh=2m+JMtyEJSE1ZFg+Sfk3SITYOSRe1A/6Ykmty219unQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bm8CfY3bKh8kQufx8FBclvZfHxbHNmLgYmMQjJkrkcZkQWx9pjpZ6Hfp3SPf6TSx/M7r0fVJWTmLLqCKrlLtmS3Jyst9Brnlm/oqFKJHJU1w2mxd8IzRXLs/y8F1tw6xEGK3+cbqmdfX04mVKmK8dWrgyNskDXvtwVO11pEQsmk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=AwvnyBaQ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=oM9dFCi0; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="AwvnyBaQ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="oM9dFCi0"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id 2DEC6EC00F4;
	Fri, 17 Jul 2026 05:30:36 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 05:30:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280636;
	 x=1784367036; bh=awl4c3AF4FjF/O1HNQPgGsIGmb7wjykNrBLMBgNgOjk=; b=
	AwvnyBaQyn2SXqCTj3euAQ4th2j+fiIgwNr5HtdUWtN8oOh5qTCZpHGohmm+p0nh
	l8T6M7CjfN8PLB2BA6Rb+/VU3iGTDU0G3y+jD2rH5s3eZJ6ZaptXdo9x0FSFfPZL
	fmt2IE0qvhVwpKg+9FzEcczAUlwcKEw2hJrf97MYQOs31QLH4iF3rF+SvLsOMP3R
	sRAR6fBjDnp1aaLFlEeS3IgmFVDS9MITVWOPIDJ6PtOh1LZwYP/K+BhVJe+7cqAf
	ZTIGzFUbWVGs6u44toTqPzTw8dJKGa8f/jTF5ExSvPIZ/8CBI1h8V8UVh2lgyx9h
	A1aQm4Cbpti8TNWSnK5pxw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280636; x=1784367036; bh=a
	wl4c3AF4FjF/O1HNQPgGsIGmb7wjykNrBLMBgNgOjk=; b=oM9dFCi07oweN6xma
	fTSFwCc0+LAmidlMn75OrHGTFEaLrKQ1fsrNjKINXS5HZtM9tsk+S7Tqc9G9Eu2W
	yAvub7jDw+Uzpi5J7i+645QzRvgpYGith+PZlWye4rVaTBfYDs/78cfbAbJKM49M
	Th79UbothyhaNn6sIIrJ+15nmhcyIZk7YPjQBTO2xKPv6z8Xm0MJdNRGPK14xPyu
	4OnEhtUnHpqr12pdF37Xck/U/QFTXbpkRQTwaZIv2dejEM6u9whJ+9noHcmcUXRv
	GioutmKyhz+rwtFEHIyjChz8Pqpo7L7A9wSE4rCt+gGMlkXs0ogIh+HYcoO2U3lM
	YxYsA==
X-ME-Sender: <xms:PPZZasYbk6iaiqY4S7zHO6xB20LFTojoyXciDZ93Y2zf2vZDm9vi9g>
    <xme:PPZZarH4jzfLEyEdnhxpYZBqZRNx6RxaH4Bw_XKzxgnln05yN7gS14T_jEBBSle_7
    1xS8fngGJzOs-4XVtqzvokD-wYB3eRAHjLdWG2HUiIkRuQUZi8>
X-ME-Received: <xmr:PPZZagxEqwtSx7qLGSN-zrzysYVBGZINF9hwq2VF53TKH-ZZ5tgkgjIdn1hPYib-lCbqfHGRi-zP0oc7ucAtyXtVlmeQLtM>
X-ME-Proxy-Cause: dmFkZTEApqFO5jAKqrP3EdbU0Ae0MCQnQFfvSrW+r84mL3qL2UFfbuf83R37o+6oMtcUaH
    6DPJoG+34uUdqXbvR7Bw2l/P4dHaUP7HQXwsVpft7xVFNPuQCF7CPPRrJ8RbY/S97ZLP41
    U7XX1t/FfVPe+wX4TXpm1uyeb7KPzLLiiaQZAxoL0T352PWKJdXBYkCUMqwJ+Qc6GUYgZ3
    Uoo8xLxf76by20kMmFLftmzj5U0bznLrEBN2m623yRBHfn2OKPGMWK6sTxb/HqvCRKz8H9
    PuQ4+q7R9RbgvgWOq6XwvxxK5Vgvb3Gcdtw7XfnM+DdDvQvzx8yPyLi9NGYtfL0WuGqtKg
    ZRcKU5ag9n6X6MJz79QGOyqwzFuguEYxa+DpCorhFrEE3TisxjOrJ5kT9QdOMG1KbG50EV
    qPap/RumcF2xART84I24vVn9vRdwkCu5DebZu1uV0MQPW7AXxWjgswLo5CvGheawDlJ1NW
    4ufmnUk4/pCQid7JIunavCp6BlgHh+SFHjxL8XTycx3yrTmaMW1xVktVLAkQB0zWxhGGlC
    9LsdcgC68ctuSBJoAYUQQiwjn113lYI5Hv8UR8KOHxqvysZ9V23DKuhvqh7jKWzm62Q4y1
    7Su2lgkBm9x+Nc7/HnMyQ3XWu2yCsWXgMj5QStnnvy4HQ7DAYNPYW8C1a5mg
X-ME-Proxy: <xmx:PPZZatkwDN7EGf1V9hUcmiMSkKs0J6r0WFj3A3EcRqtvzXLkK9is1g>
    <xmx:PPZZapmRlRv8Nn9uFSseLrvFl7fd7YxRVNRwd3OOkRuOja2E7FbZzA>
    <xmx:PPZZavySupVSWvkWVealZDj4GgVs4zGByH49QRBihyX4oL08AEVdrA>
    <xmx:PPZZaupz13YB4m297dzxfSn784qVdE5dlqWKWQRhLGwfUBtU2AKDgA>
    <xmx:PPZZal4gAzFFWtzx49WkLEBIDuhqgTkHja8ImRxlrahii8nIsky_V3Ls>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:34 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 05/18] nfsd: move fh_want_write() after preamble in nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:27:53 +1000
Message-ID: <20260717093001.1972119-6-neilb@ownmail.net>
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

As part of separating the nfsd-specific code from the VFS interaction
code in nfsd4_create_file(), move fh_want_write() to just before we need
it.

Consequently errors in the "if" statement that this code is moved over
can now be returned immediately rather than needing to "goto out".

Also restructure that "if" statement to only test is_create_with_attrs()
once.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6e02976484d9..d5c5f440481e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -297,22 +297,18 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dput(child);
 	}
 
-	host_err = fh_want_write(fhp);
-	if (host_err)
-		return nfserrno(host_err);
-
-	if (open->op_acl) {
+	if (!is_create_with_attrs(open)) {
+		/* No attrs to check */
+	} else if (open->op_acl) {
 		if (open->op_dpacl || open->op_pacl) {
-			status = nfserr_inval;
-			goto out;
+			/* Cannot specify both NFSv4 and Posix ACLs */
+			return nfserr_inval;
 		}
-		if (is_create_with_attrs(open)) {
-			status = nfsd4_acl_to_attr(NF4REG, open->op_acl,
+		status = nfsd4_acl_to_attr(NF4REG, open->op_acl,
 						   &attrs);
-			if (status)
-				goto out;
-		}
-	} else if (is_create_with_attrs(open)) {
+		if (status)
+			return status;
+	} else {
 		/* The dpacl and pacl will get released by nfsd_attrs_free(). */
 		attrs.na_dpacl = open->op_dpacl;
 		attrs.na_pacl = open->op_pacl;
@@ -320,6 +316,12 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_pacl = NULL;
 	}
 
+	host_err = fh_want_write(fhp);
+	if (host_err) {
+		status = nfserrno(host_err);
+		goto out_free;
+	}
+
 	child = start_creating(&nop_mnt_idmap, parent,
 			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
 	if (IS_ERR(child)) {
@@ -436,8 +438,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 out:
 	end_creating(child);
-	nfsd_attrs_free(&attrs);
 	fh_drop_write(fhp);
+out_free:
+	nfsd_attrs_free(&attrs);
 	return status;
 }
 
-- 
2.50.0.107.gf914562f5916.dirty

