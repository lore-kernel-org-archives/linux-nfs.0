Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 902C92DB7BF;
	Sat, 15 Aug 2026 04:29:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768160; cv=none; b=k6cYprQpOeKIdTsrEvK8HI9bz7WYJZx6mnJIQLceogZ7ODfCFFsrpTqb1eNOQjgoESJQ7h1tqV6ma/jpHsKS5Abm5P5id8hoL7xM7e9ouUDFTKnpbSU1Ri3BKZ6BIldo8/5LmEITN1KL0u2+fdfBI63TsE58i8M5yeBEGizVqi0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768160; c=relaxed/simple;
	bh=ZE2AWEM7O60kQNA58ZkvgPkhSH4ss7eUl3SaCWj191U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kmLP48Ca4YjyzURRGyVidjVqiQh0DBriPxMA65X/OPTjWw7db0ewItxqJVU3E9Nfyn7ge7owMllJrn4VwTcSRFBc923adu9U8hyZ0KT7BS+5J3+S3G8ytvDF1xH4h4AqLUe2Wkm1jmveWckFxznK2d+omSV+A9CNaYms02cgbmw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=iQYsNxHm; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=hyWnXGeB; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="iQYsNxHm";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hyWnXGeB"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.phl.internal (Postfix) with ESMTP id DB9DB13803F8;
	Sat, 15 Aug 2026 00:29:18 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Sat, 15 Aug 2026 00:29:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768158;
	 x=1786775358; bh=MTJXqUkyboP6nT1GdTre2i6fxL2R8FyE2y1tAnQFr54=; b=
	iQYsNxHmTqnqXN9YIEHGTBNqeP90eSrxSPZEDBAstp6pqBfxQNOGYYj0Ob+LrCX0
	IeJFxZuRNkjRToAglDkBPadPiVj3blQYQA2Yjt3Vv67SmrFA+T07XrXO9GU+3ksQ
	0yq2JfM92++mqmYBnG/k5D7HraoAr76TypGIFwJNSjSsRsk3GHwx075wQ0t3ZAQ6
	hUPIuKOL1SBGQk4HM2WAL8qrI07pfzZvXgZyziktOMS2UaWOHb06zTs9cD5s69tk
	ZT1E4z0JHB5++7i5Q8XMakocUpDJcbs63uSHs0qUT+DuKX7BgoQ72VnBYgUPE8os
	PxeVj046br0Fkrc2vnhHDA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768158; x=1786775358; bh=M
	TJXqUkyboP6nT1GdTre2i6fxL2R8FyE2y1tAnQFr54=; b=hyWnXGeBGBjoTLk4B
	tcBhYbvO3hKJ3RL6PBhXODlknM2ULrDYX83e5FsHeNG8L2lvCr0hmzTTdxNQRXUu
	Mdjcum5s9qXNzugGN86r21ldea9SY8pHyxK6AM2//RlBO1B8oqmnXIU2zUO1XCqz
	qx6iOGXnITXWE41WjJjOoDN6hTtSKE3TP/nWRCEhH4ll7GpE8ALdD3ZFMj7sSA4s
	uk2nEsFUWPUUYpOhac+Yfp16KWoZN6tteoXfY6+2fbhZQxdJR/1SLpwHRw+DWfNw
	A0FPcz7M6K5BWCJOrxSG6OJmQRYfYyG0HQO966gEUizJxHngRyShygSoINB3etiF
	PTwOg==
X-ME-Sender: <xms:Hut_asdfAjerTEj2B-EwSAkAqgr3Tc25GaL1JQT9rJYxFAlRiK4D4g>
    <xme:Hut_ambkSzrpv_BL_ckl89MM0bXa5TfpG7ZJRGIysRlDwLl1aGfbQDwZ2P8_dZwGP
    GrcjHB1RpZX2aKhZ3qdUCjb9dZzbdYPNAK5mz2VGvGa0J8U>
