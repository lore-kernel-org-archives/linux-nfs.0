Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185733;
	b=c0tqZBRQV4S32k3mlGqvng1glC4gHOlLcmXX6r8pxkHuYk7v5nVVKuKBHNnKeRMj+2jd
	 ikyVcknlstd+zaudtMdUS1lqZEj6hfVYANeWk1K2M6sY5hqBvOXrPHbLLMZtqO/SvfQ4E
	 BIBElx8d3x3OglLj0oq2NKFUCl18GxTKFebyzE3xPnqpMz0IFL9p09tfQfCxrJVXMGCcv
	 xnnNXls3ezyS2nhPms9xkEGxoZYJQ7WpdqnVZRLLnD2/rudiINDXLW86rOdFP/TxBG4JF
	 R3RFKhWQYt46qRHzKh1p44KYmj8aqSI+P0lwm9MJU/6GEJ9fF/Z+NGQdIinktjLS7Uw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185733;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=2Jg0SQ1LLJigYLVMajqtztlXWwnnOYvqXRTT9b6/JlM=;
	b=QduakR0lr99mKJgYZcpCRgKxCBNYn0bhT26Bsz5Zytbl8HzGmsH9VfgCVQYOFqEifmZc
	 RvdGr3YFpNHm6FmOJx1KWCQvW8oguYPS7lM3IAqKz0io/y/XPXyP5wawm3zz/PQ6Q2EUj
	 6AUWHwkBnVA9Iz6+BBEzF8z/D+u++nYSGIwfs6aW+5IKKduN+HOrhTzwciTS8tkmS42ZW
	 5tjlFBM+4rH+VP2UPeFaAvB/QsjQ499AgHLVQOclYi20m5+4nx/XdL1qEFWcqj9/KwMw6
	 z0+iNJeNLK7td0YGZgd967pjumRZOnrQMhsoL06nMe+8Z8KmPD7RiJgdQoU49blEZPA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=THjysqMW;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=PYtN8ENg;
	arc=none smtp.remote-ip=202.12.124.152
