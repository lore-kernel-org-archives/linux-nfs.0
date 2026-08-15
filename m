Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7EF423BD06;
	Sat, 15 Aug 2026 04:28:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768113; cv=none; b=nl8Hwwu/ORtsjYoc2SKLOEPmIPFJl3GXz93OJMgdWIunckKsmDlJQjrfP5MrrL3RyM9D2pRUNjbYd/uoy/UV2RfOFse70tdnob/aMb6Jlf2PxN/uVHjOeN6+5bWHr+iEoqWdNxCwGGs08+CZSbgrmdSp0f4R6Cx5v74dakyiAkA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768113; c=relaxed/simple;
	bh=H5SH3/ro6ITe1unbKv6X98QtZBMK8wgTThIC4wk+kBM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rkaJwXr5xwFl9qaSlcdoCuriKC5xg/dMVg9OlTZgakZiuk/ALaMh6Jo2SnuzgjIEqJwQVJ6vN8qf9LICtJwiSdyitZ0Ws3zLrEfxSSefogyO1aMrKxOA1uigeGXynIZnPDghukYu++cdf2z+2UTthqbEkhmG5p+ziVLZpP2Pqf4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=V/p/o4WP; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lBBmDaW9; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="V/p/o4WP";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lBBmDaW9"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id D747213803F8;
	Sat, 15 Aug 2026 00:28:30 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sat, 15 Aug 2026 00:28:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768110;
	 x=1786775310; bh=vhLaq8TeacEW12FmtPepvksnJ81hegqNRNrapfehjX8=; b=
	V/p/o4WP0WcwfrEWun9wojoBjFslQ2KR8eymAbIyfKXYJhmjh2zpPd5HWeYzYXEI
	VVr33kr/8VNLYnXPLh/xYsilyGiRfVWHluoMjMUMJXLQ5wrOA+Z6LEAZulJj1qv/
	VvM2OzsQDxWxfEQRdAUs4koAkrdm2U+kBOtft8OtuwMjV8080Cu3xYk8hNWf7tGG
	fztY3DHgBmW9e7WZkXNLSnQsaT3jzqz1iOojp5Apo0vcDM9EmggbnjICsd6SyZ6P
	V7Jinv47FA/fNAPFu1sYIyOd5U41+nNyaZICtQqqC3ATBfwZL6tyIi2Gdm1Wx9fz
	eT4ScfyF3PWtj3XyGsyapw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768110; x=1786775310; bh=v
	hLaq8TeacEW12FmtPepvksnJ81hegqNRNrapfehjX8=; b=lBBmDaW9o3UkM1erN
	lpxbHNJXIhY2pOMT9LR1O+n1qTpOImF9zp5gedc6gsZxqqaHiQqu1RazOM5d8OzT
	V7nU7MgfWBvejQIKJ89ie47gAtEgi3O/i7ikhTsvedTvWyErZt/khfAmIa2msaRR
	oYVEffLxk5Ejn4vBAdVW8xMHxNoVAG4wyyWifpx1lMLG4GYTPk1EkdTun4dgUsaI
	eeObrdoeAD1v5AIw8KP0PWvnSF2/GrYU8em5nRBCkYUmjf5xmwnKk1eX0nzXwjJq
	jFobsDFxiVdSPgoZiljCB7xEygQsvBv5WXcXTcEYUgcb0epxgnUxTqKQH36oZyac
	Tm90g==
X-ME-Sender: <xms:7up_aq_TDof6Z0SVMeLx7cIgKGHhdR9S43U91E_GdBF8Qq30Emjt7g>
    <xme:7up_altsryzcOkfydnvISCM9jpCP1oJr8SD0B5JNNRm5q0NJAaZ1Tz-72bIHHSaOQ
    XBKP6Euviaa7g8Of96MIOUMMOLG2gn9uEvbPCjil3DD2uJ6>
