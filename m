Received: from fout-a8-smtp.messagingengine.com (fout-a8-smtp.messagingengine.com [103.168.172.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B89535AC01;
	Mon, 27 Apr 2026 04:06:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777262811; cv=none; b=OEL3OW4pQ+AFMqZ7j0vWWkuvugKDK7Jvu8zw5dmiy/TRRgQPYalUgB051sSfHfVHFYQfTSi7HnYAkNzlbOyP0Nz+moU9L2bEr4GuMrkKcz4W/VTg2DFVMQrAt3wKxwXF7WngM2t4UI1JohJHNajnUTFun3gky5/ZabM5qJbxDPQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777262811; c=relaxed/simple;
	bh=Af17cpjWLrgjln+x15PYEXYO/pHIZybmrmOg/uu6FGs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sBrRPMvqElrXbc2NjWu3hdjW8K3mRTGVNq/v3GOtZvqRBAGdAEx4sT+/ivyt45riuPjgqXuE9cD3NDKYzT1BjsDnSEVCKdmn7sN/6v83AGUuqyVFU04xZ8kteu6akXx5/E317iJMtTCUE+dnRHBdEg4DOqbFGufcN1MO5gwLYBE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=QyxVJdxr; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=R23otq2G; arc=none smtp.client-ip=103.168.172.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="QyxVJdxr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="R23otq2G"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.phl.internal (Postfix) with ESMTP id 9575EEC03EF;
	Mon, 27 Apr 2026 00:06:46 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Mon, 27 Apr 2026 00:06:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1777262806;
	 x=1777349206; bh=2Sazp1M0TdInI6mi6hF1QSnGjDghjOgL8lkwZNivMpc=; b=
	QyxVJdxrsn4Mx6G6wXw6rxDv3RQ1d108vFjLoBBhBzmRVoBRDhicrmszPcqC6YGX
	Z4RefjOrpb/Q/mKPInuDuq69EPUbKhw3tL6esu01iwgQDBeqq2DHcnnU1Hye6DPP
	xOiy5IdfY+v390KztQH27yKqWEB19HwsFYZKhWXZOERV4jQAz9kXPg3TnzysgKVx
	cQ//yPP0wtQwjQ9SppgiaSSanfZ/ajaKz3HOrJCOB/5EHkGCWZZWUUc09Skvmkkn
	RL9BFumBZUSeGlwlOWBH5qP68xUw1yqpoDWC1IL0XIEBqURBtBQ8H+EWAsjv4GYw
	LPN/6vLgATtrVxXRZ+b7/Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1777262806; x=1777349206; bh=2
	Sazp1M0TdInI6mi6hF1QSnGjDghjOgL8lkwZNivMpc=; b=R23otq2GivT/UyOjd
	RB/ntwNtlOel3b0Jw6TgSOas1rVsPqF2uskubyAeYc9Xt3LUQ7RJQ+GNBEn3ysK+
	x11YzskK4/+fCGzPjqdNoc6N60KfuWnchJNhBXcoChSwzaH7vmiOYg3ngvPHN4+O
	ZU5OA1xm/aVzXKGUwtkkbnphhMWBIrfDY/6j0eyszOztAAwyMP3twaeoAWSieXo2
	jmje2AxG18mgh0ezk+lM3vLJHeUoq6Ai5UCul1Ue/mLmZM4lh2OjBSeiDnA/DgqY
	PjtBmF0+c8pAya+XibzxnnCUW5KiU8NsIcRAfG/yQCoGegMkbBdikwZufr67/LgH
	LK9kQ==
X-ME-Sender: <xms:1uDuad9oQN0trO6maR9wP2MTXaFEex0syKsz3Fenj8cMxh5TAvW55A>
    <xme:1uDuaeDKus8yFXYGX08ExGZnrNosvELDcyZgCBHzh70jgT7XJ4bS5Y6Y5mxrrI3U7
    14O4h6GkNZpX1jGS0hFch4LOVYjp86AxMpROSB0QIfJOLYh9g>
X-ME-Received: <xmr:1uDuacpDQ0Wutj7xEcJETa9tnITV98tzABJFBIbLqDu1f0-KzDGSye4pSDMPxRM5-8wqaxF83q72jhdtFA7t_RIxvvgNpYI>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejjeeikecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefhvfevufffkffojghfrhgggfestdekredtredttdenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    evveekffduueevhfeigefhgfdukedtleekjeeitdejudfgueekvdekffdvfedvudenucev
    lhhushhtvghrufhiiigvpedunecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgsse
    hofihnmhgrihhlrdhnvghtpdhnsggprhgtphhtthhopeduiedpmhhouggvpehsmhhtphho
    uhhtpdhrtghpthhtohepvhhirhhoseiivghnihhvrdhlihhnuhigrdhorhhgrdhukhdprh
    gtphhtthhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnhgvlhdrohhrghdp
    rhgtphhtthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorh
    hgpdhrtghpthhtoheplhhinhhugidqvghfihesvhhgvghrrdhkvghrnhgvlhdrohhrghdp
    rhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghpthhtohepjhgrtg
    hksehsuhhsvgdrtgiipdhrtghpthhtohepjhhksehoiihlrggsshdrohhrgh
X-ME-Proxy: <xmx:1uDuaekXCOCGs5COxQFvRDm6A7x3G116hfDewoymm7bz_QEBUb7R7w>
    <xmx:1uDuaXUgm4Ta-qYnGkdMo4MC4NB4W0uSfbEehkZ-nz_Jl09-dnp-zA>
    <xmx:1uDuaaTIt1noltMu1Lj0hNfSfp6ys9k_cVfC8w0LtQaGupu2le1Cvw>
    <xmx:1uDuaaB4c40vjTK3hQ8jTgVSho-3N6ctS0wxQM21rJ9BMXfMO-lkmg>
    <xmx:1uDuabt0eiCz854c7kjV-iD_hVOO8qcn3778gZLmyOnv4xexGBNgFmGa>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 27 Apr 2026 00:06:42 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Amir Goldstein <amir73il@gmail.com>,
	Jeremy Kerr <jk@ozlabs.org>,
	Ard Biesheuvel <ardb@kernel.org>
Cc: linux-efi@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 07/19] VFS: Add LOOKUP_SHARED flag.
Date: Mon, 27 Apr 2026 14:01:25 +1000
Message-ID: <20260427040517.828226-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260427040517.828226-1-neilb@ownmail.net>
References: <20260427040517.828226-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Some ->lookup handlers will need to drop and retake the parent lock, so
they can safely use d_alloc_parallel().

->lookup can be called with the parent lock either exclusive or shared.

A new flag, LOOKUP_SHARED, tells ->lookup how the parent is locked.

This is rather ugly, but will be gone soon after we move
d_alloc_parallel() out of the directory lock as ->lookup() will *always*
called with a shared lock on the parent.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c            | 7 ++++---
 include/linux/namei.h | 3 ++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a6349b31fdb6..e77ba9d31857 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1928,7 +1928,7 @@ static noinline struct dentry *lookup_slow(const struct qstr *name,
 	struct inode *inode = dir->d_inode;
 	struct dentry *res;
 	inode_lock_shared(inode);
-	res = __lookup_slow(name, dir, flags);
+	res = __lookup_slow(name, dir, flags | LOOKUP_SHARED);
 	inode_unlock_shared(inode);
 	return res;
 }
@@ -1942,7 +1942,7 @@ static struct dentry *lookup_slow_killable(const struct qstr *name,
 
 	if (inode_lock_shared_killable(inode))
 		return ERR_PTR(-EINTR);
-	res = __lookup_slow(name, dir, flags);
+	res = __lookup_slow(name, dir, flags | LOOKUP_SHARED);
 	inode_unlock_shared(inode);
 	return res;
 }
@@ -4413,6 +4413,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 	struct dentry *dentry;
 	int error, create_error = 0;
 	umode_t mode = op->mode;
+	unsigned int shared_flag = (op->open_flag & O_CREAT) ? 0 : LOOKUP_SHARED;
 
 	if (unlikely(IS_DEADDIR(dir_inode)))
 		return ERR_PTR(-ENOENT);
@@ -4480,7 +4481,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 
 	if (d_in_lookup(dentry)) {
 		struct dentry *res = dir_inode->i_op->lookup(dir_inode, dentry,
-							     nd->flags);
+							     nd->flags | shared_flag);
 		d_lookup_done(dentry);
 		if (unlikely(res)) {
 			if (IS_ERR(res)) {
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 2ad6dd9987b9..b3346a513d8f 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -37,8 +37,9 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT};
 #define LOOKUP_CREATE		BIT(17)	/* ... in object creation */
 #define LOOKUP_EXCL		BIT(18)	/* ... in target must not exist */
 #define LOOKUP_RENAME_TARGET	BIT(19)	/* ... in destination of rename() */
+#define LOOKUP_SHARED		BIT(20) /* Parent lock is held shared */
 
-/* 4 spare bits for intent */
+/* 3 spare bits for intent */
 
 /* Scoping flags for lookup. */
 #define LOOKUP_NO_SYMLINKS	BIT(24) /* No symlink crossing. */
-- 
2.50.0.107.gf914562f5916.dirty

