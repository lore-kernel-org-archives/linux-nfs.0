Received: from flow-a6-smtp.messagingengine.com (flow-a6-smtp.messagingengine.com [103.168.172.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 042B734F27D;
	Wed,  4 Feb 2026 05:08:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770181688; cv=none; b=CAIU4rDl4axAOlIVwqtBhxAJVbHRmjEsVPv6ah1jv8LxBlkXLaqcQjaCyq3ECgByoxL2JwGYRe+KsANfnWxc6Axiy9EPlauYFxljqC64umfeNBRUy6awOCKSn8hGxe8ib02I/bpLexCbcLz5KD/KjtTdgFn/OaCvBzYxi3AZjqY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770181688; c=relaxed/simple;
	bh=dC323i3a5pzLmkG4eSohnUBpRgc+HMW7uI7HFtwc31Y=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tP5TdREN3KPScYzXW7dBou+cOTknhAbmMSSPpVY0YFYEQxL2wXq/pNAHRJaNa6vbvVq081Uq+DwX7uflLdW8pDWzkPUjMN9n3sM8+WSTLa6z9alzUiKccK+TZLI/3etTaxSTc+u59ZS9ocwbk+lVAhEmwVPCbGg3JxyGbYpn1tA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=CiEJ6Hua; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=pgfRNb3G; arc=none smtp.client-ip=103.168.172.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="CiEJ6Hua";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="pgfRNb3G"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.phl.internal (Postfix) with ESMTP id 033571380778;
	Wed,  4 Feb 2026 00:08:07 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Wed, 04 Feb 2026 00:08:07 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm3; t=1770181686; x=1770188886; bh=XrOETrfLvn
	IX9izHaz3N3kjXjvH1wtHjpHJBz8OfYz8=; b=CiEJ6HuaYbyBncQK0Lqj0/lNF8
	DhAmxjQyJmxvozS5jXPzzY+XP7IqzDOshTUQIx5F8q3jdVkAJYIqxAnNmTKZc1Gc
	Rz6Gaz9g7gPNDWVQt/eBmoyqW1ED0k4S51L6PgC88F91vhkAkANrbidvxi4Ft6kn
	Z2QnDJeyZyYC7DOrS8xQ4bely67rhZsZ1nPcgZbLnLAfZTV0geZRruUBh41QxYNj
	RMHAnpZjEY2jeseKrnxpnBqyZa169DbRKrWWyH1qV5TRi5qaQv0Q/gzB/4Frw3Sj
	gqXeBzBZPeZAkYNF4LZQWDkWzdvk596wFMvuBn/FtrqS50DqnP9FXdCRp3DQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm3; t=1770181686; x=1770188886; bh=XrOETrfLvnIX9izHaz3N3kjXjvH1
	wtHjpHJBz8OfYz8=; b=pgfRNb3GFaNvHPggUPmqU3BzhV1DYsxFsfCeubzJ34Z2
	IAXUcDPPY6B4jFTc/sHFd+FFVWOCN61ZY1n4FSp/lZ/Gm8OL3IoxKdmtGG4mwtRB
	0cvuLMaVwfbCkuk6RJ2Z63jD94vV4qNep/luiPmUR+3LvEv6P8s37xlYrISuSGuK
	wEYDRQ498aJsPgxTcI5zvZ6ka/ASQo1kuhn1czQJTHfYm1VOYKS8UMSqyacqcxV7
	WNLo000OpWyqHhPs34vOA0xlHoFgXDDUMaUZybJyVpOdqP0l7sYl91BeFNKbwqHN
	X25D7DUOSE4gBsH5flU2yCWtokXqSMsawaOX095y/A==
X-ME-Sender: <xms:NdSCacyHAcWi0GB6-jJHZwbkg7Gp-Z8lim-4rJwYDEn4tUsEpVVp5A>
    <xme:NdSCaUi2sidAli4k4HESJm4YuHT-yfhGDUFNfA9wk6-Xew_E4Id6MUquzyDqQgKWj
    6oVs_Or_AOLCF3MayEIM7vc75zzFysDBEkNd25_ItQdv_Uc0w>
X-ME-Received: <xmr:NdSCaR5AjfPMw9UHtqMCUY3gZiF0HwOinEkXMxQrj_q1sM-SP-zb0drYuARdpjKpES6FgKhhf7urx73AS9dGuMBwFTAN-m-EErtLCvsusGkf>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddukedukeeiucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhephffvvefufffkofhrggfgsedtkeertdertddtnecuhfhrohhmpefpvghilheurhho
    fihnuceonhgvihhlsgesohifnhhmrghilhdrnhgvtheqnecuggftrfgrthhtvghrnhepge
    etfeegtddtvdeigfegueevfeelleelgfejueefueektdelieeikeevtdelveelnecuvehl
    uhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhepnhgvihhlsgesoh
    ifnhhmrghilhdrnhgvthdpnhgspghrtghpthhtohepvddupdhmohguvgepshhmthhpohhu
    thdprhgtphhtthhopehvihhrohesiigvnhhivhdrlhhinhhugidrohhrghdruhhkpdhrtg
    hpthhtohepshgvlhhinhhugiesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphhtthho
    pehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtghpth
    htoheplhhinhhugidqshgvtghurhhithihqdhmohguuhhlvgesvhhgvghrrdhkvghrnhgv
    lhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrd
    horhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkhgvrhhnvghl
    rdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhgvghrrdhkvghrnh
    gvlhdrohhrghdprhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghp
    thhtohepjhgrtghksehsuhhsvgdrtgii
X-ME-Proxy: <xmx:NdSCaZpRkxJWPNmIpcpGeNAy50vMwvTXVXySj4QxXdsBDVBq8ly_5w>
    <xmx:NdSCaXXqpBY4J628Zt1MD0CWCDQFIjb_nD-zpyZCDCVuAS2xOS78Aw>
    <xmx:NdSCaQ5LAQWkq85YI4N5auTuRMssrLuYMh8Grxsq06CB1xQnOGG43A>
    <xmx:NdSCaV3QDW52SEeAdjmfBcdJhYLQR-XjBl5pKwa3C3AKajI2bStWiA>
    <xmx:NtSCaTz-dtrlfjILOYM9GTMXnZa_VQglEYUC71RT6cu45HHOJ53g7HKW>
Feedback-ID: iab3e480c:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 4 Feb 2026 00:08:00 -0500 (EST)
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
Subject: [PATCH 00/13] Further centralising of directory locking for name ops.
Date: Wed,  4 Feb 2026 15:57:44 +1100
Message-ID: <20260204050726.177283-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I am working towards changing the locking rules for name-operations: locking
the name rather than the whole directory.

The current part of this process is centralising all the locking so that
it can be changed in one place.

Recently "start_creating", "start_removing", "start_renaming" and related
interaces were added which combine the locking and the lookup.  At that time
many callers were changed to use the new interfaces.  However there are still
an assortment of places out side of fs/namei.c where the directory is locked
explictly, whether with inode_lock() or lock_rename() or similar.  These were
missed in the first pass for an assortment of uninteresting reasons.

This series addresses the remaining places where explicit locking is
used, and changes them to use the new interfaces, or otherwise removes
the explicit locking.

The biggest changes are in overlayfs.  The other changes are quite
simple, though maybe the cachefiles changes is the least simple of those.

I'm running the --overlay tests in xfstests and nothing has popped yet.
I'll continue with this and run some NFS tests too.

Thanks for your review of these patches!

NeilBrown


 [PATCH 01/13] fs/proc: Don't lock root inode when creating "self" and
 [PATCH 02/13] VFS: move the start_dirop() kerndoc comment to before
 [PATCH 03/13] libfs: change simple_done_creating() to use
 [PATCH 04/13] Apparmor: Use simple_start_creating() /
 [PATCH 05/13] selinux: Use simple_start_creating() /
 [PATCH 06/13] nfsd: switch purge_old() to use start_removing_noperm()
 [PATCH 07/13] VFS: make lookup_one_qstr_excl() static.
 [PATCH 08/13] ovl: Simplify ovl_lookup_real_one()
 [PATCH 09/13] cachefiles: change cachefiles_bury_object to use
 [PATCH 10/13] ovl: change ovl_create_real() to get a new lock when
 [PATCH 11/13] ovl: use is_subdir() for testing if one thing is a
 [PATCH 12/13] ovl: remove ovl_lock_rename_workdir()
 [PATCH 13/13] VFS: unexport lock_rename(), lock_rename_child(),
