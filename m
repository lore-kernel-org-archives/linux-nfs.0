Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78A262D1913;
	Tue, 29 Sep 2026 02:26:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648817; cv=none; b=pnSRUc8iZcA4S38l0412uNGWtvhUUEXQ2XzHQ/MDFqn9y2dw1zhPu3HcqAA10Yfch4WQ1YA0uWRDwi9uEWVtW1SU5HxlOJ3uJ8OGJH77pnEAjJW3QOFVJNKiHk+aRM2GtkAZZ+T4fUjuqznlY79UkHfnrCFNacRCIYPzMcKsW8s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648817; c=relaxed/simple;
	bh=/ZoaH+vOkUglJ8Z3lzEiYwSjjMPFBJyuhIzSTt2tARo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NggueTStPnRb1w2ta+tSebZ7iPdlqOwZ7JOxa3XowIxroOPebZ5COyBpOQNnjEHIG4mbEE9opKTuGCkzluB5ec7SsRUSPs/BqUsAjS0W8DMrBgZLaCyfNIlD1vjmCa7jo/K95YcElEAQm3llHD4Zj93VRiIkF3kelYMGsBJ6Vec=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=l+5UGnsf; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=CBUv9ERU; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="l+5UGnsf";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CBUv9ERU"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 92C5F1D0010E;
	Mon, 28 Sep 2026 22:26:55 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Mon, 28 Sep 2026 22:26:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648815;
	 x=1790735215; bh=0tWbFhV8Hhf9sFrHyq38w4c/gUVvhIW+x+RDW64Ml54=; b=
	l+5UGnsf+7lxQkUD7OTmF/3kHeRN5hQF80C3yTZKd4wyE4dzHYLrUUUAxhE4GE3G
	5ptuYxjwvAMt5REJtQ7MxgHiFTVT8igAVUmjlKN/LZ5mWrZISfNGIsupfPw80X8y
	BuVvrsWO54gEj4S3ptB99spqKCdxrlbb4gyO2Kt7ITUXrim+5XlUdWr1RY3PUAM2
	mPXwieidtDopuPA6il/ft2vsVnntKqcRO5sFu8XM5RE2nq0LTl475IaohOs0vZzq
	aSfU6ScpVK7DdpBFlQOvnMKo7QhLI64Q9/tD09JJZx3KtrefQa67ciAqn4+BuBRJ
	l/iYzq/Be58lhreTGFEg+A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648815; x=1790735215; bh=0
	tWbFhV8Hhf9sFrHyq38w4c/gUVvhIW+x+RDW64Ml54=; b=CBUv9ERUkZtwtUe47
	rfbNRUy3w198srJ0P3C4CduM18HWZIGvHUkFZCM5XAaTqQguuyMZqbP02IOjZ4rc
	eLtxDzZemA/EUJcQI2ntd/jhpRG7/b68lFOwAyIiYM8kENfSJYeTHMuGWzsFaCcc
	5iPOZDBGPu1ewHVX5PddPNiRttLCNf5nNb1vNYR4L8iWuJLQCG63oVxUkwowoN+1
	w/sGLB14V7QniHFBmETmrlBqoUhSM6DzaHw4YKJLG4LRDo5xM/hnQxTzAYbIZq7Q
	2ShvALMUWZnw/y0dU+oUW1ExsuuV7fSDDmNfayQpx3hPGMt70vxxwjVxK3aJs4iN
	IFK9w==
X-ME-Sender: <xms:7yG7aujubRQ6eMVaOS6GcKebiPR4UiNL0qkLYNRijDVagyoBN2cY_Q>
    <xme:7yG7aiEqyBX1mVfqpzvGU_GsjMmG_T_g_I2EI9aKA-Mij1_OXtca53NfkMhuNX_LE
    TaTTP-5FtrkCAw1c4Hx_0tGKSBaehkzKOfKzgtKyGzK36RjtUY>
