Received: from fout-a3-smtp.messagingengine.com (fout-a3-smtp.messagingengine.com [103.168.172.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6DB9635CB6F;
	Mon, 27 Apr 2026 03:37:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777261035; cv=none; b=oluX1gN9UNtj99/kkfE/TzuvRKYxSh6yglCBFlvMjB1Dbq3MHCOes25OoX0ej+vsT5mCnxZpgRbRScUFFWBVKBhy5gwW77zp5kKdo5wTFpGqgLhJbunT8Y0wPEnQj5sQNpP1DF1YwnWYWOy0q/RkBOuT/RUTHJ3mr/23GQm4GN0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777261035; c=relaxed/simple;
	bh=yRP77MAWO+gIHiR84B9F5QCRIoLxg6i5LGDL4a/5i6Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=T/jzCYf5drrOssMxO1hqRP4c2OYvyai/HlXwL2A5AQrd1HvpdiqEDWWwnY37AQWivJ+zjSyJWPRmAWV6g8z2PT0GL41L8HJhyUzQyHbpL0m5rwemM6Sjxnw6oX3RcKEaxPqL4XBwKiGIyRoXVYQEvSoXDu+TH7NccNe8/ONTljA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=OxQ1mskw; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Lgp7s8OE; arc=none smtp.client-ip=103.168.172.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="OxQ1mskw";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Lgp7s8OE"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfout.phl.internal (Postfix) with ESMTP id AC90EEC032E;
	Sun, 26 Apr 2026 23:37:13 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-09.internal (MEProxy); Sun, 26 Apr 2026 23:37:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1777261033;
	 x=1777347433; bh=zdXjCv6aJzC4DSxkackOkKHCbtNaMCphdlTQdbSEugA=; b=
	OxQ1mskwnO1U21tZe6h0hS5FQeZLNn61iLf+PMzKQjdHAM60Ozm6msNIxipwYrGD
	8IXM2h/Z+17HJPNh4tQ+i3uZcF0MDJt+bqJiHg/cob1YMy8QKoKgGC7uPUhGmUs/
	ZM+ZuOIonUViAdqMDecAdDIMPG/N+wkao73ya9S5ZJfrFGX+Wyn3uK23qlb0LWQQ
	BjmPg8mym1Iq0+ewgb780ZouGQXzXYagyHDsabPcYs2bZcOnn6BZn4T2id5LQ1ZD
	LiOD8qL9G5nlaAsXH/jtkPOaiwMTo5VhlnjuOUlZ5ejt7rnlp1BHa+FnhQ7m5wPd
	eiT2m0qPOPadakPyPeN57Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1777261033; x=1777347433; bh=z
	dXjCv6aJzC4DSxkackOkKHCbtNaMCphdlTQdbSEugA=; b=Lgp7s8OEZnKpP9jg1
	0frz+/XA2Y5Iep7LBvqroFlUThzW5OvIkCtZ9vz71yFGo2LCGOxtPVe6bO8sdA8c
	kNxBgPczbs2sxCClrUe4ZnKnq/WByUyn5JG93TQIkOy7GRb+opdBhJord29A0N/u
	WYORk2h9sZGlrd3X8oz5d0wUKWgYOoLP6bFHZ05fhWHn3ArPh9Bnfbx0NLR1tKSA
	X+Vmp37NX7HIp9Tx3YOAkHQ0g1NDTziIg3P2RxF9jxJJDPE/IsqU18wlj+LvO/sv
	e0xgdLG2wTx8VvONptloicdo0TWUkPn4IfMe0KpkIDQa+3hP5tqrFkIC4Um9gYrp
	m4U2w==
X-ME-Sender: <xms:6dnuaW109XlpjbKcOiJYFOX2l8dx-vGn9yeHmV1usASsLvW473qyQA>
    <xme:6dnuaTxZPnGENzC9YaoH1RyPPt4P44_T4r9yrmpA1qtPfAkY4hkNXnfRgiBzDagxm
    Ff-iEjZTvBEE7yD5xUYVkLXOdZe__Thii9-m4jQx4X8b1R27Q>
X-ME-Received: <xmr:6dnuaViZx5MrzxBCwaFwYd3-ZOIbX1VJTm9Y--dlNjR0KSW8D5-K7bAmUjpRFxqLjR6k-AlMLa4ISC9VZcbA5ctPpzVOMeE>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejjeeivdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefhvfevufffkffojghfrhgggfestdekredtredttdenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    evveekffduueevhfeigefhgfdukedtleekjeeitdejudfgueekvdekffdvfedvudenucev
    lhhushhtvghrufhiiigvpedunecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgsse
    hofihnmhgrihhlrdhnvghtpdhnsggprhgtphhtthhopedujedpmhhouggvpehsmhhtphho
    uhhtpdhrtghpthhtohepvhhirhhoseiivghnihhvrdhlihhnuhigrdhorhhgrdhukhdprh
    gtphhtthhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqvghfihesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnhgvlhdprhgtphht
    thhopehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghpthhtohepjhgrtghksehsuh
    hsvgdrtgiipdhrtghpthhtohepjhhksehoiihlrggsshdrohhrgh
X-ME-Proxy: <xmx:6dnuaSz2CYrmtZFrGTC-fvTLmVPoSIL1mHx8OtTQ4JKqYpPGlFlyPQ>
    <xmx:6dnuaTx4mBzBV2oiIqgmfYBFAKDmj5lzrc4KvMq9E1dpiFFJUP5apA>
    <xmx:6dnuacqwW2oHJDbSTE7LxaUvOzzNBvI45zJfJqisyxM1Sz_tBkN9Lw>
    <xmx:6dnuaWmBzmtVJCpGFMEX3EQA6HQ7ho8YOrw48ib7ETjErmP_3VSDeg>
    <xmx:6dnuabY7poa6J79H75xr-UOGIiLESIuNqZ7_zE3Ag1V4BaRFsNphNBeM>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 26 Apr 2026 23:37:08 -0400 (EDT)
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
Subject: [PATCH v2 08/19] VFS/xfs/ntfs: drop parent lock across d_alloc_parallel() in d_add_ci()
Date: Mon, 27 Apr 2026 13:29:41 +1000
Message-ID: <20260427033527.773006-9-neilb@ownmail.net>
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

A proposed change will invert the lock ordering between
d_alloc_parallel() and inode_lock() on the parent.
When that happens it will not be safe to call d_alloc_parallel() while
holding the parent lock - even shared.

We don't need to keep the parent lock held when d_add_ci() is run - the
VFS doesn't need it as dentry is exclusively held due to
DCACHE_PAR_LOOKUP and the filesystem has finished its work.

So drop and reclaim the lock (shared or exclusive as determined by
LOOKUP_SHARED) to avoid future deadlock.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c            | 18 +++++++++++++++++-
 fs/ntfs/namei.c        |  4 +++-
 fs/xfs/xfs_iops.c      |  3 ++-
 include/linux/dcache.h |  3 ++-
 4 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 569a8ddf4c0d..a2ddfe811df3 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2294,6 +2294,7 @@ EXPORT_SYMBOL(d_obtain_root);
  * @dentry: the negative dentry that was passed to the parent's lookup func
  * @inode:  the inode case-insensitive lookup has found
  * @name:   the case-exact name to be associated with the returned dentry
+ * @bool:   %true if lookup was performed with LOOKUP_SHARED
  *
  * This is to avoid filling the dcache with case-insensitive names to the
  * same inode, only the actual correct case is stored in the dcache for
@@ -2306,7 +2307,7 @@ EXPORT_SYMBOL(d_obtain_root);
  * the exact case, and return the spliced entry.
  */
 struct dentry *d_add_ci(struct dentry *dentry, struct inode *inode,
-			struct qstr *name)
+			struct qstr *name, bool shared)
 {
 	struct dentry *found, *res;
 
@@ -2319,6 +2320,17 @@ struct dentry *d_add_ci(struct dentry *dentry, struct inode *inode,
 		iput(inode);
 		return found;
 	}
+	/*
+	 * We are holding parent lock and so don't want to wait for a
+	 * d_in_lookup() dentry.  We can safely drop the parent lock and
+	 * reclaim it as we have exclusive access to dentry as it is
+	 * d_in_lookup() (so ->d_parent is stable) and we are near the
+	 * end ->lookup() and will shortly drop the lock anyway.
+	 */
+	if (shared)
+		inode_unlock_shared(d_inode(dentry->d_parent));
+	else
+		inode_unlock(d_inode(dentry->d_parent));
 	if (d_in_lookup(dentry)) {
 		found = d_alloc_parallel(dentry->d_parent, name);
 		if (IS_ERR(found) || !d_in_lookup(found)) {
@@ -2332,6 +2344,10 @@ struct dentry *d_add_ci(struct dentry *dentry, struct inode *inode,
 			return ERR_PTR(-ENOMEM);
 		}
 	}
+	if (shared)
+		inode_lock_shared(d_inode(dentry->d_parent));
+	else
+		inode_lock_nested(d_inode(dentry->d_parent), I_MUTEX_PARENT);
 	res = d_splice_alias(inode, found);
 	if (res) {
 		d_lookup_done(found);
diff --git a/fs/ntfs/namei.c b/fs/ntfs/namei.c
index 10894de519c3..30dddef43300 100644
--- a/fs/ntfs/namei.c
+++ b/fs/ntfs/namei.c
@@ -8,6 +8,7 @@
 
 #include <linux/exportfs.h>
 #include <linux/iversion.h>
+#include <linux/namei.h> // for LOOKUP_SHARED
 
 #include "ntfs.h"
 #include "time.h"
@@ -310,7 +311,8 @@ static struct dentry *ntfs_lookup(struct inode *dir_ino, struct dentry *dent,
 		}
 		nls_name.hash = full_name_hash(dent, nls_name.name, nls_name.len);
 
-		dent = d_add_ci(dent, dent_inode, &nls_name);
+		dent = d_add_ci(dent, dent_inode, &nls_name,
+				!!(flags & LOOKUP_SHARED));
 		kfree(nls_name.name);
 		return dent;
 
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 325c2200c501..f03d832f1468 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -35,6 +35,7 @@
 #include <linux/security.h>
 #include <linux/iversion.h>
 #include <linux/fiemap.h>
+#include <linux/namei.h> // for LOOKUP_SHARED
 
 /*
  * Directories have different lock order w.r.t. mmap_lock compared to regular
@@ -369,7 +370,7 @@ xfs_vn_ci_lookup(
 	/* else case-insensitive match... */
 	dname.name = ci_name.name;
 	dname.len = ci_name.len;
-	dentry = d_add_ci(dentry, VFS_I(ip), &dname);
+	dentry = d_add_ci(dentry, VFS_I(ip), &dname, !!(flags & LOOKUP_SHARED));
 	kfree(ci_name.name);
 	return dentry;
 }
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 3991f9988599..662b98185337 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -263,7 +263,8 @@ struct dentry *d_duplicate(struct dentry *dentry);
 /* weird procfs mess; *NOT* exported */
 extern struct dentry * d_splice_alias_ops(struct inode *, struct dentry *,
 					  const struct dentry_operations *);
-extern struct dentry * d_add_ci(struct dentry *, struct inode *, struct qstr *);
+extern struct dentry * d_add_ci(struct dentry *, struct inode *, struct qstr *,
+				bool);
 extern bool d_same_name(const struct dentry *dentry, const struct dentry *parent,
 			const struct qstr *name);
 extern struct dentry *d_find_any_alias(struct inode *inode);
-- 
2.50.0.107.gf914562f5916.dirty

