Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8646F2E6CAB;
	Mon,  3 Aug 2026 01:39:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721157; cv=none; b=TffIN9hop90xkJ2NwkdJTYuiH1T2tBBGOZi0J3gjfCyYjGlrG2UODiaU9lD2Bj+qSCNeUN9p6QCUO4eNgerzjch4ut+GSNNNG+klbdVx9hKSsGUHyp3J/IBrB2MomUC1OzyTj3tvrR7d0YllqzyZBgjBpj/TOn4umLMZQf/sLrY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721157; c=relaxed/simple;
	bh=xah1IZBUivqmQDuiMbVbkX4ugtrL2Xtzx9N4QCKerkc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=p1+gWGu2VN8d1zz1uIL58yyzz1F1mCIS9uVDy2CiIp1Q1Nm7W7ZXbzwJY+6h3b/8Qn3k/vH/G9VOcVC/f4sQzsSwbGPeWY2LPD091yDilUsoSveWFzKhtnhtfexxBoynsAf90eL/ndunU8UZ9RIyPzVhaFuDWjn97rTMxkm70FQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=MmTcyLcM; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Kcsz9Wpk; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="MmTcyLcM";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Kcsz9Wpk"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id 7C7B51300128;
	Sun,  2 Aug 2026 21:39:15 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sun, 02 Aug 2026 21:39:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721155;
	 x=1785728355; bh=48Fkc2hhO16ufhmd1558xtjY3jyS/m26wkZxQxAYLN4=; b=
	MmTcyLcMzoglUJq5DvMYnZYd5dxPosypo6M/Czfn6KbZhjhaV5cGXYOeTv4oR0TT
	sgQeNmTSOWtAIK1eFjh0CppB+cW3OJOGTEKFbINbZG+7FMGsDxBdw7q2B9GXviVm
	trc4zXspmN/Ddr2UGslL7EdXUOGsx0inSYQAn4Tnm8JA5WXxbhw2lujtXlZ2j5uS
	Oi9DUHD2G5p/kuC+nIFF9/K/rDiy2GpJykkv6lPqSgOCTwIpZKFEz2Yang/bbglA
	//wkYWxj5HmN/ShJAlYORy8aCkVzy4YMuaUlsR7cM2m80DBbodnC+Qyl3uUgFxwg
	JFOaflya03Xaiy9RAjuWoQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721155; x=1785728355; bh=4
	8Fkc2hhO16ufhmd1558xtjY3jyS/m26wkZxQxAYLN4=; b=Kcsz9WpkZmbKKAn7R
	BSWde2q3tmv1TuCv/DZM6/QYpvZdyb4+1GtF0ImDSLUDaSYmHIEXV7e3AiN1/idL
	4hyTU7pBZjIKFjfwp7w/NuJuT+GJgpmz/RnV8PIZrcPawUhFJ6/bCFw6T3KuHeKe
	FfXEpr4K+fRWcUFeMt/hgZm38kep6eBowrLSAijJJdo9NIS0vpYXcz76uzCigAYS
	LE3zGsGX7ATZz+Ce1bTJtoum4SRvYsAW7S5oqdV2vXJKwHPVprraItJvn2SidkDF
	Et0n8U4syijG6V2teDdrN9r9IYsdi6JiZ3lEAIkpaVyxkkrr1HgGA0G8kccUYo7g
	MhIfg==
X-ME-Sender: <xms:Q_Fvao4OVt1w0DDQ-nTkHW0vRax88fuU8qfppt0KxI4PzNqT92Uoog>
    <xme:Q_FvaiEZaOxw5w0nvqFa6h4kHWc88-GWzJOiJkhKb71AWUItQyZA2x36nSP4DJdJX
    FLdCo903k0Rr1gjV_M2JxJDH7GK4zB_r1Dk_xXqjXZ8rCRRjFg>
X-ME-Received: <xmr:Q_Fvauxqm_Z2j-DFGTtsnAgP44uhKD1605Lqs1xzbn31NI--xqChYDCF5aRzxMMZRQ26gGe9Wny5eI_0GsLV2P2Lf-S5SWc>
X-ME-Proxy-Cause: dmFkZTEkjpQitAtmxGBQYKqyuxI2Zkeo3c6RoaKCNErqeb7OpTUkwok+umPK8wjjzKilLR
    oEkJ4cvJVGjSJ84RQAU1yMp4OnVAa0j48I+IZh9Fdm8T9NlXb22vW2b++I/w1xpR0D9cGg
    PY5vxXMwbazIrQndnHZZeUaDjtiO7oMO4JfvURQOW8xpTRIAhWmk/yj3tGiTCFDkK11PUi
    8zP+PAM6p9S6yYk+YxJK09JqJLxfofUFwglAMcxid0fjJ/8eCuMBF6ZgJ9khwYNTvmmvDv
    XHb98vv+s9pbhqVhgG7tjgoBPJWqvJT0PbLNRH63wXqa3Yd9frMtJBXjxnj2koyaKciEdl
    uFMMz/4CEUcGyouzkIImU/OhVANGkyFS72dBLv8gabALYxnV5Tqh6acfylQZWUdliw+z9E
    bY051siIlw2Ox7ryWHJ5c0bt3NjEccKlc099E7t+VNREBTdm8Jj+6iKP0C+r6YGgyGTDcw
    q4sQLDcx7PBXLdmd26XcAXfyMzQu66MviRh0kq6A4mXxLyX9JOUvnTnZ3BoCPIz3FNVnj/
    brhwej9bFhJXHOMEsW1uxSwNwWTzwQeozhxzEJicXviJfH0NqSaAH6OGUX5cgpxPJgji6/
    N74k5PdE+TwvVvSOKrfR2olAgDTA2/Y+MSeg4U8X3elFfFCDTVNchi2yLV9g
