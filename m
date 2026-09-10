Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE15725F7A9;
	Thu, 10 Sep 2026 00:30:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000211; cv=none; b=G9Ex4V1zqgICytniBdWTRC0Nbc3+vNkeT7g5Nkm0zz5R5TlqBFf+lO8E4Ixn7ZRWfxBoKB8MQriduM8iAgPw+XE2uoHVkAnkNVK9Lgya/WsU4UQF/sTTiVAh2QMDf1Ckl5KwHjbBAKKS4sVhO2jqLykV4EUjg433CvtkNTswo3o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000211; c=relaxed/simple;
	bh=zdkQKSyd0kovnMaP0eMA1slZLU4vHeG2b16aLUm3Vr4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LkXusN30lIk2FJjH2hI6oubvixt56PIbopOM2hBmTwkD4uO17/VzKwfRrL+l8i4ZgMWksvRn4k0d/v4iOAC797wIvO0b0JfGXpjy8RKnJrzMUqWxXzLnZ4SjKRkBXiB9TC6pnd0403uuEBZmXFJzuGXKylEVZghgFZGLAXX+vbg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ea52vt3S; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=l0lQV1Ij; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ea52vt3S";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="l0lQV1Ij"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfout.stl.internal (Postfix) with ESMTP id C60031D000AC;
	Wed,  9 Sep 2026 20:30:08 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Wed, 09 Sep 2026 20:30:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000208;
	 x=1789086608; bh=O5AQGENYa5LEnebPXCtFAydy9fJkCthU+mbJWDwHxic=; b=
	ea52vt3SFSEFPqeSwsL43kdU2qBk04woNUvXiPp1/ov5xQA4DyqH8iI9+QLwp54f
	GvLZMW3f2//ax8Ayogn/0e2PPeNFrUWt3ioKg3m+p7JAsvHJd+hlSlkFPuxf7OFK
	XqR1I/pTySIgWa2TQX+vGPZI+a3c3Kd2wDiEu3LYPXUEEBeYgqIrvRS+FGIdxX5X
	SP7wiTlybZM/I4paHklLkXqrfGcUpZPZ57cVm4vBsuXxeTTdr56eXNTczxBXJDfV
	eQQzXGG+IfSjAmULEoHFWpErc61a9NiixSB6mMsdJdLpH+uT1uywZs1cOT//kU4V
	cTmnxB/52U6104IpL0S22A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000208; x=1789086608; bh=O
	5AQGENYa5LEnebPXCtFAydy9fJkCthU+mbJWDwHxic=; b=l0lQV1Ij536TxJc+D
	LLdKjTIpNtrIt3+KBwaDhqxt/1DRJlyPl6UO7jGra8ho5pfsJRrYJT2kZOdFa5Ji
	z/awbVAQLOJ+VgUm75yPrLRWl9KJQg39K2ay7bCnqJiWHzIec7N2qYKRVmDkAicU
	amwJrpsQWPdc5798mmWoUXZij8lV4aWjgcg9W96feWDO0XqP4sM7CCsYtHgrunfg
	jSAVNbH8E9tIissm1mwQLZhcW/jv//Db9lW5qT3jXOhsPXQiD2JpEZYor+jnywty
	WzglkrTuLQN7SV9mhC4sl3HkMGMOm4peJTiptzFa9w3Xz53MoY1+tWNndaa01fMx
	FI5fw==
X-ME-Sender: <xms:EPqharvyZATul-V65XXB0y7LF0FvNLxkO4hNV9JS4TPePbRAfbXkDA>
    <xme:EPqhautfQX6n5tug0uYWaEecwhgK7DSl6xgY7p2p4NAdFUaCS3E4wych5Z2LN2TRT
    GzhPTW7iWDuZZ1nh29BhI9g8bVexRggbFZC94AxLqnzwwFT2SQ>
X-ME-Received: <xmr:EPqhahDV6p_BPnXbTzNSeSzXiukDqe6LDgRwn9C-PQ8qHP1XHutiTyGRrzIL0KuKgH2m6xt4h8nhwnqAMjzDtAjaiaQtZRY>
X-ME-Proxy-Cause: dmFkZTG2ZuPEN34R+utP3ESxb9Vdcejdvq1qn0GN2MsSCwESAHSyvwppLG2Yu+T030L2Os
    C8wXU3PxCkVzFW4dp/42EieFv6R0T70CdXif1RWlK2b+xBeP4D18DTQhJEghKWlRjrKyUb
    GdlNnxTgZ+lDp+o1Kz2BsylhbrNhfAZgPcMxHnaH8xn6D8vPLCsNPSG5ApS8ATGgHc/HWj
    wRdbCBCalK8qL4He0aXC4Lyqu1cVz74DhCxPFDqYj/33GFHQ6XxHNgTamDOpUZSq1ebJcO
    0bZ7djSj1c7whFp8Heq+QUaxe+WPB/b+6uiBLPfuZqukj1/5KZnVgOb+3nKerXH+iKGBkd
    hB8//2uopdyi5zK+/zviyfqGO1hTHUsgLzew25Q7Z1C9CCrcP8FBEjp7sOMcn82EhA5ooF
    hXWnkvzD/hqpPnzeSLhHnjD36BOLkMyFWAzcr66yOn1hq/8ohbKc6yOmgMDD4OeFGqU9KN
    dKW12NzIstT87XfU8XK7PyB51T3ZE5nLWXAFOg8KSW2Gpt0JrLPexGWXqSxCZ+YuEWj4RX
    NQlb69gTmn9DnxDD7W2t0+s/Nfnxz6uOlLN+4ISHdx59DSTuPUKLpFzoUqcn1HROeQlRJs
    1K79l5A2yvsnp23mBoTTpfF0LtJFC5VQoitXv15rgaYoDd26Yo3H+IugwdYw