X-ME-Received: <xmr:7yG7agtunezgG8FF2YsOISD2znrTIW1A8135x7FpTTex1qFp7L6mfocS5zW8BO0pjcK_ccdvzrBv6VJP46WmsHpt3kpqcJY>
X-ME-Proxy-Cause: dmFkZTE+bsogD40d2GxBgpnYeHp/aup6WVRLzjdWBHHPlKBynVrzNWh8QEoADNOHP+FK+Z
    Vgqz5hC90Yp6jn9MDfo9aRFsYr2vMRz0xkNM8qRCjZwAXlP78t6WYYtP5SMZJn0d0uhQfe
    gFgWB4/7khWSm3cmBSPuGM0BFEi9gykQl8qvlo22NeQC6/uQwRqZOUFbgyYVOtcf7rUASX
    7Kaqhw7pe+zb3JDOIQ8+ig3BBnwuM5Xo+83Pt9mtsfvsMhL3F500p85F5BLBBgJRLOp1EP
    +Hcng1Jy3IJ4SZQiTS20OSaSrrdwyfitMh3HWtIXcSjsNttSH1A8upFBeYFTHElHPf89Jw
    XDBRlJJNKOYiwWn+AVPSceEeyuwa7uwyuL8NFtRdz4VpBaulKCogSlZUZGsIgCAfdVH4g6
    GGMA61AOWk0g90cW0JkbDT3xF0H6FJtkmc9yVeHL+Zp6e4+pC1Z6y/SYOsuZ0PZFgy0Vp8
    o0qfroyYmv2d1R+yU78gZ03PfIvZV9N5nV91e1XrHzwCJpBhoN+kedW/hj+9XsPOqLCOPY
    pRh1yiJ9colessSwEB8DeF9JvP1wWpa8N+3q0GlmIKNbax0D6yKxX9G1m5BjZ4uYuwzijJ
    l0/k555j15U1xwNs4j7kdoL1FZhmOHDcKGJwQ0Eos4Y1fjN2oeGs3Ltl+2iA
X-ME-Proxy: <xmx:7yG7ajc0DAXZJmRwRjMzYh5A7GHaww-SfXfhvSfcVcbgoiiZpN6WYg>
    <xmx:7yG7amkOkIVeC0IUamOYE6z4vKaoq0pXQDZvx_QOHBebbQfaV1Pckg>
    <xmx:7yG7amCJhmTElWlroR2qMzvBc7LR1Kfj9i8gu0-BLslQdjccZI6FKw>
    <xmx:7yG7agOArxrwVf4floGehUJCN8aM1xYunQW1kN9RSrScM1VpachFAw>
    <xmx:7yG7ao5T3RERhJxQZIhPuK_1AqxYuAu_xtXHVK2IBNwbMShppywwg07O>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:52 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 5/9] nfs: don't d_drop() before d_splice_alias()
Date: Tue, 29 Sep 2026 12:21:15 +1000
Message-ID: <20260929022547.1428036-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfs_add_or_obtain() is used, often via nfs_instantiate(), to attach a
newly created inode to the appropriate dentry - or to provide an
alternate dentry.
It has to drop the dentry first, which is problematic for proposed
locking changes.

As d_splice_alias() now works with hashed dentries, the d_drop() is no
longer needed.

However we still d_drop() on error as the status of the name is
uncertain.

_nfs4_open_and_get_state() is only used for files so we should be able to
use d_instantiate().  However as that depends on the server for
correctness, it is safer to stay with the current code pattern and use
d_splice_alias() there too.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c      | 3 +--
 fs/nfs/nfs4proc.c | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b7cb14310bcf..a0d22445dd06 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2346,8 +2346,6 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	struct dentry *d;
 	int error;
 
-	d_drop(dentry);
-
 	if (fhandle->size == 0) {
 		error = NFS_PROTO(dir)->lookup(dir, dentry, &dentry->d_name,
 					       fhandle, fattr);
@@ -2368,6 +2366,7 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	dput(parent);
 	return d;
 out_error:
+	d_drop(dentry);
 	d = ERR_PTR(error);
 	goto out;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..8f07f34f899e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3113,7 +3113,6 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	nfs_set_verifier(dentry, dir_verifier);
 	if (d_really_is_negative(dentry)) {
 		struct dentry *alias;
-		d_drop(dentry);
 		alias = d_splice_alias(igrab(state->inode), dentry);
 		/* d_splice_alias() can't fail here - it's a non-directory */
 		if (alias) {
-- 
2.50.0.107.gf914562f5916.dirty

