Received: from flow-a1-smtp.messagingengine.com (flow-a1-smtp.messagingengine.com [103.168.172.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06C4C20B80B;
	Mon, 23 Feb 2026 01:13:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.136
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771809217; cv=none; b=ssBQEF98YTivLftUGLB3Yh7Vbc+m3MOyt6G34j+me9fCYs3c8iEXJniqo5fV9KMUuYRW5CuvHLJzwNry8AE9/Xoo3GIK0qGr3k9uAe4dTtCQ8Lian50iC9+tQiRCMfjTs8knzmvIWvDLby3i7O+64bt9yQ6xdCGyjCW+N5pAG0g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771809217; c=relaxed/simple;
	bh=KfiYIcpQGDA7CCeuR5+khe3o6J1hGjpGeg4/kbtzg8U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=d1CbgVt0nfg+pNq6ZX34tPXbVC1xpXGTn0Em0BVuw39Z6SYnmqNVK1CRojWvMFIqu8KGiXSm+YtPuuUeNGWxKCMUeUPT3f+/CH9vOqAheuB85gewWq2X3R4nG7/8jNaeuV+X7Ltn55tBT7HPqn+x4J/fkvcjDbVAd7DVq8UfiVk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=M5ZrAVtu; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=RyNEPdPV; arc=none smtp.client-ip=103.168.172.136
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="M5ZrAVtu";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="RyNEPdPV"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.phl.internal (Postfix) with ESMTP id 5216913807AC;
	Sun, 22 Feb 2026 20:13:35 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Sun, 22 Feb 2026 20:13:35 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1771809215;
	 x=1771816415; bh=rVzESsgVzPWBQDwiGwCUvziOL/TfwILm1t61in7kI2M=; b=
	M5ZrAVtuV+PdVHr9uFhB8hdnMbNrkxjSPb9aGj6UZj2B0R4MaP2zrrIpVXCT0eC0
	T0J87kJmibYk/c0l3mzGF8nl3CSDj9A7AwG1J6GdaGMkJbCxiMd9ILZAL4aHDvMh
	dZwt+WXbzi2kv4LxVWNBP2pM7lPZROzi6reLd9VS6g6iRSb2Glbqxh8hhpsxR3yV
	eONlgS/w7oiOjPTjcK52M6B7pD34PcaWF9ACVj59uLfuklj+yOIasJhj4b8uh72t
	BfWu1SWCr6DgylmQGHluN0zhti5OgrToqLM8YKaXZSY17xb7etOPWJBBZrhJfb+j
	gNwrS42KI+rSDLFKp2GaDw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1771809215; x=1771816415; bh=r
	VzESsgVzPWBQDwiGwCUvziOL/TfwILm1t61in7kI2M=; b=RyNEPdPVWI8tYYRmn
	AymLeVyaHAUgaLIk6xTbA7+8YYKfQJj7syS0+jcTrJXAse8mL+m51jFmbBtds1t1
	aCYXFTb/BlgKNBlAzfmyBc0/JnWK17c60iUx1AZVFJaWBCzfwtQeYwBWyoc9ac0D
	nRxPXeL4wEWaTTnSHNBNrwcU/h8zXb7U/iZ6ELdwFyUclvhqovcmdc5nw4Hykbma
	HCEsAkoMssBnYQKt0bDC+/B6LncfKBtUVcuyuPedUC9hRdHbP1b8r8WVgz6lg1/5
	PNtZ9H6nJ7Y4siqo48rbX80TSZYjcefHJ+zP+PNNM6KNIm6MDEZBAROw334nhVa5
	2YANQ==
X-ME-Sender: <xms:v6mbaVbdZLa-rxQs9EqxXHFKVWq-q9JCrLGSNGmOsAoK7AkH0kqEfQ>
    <xme:v6mbaQXJP7W_-CkYspKhZbi8ZKpFWfllqR32sX3vx0djhM-hz67ukp8n48ZECgAAp
    w-AkdWPDU-QDSmF2CtAU8usasDO2AVgD3C9gWtd4fisrRWiwQ>
X-ME-Received: <xmr:v6mbaQdVHGoZD3c9oEsL4rB-BNVF5zM8QFhSyl2cn3AKHRLJIBdmXC_jWIleg1kUZLZGO-eusJKsZzRoqH3wKYPn5bC5rXSYtOQFKWVjgf-J>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvfeehkeegucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhephffvvefufffkofgjfhhrggfgsedtkeertdertddtnecuhfhrohhmpefpvghilheu
    rhhofihnuceonhgvihhlsgesohifnhhmrghilhdrnhgvtheqnecuggftrfgrthhtvghrnh
    epveevkeffudeuvefhieeghffgudektdelkeejiedtjedugfeukedvkeffvdefvddunecu
    vehluhhsthgvrhfuihiivgepudenucfrrghrrghmpehmrghilhhfrhhomhepnhgvihhlsg
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
X-ME-Proxy: <xmx:v6mbadOOxIgk6QRH-SE2aSLI53rgE9_-aD2T-W-mxXT3r84brZDwig>
    <xmx:v6mbaYK0TkcIk5yACvAR8JZnEKa5TPLMw76dHXnFRTVMwoHl8yfKjQ>
    <xmx:v6mbaTm50DWRBYcs261WWw9jkAZAcr6kZ6INKKBbuIgElOJPp4rwbw>
    <xmx:v6mbaXY5xe6Zw7OEwdsvSc1GoLXrYfZB2OthNtLIVGnKE6xTuhNQYA>
    <xmx:v6mbacToUlu22gknl3r-RtDNvFrAC18iLW4VWVWHEu5ARU6QB14yz5F7>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 22 Feb 2026 20:13:29 -0500 (EST)
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
Subject: [PATCH v2 07/15] nfsd: switch purge_old() to use start_removing_noperm()
Date: Mon, 23 Feb 2026 12:06:22 +1100
Message-ID: <20260223011210.3853517-8-neilb@ownmail.net>
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

Rather than explicit locking, use the start_removing_noperm() and
end_removing() wrappers.
This was not done with other start_removing changes due to conflicting
in-flight patches.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4recover.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index b4bf85f96f6e..b338473d6e52 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -352,16 +352,14 @@ purge_old(struct dentry *parent, char *cname, struct nfsd_net *nn)
 	if (nfs4_has_reclaimed_state(name, nn))
 		goto out_free;
 
-	inode_lock_nested(d_inode(parent), I_MUTEX_PARENT);
-	child = lookup_one(&nop_mnt_idmap, &QSTR(cname), parent);
+	child = start_removing_noperm(parent, &QSTR(cname));
 	if (!IS_ERR(child)) {
 		status = vfs_rmdir(&nop_mnt_idmap, d_inode(parent), child, NULL);
 		if (status)
 			printk("failed to remove client recovery directory %pd\n",
 			       child);
-		dput(child);
 	}
-	inode_unlock(d_inode(parent));
+	end_removing(child);
 
 out_free:
 	kfree(name.data);
-- 
2.50.0.107.gf914562f5916.dirty

