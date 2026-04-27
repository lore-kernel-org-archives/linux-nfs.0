Received: from fout-a3-smtp.messagingengine.com (fout-a3-smtp.messagingengine.com [103.168.172.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E13AB246768;
	Mon, 27 Apr 2026 03:36:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777260979; cv=none; b=GQr1lWIqdfiuOZl1DNft5JTH22otRlNvRs52L+JiJ1w6uQnYmuKqBMEqvLceF16kUm3QyNhMxHZxzdwHeqAt//YIPlBOT0sCpkHRSHjxUcYhCURQXLnZzq/poJoM+MSoVsWEU2bIUBslAuuSIa86p+qq1EgEw7yH9N9hLE9mc64=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777260979; c=relaxed/simple;
	bh=qSiA65OlAkTnkbcTeNV7mR1EhobDVI0BoCP/VRJI/W4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uVs1SkM5N5KA4DsvyKVBuEtEzrrqnCI7CyV+hk1cTK+iDnnUoDZwyVyPpk4+f+N70O+wS/gi+zc78lDCWYO4QXJDoKh6wIIr8+DFlVzRedFSse13uASuZ/rgfvY5hz1FGPFonNLmRQlD2q9FwuDpWu7PJ4sDzMjI137N3QC2VtM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=EV/B7sz6; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VBhN6xtx; arc=none smtp.client-ip=103.168.172.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="EV/B7sz6";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VBhN6xtx"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.phl.internal (Postfix) with ESMTP id 107DCEC01BC;
	Sun, 26 Apr 2026 23:36:16 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Sun, 26 Apr 2026 23:36:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm2; t=1777260976; x=1777347376; bh=+AfzVtcFdv
	bs3O1oT5LWwepSI/hImgSuRlsSjxTGP/g=; b=EV/B7sz6hnO1bI52+uUOZIoI2w
	SUjLidWwP3E1D9uD07z74T0evdJmmxhFR8WbD4d9dyQPj+DUhF/x39qqg43ebUNR
	I4Wef9lmIPKl3dHt6AIb3VbLfrXhyOp0wSul4eDMrmiyNXpPSOyDgrvpNlDcDgNm
	nukvwX4q4PSpXlBVG23d9i74pFJiOPXGs6SQtWme58kPen26xlw6X1C21Vn+XycH
	1wMjVsFWDwM3JAHISzGbAZGTAZ//2L8CGbeEOChlJzQiLyQ21I2C7C/1ymltEBgJ
	p2HEFltuEscBugWNV+7mGkdqVvkdS3WS92UV0XM30KHhjNnTCRzorqeTmNQg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; t=1777260976; x=1777347376; bh=+AfzVtcFdvbs3O1oT5LWwepSI/hI
	mgSuRlsSjxTGP/g=; b=VBhN6xtxnCpxe9/yuUCvdU1CamGy9W7c17XKEFs3d5yE
	3LMVehRo/WRGKdqclzc1Mli0lRdJbzUPtZESrl36prLtNFDnWiYt2tcL+n/I4lyN
	gBMX+iSspfEfl6UeAP6ygM6+1QAOpcHT6YGh8tX/afxGxbNC6BA3qhXhao093+J2
	siQdZMSHJOuW/9JEjGJ13QgugIMvYUiTj3pDSJrhFptcKBiI5q0zdHbGf8vAAnvB
	anXhr1bvoHkisUCp0LHEK9haoSrnY1qjOS/5jz+jsQeLm1azUABbE6nh89SFiT+s
	KbDXFSgtSGJSMkSUp4ywu92bg5ELAB04V+ugRkARSA==
X-ME-Sender: <xms:rtnuabyEcl926lDXoQ05S3AkJLRXR-e0T3QWn1ReOYTwwd36FeCV6g>
    <xme:rtnuad9E-Q4DRg7VTp2ryPlpNb-RQLEVYWbXG2Qb6gAxJ5BLi6IfBzl7q-tLVj9MK
    2zazQQPyCS4VxuiyrTsbP_UTb9y1oJ9f6nBQXyj8UUtkbE>
X-ME-Received: <xmr:rtnuab9fVkCi4NjnXJIpOT35S9BdWO4B9QL7o9ju9qKDLj_Dxf1lAPiYC8xBBHGX_KIv1VFegNCKgJRM4nBnxyVNNH76WUg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejjeeivdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefhvfevufffkfforhgggfestdekredtredttdenucfhrhhomheppfgvihhluehrohif
    nhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpeegte
    efgedttddviefggeeuveefleellefgjeeufeeukedtleeiieekvedtleevleenucevlhhu
    shhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgssehofi
    hnmhgrihhlrdhnvghtpdhnsggprhgtphhtthhopedujedpmhhouggvpehsmhhtphhouhht
    pdhrtghpthhtohepvhhirhhoseiivghnihhvrdhlihhnuhigrdhorhhgrdhukhdprhgtph
    htthhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhr
    tghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtph
    htthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhr
    tghpthhtoheplhhinhhugidqvghfihesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtph
    htthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnhgvlhdprhgtphhtthho
    pehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghpthhtohepjhgrtghksehsuhhsvg
    drtgiipdhrtghpthhtohepjhhksehoiihlrggsshdrohhrgh
X-ME-Proxy: <xmx:rtnuaQf6CIJXgs7MwtyqLd5Rs5vj3APCdsQ3lyLN3Ba3xVDaEPWXvQ>
    <xmx:rtnuaXveh0lQ8aESqcfzMz4E0dA0aNeSXBNjtwbzbJzEl6a68QKS4g>
    <xmx:rtnuaZ3TOobK0NBGaMUCiO0HVtXYQ1rLEB9dZ3AwIqNXjc0Dy8vzMQ>
    <xmx:rtnuaUDnndcrJU6ecu5lEXRMD0n6opFReSunJGtE961ZUTcQwDrj4Q>
    <xmx:sNnuaQxDW4zaamrwn1UR_gAq5SLznvyiUdMBRbJuGUxUzKE_yfc4RvQr>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 26 Apr 2026 23:36:09 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Amir Goldstein <amir73il@gmail.com>,
	Jeremy Kerr <jk@ozlabs.org>,
	Ard Biesheuvel <ardb@kernel.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: linux-efi@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org,
	linux-kernel@vger.kernel
Subject: [PATCH v2 00/19] Prepare to lift lookup out of exclusive lock for directory ops
Date: Mon, 27 Apr 2026 13:29:33 +1000
Message-ID: <20260427033527.773006-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This patch set progresses my effort to improve concurrency of
directory operations and specifically to allow concurrent updates
in a given directory.

It is a selection of patches from the 53-patch set I posted in March
which got relatively little response.  Maybe a shorter set will be more
approachable.

This set:
 - prepares the VFS in various ways
 - make use of these preparations in ovl and NFS (the most challenging
   filesystems for lookup as they do the most interesting things)
 - make use in efivars and shmem which for different reasons need a small 
   change that seemed worth including here.

The goal that these patch work towards is moving lookup out of i_rwsem
on the directory - except for the actual ->lookup call.  This is itself
a step towards allowing broad concurrency of operations in a given
directory.

There are two particular requirements before lookup can move outside the lock:
1/ d_drop() mustn't be used before an operation completes: the dentry being present
   in the dcache becomes part of the locking protocol.  This in turn requires
   d_splice_alias() to work with hashed negative dentries.
2/ d_alloc_parallel() mustn't be called while i_rw_sem is held, as this would
   result in a lock inversion.  So d_alloc_noblock and others are introduced
   to handle the various cases.
   In a few cases we need to drop and re-take i_rw_sem inside ->lookup.
   As lookup might be called with a shared or exclusive lock this requires
   a new LOOKUP_SHARED flag which is ugly but can be removed after the
   lookup is moved out of the lock (then ->lookup will only ever be called
   with a shared lock).

The full set of patches including these 19 and the rest to complete the
lifting of lookup out of the exclusive lock can be found at
   github/neilbrown/linux in branch pdirops

Significant changes since last time are:
 - use wait_var_event for d_alloc_parallel() rather than effectively
   duplicating that infrastructure - as suggested by Christop
 - changes to ovl_readdir handling as discussed with Amir.

Thanks,
NeilBrown


 [PATCH v2 01/19] VFS: fix various typos in documentation for
 [PATCH v2 02/19] VFS: enhance d_splice_alias() to handle in-lookup
 [PATCH v2 03/19] VFS: allow d_alloc_name() to be used with ->d_hash
 [PATCH v2 04/19] VFS: use wait_var_event for waiting in
 [PATCH v2 05/19] VFS: introduce d_alloc_noblock()
 [PATCH v2 06/19] VFS: add d_duplicate()
 [PATCH v2 07/19] VFS: Add LOOKUP_SHARED flag.
 [PATCH v2 08/19] VFS/xfs/ntfs: drop parent lock across
 [PATCH v2 09/19] ovl: stop using lookup_one() in iterate_shared()
 [PATCH v2 10/19] VFS/ovl: add d_alloc_noblock_return()
 [PATCH v2 11/19] efivarfs: use d_alloc_name()
 [PATCH v2 12/19] shmem: use d_duplicate()
 [PATCH v2 13/19] nfs: remove d_drop()/d_alloc_parallel() from
 [PATCH v2 14/19] nfs: use d_splice_alias() in nfs_link()
 [PATCH v2 15/19] nfs: don't d_drop() before d_splice_alias()
 [PATCH v2 16/19] nfs: don't d_drop() before d_splice_alias() in
 [PATCH v2 17/19] nfs: Use d_alloc_noblock() in nfs_prime_dcache()
 [PATCH v2 18/19] nfs: use d_alloc_noblock() in silly-rename
 [PATCH v2 19/19] nfs: use d_duplicate()