X-ME-Proxy: <xmx:EPqhagOG2Osj2G_j5LrHvIt6J5xRl3JSuPFjSVABh5K1C3rEGqQC7g>
    <xmx:EPqhaqyVEGB1vjgegTnKgbpRoAxUoEdG4oUmK-YklNlYeZFwZj8fcg>
    <xmx:EPqhagWiZULtGbuyoVf3aMV3gmpdOp0-t0igxKnUGo-3YwW6-eoqAQ>
    <xmx:EPqhasPVTLsxhXvoaY4i3xZRUrz5k_bbFBwWsrTxrZ05nq3aWxVcHQ>
    <xmx:EPqhaobtki2mh37AWWtJdTwz5Nyvoa6OUSaEef6XR7p-Oihw5RtgbyS7>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:30:06 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry in path.dentry.
Date: Thu, 10 Sep 2026 10:20:50 +1000
Message-ID: <20260910002934.192979-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260910002934.192979-1-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

The caller - nfsd - needs to know the type of object found when a
non-regular file was found to exist.  This is most easily done
by passing back the dentry.

So change calling pattern so that the path (now called "path") contains
the parent dentry on entry and the child dentry on exit.
vfs_lookup_open() will dput() the parent and caller must dput() the
child.

If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
dentry to the dcache we return %NULL in %path->dentry.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0c787363b101..30ccc0c2f02f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 
 /**
  * vfs_lookup_open - open and possibly create a regular file
- * @parent: directory to contain file
+ * @path: directory to contain file
  * @last: final component of file name
  * @open_flag: O_flags
  * @mode: initial permissions for file
@@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
  * If the fs object found is not a regular file then -EFTYPE is
  * returned.
  *
+ * @path is updated to contain the dentry that was found if possible.
+ * In particular, if -EFTYPE is returned, then @path.dentry will be the
+ * object that is not a regular file, or %NULL.
+ * Consequently the caller must be prepared for @path.dentry to be
+ * dput(), an it must dput() whatever is in @path.dentry after the call.
+ *
  * Returns: the opened struct file, or an error.
  */
-struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
+struct file *vfs_lookup_open(struct path *path, struct qstr *last,
 			     int open_flag, umode_t mode)
 {
 	struct file *file __free(fput) = NULL;
@@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	mode |= S_IFREG;
 	open_flag |= __O_REGULAR;
 
-	error = lookup_noperm_common(last, parent->dentry);
+	error = lookup_noperm_common(last, path->dentry);
 	if (error)
 		return ERR_PTR(error);
 
@@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	if (IS_ERR(file))
 		return file;
 
-	nd.path = *parent;
+	nd.path = *path;
 	nd.last = *last;
 	nd.flags = LOOKUP_OPEN;
 	if (open_flag & O_CREAT) {
@@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	op.mode = mode;
 	dentry = lookup_open(&nd, file, &op);
 
-	if (IS_ERR(dentry))
+	if (IS_ERR(dentry)) {
+		if (dentry == -EFTYPE) {
+			/* Try to determine what was found */
+			struct dentry *child = d_lookup(path->dentry, &nd.last);
+			dput(path->dentry);
+			path->dentry = child;
+			WARN_ON_ONCE(child && d_is_reg(child));
+		}
 		return ERR_CAST(dentry);
-
+	}
+	dput(path->dentry);
+	path->dentry = dentry;
 	if (d_really_is_negative(dentry)) {
 		error = -ENOENT;
 	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
@@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	} else if (!d_is_reg(dentry)) {
 		error = -EFTYPE;
 	} else if (!(file->f_mode & FMODE_OPENED)) {
-		nd.path.dentry = dentry;
-		error = vfs_open(&nd.path, file);
+		error = vfs_open(path, file);
 	}
-	dput(dentry);
 
 	if (error)
 		return ERR_PTR(error);
-- 
2.50.0.107.gf914562f5916.dirty

