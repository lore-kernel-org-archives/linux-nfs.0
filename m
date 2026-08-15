Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D57492222CC;
	Sat, 15 Aug 2026 04:29:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768171; cv=none; b=DHtsX8BZahHwVqC1mvHzHP7FI14vAt6npw/NVg1YAbqtYgm1sOs8B7qIYonexM79wt8QGYeKIrKTodhSIiaoEjMBul8Li+7GikCSCcqjIV7wChfQKyquSSx8jzsQwdXyYiiSZHnDp+M/Wv6BzvSLaxIFGweLD/GjxWLUsKwxKL8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768171; c=relaxed/simple;
	bh=AdhooIjboAu3YKY/yuVksKwU8xau5i7EOd+Vl1SZzvQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sAjGKMIXutpUoaCcikkXhizi4SABtvJIPQqCCX3rbVqGW8aRv4r6ss/p1lul/7vNXVRQfv5lcOcL495okcK7mYPHjBKvTowzDWZZK0SJVCIZcrtPlf5IX5Ch5L7wQPc1MOuAuzHRCcmrSqXCeo7KOJVlE6BTBti/qRbNrbawYKU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ZR4KrllY; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=OHQh6o/D; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ZR4KrllY";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OHQh6o/D"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id EAA3213803F8;
	Sat, 15 Aug 2026 00:29:28 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:29:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768168;
	 x=1786775368; bh=2qeLuelJx2/+SBs2S68hwoXODkH6n7+CkxfeqKI7W2s=; b=
	ZR4KrllYxWnBYgC4dsMIDPZkLXfN6UK1oOr1OqWkALKcfMzAeG8LVg/viclNxycS
	4kqiDGc3DE4Z4yIxhSDaYQ0QDmxWzIF8mr2jP2Qnj5dfr6kTmpd0piI5+IwCDt4m
	Gr/y7zY8nygnvK3DoQEaf0Sv8RWji+l1Sqh51WJwD00Jv7ozQMgTpHHj+Bdyv0xL
	oqeJJ3ZN9MRTnNqbyypNIVnB6DrfkA2nIdwdmAxK5IXT2mg/zD9HUG2iXQbK7toZ
	eaeU9Axb2/T4xC9p8CkKfN3cjeDC1vj9M7Z7NZhnXIxy2Ut5fQaIw3f0B8PnHWgP
	sQ+OUVgbcjDSmkjTHUHSkg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768168; x=1786775368; bh=2
	qeLuelJx2/+SBs2S68hwoXODkH6n7+CkxfeqKI7W2s=; b=OHQh6o/Dp9Bohl9Er
	mPbsOGSvRBLcxD+15NWWBFgozYJVvJbRqsP8YPuC+t3e8/sS8PH29EU00mD4SNy0
	HEZ2Jm66WfGX2j/VXv6p2XM6XwvrpUlx6ptHVqd1VmxuffYtCIbjMiXnX2P+zaZ+
	aaOpaxkLvd1ceDBqaSD3N1/SxPoP+++OxOeql1TKQrbqaTTX2BFFRJbvzbtEU+1w
	LOAWw25tdazkuIBzYJhnt3+wshR23vZUuIpP+b3hVj6usI5QgXrDKfMgETlD1WO5
	UMtSTj8+UOyFCUXhuUDLd0BYiUeZsiAxVFO94U3iViUXF40rkvjPxcWRDguaVdqm
	rhzGw==
X-ME-Sender: <xms:KOt_aiY7IPfazNj8YKzDH52LIjAlYlWOlynUL7Yn-wm4buPkB9lwWw>
    <xme:KOt_agZkwRpwDcsdHoJC_Tje86xPwpgB5n_yh0D20WV8Wa2pyat4s1-Qeo621IyGJ
    bICpn1IgFhxnxYrACcJ1A0ftDOFOadEgao_33qcJ0o0mMp1>
X-ME-Received: <xmr:KOt_ajlNhVwlCAl6J6ghU8JqWYBipnV1Tw2Ujkhgt-MPqvzJbxP2XgeaDdAqGX685dGEnzrBdqMQ-RSjxCW0ViDNF7zoSto>
X-ME-Proxy-Cause: dmFkZTE47D4+VfwQFQzr11DJvQLYIXqMi0hZV0dErVHB+rL0DNVNd8lKaFjc/DBGC/9Z+e
    1XqqSxG1COnVE2p0h+gE+3sT3WHc2s4pfHSbkJDPkdz9l078ivxoBUX7LaQuIqMUvNfdCK
    OTO6fH4CbhonnMAQrCy6mAjkD3yfDfiioSRLElGFQqu4IKzk74/3+ETPYsMsadCTSlIE72
    pFesoG42fVWkR1DR5x8Czt3y4MWTPZ7Vk8PZOOBmt7LfMXAwJXwlpNe3RczRrG53IXGKeB
    lZ2vtwNbgIUpnHC00hTYciEg8pKF9qQ82JcZyji4nf8ZRkE3Cre+0W/dXUWlpbwnOwzitG
    Ch201FCa68CyyiT9UPUmL5R7nuDBzo5e54dDHD3COMxf2yP3fi4ndKcc5O3oDVsmb8S9IM
    uD97AUUD4DvwjItpp22V3agGLAivOVOMAxrGXyWbiRnxRL7icIV7jaNx5Ex7prYayXIhz+
    UiJnuYexXYZqo/dTaf3PSaDa1G0yv4qQ14LPP8t18GvE0/hMWZK9fN4vRqCZvSUFN/9pf8
    8+7NFwQt6UpJSF7mbuayno783GhQQp4OnNMMJsvnH8nTAKSCwMURpLsm2fiPBycyVs4rLl
    XGUdWkZ+A6H2vRDD1uefDY7BuiGnaAq2rEXxnRt7xvYCvGZ5cogLMUAe4QxQ
