Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6824D2E62B7;
	Mon,  3 Aug 2026 01:38:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721123; cv=none; b=eDmWfPrfJC031hpc3k29V+3LEneUq7dA1dKfe3gdJ+inqgaAuKawXKgnijWyRZvpN9KQM+rs1ulIjCtL1I6W/BUtmzbyBJXuMPuyKjJhKN2/eT4pBs9AbtFAYB/d13bv9rN8o4NNT2vuqE7ZgnX39lLWZ9gNIUs1xkwjmyJK814=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721123; c=relaxed/simple;
	bh=+3Idv6bxMqOnuq3JEZvBj1oxzFVrITpJmZ12zRTky1k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F3CS9/trJ4i4pSon5n/4anJH7MaRqTP+n1v7LbeRa/gdIKWXJExRZD6+PWz3Ox4H3HD718VxxRvQ+fKkdBI4w0Hmcc+bTGswxhTaHa1lfepnzlbfeQuOTRvpiWO/gkhZIrnIFjNd0pdALx+22RnBSYnWv0NWRj8rLUGPl/VsamQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gZlZu9WJ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=jYR2Tw1c; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gZlZu9WJ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jYR2Tw1c"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.stl.internal (Postfix) with ESMTP id 369A71300113;
	Sun,  2 Aug 2026 21:38:41 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Sun, 02 Aug 2026 21:38:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721121;
	 x=1785728321; bh=+K59W8wegJRgf4rZVwaCEzIeJ3KAOgf2KEvJDu7Itzk=; b=
	gZlZu9WJFcmlVE8++0HlLN20+XcGxLuoITGWEGggLbzuvwtNr0gvdCgGVjl6giJS
	fIOGnzZ+3TKKA3jN7cvLDt1hDF66dxhmhGLmUeOEW2a2+2IIOIt9ID3/638fEN2I
	qq3Tz+cZQHfF4WhNBP/v1GXBXT3RtWuA2P44oR5zI+aSnceOtjSyEW3LLtN2FXrb
	Fl4dxAcIG1LFzXkgG07la2gMZglENBn21/9tfhqg07oZ0F8GVzs4Lrjt0rMqXdsL
	sZzM5MtoqD1xO+9aW5ueAAgwGt3Q8X9VpDf0I2rE5RQUIXEClyOL8t8UQHzYg36I
	Y/ebO+k+07kU6F+QWlEi+g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721121; x=1785728321; bh=+
	K59W8wegJRgf4rZVwaCEzIeJ3KAOgf2KEvJDu7Itzk=; b=jYR2Tw1chu2Z0fefB
	yE8Mso7Z/uBk1feSgvruMx1Qvqeh31Q5SrsY5otL2nHQkQ4+ctY6JORdipbjBx0J
	VFmXjQXXHwuK3i5EpOkcbuRGph21EGcbpYOBM8d3WUuffbp1HGgVIJQmQG6aUoI0
	hu1QqPLqBeESrTmyXTKpciz1x1QUQBCGKCmtXDrmrR/X+SPVyLJA1aRmcTUubepf
	hOoDCugXdSGASotH+Q+UZVTHPYGmI2ZJ8uYKKwlfLupW5Znp7coBKRMpRUgiqPxN
	AGa8j5MkgPTLOhwjo8thjn6PpWg0lNTdnn0/AL36ZhW3qnKK+31SXrYzHnlWV9B3
	oE8Jg==
X-ME-Sender: <xms:IPFvaljzeS0pIp8PcZffofpjUHu7PE4b4fbo5zinDsWmff2WXR7a1Q>
    <xme:IPFvalC9iQSlMETyLWXo-90wETp2uCNFRXr4IBY-_c-OVJXfHUao059WioCR7RCYi
    DPXxxUldivB9EhGGGYmCAbPiCqxM6XSARa0D8sLrsx2LaUu9A>