X-ME-Received: <xmr:Hut_ak311AIruE79TvSdyMmPRciPh22hwaMYpjiT8G2GIh59x6exbpezzzrS0v1DiKUld9FDRfycyVJTQf5dNJ03yJNRqj8>
X-ME-Proxy-Cause: dmFkZTF9KskX6ORZkk2qDbanJAqhpO1c3Xju1rB/XGbwQvOGWemlAS7RTfehH6z/blxuZu
    ndq9JpuBON/sKJpHNFmlA8NZthzZuohefFsXvvzkhDLNc/boPY1CbYwGZ3ejocQdZP5Ev/
    BXLTdsGGIGk/QWYctoHjfRUZGHXRv5et6FUSLml8RkvDkfsb7WSgppX3LyXjWcFTLwfp/k
    XOfgf9r/SZsCIW4bEY4xzTmE8sCd1BMMrUIBiSLPUM5HPZAu9IGndquxD0N2k1kJS4EkJO
    uSSxartPr+p/2sBY7kb8VaiOyCHt8JoqHMJjX2cNsGCbf1T449z1owAvKjvcnWl37FvYCJ
    /8WMwfkQVLpPQ3C5lHBVZt7sM9Uzikm2MYqCDrsEuafBjLRBE7DuzED7NYTvSWa5sMEDTa
    CWGxclX/6PIYcR6Qh4v4AE/hAtA2N/j+G+pO9cs9TV6Jla1UrDHwg1knSwGjwVRrUsN678
    MQNZvJxAXot0nE/7DgKB2wKTCeGMl6arvqMiYDPs3Gj0wgiC2CCl7DmITUMPy6yeVjbhf2
    p974jswAGkRxBAJrLKcVaaxk7q27/hZZ52PuTqKQrg8861pX+HdOhyEHBjAwn+I0hNmpoC
    JHQP+fYk2DSVo9q16f7P0FoZSicAzwlBZ0DXk7V60ijseMYd+sS2uuEhkPDQ
X-ME-Proxy: <xmx:Hut_avrF_MEOd4vnvma6IZQBFH9d1p6rIocpqJtqi-gAd5gdODBrOA>
    <xmx:Hut_alwWmVmoTbnYwS3mZPHS42M3c-Wd_X6AiqBjoXzo6KHaikpvoQ>
    <xmx:Hut_aoB5Xz33ogaLeTXaYEF1UKaZ2mLm4IKnaPssaZTf3DnpQLe-iw>
    <xmx:Hut_asNWLH4zvikobLldDl-hbS9LvY7vosU0DFlxwm0OOM21NVdMgw>
    <xmx:Hut_aqcgWXpPWFWM1Y9NYShN3dpdkk1rt5yK0cf2P1bxAqkh3S9YaLrb>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:12 -0400 (EDT)
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
Subject: [PATCH v2 07/18] fsnotify: reduce i_lock hold time in fsnotify_set_children_dentry_flags()
Date: Sat, 15 Aug 2026 14:21:24 +1000
Message-ID: <20260815042707.2535717-8-neilb@ownmail.net>
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

Rather than hold i_lock across a d_children walk, dget() a reference to
the dentry and drop the i_lock before the walk.  This is easily done
with d_find_alias().

This requires that we dput() which can sleep.  Now that no locks are
held across calls to fsnotify_set_children_dentry_flags(), this is safe.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/notify/fsnotify.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
index 90a2121fc54a..4a383d4d8a7b 100644
--- a/fs/notify/fsnotify.c
+++ b/fs/notify/fsnotify.c
@@ -71,27 +71,28 @@ void fsnotify_sb_free(struct super_block *sb)
  */
 void fsnotify_set_children_dentry_flags(struct inode *inode)
 {
-	struct dentry *alias;
+	struct dentry *alias, *child;
 
 	if (!S_ISDIR(inode->i_mode))
 		return;
 
-	spin_lock(&inode->i_lock);
-	/* run all of the dentries associated with this inode.  Since this is a
-	 * directory, there damn well better only be one item on this list */
-	for_each_alias(alias, inode) {
-		struct dentry *child;
-
-		/* run all of the children of the original inode and fix their
-		 * d_flags to indicate parental interest (their parent is the
-		 * original inode) */
-		d_for_each_positive_child(child, alias) {
-			spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
-			child->d_flags |= DCACHE_FSNOTIFY_PARENT_WATCHED;
-			spin_unlock(&child->d_lock);
-		}
+	/* Find the dentry for inode - there can only be one */
+	alias = d_find_alias(inode);
+
+	if (!alias)
+		return;
+
+	/*
+	 * run all of the children of the original inode and fix their
+	 * d_flags to indicate parental interest (their parent is the
+	 * original inode)
+	 */
+	d_for_each_positive_child(child, alias) {
+		spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
+		child->d_flags |= DCACHE_FSNOTIFY_PARENT_WATCHED;
+		spin_unlock(&child->d_lock);
 	}
-	spin_unlock(&inode->i_lock);
+	dput(alias);
 }
 
 /*
-- 
2.50.0.107.gf914562f5916.dirty

