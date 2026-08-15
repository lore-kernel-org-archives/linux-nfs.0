Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EEF92AD3C;
	Sat, 15 Aug 2026 04:30:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768236; cv=none; b=UaIfmczew7ZW8lAq6qDWOCteCGunQ7WX9sS4Hr5yw0WcIYwxJwuDTPlx3HrGenwAugFKYFq05ySAFYu2KHgpqHf7Bo9HjBlaV240Trk/4HWrF2i1Buw6Kenf35q0TFO7PrNSSlMJxg4iM6OuestVfEl/QXQkU5EB+SfDuVHXn2M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768236; c=relaxed/simple;
	bh=9qZMcypa/gy5kjHN/LBtAlnlzenkV/IzDp6Z1yGYhXw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TegsaRNTroUCzRi1PLn+WPb7ImLTDG1dZ66VwBjt/HZeuN4mLmQmQ2fSq45ws/j/rh9hP66zRhsnZbLbaeaNruNDo7QeISbM4XFVOn/InaBJOWClgRCn+X2fZMDRnsJJhUm/7j/wrC+og7VX5fGjjptXL9+8y2PLZXzUwsxPNHI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=VYK9PzO5; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=KKUsjTju; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="VYK9PzO5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KKUsjTju"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id 5966513803F8;
	Sat, 15 Aug 2026 00:30:34 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:30:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768234;
	 x=1786775434; bh=8omHB5Ik+xex9gC8avsA7r2d4Low0LcWs+AokawDNtY=; b=
	VYK9PzO5OraQOAQipKRJMel6XhD4dTWDtuRPRWCEHmm5jxki0dbR0ahhJHwACx8E
	XWoAB2ZWsB3ekKYaxXoXfYBvGFhwNoRTaxQrBEyNea1/unVpSntNazQhKeep4PHh
	P7Vyz7df6jt0tHh3M5JXdDcVNTttTIOQ3bo9j+3oXyIv65bAanax/VqDPFXV3XOU
	5afmKYxRA/F4b7WE8OP0uRZTFfaem+Jv4KD1hhu8/77UYxDkDZVeqffWc1ZLzHIh
	nHWtocLKnvquMwvkfrt2hUQhj0Lpho4Uu33pwOQNM8a58eR0GeB3gA85JhmFSVcf
	jKuVP31Y1Xbp16OOqjPUWQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768234; x=1786775434; bh=8
	omHB5Ik+xex9gC8avsA7r2d4Low0LcWs+AokawDNtY=; b=KKUsjTjuzdDyamND/
	HVM7KSAQPI5fKD2nFN+em5tkjfOc1omraZ3cbkVD9ZO6t1MAHSzayli4/FW0W61c
	gZc/KQJxNfmfLk5FA5E7ekJb8/JglfFz95ndQpllgerSTHXpIR99Z+G1mfE7huFO
	iJONThNOV95DxflXKkEwu7nW+Zt9O7sYamHKKySFNNrNTT42XC+iDIIzn6LV1afC
	SQFdPmZY3cOqcvuZQyFH6dFcTipflnmwxk/vnFG3o5C4YYX4ec5ZRvJI8IXdq388
	5R2rZgUHKKFVKnxKOUwqonV/xlc/J/Xktf5oW+VQ7yJQrQGwjvt1zzG9NQ+TXuVZ
	3h3aw==
X-ME-Sender: <xms:aut_atjWeoHLJwUaoJj8AloixlSx7feDvjLEMTaFMY_izaZLoFa4yA>
    <xme:aut_atCaT08KnseOoznhMpLNcPCq0T_10JBGmCdDkV6FBCLQFfq_3lgTljvmMHu8z
    uUu1sEga5walWIZn-KzYkDVn1L7KY5Z3FwS9QL3FDn4Qjw_NA>
X-ME-Received: <xmr:aut_ajsdhDDgZgud_mCkNplajWHK4FjkiXKKmopRWPFXlygrVCBad1eUTyuA4cPFEY7P5jLP2Dt4saDghb-8GpLvSNd3q60>
X-ME-Proxy-Cause: dmFkZTGgH1yB2n7ycrnT317G63mA4K8J+0+N/EMola1f3Yo9FMDyeCxNlCpW0ogG8SDzVK
    nuqmbd9pMlKrj8W+iYmq1pVTGvt74D3ZCctc/uPGmP05B5l1l0R4ZDIBCIl/8oEandYMD/
    4fMlB5yv+92TDAVOY+2CBU7LrzZy25zRdg8qTNOxVbsq7k24tgXs/5TnSd4dLDpY87DDx3
    U3W1uESsjbyhpYP7efCKAtwoUDG8Gecy6pK22NJSQWi5TompJWiG+uhiQDvSBSwloZ0ml1
    Gf9seSd/eZq/h5vGIIRNPD6wpSL2TVBhjzDzH8E39xrhx5Ml7hez0SHzhnJuI33Pe/qwXz
    9BPKLtVy7zPFrINbO2rPyoNOKAe1gngEwrv45dtD8oe0YHOcWl3Cd21Itg+ZWYhXu1zXFP
    izSWd7w8lawjwmzwsA51nmDv3SJslCrsKIz3474E3xmZXyeh4LBRduzNlZdbzY7SnLf/s8
    +ZdfnyLqRBz+PQKl8cgHMGFZijpGwFGsbktQZlFjWI9vzye6AHJeG52qzurVLBF9DwsD9z
    Nr27UwJDn07hUhntleOUqHpmeoJKLVpZzdu5Nx+7ppXptLRBfkQJc5499lBWSnIKdc0FF/
    1ZhelzCBZBqz+Y53gMvcYnW1OYfw1HicPeMCgUfN+yTi4x6nYIrtOUzbr4fQ