X-ME-Received: <xmr:IPFvarvNQ2NQ-4qnjOS_RHu7tSl6XSCm68oy2Zmfgep7fHcvdLI_F6UKzH7IB_VIwXLRHP5NdA7WPLnlnRP_aV3R7fR4-Kw>
X-ME-Proxy-Cause: dmFkZTEkjpQitAtmxGBQYKqyuxI2Zkeo3c6RoaKCNErqeb7OpTUkwok+umPK8wjjzKilLR
    oEkJ4cvJVGjSJ84RQAU1yMp4OnVAa0j48I+IZh9Fdm8T9NlXb22vW2b++I/w1xpR0D9cGg
    PY5vxXMwbazIrQndnHZZeUaDjtiO7oMO4JfvURQOW8xpTRIAhWmk/yj3tGiTCFDkK11PUi
    8zP+PAM6p9S6yYk+YxJK09JqJLxfofUFwglAMcxid0fjJ/8eCuMBF6ZgJ9khwYNTvmmvDv
    XHb98vv+s9pbhqVhgG7tjgoBPJWqvJT0PbLNRH63wXqa3Yd9frMtJBXjxnj2koyaKciEdI
    bRbRUQ3euKwQRaJmomeMioKgyg03Gsf8sWYRPARCdg9ZmzReBQTpAcs29YeE1w7xi/MfQr
    8P+nRgrFcRmwZgGIQrovzK3fawYO5NRUJEpbBA2+n9kl8fnyOsy0rz1efQypHE+Hhp4WW9
    bc0XlBZi78SpfbzaqVsMsJB2YrdputGlmucUr34SmSbnDXU42O53QE4FatftoKdy/JWkvu
    /vuv+V+QvXf07yHfzDknLcfnGrVoa8lIhgyL6tuG8J59arzxB796XURKGnl/mUyMU6vyb7
    jVMmGLbjidEC7RaL7MFpOiAlD4kZRfYhQemaKB17A/y6yQbi+uaXO6Kw1wYQ
X-ME-Proxy: <xmx:IPFvan6sYQBuAV7OHmL4ByCoNxljle4GWk4vGpw_3YOVyFC7ua9RaA>
    <xmx:IfFvatfLqIIVnNs8stVidBoBm26HuAhhGP6e_mGuoT58pYKG9fw_8w>
    <xmx:IfFvanUj2P3kS5vcjKhU1kFZILFoRXJ6sPOjnf_QupyqSNADCdYaeQ>
    <xmx:IfFvaiWDCJOfYsllWp5wz792mjfwAE0YEmIEDA1miNMbxS3hFDm4pg>
    <xmx:IfFvagbgV1NJm7EpAeq-ciy0ojglJAfLUo_LTTF2JgAP1JQOfikLy2jS>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:38:33 -0400 (EDT)
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
Subject: [PATCH v1 09/12] autofs: don't hold ->lookup_lock in get_next_positive_*
Date: Mon,  3 Aug 2026 11:21:18 +1000
Message-ID: <20260803012648.2195405-10-neilb@ownmail.net>
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

get_next_positive_subdir() and get_next_positive_dentry() currently hold
->lookup_lock while walking the d_children list, which a subsequent
patch will add schedule points to.  So this spinlock will be a problem.

The only data structures that a protected by ->lookup_lock are the
  sbi->expiring and sbi->active_list
lists of inodes.  Neither of these are accessed in these functions,
so the lock cannot be needed.

Signed-Off-By: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 7b0a22629415..704d5394cbb8 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -91,12 +91,9 @@ static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 static struct dentry *get_next_positive_subdir(struct dentry *prev,
 					       struct dentry *root)
 {
-	struct autofs_sb_info *sbi = autofs_sbi(root->d_sb);
 	struct dentry *q;
 
-	spin_lock(&sbi->lookup_lock);
 	q = positive_after(root, prev);
-	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return q;
 }
@@ -107,13 +104,11 @@ static struct dentry *get_next_positive_subdir(struct dentry *prev,
 static struct dentry *get_next_positive_dentry(struct dentry *prev,
 					       struct dentry *root)
 {
-	struct autofs_sb_info *sbi = autofs_sbi(root->d_sb);
 	struct dentry *p = prev, *ret = NULL, *d = NULL;
 
 	if (prev == NULL)
 		return dget(root);
 
-	spin_lock(&sbi->lookup_lock);
 	while (1) {
 		struct dentry *parent;
 
@@ -124,7 +119,6 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		d = p;
 		p = parent;
 	}
-	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return ret;
 }
-- 
2.50.0.107.gf914562f5916.dirty

