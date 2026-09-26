Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC956547073;
	Sat, 26 Sep 2026 00:11:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381476; cv=none; b=TaO2sJ8bEPxgQ/O7to3lUZm/CThEbf6ghL1QCNcT5G5Js/6YTzmRzEIxPkLT1SJu5dGWnVR3I/w7/Lar7PYFr4z8ObE1ij/0Wvg5Ozzy3Sg8bqUI5au/+UNBsVpOECYdim9NFH2CoTFBQtueLdWN9OHBKImAU86MXl20oUD9WkY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381476; c=relaxed/simple;
	bh=HIF0eb1hm/XIljk3b2DI7nSzcYH4Dap2a0e6M83n0sA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kOn199qdmNqIzuL3YFPLZivwEJDl1bBHmmT5yZxxmda6UJ1hC2Ds23P+f1b4/X4lczNMk+cv52rYjDc4ZiEq1YhaN5Khz5UeGtQGcVYx9B/aXjSTeh4AhSKLPH4O72ys1vEu5tFDGS8CSLUK5CSLVMTFxTanyiLI3PUoEUy7gLI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=X/F0lvxJ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UVtOhZki; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="X/F0lvxJ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UVtOhZki"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfout.stl.internal (Postfix) with ESMTP id 072E81D000C5;
	Fri, 25 Sep 2026 20:11:14 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-09.internal (MEProxy); Fri, 25 Sep 2026 20:11:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381473;
	 x=1790467873; bh=R/9dzSO/o/WT4bh5yjjigqdfDVfT+cwsjfHLmYrFerQ=; b=
	X/F0lvxJ70Z3C8dlkCCI3oiLZkTyXUewj+eZe269M2dPMVPLZXQmOt44bAByl3uH
	x9b3Xc6hykzBzsfT4Kbe+mXKLpAAJXjDtK1ML4FZ6k1cKNvgZbHXEQjYovuzMuZC
	lV1EQWCm3Wl5AwDSsJjnunkOjZk2R3p4wMshXqDMXB29BiwRmcJiwsXpAa6+vwqe
	iCqTgKtPx4Z3cS97Hhagxg/gpJdMXxaQygRwcvUyMWy/RFlosFXKiaGdb0iKaV56
	lXK+wPaxPGupXsl+nONiNpI31T9zMqnXrdgmFoU7tAJ6mynZQrm3iwg4jotv6/Dd
	3SyLoNnjhqCEji+OIT6HHA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381473; x=1790467873; bh=R
	/9dzSO/o/WT4bh5yjjigqdfDVfT+cwsjfHLmYrFerQ=; b=UVtOhZkiPlXxPRzRD
	lFUe05WlWKN5oXP6ps6Jz5Bk/r/YDb1urmy0XIZCh8TZnM19wVN8qDZYTUZZ+PLf
	1gdPqrGpXBv9A7f0GqulezVjrEeW5C2mOrnoL1g61zt+4HH+HUC5bLdnU10LKqdk
	9CUzFBpSRwbylqfN1uEhwUdlV+b3dWv8t5kRn5zG84/R80WLW2/DRxCiGsnb54vY
	ie3tn8rXrNZU/LG7cClOq5gGJaSKkDScQ61tiZsoBK8euAK/VLLmZyWPuwxFf+rz
	Of+vwQ+itQ2T5FYKgNRCyPuUzi3PbG5HgHgwMlSfCyuNcE4eRcoIFrY24+ZR+IKf
	f+8Pg==
X-ME-Sender: <xms:oQ23akguZFUtjbFEfpidjAVKLDxklTeGQOkekiXNShZPHEVg3rFZrA>
    <xme:oQ23avlEUKouSuIHdAw45pTlbLcrtxjcmx_iJ968v2v8S9RTpL-XLHj2uW1qKe9vB
    d8Kxb4RtWZ5gAJ6Mk9GNZhrD4w0AXo7CjRjiDA2eGJpadKltBo>