X-ME-Proxy: <xmx:Q_Fvaq20vStdJhBNvOoSTb4g19GsvIWQlei5GuXvWwvPK7NMNTvZCA>
    <xmx:Q_FvapOKN_432hnaW59iQu0Nu7qbmCS9Eu2SC5VVgO2g60pxwiJ8NQ>
    <xmx:Q_Fvaute9IUlAcE3n2mumi95ElbmkuaWisvaItgo5JRVmkm3TYiBzA>
    <xmx:Q_FvalInVHTSd5EPpi7oprbXA0FqpodVYjtUJg7J4sBNztjtGScCVw>
    <xmx:Q_FvakJ0jH_MWyiL7sI7PtHnFADOaliSXLBWRfFFhdNaTJMwlL03Z6kv>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:39:07 -0400 (EDT)
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
Subject: [PATCH v1 12/12] libfs: remove cond_resched() from scan_positives()
Date: Mon,  3 Aug 2026 11:21:21 +1000
Message-ID: <20260803012648.2195405-13-neilb@ownmail.net>
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

Now that d_for_each_positive_child_continue() calls cond_resced() as
needed, scan_positives() doesn't need to any more.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index c0771e8b645c..b4c9cfdc1907 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -105,7 +105,6 @@ EXPORT_SYMBOL(dcache_dir_close);
  * If no such element exists, NULL is returned.
  */
 static struct dentry *scan_positives(struct dentry *dentry,
-				     struct dentry *cursor,
 				     struct dentry *last,
 				     loff_t count)
 {
@@ -122,15 +121,6 @@ static struct dentry *scan_positives(struct dentry *dentry,
 				break;
 			count = 1;
 		}
-		if (cursor && need_resched()) {
-			if (!hlist_unhashed(&cursor->d_sib))
-				__hlist_del(&cursor->d_sib);
-			hlist_add_behind(&cursor->d_sib, &d->d_sib);
-			d = cursor;
-			spin_unlock(&dentry->d_lock);
-			cond_resched();
-			spin_lock(&dentry->d_lock);
-		}
 	}
 	dput(last);
 	return found;
@@ -157,7 +147,7 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 		inode_lock_shared(dentry->d_inode);
 
 		if (offset > 2)
-			to = scan_positives(dentry, cursor, NULL, offset - 2);
+			to = scan_positives(dentry, NULL, offset - 2);
 		spin_lock(&dentry->d_lock);
 		hlist_del_init(&cursor->d_sib);
 		if (to)
@@ -191,7 +181,7 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 	if (ctx->pos > 2)
 		next = dget(cursor);
 
-	while ((next = scan_positives(dentry, cursor, next, 1)) != NULL) {
+	while ((next = scan_positives(dentry, next, 1)) != NULL) {
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
 			      d_inode(next)->i_ino,
 			      fs_umode_to_dtype(d_inode(next)->i_mode)))
@@ -445,7 +435,7 @@ offset_dir_lookup(struct dentry *parent, loff_t offset)
 	MA_STATE(mas, &octx->mt, offset, offset);
 
 	if (offset == DIR_OFFSET_FIRST)
-		found = scan_positives(parent, NULL, NULL, 1);
+		found = scan_positives(parent, NULL, 1);
 	else {
 		rcu_read_lock();
 		spin_lock(&parent->d_lock);
@@ -467,7 +457,7 @@ offset_dir_lookup(struct dentry *parent, loff_t offset)
 		spin_unlock(&parent->d_lock);
 		rcu_read_unlock();
 		if (found && !simple_positive(found))
-			found = scan_positives(parent, NULL, found, 1);
+			found = scan_positives(parent, found, 1);
 	}
 	return found;
 }
@@ -493,7 +483,7 @@ static void offset_iterate_dir(struct file *file, struct dir_context *ctx)
 		if (!offset_dir_emit(ctx, dentry))
 			break;
 
-		dentry = scan_positives(dir, NULL, dentry, 1);
+		dentry = scan_positives(dir, dentry, 1);
 
 		if (!dentry)
 			goto out_eod;
-- 
2.50.0.107.gf914562f5916.dirty