X-ME-Proxy: <xmx:aut_av6FMHb0xc9UYAnl4PkC1H-g2_vegR6CNm3KSk09jzZElSgF8w>
    <xmx:aut_aldnJAUhGImydxG2Zfe8hilvt_rSUVn0U83fDey6HdOU_MhqEQ>
    <xmx:aut_avVYLvQvO1gCSJgYeWuMKed8_ZAELSXZo2x47VNGTHVTgKvYKA>
    <xmx:aut_aqVKzjuq0jubo8m95zF3XrOELxJFEGtWkwEBTaZHWxthc6a7Pg>
    <xmx:aut_asawYUwmurh1zG6lsFCi2WjA4pYuIwsfDiYOrF04klwHVgP8wU94>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:30:28 -0400 (EDT)
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
Subject: [PATCH v2 15/18] libfs: remove cond_resched() from scan_positives()
Date: Sat, 15 Aug 2026 14:21:32 +1000
Message-ID: <20260815042707.2535717-16-neilb@ownmail.net>
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

Now that d_for_each_positive_child_continue() calls cond_resced() as
needed, scan_positives() doesn't need to any more.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 44e8dec51237..15dd470198dd 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -108,7 +108,6 @@ EXPORT_SYMBOL(dcache_dir_close);
  * the last element of the list and %NULL is returned.
  */
 static struct dentry *scan_positives(struct dentry *dentry,
-				     struct dentry *cursor,
 				     struct dentry *last,
 				     loff_t count)
 {
@@ -125,13 +124,6 @@ static struct dentry *scan_positives(struct dentry *dentry,
 				break;
 			count = 1;
 		}
-		if (cursor && need_resched()) {
-			hlist_move_behind(&cursor->d_sib, &d->d_sib);
-			d = cursor;
-			spin_unlock(&dentry->d_lock);
-			cond_resched();
-			spin_lock(&dentry->d_lock);
-		}
 	}
 	dput(last);
 	return found;
@@ -158,7 +150,7 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 		inode_lock_shared(dentry->d_inode);
 
 		if (offset > 2)
-			to = scan_positives(dentry, cursor, NULL, offset - 2);
+			to = scan_positives(dentry, NULL, offset - 2);
 		spin_lock(&dentry->d_lock);
 		if (to)
 			hlist_move_behind(&cursor->d_sib, &to->d_sib);
@@ -193,7 +185,7 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 	if (ctx->pos > 2)
 		next = dget(cursor);
 
-	while ((next = scan_positives(dentry, cursor, next, 1)) != NULL) {
+	while ((next = scan_positives(dentry, next, 1)) != NULL) {
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
 			      d_inode(next)->i_ino,
 			      fs_umode_to_dtype(d_inode(next)->i_mode)))
@@ -448,7 +440,7 @@ offset_dir_lookup(struct dentry *parent, loff_t offset)
 	MA_STATE(mas, &octx->mt, offset, offset);
 
 	if (offset == DIR_OFFSET_FIRST)
-		found = scan_positives(parent, NULL, NULL, 1);
+		found = scan_positives(parent, NULL, 1);
 	else {
 		rcu_read_lock();
 		spin_lock(&parent->d_lock);
@@ -470,7 +462,7 @@ offset_dir_lookup(struct dentry *parent, loff_t offset)
 		spin_unlock(&parent->d_lock);
 		rcu_read_unlock();
 		if (found && !simple_positive(found))
-			found = scan_positives(parent, NULL, found, 1);
+			found = scan_positives(parent, found, 1);
 	}
 	return found;
 }
@@ -496,7 +488,7 @@ static void offset_iterate_dir(struct file *file, struct dir_context *ctx)
 		if (!offset_dir_emit(ctx, dentry))
 			break;
 
-		dentry = scan_positives(dir, NULL, dentry, 1);
+		dentry = scan_positives(dir, dentry, 1);
 
 		if (!dentry)
 			goto out_eod;
-- 
2.50.0.107.gf914562f5916.dirty

