Received: from fhigh-a5-smtp.messagingengine.com (fhigh-a5-smtp.messagingengine.com [103.168.172.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79260246768;
	Mon, 27 Apr 2026 03:36:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777261000; cv=none; b=eaxm7vBTJGMVt1PQuIrv2gv3co7D7Offmo7jV0xdl4e47inimahq1u+GAXb6Uze3fsPSWMgTbstmOCpJ+myKz5uTiErNnVdi34gxPqXXEztXTIqgNqofaus3AHdpAsaCGOGDG9utQ7lYawKBJuGmjMJpNOoTc8+TXv5TfPOwQNY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777261000; c=relaxed/simple;
	bh=s/WJXqScoUb+XDmgBWVvSpncv6x4V4yZ9QvNOvxlLFo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CIBNDfU0rqtE5NG1ChOkNcuCfe8UQGRXTdVJRVJxdnyLrqhCQMEV8YFD+mSVztgm9uwa4kN/d+j2CGSPW0Rg5pVXfS45ePRKzsQMZaCZfcuChhsA8p75j1kaFbOIQR487TWTxi5iecIW1AE6NKgIw2ryQ34vTJFHaYwObQCoFHg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=YHg/z9wF; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=CRyH2xVu; arc=none smtp.client-ip=103.168.172.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="YHg/z9wF";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CRyH2xVu"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id BA2AB14000B2;
	Sun, 26 Apr 2026 23:36:38 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Sun, 26 Apr 2026 23:36:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1777260998;
	 x=1777347398; bh=g8SM3Dg2naVtDlBlkJGj5seH51i8ZJRCDyDc8L3ShjQ=; b=
	YHg/z9wFgfVF4NyE9bn7HxG6D92z6nrJW0khBkdWZFNH2dl/Q8PhdOlAhwiSXR+2
	pufiD5ElNGawujmaJFkFw+AsxKg3lBneKuzcpzB6sw7I+XAgheX0SBPzHtPHGAJD
	yCjVxud9OCp4dresbx33Z/V+e0cRoWeRZWexFLyFNKPCjIdYowFexHP42W+iDgl1
	I8NaoiPTGTDsFxLN4Ykqb1Vbi0J88o/E8CnNC5Hj/5P2i3GESr9pLW9BNbTjVfTq
	Q3XnoWD2aEn49qORt5Qgq3LjiMexydXAI7u5bsq1h8yl5lHxpL1eJJa5hjoTxP34
	mnGGL5xRPjyJVo0FN4S1Sw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1777260998; x=1777347398; bh=g
	8SM3Dg2naVtDlBlkJGj5seH51i8ZJRCDyDc8L3ShjQ=; b=CRyH2xVu3PczfziWi
	ZfaVaPwoW45mI08gz/r9YnHAJKaz/fCO7Uq9xDzU2U5ucNEAWCK4I0Co9wFjGZ+h
	P2S7NOZlxCk9X3817mnbGy2psvpSdtMyH0v1X1HV1kBYTd5E1c4TBPSfCdtJqtrg
	tq8WRg2NfiZbgTUrpu5cxWFLe0JT74qLPSLQ/g/ZlF3ZfcBmyxNuPs5N/L3s429g
	KiC831H/DnKEV1yXyYntU0jg5AszS7rjbjcpy4aINLLb5y6swDQrpfGuqlMWr4uB
	tQDTjwSkv+xIxZnJ351MfR0vPYclo8Um38PIjUPrv3EobS3nk03MP4on2rcnLOG4
	ucVDw==
X-ME-Sender: <xms:xtnuaa52YktapynvrEgEnFQ7S5z1ZFM_1XtYT8J73GLCN-H6c2Fpag>
    <xme:xtnuaem0mv7vjluFIKoYov8P9eqiDC086KhvICxo57jzPu5IakPHYbqyDVo_YWRtn
    mfI6bl76AgY87dfNPbNRWRRMUuXb8-et-k6qQzc8zGlOZj-rHs>
X-ME-Received: <xmr:xtnuaQEQ9EcaPdI26itvkwnD872HqKUMTvMbLBK-d9O8Gxns-NiqiIkPpKHgOPII9uFL_bYyQtLfr1U37KNQPlFqcxFxGtg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejjeeivdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefhvfevufffkffojghfrhgggfestdekredtredttdenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    evveekffduueevhfeigefhgfdukedtleekjeeitdejudfgueekvdekffdvfedvudenucev
    lhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgsse
    hofihnmhgrihhlrdhnvghtpdhnsggprhgtphhtthhopedujedpmhhouggvpehsmhhtphho
    uhhtpdhrtghpthhtohepvhhirhhoseiivghnihhvrdhlihhnuhigrdhorhhgrdhukhdprh
    gtphhtthhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqvghfihesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnhgvlhdprhgtphht
    thhopehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghpthhtohepjhgrtghksehsuh
    hsvgdrtgiipdhrtghpthhtohepjhhksehoiihlrggsshdrohhrgh
X-ME-Proxy: <xmx:xtnuaSFSYCWPwOZojp4sjTVoU8z9E7yfG1BYEPh2rZJMLhIvUn10Lw>
    <xmx:xtnuaY291xL-4Fi1X3oMImf1nWEsBtT3jD2IZ6FWpOP65xYtJoOYRg>
    <xmx:xtnuaUf6PkAXn2iBZ1jDP9YGz6o7NqKf79kuPDhKGEvlFiDyGydb1Q>
    <xmx:xtnuaaIZ19aAoaTkmVJT-2CK4IquUp4hP_6-0ErBy6hucL9JqvCVKw>
    <xmx:xtnuaUOsvplzj9vyaU0f0S4Jdwb3pCNCrehC-QPIMkfYdulvkGlOK0fN>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 26 Apr 2026 23:36:33 -0400 (EDT)
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
Subject: [PATCH v2 03/19] VFS: allow d_alloc_name() to be used with ->d_hash
Date: Mon, 27 Apr 2026 13:29:36 +1000
Message-ID: <20260427033527.773006-4-neilb@ownmail.net>
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

efivarfs() is similar to other filesystems which use d_alloc_name(), but
it cannot use d_alloc_name() as it has a ->d_hash function.

The only problem with using ->d_hash if available is that it can return
an error, but d_alloc_name() cannot.  If we document that d_alloc_name()
cannot be used when ->d_hash returns an error, then any filesystem which
has a safe ->d_hash can safely use d_alloc_name().

So enhance d_alloc_name() to check for a ->d_hash function
and document that this is not permitted if the ->d_hash function can
fail( which efivarfs_d_hash() cannot).

Also document locking requirements for use.

This is a step towards eventually deprecating d_alloc().

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 789544525c56..d0a504fc62e5 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1945,12 +1945,31 @@ struct dentry *d_alloc_pseudo(struct super_block *sb, const struct qstr *name)
 	return dentry;
 }
 
+/**
+ * d_alloc_name: allocate a dentry for use in a dcache-based filesystem.
+ * @parent: dentry of the parent for the dentry
+ * @name: name of the dentry
+ *
+ * d_alloc_name() allocates a dentry without any protection against
+ * races.  It should only be used in directories that do not support
+ * create/rename/link inode operations and so is particularly suited for
+ * use with simple_dir_inode_operations.  The result is typically passed
+ * to d_make_persistent().
+ *
+ * This must NOT be used by filesystems which provide a d_hash() function
+ * that can return an error.
+ */
 struct dentry *d_alloc_name(struct dentry *parent, const char *name)
 {
 	struct qstr q;
 
 	q.name = name;
 	q.hash_len = hashlen_string(parent, name);
+	if (parent->d_flags & DCACHE_OP_HASH) {
+		int err = parent->d_op->d_hash(parent, &q);
+		if (WARN_ON_ONCE(err))
+			return NULL;
+	}
 	return d_alloc(parent, &q);
 }
 EXPORT_SYMBOL(d_alloc_name);
-- 
2.50.0.107.gf914562f5916.dirty

