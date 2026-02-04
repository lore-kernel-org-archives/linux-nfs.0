Received: from flow-a6-smtp.messagingengine.com (flow-a6-smtp.messagingengine.com [103.168.172.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BF5A3557F6;
	Wed,  4 Feb 2026 05:09:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770181773; cv=none; b=cn70DPAXw3NSOGL1jSR8IyFZuwIod33PL1v6aR5hmxRYNj6oWxPaXxK0w+txTeZ4M/+PJheen4ieDmOl2P7Md4WSyEWdZZ1N6Qp7OTkkuVJ5qE+8xJd3Lu321mcj2K8kk1x/nlQTXIKSMQ7UjeAvNeNulclEcbGcVFiOzCsEACE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770181773; c=relaxed/simple;
	bh=YqnWdgl+BCgKKNsdBVG/vaKwe9vRryUA+Go53D9kPVQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lbQVRkjQek1qJk6z1fCW1NvjCWToQFoeq+vwinLlxt7MI0VpxXFgwF3IjH000kpdPMM2KIjUfot4vLIam3yrtKAMW+FHA/RCssPEIhPpVVbsBUhCe4baoumFDtvHwbuU52lKsPtm25orL68257nu07VT8LzIODPyxVGenzuxULE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=RqZMQe4W; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=itXUm3c3; arc=none smtp.client-ip=103.168.172.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="RqZMQe4W";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="itXUm3c3"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id B6E671380795;
	Wed,  4 Feb 2026 00:09:32 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Wed, 04 Feb 2026 00:09:32 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1770181772;
	 x=1770188972; bh=9U7bJknmYXYCA1dkmsoUlWkn0IRUITK1b1AZf1IzOUM=; b=
	RqZMQe4WnaihO+TWsj+gd7Ixiw0mbJ4BhG6QYZQDl28w/G7to6z2Kndv/bnsazjv
	ajyTccbCXciqla7nf/Cy66upnAQ7PwKH7j7UyNlSqRgM2068MAUDazTgucqF29H/
	JtskH1hwDGJUCvjohGf1QWG/WrhQsdXx/xeB/vMaKagllaytn0zgfYYaSiGD1anJ
	NoKjThPVYSt6ucv5kuoqq/VacF6CEkN1Jm75ZzSuyixBBCMPjI7NulYyvl1aKhpj
	VoGxFdM872tb3NLpmRma0NQnnTIUWn2xDU+XhMXN/Px/5+1/d0bX7PkS1/ZlE+tS
	Dkaq4V7mZbi8EYCwVWqY+Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1770181772; x=1770188972; bh=9
	U7bJknmYXYCA1dkmsoUlWkn0IRUITK1b1AZf1IzOUM=; b=itXUm3c3OeaQByV6J
	ECwwF2r+B+6H0ntCq8vLw0JfBSVwK1MdJVAetWwZwLOHyd5yvAmM6N6bPlmgKXAp
	HakA6/V3ET0r12K4hI9QCi31A/7kw7UiMP5z0TUh8OAsum+lScV1AOweiFYG+dh8
	SGlbJd5XAmW/AJ+t3wXz03fDlc1Glm24haprX86ikXMVwC+6LbP9//3Zz6ZgqoIL
	NMIs0nmK2FSlzA55qbII4SJbkBJdTbFtmfmmBFGbnJdcCOomYJewWHp4+dGPIO24
	uBEfcBOSSsBvSvfVX/fe2vitlNwnEUD3v6GvR8lqNgysh5FeGTK0Eq/ja3QmAmir
	hyPAg==
X-ME-Sender: <xms:jNSCaeP-N9ufT7_VO9x0KwR9TBY1ecSwFBoBeDdoSbNvBsNbM_kdBg>
    <xme:jNSCaYgfLT9B2OKf-5xHcEZTcWvmhwiSTqIQopCx3xLwCNVNlBszZfMwEYb7N9qOl
    ohcbxxTjYth8qwhtRkiz8UD46q5bdPDMN616KSbo6h1jzk>
X-ME-Received: <xmr:jNSCaVQ55T8dj4D55AaOzle6iviI-hKz_5Q9iLbwaW-jnfgiIOmdSGe9PEvuf8kk9AfnwJxyhcHNR5qDkqnILqynT0CO8ecdAvbmcEhX4fCH>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddukedukeeiucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhephffvvefufffkofgjfhhrggfgsedtkeertdertddtnecuhfhrohhmpefpvghilheu
    rhhofihnuceonhgvihhlsgesohifnhhmrghilhdrnhgvtheqnecuggftrfgrthhtvghrnh
    epveevkeffudeuvefhieeghffgudektdelkeejiedtjedugfeukedvkeffvdefvddunecu
    vehluhhsthgvrhfuihiivgepudenucfrrghrrghmpehmrghilhhfrhhomhepnhgvihhlsg
    esohifnhhmrghilhdrnhgvthdpnhgspghrtghpthhtohepvddupdhmohguvgepshhmthhp
    ohhuthdprhgtphhtthhopehvihhrohesiigvnhhivhdrlhhinhhugidrohhrghdruhhkpd
    hrtghpthhtohepshgvlhhinhhugiesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphht
    thhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtg
    hpthhtoheplhhinhhugidqshgvtghurhhithihqdhmohguuhhlvgesvhhgvghrrdhkvghr
    nhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvg
    hlrdhorhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkhgvrhhn
    vghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhgvghrrdhkvg
    hrnhgvlhdrohhrghdprhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhr
    tghpthhtohepjhgrtghksehsuhhsvgdrtgii
X-ME-Proxy: <xmx:jNSCaTrU29kKFPm32IlYEk22fhaVC4jxLHCt6Uj4smHNqRD4Dwpx9Q>
    <xmx:jNSCaYaJ6YyhBE80ztKBR7oWP1zQcwQoIStR5tslT0q03R0PT25BYQ>
    <xmx:jNSCafHBKNmGBxt3o7o-hNBvND2iF5nhnIgbdVPFvSxS6_FQZvHgow>
    <xmx:jNSCadpyDXkLcZEQACVTKpgRg60IXxYkA-uauS-EIaf7gq0nC__Tnw>
    <xmx:jNSCaW3JgtrYqPCVAVpiKjXq83zT00dSlIEZnsseBxy1XBqXDDb2QxYZ>
Feedback-ID: iab3e480c:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 4 Feb 2026 00:09:27 -0500 (EST)
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
	Stephen Smalley <stephen.smalley.work@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	netfs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org,
	apparmor@lists.ubuntu.com,
	linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org
Subject: [PATCH 11/13] ovl: use is_subdir() for testing if one thing is a subdir of another
Date: Wed,  4 Feb 2026 15:57:55 +1100
Message-ID: <20260204050726.177283-12-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260204050726.177283-1-neilb@ownmail.net>
References: <20260204050726.177283-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Rather than using lock_rename(), use the more obvious is_subdir() for
ensuring that neither upper nor workdir contain the other.
Also be explicit in the comment that the two directories cannot be the
same.

As this is a point-it-time sanity check and does not provide any
on-going guarantees, the removal of locking does not introduce any
interesting races.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/overlayfs/super.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index ba9146f22a2c..2fd3e0aee50e 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -451,18 +451,13 @@ static int ovl_lower_dir(const char *name, const struct path *path,
 	return 0;
 }
 
-/* Workdir should not be subdir of upperdir and vice versa */
+/*
+ * Workdir should not be subdir of upperdir and vice versa, and
+ * they should not be the same.
+ */
 static bool ovl_workdir_ok(struct dentry *workdir, struct dentry *upperdir)
 {
-	bool ok = false;
-
-	if (workdir != upperdir) {
-		struct dentry *trap = lock_rename(workdir, upperdir);
-		if (!IS_ERR(trap))
-			unlock_rename(workdir, upperdir);
-		ok = (trap == NULL);
-	}
-	return ok;
+	return !is_subdir(workdir, upperdir) && !is_subdir(upperdir, workdir);
 }
 
 static int ovl_setup_trap(struct super_block *sb, struct dentry *dir,
-- 
2.50.0.107.gf914562f5916.dirty