Received: from fhigh-b1-smtp.messagingengine.com (fhigh-b1-smtp.messagingengine.com [202.12.124.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 036AB606A322
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 036AB606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=THjysqMW;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=PYtN8ENg
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 471F47A0074
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:32 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Sun, 08 Nov 2026 19:55:32 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185732;
	 x=1794272132; bh=2Jg0SQ1LLJigYLVMajqtztlXWwnnOYvqXRTT9b6/JlM=; b=
	THjysqMWD6TkJITcf4P19u7DFT7dRsEO9i8MG0w/uNkcrMuX2ZFSKUlX8JPkcJ9z
	3Rhiyw4ERKNvW/kK5JfU+CwTlrISrIPxWMaRfrr0dquKlVW9vYHb753r1R2WPOpr
	kdcc7uh5KsuWlrpYHGQ/2lyIERwuKJvrLtucnhjFvEUtTDuQOC9QIGj3K89gMT76
	/Exv2zBbYYRAiC3rkNTpnAYetHxWTmzqA5F7WT6j6XUBLegagZlzuh80KdhQJguR
	ieP9QZBCjyR7L5uN+yy+bX9fZocZ/xFrdZeCOyusY4h4BDGcxNOzHhuXLWNWrCXP
	cDTp6qgAem223dO6SB+cGA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185732; x=1794272132; bh=2
	Jg0SQ1LLJigYLVMajqtztlXWwnnOYvqXRTT9b6/JlM=; b=PYtN8ENgqNfR6fsSv
	fpWShC7N676QRwie5aEWGFDJQm/lZKJnehaijBgyCfN1GOR8oOvyyv0xqqw4TGoC
	CnJ/O+Ids4bzmVoj9MvOqFAucmFbShqJrWwFuGzIjC8fSMLLycTW+cqfa7fqekYI
	ORCCsJl017Asp0vynETH+KKb6phldIQYRz4botVcNww5aPNW/ycWQeWRbF3hGRPz
	Zssdo4XBBUJYoqk+QgwE5IeAqweM4Dp1Jo8Z21ASUHoezitNU1Tan/Encgr8jyOz
	p/p37i9kvQHaTmpZWrUC85hHKk1lVMdMqCv+pmjom57o6AyuiKtzqjAEJMLw4YE+
	aLjUg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185732; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:hOMblo/KA8EP40o6FCVtaZS73rA93J7ltGAKOagdA423hNt
	/T/isxJkzCtstWAuO0ZIC56D1gBuvpy4LAaYGdN6FCzU6iIwrIR9jHYVP7pTA7BX
	uFRXOQga/BFFPVZ1UqX4H3bojZtXx9eC3fowbtmoTd4lOxBusAxC8lCieyDOcQcF
	hyyVUlylNe/gA+oD6DRDcV0Zzw753zAFanVhURghR1Fpa4RhRo+0zvSO4mRJmr7Q
	v8Y7hTgW9mCPtanDSVo3dPxC3jB+oI2iFOEYiqle3qR5tlWLIctGOYShkw6pE62c
	8NN5pkNhujL4FaS2zUOf0oONrN06tlW3rolTQaQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:4oOOTyGhc34avlbk+JJO+zq3YshTO4SIJSdtJ660iyY=:nfP2LxHkP2vCsnI2dBdHNox3wY+hOGbe/FxaCbkGnz8=;
X-ME-Sender: <xms:BBrxauPY9P5nNIAz1Dpu5MrIJjl6WOZiJS46OrXkbUzQCPBacTFiNQ>
    <xme:BBrxaj0xjW8pcbD3pgg_ie0HiG5ogxOWY9dpxNkDImIrrbtKOVBk205tRSCCmhSYJ
    pX6v6DFceWSepraJ69D_uA9UOv1q9wOofDJycxlDWAYEHiptw>
X-ME-Received: <xmr:BBrxatlXqUZ-AVmX0ToYCURslJ3AB1qU6F8m-Usc4cbL3hThwh3zzF1EYwPo8gCSzZHxb0WPUetLhsLVw8dEQGZOxTPV7XM>
X-ME-Proxy-Cause: dmFkZTEPgGX5rX4Ucy9bGCLV0zpjHv/7YUdO1BRO67uZ1TFyuKYxCDG+4cdOWOhtgfjVze
    PVutz9cU629FCOHBFtt+de+rIg9CTtjPxcMAwoe89DxXO7xZ3r6p8v2MFYVVkYRHXDz9Mh
    gCqeLaxurlcJDCrh2IxfeOOcNpJi0oApyeWdeKNVmshFa8D5ijJLsAPSLpBjZTF8VS50oQ
    7YX9Mp9zFmAY/0AQPNMv7wQaDLZNFeJjTyFOACwXaYbK/XeBnGqeE9LlOcxaVXym2HhfGv
    R642p73EynQMSVnPBS0569H6Gxw1QWkN15W/8hF5kTbO3qt/StZeLJIrydtR7wkXRjnNlQ
    AzC5ci5ydtcoDZeZZWpURLfRj9k/qidEMmrFN7gUMdQ0miGkP7fIJh3G4w117UfvnHlQfq
    aWo6hK6KOlAQd2gnCIDNwkgUggjngIgx6CX9fFfZRxbSHvjSTPYOTjNrZuD8K1V2PY+2zU
    TLL0WbZb0gwYI9Ktrddz6JDrmG+3nKOmLUkNRsGrjXxikIpG2l0uUjQe+UBDfEiHg0UY4X
    X+edkpWAc4dpIcg8IOFs9NQgiyLrQYPS455qqcujErMyVRaDeDrO546voBTH0+5zeX6VPa
    o0S1bbIfNGx3KewNvzW2QBbYda7fbh4nYWxF+E7uyzj6eTbfhc1SEATkbyeg
X-ME-Proxy: <xmx:BBrxaqWHtOpDWPQpdgbAPoBRuhX62zzin3FBiH-YjW1DFusjVCT-HQ>
    <xmx:BBrxaju87XfSsqkzRlkeetcMfANqpCspMJI--NrZAOeHbmhIf70VsQ>
    <xmx:BBrxataAtlvwDz2Vl-SkOJ5Z0LDF_V7hdCbdIOvJm9xMs6XRMBNzxA>
    <xmx:BBrxaiVn9rOZWQxF8HC_v-K9uBeHGsZk4bJew-b2pmvQ7v61SN6XdA>
    <xmx:BBrxapgz2dyqcvfiFH6d73xZXZjd0oWbX7cRVhWexmrpr8rGJ5mmyIC1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:30 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 3/8] nfs: use d_splice_alias() in nfs_link()
Date: Mon,  9 Nov 2026 11:52:32 +1100
Message-ID: <20261109005504.1804605-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261109005504.1804605-1-neilb@ownmail.net>
References: <20261109005504.1804605-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
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
index de8d0be9a8a6..2b015a5c1dd5 100644
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
@@ -2709,14 +2712,15 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
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

