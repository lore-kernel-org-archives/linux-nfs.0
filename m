Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEE95234994;
	Mon,  3 Aug 2026 01:37:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721079; cv=none; b=FrxsaihHkU9VCCeda4qFxps92A/9cE6U2t+6MSnIHoAEIIvIXyzze4lkm/17CjS+SmpjwaKcxBYnPr5N6iVbhlbCZtSR0RLM+wuV2RYg0bCkjE+SMRthdZQutaFNhAQhS6hDfi/uK5/8YN9SL3wP8lrYJSfB6qjn+J21arD0kC8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721079; c=relaxed/simple;
	bh=yvoq+derSFn4Ih/ybaF7AWNnX/BuYjoP9FBTtDHfYaY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UCYc0upMek4fbpXcEjonH07BnZSHxfa40+FwnfoDk5tKqn3huQiPut2JnQeHiVI4jD4MC9NSw0nKxCC9ImhJdVSSb6rK2bG/gjnDmsQIlOeJWUkgJbo6QOEA3zqSt24gH/7a15QHoAC0+aoAkE69Ur36bA/vJCWdBunPiR4t4UM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gNBB+Mz/; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Ow0AKg4w; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gNBB+Mz/";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Ow0AKg4w"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailflow.stl.internal (Postfix) with ESMTP id B0D4B1300101;
	Sun,  2 Aug 2026 21:37:56 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-12.internal (MEProxy); Sun, 02 Aug 2026 21:37:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721076;
	 x=1785728276; bh=LRXjGHlh2+nCnx6IVsF6Rd5nMZtgJdRoJmvfHXGHHCU=; b=
	gNBB+Mz/+u6/HJXv8Lxe9NUGV0PEJRfaJBZmtEtrDmqkVXbq8sFu/+dnSimt0HeG
	RaL9omXhpMe+oW5HDF1xnZLxdH5frY5umjz2NwiG1zera27HdsXMQmDBHHfm8RK3
	RDY/UIhkXVmgW0Cp8K5kvIvWWJAGwXQwiGxJtOoS10Tr5meoKVMsuZ7NL2J5+TDJ
	hIyFYZ4dmYFXB+sdOckhooMmcDUghh3bk6F/sE82U2vLDKKnNXPl2QAfYazQKCoN
	TmjWzYveOOlxv2iOiKXyzhA4N1awCcTTadYSezKQngSSQyGUrnjYiXac+H67Gzl+
	pd/CvArM+T5Ul0yL04dCtQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721076; x=1785728276; bh=L
	RXjGHlh2+nCnx6IVsF6Rd5nMZtgJdRoJmvfHXGHHCU=; b=Ow0AKg4w/beSCP1X3
	AEK9CAQ99dBsJc83L32r/tymlxAmIvmgHuAn0hJrPls+vxdueIp1M9XYJ5iNjJIk
	xyqDL3ZsM4uMvo3i3nyvfse+9e9V/c5swyOQYun7u9RjtasPatFXyhgWIPUhTDRx
	qq0GDhTThV1ui7xTqGJDTKM4JTMw+/80jRie8WJLBOfWRoLgVkvukMiVVSTR1aZi
	QksJN9IOPa/7+Y+Qx/t6cRTsGaC5XXrY7WWJuH8A3s3TxYk+kSufSt8H8RF1zljv
	yxt9iFNmlwo3m6rL96bnpAHlfXUEDCJQtD9wwHGrIszMOpuThiX/Ae/0LdJcOk+1
	Mi3ZA==
X-ME-Sender: <xms:9PBvahAjtJ2IGoI2AOWFssD3xSp0wGA7dAj57fCBhEEjTNGx8Mqu-Q>
    <xme:9PBvaqhez6EP-coUEqhkX6aF17mV0W42txIePOZNwvlDMvToC0RXS1pIBab-y4l3D
    NpldjOCro4tEAqSrLdglJJCVJvWcz0fvWpvsKLabB9w12unSA>