X-ME-Received: <xmr:7up_amo3tz7QqHD1VjMBJkjEq-w4R588YAJfg6Ks2n6WrzlHZ_4OX4qDLQNTYW-GTQJcTf0WcP5Qnf1VYnN2csGUO9wATwU>
X-ME-Proxy-Cause: dmFkZTGxKCIJg189DggFiXo5ZJL4dIjbhm46neB2Vqz0yysnTK2EEvZfyUO+W+5VylOmxA
    MXt5kdik9jz+bmdCUGG9zhM/yC7XCFdf6P2fYdm8xoYAkS4lmA5u96Kjpq2TeGn/dPFbKL
    mULzfOuDXcNtV/w8ss/fVr14WSq3NSOCPLhEhjAPC143exYjC0qGmAPeJSTejsuElTX1t+
    XC5iq/pm2rahqBTv8qgJG6LygUrvIIzUau+lgT4YNtEUmALkB88s8XvdfVuXa0aHqANFgm
    TtvBEfNb5mRkIrhcsMJtSzP4V6xOiTZaNgnWWaBZgJzE/9cocWzpzl5kcQPsd0HyLX0eMr
    YAbw5tYyR7joh4+2EBy9c/8oggr3yXL2s0H5Z6uMmkWP00w9VqaPyh8NbGrhoT7zl0MOOy
    TfEkwe+LH/DNUh7n1MO4ZjHSUKId3FwShs7sdUQ1TJIs2eJ3juFCAtzAuyK0bl/9yp2xrx
    ORdVMowDPiG/Ef1wms65ffMPJ0dD+zgBWGUSuAqbBLs7y02okxkILz346Dsj3GzazCdPn2
    QL53Wd3dT+Q8GZKflBMhoMWJi6XVPuqNhi7Fut/F2KZzjh7EaenT0nXlalxL5jm7Zs1fAs
    MSc/LuWOCPfh4nX4eMa2qY4CTh1BMoU9pbp9yrC0WJqZAJCNY9xXlxZPoPWw
X-ME-Proxy: <xmx:7up_agHmzFAxeZZXrPWcD113kd-brOBJyXoSkK7QZsAJhmAAV7Ud4g>
    <xmx:7up_ap76v7RlyBU4FEZje5t0XyAxUUGZrj82aUUW6vc558yHbhkuxA>
    <xmx:7up_ajDYMdfiYSibmhD3RGAyo4PVBUWHRODWE3Q-nzP-mUV7w0OrtA>
    <xmx:7up_asR4_nwXQ29qezffIJNrZSQiuBhcj-vX_ibZhnj-DkJCspS0MA>
    <xmx:7up_ajEDV0eIyFDa48UsgPuwQ4DU1EtkcCX0xf6SwzfB6Q66p2vV6rNh>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:28:24 -0400 (EDT)
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
Subject: [PATCH v2 02/18] autofs: change positive_after() so it takes d_lock rather than the caller
Date: Sat, 15 Aug 2026 14:21:19 +1000
Message-ID: <20260815042707.2535717-3-neilb@ownmail.net>
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

Moving the d_lock from caller to callee simplifies the code.

The only non-trivial code that is no longer locked is
		parent = p->d_parent;
and as autofs doesn't support rename, ->d_parent is stable
and this doesn't need to be protected.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 5c2d459e1e48..909622eeb8a0 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -70,9 +70,9 @@ static int autofs_mount_busy(struct vfsmount *mnt,
 	return status;
 }
 
-/* p->d_lock held */
 static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 {
+	spin_lock(&p->d_lock);
 	child = child ? d_next_sibling(child) : d_first_child(p);
 
 	hlist_for_each_entry_from(child, d_sib) {
@@ -84,6 +84,7 @@ static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 		}
 		spin_unlock(&child->d_lock);
 	}
+	spin_unlock(&p->d_lock);
 
 	return NULL;
 }
@@ -98,9 +99,7 @@ static struct dentry *get_next_positive_subdir(struct dentry *prev,
 	struct dentry *q;
 
 	spin_lock(&sbi->lookup_lock);
-	spin_lock(&root->d_lock);
 	q = positive_after(root, prev);
-	spin_unlock(&root->d_lock);
 	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return q;
@@ -119,7 +118,6 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		return dget(root);
 
 	spin_lock(&sbi->lookup_lock);
-	spin_lock(&p->d_lock);
 	while (1) {
 		struct dentry *parent;
 
@@ -127,12 +125,9 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		if (ret || p == root)
 			break;
 		parent = p->d_parent;
-		spin_unlock(&p->d_lock);
-		spin_lock(&parent->d_lock);
 		d = p;
 		p = parent;
 	}
-	spin_unlock(&p->d_lock);
 	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return ret;
-- 
2.50.0.107.gf914562f5916.dirty