X-ME-Received: <xmr:oQ23avvozqyejQ8gMwvrw6GIbp80-mNwSixrRLcwzG9k4bTUEu5Mf3WcrlWypMU7DFtMexZS-oL8NfM8Eun_-FO3M6ygCUI>
X-ME-Proxy-Cause: dmFkZTFAO/Qx17dcHFT5ww4Qk9PU1QcSwvc3USneMF4ZN96aB2KTPr36PDKeziqN5cNiSv
    mLFQhNjk5FDW8Bqt1p8i3h2lM5T/6Nh03c1t4b2sX08AHZpvZ/zeMuwfYLXNCWJ/VdxgZA
    t/kJnvW8Yg/3yAJubi6vzBJveA+95GTPATWr29QOJmV6OvPx1Sj3qP0Cvjdub7lcmrEtEP
    6q5n5GZ9z2eYkcsQfc2BKf92wyKDgBwUKtkeS0Bbssmf1/ceRs9V8vBzetuD78dgQxd27n
    IDdwl7J+GNkp/07h/XwHPE+j/aahItUSlJ1/czIIfSI1DqCYbdGnxUhR5r9ktTbhj8KnsN
    cJo047DvP8U+HJkVQNx5EzAtFB85vXLiJUikOOdH8kbFmeDrU5YvD2RUYmG3JWpFFG4mh0
    nHdUCnYgMAGNbNtulfBP0/HHgFSwKlBFiVnGImp8mncKRVBCcLEQQqZXh161+fM18gjrbA
    R00E+uwmgD9tOtmUO9K2NtJrnquahr/10nTZAkxkiIoJXM3qVZaW6OrGjeKqwPByG7flfK
    XryuMmbpMh8G90oudmkUEZWtLwUoPrwB+ucsuAoHu7nnRM2s50GJSh+ErXKxPLGB+MqHyL
    Mcsxz+/fYAViFPmRRXKsOdJ98kizl1tlb3iRwJZmubeF9W+WJsGtJcHOz+Dw
X-ME-Proxy: <xmx:oQ23alZqW_gl_KZf4gNmDDYDkmJT7k5Wz9Swqr1IDaLuPBobLarmdw>
    <xmx:oQ23anC6Pf1iaYcAjpxopwM83FYbO_ZzbvMxcGa-TN4uPgW5Fa6jxQ>
    <xmx:oQ23at-3qlkIP4ZLe94ilKl_MG4tWwx1KWF9aWNlfAzYyzSUW6cXqg>
    <xmx:oQ23ajSgfTvO0dk54Bnf7rNstRF0oUzpnbZd6R2VUbNULtAHbehmxA>
    <xmx:oQ23amZO6-AL5dFB8RmjqoNSTWIhweCGCWXlHDIYIXlnVSX03faO2PFD>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:11 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] nfs: use d_splice_alias() in nfs_link()
Date: Sat, 26 Sep 2026 10:01:21 +1000
Message-ID: <20260926001011.401824-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>
References: <20260926001011.401824-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

When filename_linkat() calls filename_create() which ultimately
calls ->lookup, the flags LOOKUP_CREATE|LOOKUP_EXCL are passed.
nfs_lookup() treats this as an exclusive create (which it is) and
skips the ->lookup, leaving the dentry unchanged.

Currently that means nfs_link() can get a hashed dentry (if the name was
already in the cache) or an unhashed dentry (if it wasn't). As none of
d_add(), d_instantiate(), d_splice_alias() could handle both of these,
nfs_link() calls d_drop() and then d_add().

Recent changes to d_splice_alias() mean that it *can* work with either
hashed or unhashed dentries.  Future changes to locking mean that it
will be unsafe to d_drop() a dentry while an operation (in this case
"link()") is still ongoing.

So change to use d_splice_alias(), and not to d_drop() until an error is
detected (as in that case was can't be sure what is actually on the server).

Also update the comment for nfs_is_exclusive_create() to note that
link(), mkdir(), mknod(), symlink() all appear as exclusive creates.
Those other than link() already used d_splice_alias() via
nfs_add_or_obtain().

Possibly nfs_is_exclusive_create() should return true even with NFSv2
when the request isn't an open (not LOOKUP_OPEN).

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 46e7fb610c7b..1a238c66fd34 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1570,6 +1570,9 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry,
 /*
  * Use intent information to check whether or not we're going to do
  * an O_EXCL create using this path component.
+ * Note that link(), mkdir(), mknod(), symlink() all appear as
+ * exclusive creation.  Regular file creation could be distinguished
+ * with LOOKUP_OPEN.
  */
 static int nfs_is_exclusive_create(struct inode *dir, unsigned int flags)
 {
@@ -2699,14 +2702,15 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry, dentry);
 
 	trace_nfs_link_enter(inode, dir, dentry);
-	d_drop(dentry);
 	if (S_ISREG(inode->i_mode))
 		nfs_sync_inode(inode);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
 	if (error == 0) {
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		ihold(inode);
-		d_add(dentry, inode);
+		d_splice_alias(inode, dentry);
+	} else {
+		d_drop(dentry);
 	}
 	trace_nfs_link_exit(inode, dir, dentry, error);
 	return error;
-- 
2.50.0.107.gf914562f5916.dirty