X-ME-Proxy: <xmx:KOt_aiQp-MV5nhI1XSnHfA1ySPkObXNjj6zYMonTdQwCxSuyuQ90_A>
    <xmx:KOt_aoUCwbSZnQ5J21WZp9hCgWdmMWibhw-jzzbauSr0fSqCSByYJw>
    <xmx:KOt_aou_r1-JqTlt-HPIgEjB2dLgbSW-zoQbF_oDWM8_NqCaWb6lTA>
    <xmx:KOt_aoO8WepLtfZNgJfgt5Xkeu7v7M8TrNebEvgTdxghHbNgOhh0WA>
    <xmx:KOt_arwP5iWUvpdMnt8ffASxkajRwvfmaK35cIljFLJE4KEoGjR47KFh>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:22 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/18] libfs: simplify scan_positives()
Date: Sat, 15 Aug 2026 14:21:25 +1000
Message-ID: <20260815042707.2535717-9-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

This patch removes explicit use of hlist_node from scan_positives() and
callers, and consistently uses struct dentry instead.

Previously scan_positives() had two args which were closely related: p
and last.
If last was not NULL, p was precisely &last->d_sib.next.
If last WAS NULL, then p was
   &cursor->d_parent->d_children.first or
   &cursor->d_sib.next

If, for the final case, we pass 'cursor' as 'last', then we only need
'last' not 'p'.  For this to work we must dget(cursor) before passing
it, as scan_positives() calls dput() on last.

So now to scan from the start, pass NULL; to scan from a particular
dentry, pass that dentry.

Note that scan_positives() can be given a "last' which is unhashed.
This happens if, for example, dcache_dir_lseek is called to seek beyond
the end of the directory - thus leaving the cursor detached - and then
dcache_readdir() is called.  "next" will be the detached cursor which
will be passed in to scan_positives() as "last".  d_next_sibling()
of this will be NULL.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 8e99067079e8..c2b09e72cbd8 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -103,18 +103,23 @@ EXPORT_SYMBOL(dcache_dir_close);
  * We are looking for <count>th positive after <p>; if
  * found, dentry is grabbed and returned to caller.
  * If no such element exists, NULL is returned.
+ * If last has been removed from the d_children list
+ * (i.e. last->d_sib is unhashed) then it is treated like
+ * the last element of the list and %NULL is returned.
  */
 static struct dentry *scan_positives(struct dentry *cursor,
-					struct hlist_node **p,
-					loff_t count,
-					struct dentry *last)
+				     struct dentry *last,
+				     loff_t count)
 {
 	struct dentry *dentry = cursor->d_parent, *found = NULL;
+	struct dentry *next;
 
 	spin_lock(&dentry->d_lock);
-	while (*p) {
-		struct dentry *d = hlist_entry(*p, struct dentry, d_sib);
-		p = &d->d_sib.next;
+	next = last ? d_next_sibling(last) : d_first_child(dentry);
+	while (next) {
+		struct dentry *d = next;
+
+		next = d_next_sibling(next);
 		// we must at least skip cursors, to avoid livelocks
 		if (d->d_flags & DCACHE_DENTRY_CURSOR)
 			continue;
@@ -129,10 +134,10 @@ static struct dentry *scan_positives(struct dentry *cursor,
 		}
 		if (need_resched()) {
 			hlist_move_behind(&cursor->d_sib, &d->d_sib);
-			p = &cursor->d_sib.next;
 			spin_unlock(&dentry->d_lock);
 			cond_resched();
 			spin_lock(&dentry->d_lock);
+			next = d_next_sibling(cursor);
 		}
 	}
 	spin_unlock(&dentry->d_lock);
@@ -161,8 +166,7 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 		inode_lock_shared(dentry->d_inode);
 
 		if (offset > 2)
-			to = scan_positives(cursor, &dentry->d_children.first,
-					    offset - 2, NULL);
+			to = scan_positives(cursor, NULL, offset - 2);
 		spin_lock(&dentry->d_lock);
 		if (to)
 			hlist_move_behind(&cursor->d_sib, &to->d_sib);
@@ -190,23 +194,19 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 	struct dentry *dentry = file->f_path.dentry;
 	struct dentry *cursor = file->private_data;
 	struct dentry *next = NULL;
-	struct hlist_node **p;
 
 	if (!dir_emit_dots(file, ctx))
 		return 0;
 
-	if (ctx->pos == 2)
-		p = &dentry->d_children.first;
-	else
-		p = &cursor->d_sib.next;
+	if (ctx->pos > 2)
+		next = dget(cursor);
 
-	while ((next = scan_positives(cursor, p, 1, next)) != NULL) {
+	while ((next = scan_positives(cursor, next, 1)) != NULL) {
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
 			      d_inode(next)->i_ino,
 			      fs_umode_to_dtype(d_inode(next)->i_mode)))
 			break;
 		ctx->pos++;
-		p = &next->d_sib.next;
 	}
 	spin_lock(&dentry->d_lock);
 	if (next)
-- 
2.50.0.107.gf914562f5916.dirty

