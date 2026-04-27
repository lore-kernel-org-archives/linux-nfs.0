Received: from fout-a3-smtp.messagingengine.com (fout-a3-smtp.messagingengine.com [103.168.172.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98CFF246768;
	Mon, 27 Apr 2026 03:37:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777261076; cv=none; b=szDutyWogwXWNT1JUOH4Q9GKzVg3TRx/pC+Ki0FyTpsjOHEAIhV8GSJ+AXC5CsR3n6zUpTZjGIlRpCqXsmarNK5U9zIBDtH8SOXRjGUdnxVF2idfSdPn2dfFsV6XUe1oovotCmW4S87XnMzHB+g9xvliloKxV3KG+IvkOV3v0pY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777261076; c=relaxed/simple;
	bh=JM9LLqSf9XLlCtfxMB7Z+hQXEmomGURwLcnDXDC0yHY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=r5yf2mKQGRJlaYwaxpLhdip+LeEz/S8YY1n60yl90pCI6+jVo0DOIOpHyHVySk+ei0OSnAECqqOF5Od3tUHqc6RzPfjx2Uq8o0NBloc+8ghlHyUcZgyrJJr571txo2Ut1low6W294vt0v7c1cOmGc9AnoNctPV+MTrXbCdVoxXo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=myDOBf4Q; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ZLsAmflG; arc=none smtp.client-ip=103.168.172.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="myDOBf4Q";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZLsAmflG"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id EB77FEC033E;
	Sun, 26 Apr 2026 23:37:54 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Sun, 26 Apr 2026 23:37:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1777261074;
	 x=1777347474; bh=As30Bn0VYVoxaWKi4m0aODUf1VutcCrIZEa7WHHt+uk=; b=
	myDOBf4QzVjifFlpdu39ZSJ3fEVcGc8aJFUpjxZFOI7A3ZflTKZBArFh1XqpP02n
	QqPBsfYplCG6f9Dj0mtJim2qm+8XZT8R1cnDhdv2ATNoEfhfFiEKJRvlOomQctEV
	z2DcutM6mxgN5iQADu27O1mWd+Q7uy42S/SXs/59nvWXc+wza30Jrx26rFMbF34c
	MPAVLH3pYY1Fq1RyQTpgJuSJkgEA5gNYx9IEDDwqBCy30z+okKxs5JbYOVbFVmZl
	ByP+a58kFkNusLP7VLTRzUUPGgU87a6qnsLFTj+GZud85v/gMXa53NXgnsEILdQo
	IYPxA2TC8FPggAE8x466Xw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1777261074; x=1777347474; bh=A
	s30Bn0VYVoxaWKi4m0aODUf1VutcCrIZEa7WHHt+uk=; b=ZLsAmflGULf4ntadu
	qzRmX4Q6Fo5fxhlZ75Cjwe1rbuRWX3lv+NxdRmfugiRYf+L6oZ5To7Z49tl4wi7n
	XyfziamFl9yZSgpmRCwQ8y8ASAW+lQQsx5gj8gSe46fJnhR/PLCHYqkcZ9Oa3vH2
	QIc9NP3YN5CKo9btcumba6PmUIv1pqWizQueFRDVeGXKho9LI3lDTYClZTim27Yr
	fdxIFPeYctff06PdvD4OAg10VWoISAZHL/hQDFC49ESR6hH13PUrK6afj8georG4
	jMU3QycdTXCIhlXOeAdzJ7lwyyJeGDW7k3Wk4VkVs2gq3RIcekzBM1qUMIgnHLY+
	dWdNg==
X-ME-Sender: <xms:EtruaTIV1snf2PpZI7yqPeI9MlDFTdWpQSmzSHGoVKnmE8mKssR5ng>
    <xme:EtruaR3L708l_xfzu6IgVLqCFADWUU9igxycb0XLlpPqGIFaadkV9o4vW0-ZCxi0N
    0Vtyr6-o7H85YsKEo-A3znsHCzegJIMlIQj1iD-ooAQ5C_bfg>
X-ME-Received: <xmr:EtruaSU8Eev_zLFKINpeLK8yShuzHFjHD7KgKie4AcmZ5LtRgKdK1LNh8jTbA3GZKPmGrsGeKXGLu2SmXQ8KxkRWnj2PQuE>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejjeeivdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefhvfevufffkffojghfrhgggfestdekredtredttdenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    evveekffduueevhfeigefhgfdukedtleekjeeitdejudfgueekvdekffdvfedvudenucev
    lhhushhtvghrufhiiigvpedvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgsse
    hofihnmhgrihhlrdhnvghtpdhnsggprhgtphhtthhopedujedpmhhouggvpehsmhhtphho
    uhhtpdhrtghpthhtohepvhhirhhoseiivghnihhvrdhlihhnuhigrdhorhhgrdhukhdprh
    gtphhtthhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqvghfihesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnhgvlhdprhgtphht
    thhopehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghpthhtohepjhgrtghksehsuh
    hsvgdrtgiipdhrtghpthhtohepjhhksehoiihlrggsshdrohhrgh
X-ME-Proxy: <xmx:EtruaXV1pLfVHEJOXmeRr_Q0CLYU6YEPuoRw41wpxhBU33G1spXH4Q>
    <xmx:EtruaVFACPtI-emhQbxNBsB78Rdrd2Ryw1JmfJcmUtLCyOcyyTBVLQ>
    <xmx:Etruabu_EjevFotCoKvmkVssW9vNXPePzQmzPi7MUMmuY_4cJ2M75A>
    <xmx:EtruaQZkWNE8xJqvZLFe5-z80oalGZ_CZFcdrQ17Sf82WFDRXFUuVQ>
    <xmx:EtruafflgELeHv6UAi9hpjNGgCw5Gv5riV2WR4U_efutJLY-m0EzKudY>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 26 Apr 2026 23:37:50 -0400 (EDT)
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
	Ard Biesheuvel <ardb@kernel.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: linux-efi@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org,
	linux-kernel@vger.kernel
Subject: [PATCH v2 14/19] nfs: use d_splice_alias() in nfs_link()
Date: Mon, 27 Apr 2026 13:29:47 +1000
Message-ID: <20260427033527.773006-15-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260427033527.773006-1-neilb@ownmail.net>
References: <20260427033527.773006-1-neilb@ownmail.net>
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
nfs_link() calls d_drop() and then then d_add().

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

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0791fc2d161b..2c1315a02e52 100644
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
@@ -2676,14 +2679,15 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
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

