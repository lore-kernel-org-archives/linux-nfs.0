Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4215848D882;
	Tue, 25 Aug 2026 22:17:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696229; cv=none; b=ENOjg/QlX4p02r7EBjLYek4pFa4jNAj/xjUaW+N2upG5hA8IgWW9kbPup6JwVPrR8xGX+EJP8bph/wy0/GtCVWq8LVqOCY+zq1r0HiKwXvwVLzwS6dmlUsPUVu2A1pWhRAYjhR3c+B8XWM1p3n3X2RcPWRMNVh5WyJPKkKKjPFw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696229; c=relaxed/simple;
	bh=Fm6xHhCkZjtxiXpBHP/xrRjaExSJTlDx8x8+SJ0yzhw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rArkFd1oBdV0mICiRZI9K3Vn9A7vdlLuZEMgaCLdN32rFeFrpR/Dey8NpwSwGy03J7Cn6p2xft/UMb1rmUVKlZyLm4GS2GANbILXveZVdMt8SwhSbyGD4t+C4kebH7dzk+qmMvHY0gC7Gm3ww/8udC1AepTgHlB0kSk6GeT7oW8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=pnU2LsrX; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=RGuHdiI4; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="pnU2LsrX";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="RGuHdiI4"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.stl.internal (Postfix) with ESMTP id 5CB1A130017A;
	Tue, 25 Aug 2026 18:17:05 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Tue, 25 Aug 2026 18:17:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696225;
	 x=1787703425; bh=gWfvCddiL95g7aF3HuSf7fyTkicRc4rwTmcdcNoKwZY=; b=
	pnU2LsrXVFhWceDm0Iiv5tsiRbgjqGIEk0grlwIhEiQl2QII8vIdn7gOZ32DobtA
	delgYe6nF6h8b+I6K48OOvLnOCRBLonvDtN52BZ+XJ3j1zBXK3XnjGkIV6pf6vP7
	Nn2GXo6+xj59prJlcRAkAPtpGLL/giYD1q0GGLSaBh/fMH0p3ovK4AOYyjeAIjnj
	9pAbCI6kXS5Gd4XVe/P4wNLLYfVGWVTmmh0L2NYdeep7GzjoiN0v5WheCInI5AJO
	HCOihDADhnsZB4u2yU1u1JXanu4u+RtwY+tuThyP5ZtkK//FiBZDRjViJvYo2RSt
	9dxiZrR1SAfD94VzVaGJ7g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696225; x=1787703425; bh=g
	WfvCddiL95g7aF3HuSf7fyTkicRc4rwTmcdcNoKwZY=; b=RGuHdiI4bEQhgWrQ3
	4gMgLCOUOSVYzLelqCVtvO/KQhu9nc7klrvy7a1TBfxC4+IZwvFAS0CGxf51+1PS
	X3cuqycizh6UAr4kd3pREE8S12+tef84yesd8aCrHItP8cACVIwYiKUpXXEAiJ8P
	I1tXXEfFO1jAdKDlenxxwnnt4ShdZOa3vDruASXkQQenN6ak2KC73fZUGc7tv6aG
	uz0cwXVQ+PI6Z/Uk5M65oaVIojPlTJEbN9DWdCxQBhBurtDznznFYQGbQNdeE3Ea
	VeOJb6A6hU9m9TXwZB4YAgIDqngYSZ82smG4UExqOwqAH+1xo8o6XuE0dDNkb1kK
	cSdWw==
X-ME-Sender: <xms:YRSOan5Jpzh7EgPZN9DwuHG_MrysmorJ5AGABJ2c05IqGOIy4-WNHg>
    <xme:YRSOan6PReFZjizDxjpWeLMTMB4fWlWpSCMJahniL000HeRTX67XPnvY46S5BQoaL
    HZS3rXzeaVTZ6grgSx_Wx2XQl7TYoIZ-pdtuWMZI0F9pOOl3Q>
X-ME-Received: <xmr:YRSOalGfecTnKoz8A0uLOWr8zfVOx8Kp9LUN8uL9G9DhgpgGfpPsOAC1NEe5dfTb-1QcfHjdVaIsDcZTSkfvFKbYF5LzQ4A>
X-ME-Proxy-Cause: dmFkZTEjJ6W0pcv5dKdBouhAeA3W1aBgLlKUugU6GgJEe14GlOW3sqsKABKbiwQbJ/fhnC
    08rS3L5+nyLVGVEl53EbOBH413gsqznjvALzKGI2w6xxkZTK9kVpUzqbInp2P/zHn32egQ
    fbo+xbxKrE3W063gtvBfsGJY+4a/GENFrlKN+jgA9PT7gxbetJJs7zoKTbHRWcbnq04XFx
    Vqogj5GlCQ2eRDL1UggSUnm0pkXFG1ivud2B/ZAs+pu6/L8iCWuNjQj6Wckw9lzCyE4Suh
    SbIvegTnRH1aMPQmF96L4x1YdiiUn3LaW6be9Due+JczR4uCvQU7J/6xYUWeSTX4maHtXv
    LdZklf9dq9Q/Jm4OQVtKuWFLlU4aP93Aplm1kF5E0mVUrUbjRDwB01fpkXzGpcUVTcr0tT
    ieDUvUvkyzMwL6ZN69980eu52IXXTVGihmCCyTjDeXkBJSsG/wgDZNcReh+LGsVW3aykBB
    /Ow+6yT/mO+WQikDsHsAQKkQZkEWhG4BI+7hOb3lER6IUolF2kEbclHMYijTEPYPcZ5x2l
    wgkhKrOAGxra6/+TQMIUnqbW+sfhqyYB4eJjTYI7w4kxs2yIfI0nNCKhHnzFe1HmL3o+qn
    dbIlSdHzLxeCzssJySxA5m7PWguHAbXaj1R0xO3ZfM8OXqgjIwA/0cb5Uarw
X-ME-Proxy: <xmx:YRSOalyt4AgqtpABnyHwvt5VKLxDCiZ4DB7es2g-Y4Y8KX5RRILx-A>
    <xmx:YRSOal2eK4zFAW0FYO5_XD7Vi4LDEQkN-sCXkbS_n9VwRItzCl7inA>
    <xmx:YRSOaoMqONstq5rnkPz2tlZo411pTZ5nZQ3MuD38gHrrRFpzZh5rlw>
    <xmx:YRSOahsYKsDvhuoPXA6u0ToYW6s17ZPilYojoRfh2q2efb41gFKPiA>
    <xmx:YRSOajR2F6f69FPPMyvokWXo_YmZppAXUhrQRb58RhLSWwfAAXjrnVbz>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:59 -0400 (EDT)
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
Subject: [PATCH v3 09/11] autofs: don't hold ->lookup_lock in get_next_positive_*
Date: Wed, 26 Aug 2026 08:06:26 +1000
Message-ID: <20260825221459.966875-10-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260825221459.966875-1-neilb@ownmail.net>
References: <20260825221459.966875-1-neilb@ownmail.net>
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

I think the presence of these locks is a hold-over from a previous
locking scheme.

Signed-Off-By: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 3a70f861ad32..330c40a17a74 100644
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

