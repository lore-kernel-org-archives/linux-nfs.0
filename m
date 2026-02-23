Received: from flow-a1-smtp.messagingengine.com (flow-a1-smtp.messagingengine.com [103.168.172.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEF9820B80B;
	Mon, 23 Feb 2026 01:13:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.136
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771809184; cv=none; b=R6Ae6Xl3Lev68LxJrAJmj6Rb8ZdJu9KF0FX442P6ohY6kR+gtq7iI3NRf5bW2czH2PNnL340cGraT9C8GuHh5bHMnNkI6VcR2cn2gC4rZITHA4c/EeXw6P+fvQ0x0l/TshXDePIVF5ysB8VFn+eA/RN9fGGxd+wNe5r1XkZmNLE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771809184; c=relaxed/simple;
	bh=zFiJHa4JpTLhCUXW4JYDY9QePHuxSGmxqEgcz0kVMNs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QUeOfG/obptF7pFMzoIKm8d5h51n1nrNNWdGefo4zuNkB+EUcaXFuBeM64VeO2jB0GAfEKrCSsprsXMl2LU4B8CStPAl9cre1aRBMuTmuiWvVaRDL942FWGA09VtNed5Osc5zu5ojo60piBoWM6fE/MzrMBk0ykmc0AbjkasQuU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Y+szD3Yn; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eVhfSbgh; arc=none smtp.client-ip=103.168.172.136
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Y+szD3Yn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eVhfSbgh"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id 21CB313807AC;
	Sun, 22 Feb 2026 20:13:02 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sun, 22 Feb 2026 20:13:02 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1771809182;
	 x=1771816382; bh=F2ruswJ16EK8VK0D0nBKaLrqHDOOMda6+QvATeDl+8E=; b=
	Y+szD3Ynj5pQxiT1amJ9JRzMiTU/5dq33ZQZsAJWRtpNKRayvYQwTypJhnvy/ojZ
	BZ+CF73qMI7UJWEOTstRXc1SFji9Ox8lCS6X/tJeyYp9vSwWZrB3JCJZvc3Q4stt
	EdjynsjtTO8UabzpZMp4p0QQLSsuwMfOWUqlNvGx7t9WPLrSwLjHSuzet7Kz7QZo
	obKcMNSPIQr6N4oCh4N0FgMWV7Gj+Bogh/vukVX+A9PQjvEXQjxhV9996InFpy2m
	oUS4P4vBecwQYHne/HqIYwK66sJUTdQxiUj1W4jBidfgHhdD6iOTjn/VYiwcst2h
	M/n82QyuTwdabyzA3vr6/Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1771809182; x=1771816382; bh=F
	2ruswJ16EK8VK0D0nBKaLrqHDOOMda6+QvATeDl+8E=; b=eVhfSbghVue9dXdoe
	Nlq9dlIpBi/bXDjuQIuQiSdyRz7ZSqLucVqmD977FWQT8t1xgmG8dcQ/65SlNc9F
	h8m/MBmuI3KIxq2kYhv0wKk2C9kICoGcCwWHdn0qlaZLJWbfQbks2zbtsG0K+wOc
	3+nbwV6oavX5vUBUwlpskR2zQiTeRLRpi12hYBPw7kAEX/aDJXYcNMv+PWxlM0vq
	Sc+RelU5LcmPgTCtP72z/L6nSv2o+VoDXqS4/h0kU41V9kIqzfpZv53jske+bRxF
	sr3ttbBIa601YHzqJhscY+66qaq/kYV+OdtWR+7rs0JB+V8Oeu505CwhoefRxQlP
	dSw/w==
X-ME-Sender: <xms:nambaS-UAv85VtS3xj0mMiSIIY9BbNdxpJUyNSLiJYPIQpuwDE8eiw>
    <xme:nambaWqZuRAaAFC-OK6HnOzWTGVw8_wNk_nGSSRGIeth6C8verBLqvz56D7eJeDcF
    X73AXHLnPH4vJYQEXAE2iF6urUE3I5Ha6G6FWqRKbD-WfAP>
X-ME-Received: <xmr:nambaQjOUIFx_bY-zlpcxAIvcEtBf-KaL5dfECizuZxX6lNcguuMgpP4EWLk9j2bInAVyzpBPXtrxfuZlaPdmbCKe9DLCMWPM7kg_f0UHa8f>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvfeehkeegucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhephffvvefufffkofgjfhhrggfgsedtkeertdertddtnecuhfhrohhmpefpvghilheu
    rhhofihnuceonhgvihhlsgesohifnhhmrghilhdrnhgvtheqnecuggftrfgrthhtvghrnh
    epveevkeffudeuvefhieeghffgudektdelkeejiedtjedugfeukedvkeffvdefvddunecu
    vehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhepnhgvihhlsg
    esohifnhhmrghilhdrnhgvthdpnhgspghrtghpthhtohepvddvpdhmohguvgepshhmthhp
    ohhuthdprhgtphhtthhopehvihhrohesiigvnhhivhdrlhhinhhugidrohhrghdruhhkpd
    hrtghpthhtohepshgvlhhinhhugiesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphht
    thhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtg
    hpthhtoheplhhinhhugidqshgvtghurhhithihqdhmohguuhhlvgesvhhgvghrrdhkvghr
    nhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvg
    hlrdhorhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkhgvrhhn
    vghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhgvghrrdhkvg
    hrnhgvlhdrohhrghdprhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhr
    tghpthhtohepjhgrtghksehsuhhsvgdrtgii
X-ME-Proxy: <xmx:nambaUD6vvkPX4AAfOLjeIGp_m2IH6QMkoK9EfVq0_FoEav9czxd4w>
    <xmx:nambaetf7uzY2gIehqhiHp90njXwxuwiK5RlLgdxZ0oMA5wndC3lxA>
    <xmx:nambae4KmUFLs6UT8nRadTKWJruhmxxsDzTc8DVJvsOft27m32zUrw>
    <xmx:nambaYehVDWoyM5jfXdY3DTLkReLv8rLKsgbS1o6jxbGTz2Zk0fPTw>
    <xmx:nqmbaSGqOa6WaCwYYGhEbWOmDI4U699_PXeZrYZ4DW1qNiX61CxsHgkg>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 22 Feb 2026 20:12:55 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Amir Goldstein <amir73il@gmail.com>,
	John Johansen <john.johansen@canonical.com>,
	Paul Moore <paul@paul-moore.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Stephen Smalley <stephen.smalley.work@gmail.com>,
	"Darrick J. Wong" <djwong@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	netfs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org,
	apparmor@lists.ubuntu.com,
	linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org
Subject: [PATCH v2 03/15] VFS: move the start_dirop() kerndoc comment to before start_dirop()
Date: Mon, 23 Feb 2026 12:06:18 +1100
Message-ID: <20260223011210.3853517-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260223011210.3853517-1-neilb@ownmail.net>
References: <20260223011210.3853517-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

This kerneldoc comment was always meant for start_dirop(), not for
__start_dirop() which is a static function and doesn't need
documentation.

It was in the wrong place and was then incorrectly renamed (instead of
moved) and useless "documentation" was added for "@state" was provided.

This patch reverts the name, removes the mention of @state, and moves
the comment to where it belongs.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index e4ac07a4090e..d80b81a1f06a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2893,20 +2893,6 @@ static int filename_parentat(int dfd, struct filename *name,
 	return __filename_parentat(dfd, name, flags, parent, last, type, NULL);
 }
 
-/**
- * __start_dirop - begin a create or remove dirop, performing locking and lookup
- * @parent:       the dentry of the parent in which the operation will occur
- * @name:         a qstr holding the name within that parent
- * @lookup_flags: intent and other lookup flags.
- * @state:        task state bitmask
- *
- * The lookup is performed and necessary locks are taken so that, on success,
- * the returned dentry can be operated on safely.
- * The qstr must already have the hash value calculated.
- *
- * Returns: a locked dentry, or an error.
- *
- */
 static struct dentry *__start_dirop(struct dentry *parent, struct qstr *name,
 				    unsigned int lookup_flags,
 				    unsigned int state)
@@ -2928,6 +2914,19 @@ static struct dentry *__start_dirop(struct dentry *parent, struct qstr *name,
 	return dentry;
 }
 
+/**
+ * start_dirop - begin a create or remove dirop, performing locking and lookup
+ * @parent:       the dentry of the parent in which the operation will occur
+ * @name:         a qstr holding the name within that parent
+ * @lookup_flags: intent and other lookup flags.
+ *
+ * The lookup is performed and necessary locks are taken so that, on success,
+ * the returned dentry can be operated on safely.
+ * The qstr must already have the hash value calculated.
+ *
+ * Returns: a locked dentry, or an error.
+ *
+ */
 struct dentry *start_dirop(struct dentry *parent, struct qstr *name,
 			   unsigned int lookup_flags)
 {
-- 
2.50.0.107.gf914562f5916.dirty