X-ME-Received: <xmr:9PBvajOQ_vWLnZqsDbjeAQ7T6y97iH3H11LIqKHKiMhsnYc3jp6UnBDR9OArUEJLVLRv7yz_52_6wxBW0V_5iYGsUalltWo>
X-ME-Proxy-Cause: dmFkZTEu0UNNG3Y5ooWE0RW0hb4az30oOOCqiR21A+NF5dBXRIXwF7e1ZQQcPeI1Y+2g3G
    2p5taGZPwiaaM3/xeTLW1FCz9U/vJJJskTdg41lYE8VUiZH3MPaQbRkjgX9sOC9ECG/cTt
    EsmfJCIwMKXkPJdCSK/JXV+uNx8CZDrRBVBEoFtsVP6zXAB6qeB8/w/DykMlOqIBtf3Btj
    xISH9DdsaZIjdYArnJRbVHFMU7yzbJxCLAWmCc9hUaSiSdlTAIOT4N2Kv8CS0tgpHV+N+f
    k8nNXssq6c7SmtuWSNjzKUGklZ3BjLsq0xMUopueJIhR+ZPYvLBJVSK2Tqb5Oui4sXj8It
    FV+4BN11kfVmubMl0upk5n+Xcy9uFD9BBSQgJHh5L5DafEWPCIVc7b/B5zL2ZAHElqAXSP
    Jhpk+s3cl0b4f2bSoH/fcExTmw5QRlNHUV1cD0znwrM9ipFPu1c2ycLFcxmSI2RjOhF02o
    sq0Wz70PmxEJAJAJizhpsqxB9PvjkAVynOLAubHtIziPzNcwMf29po4n9r+t1MzdkniI85
    8Hm3Z29rUN3E0QfbLqwpOIYpvs5P1RQ5MZWltY40h7FFBFS1SGEnChOc0vMBViGG9dRKh0
    xNXXmunlKHX18AozUeWuv1IcHDQoJbmr+jdFG5WTavERha0V3DIpf1/qzXPA
X-ME-Proxy: <xmx:9PBvapZJPpsbdnA99sHlXZg275jqUpQsk4xspSHDn49IutJNs5QxEQ>
    <xmx:9PBvag8_20lyF2gCUIzzZECikLav7W4aTxD3hWhYiYHY4nqIDx6pDQ>
    <xmx:9PBvak2Cd-mA_D8nwJecsooFMG940FDxRI6vnI7OlKzjnyOD9J5H1w>
    <xmx:9PBvah31OdS0Y1qTDxiz1XyIpOfOrwrosMilK7d552O_LlHj25XBeQ>
    <xmx:9PBvap4rcfBivaBVKLpnFruvo24dWR-qo7h00IMH29WSMUOU6JCUTN4D>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:37:48 -0400 (EDT)
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
Subject: [PATCH v1 05/12] libfs: simplify scan_positives()
Date: Mon,  3 Aug 2026 11:21:14 +1000
Message-ID: <20260803012648.2195405-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260803012648.2195405-1-neilb@ownmail.net>
References: <20260803012648.2195405-1-neilb@ownmail.net>
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

So now to scan from the start, pass NULL, to scan from a particular
dentry, pass that dentry.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index fc283e0a7c3a..080ca615593c 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -105,16 +105,18 @@ EXPORT_SYMBOL(dcache_dir_close);
  * If no such element exists, NULL is returned.
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
@@ -131,10 +133,10 @@ static struct dentry *scan_positives(struct dentry *cursor,
 			if (!hlist_unhashed(&cursor->d_sib))
 				__hlist_del(&cursor->d_sib);
 			hlist_add_behind(&cursor->d_sib, &d->d_sib);
-			p = &cursor->d_sib.next;
 			spin_unlock(&dentry->d_lock);
 			cond_resched();
 			spin_lock(&dentry->d_lock);
+			next = d_next_sibling(cursor);
 		}
 	}
 	spin_unlock(&dentry->d_lock);
@@ -163,8 +165,7 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 		inode_lock_shared(dentry->d_inode);
 
 		if (offset > 2)
-			to = scan_positives(cursor, &dentry->d_children.first,
-					    offset - 2, NULL);
+			to = scan_positives(cursor, NULL, offset - 2);
 		spin_lock(&dentry->d_lock);
 		hlist_del_init(&cursor->d_sib);
 		if (to)
@@ -191,23 +192,19 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
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
 	hlist_del_init(&cursor->d_sib);
-- 
2.50.0.107.gf914562f5916.dirty

