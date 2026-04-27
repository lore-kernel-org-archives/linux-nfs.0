Received: from fhigh-a5-smtp.messagingengine.com (fhigh-a5-smtp.messagingengine.com [103.168.172.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB5A02749ED;
	Mon, 27 Apr 2026 04:07:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777262858; cv=none; b=sIDcSJ1a9P43YWqbGbTXaUGOKza+uvDzT98KDTcZy1eyxmFpj7AH5vzqThnI/o+uShAFl0kZBRtsIQ5RHXBz+ZOrDpteT/73GVYxlGLdPDaWL8Xqlaem9kHeIa5fUSmesojuiD1QMIkLsKxGWSORs3aJh/2fcoHishdYks3uAxU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777262858; c=relaxed/simple;
	bh=DFrp9NHxbOh7DcW+macG4cAgQAoWvIrKkUHLuu82auc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mZFWQixEaaXBoy/yRBoz0J6u4Bl0TYBrw/mNpNWSKK1gY2C5lnyXSsd5bB4ANAvebzHM1gredw50i5gbDCI9bCowguda5cFPz4603B7hDGzazTOJhn4G/4Rlh4R/qzIz7uzM/uKhDU6oINiLSxtnhvD45n1E5QFBEIEM6Y/IK6Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Ohjtv5HI; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=urpFUAP1; arc=none smtp.client-ip=103.168.172.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Ohjtv5HI";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="urpFUAP1"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 1283114000B0;
	Mon, 27 Apr 2026 00:07:37 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 27 Apr 2026 00:07:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1777262857;
	 x=1777349257; bh=/lh7HUK0TKvg2/UYrerSNegrbJ1j2gtRpk+NrmqwPSE=; b=
	Ohjtv5HIy8kwh11+SsbiMh/ABYNn7tIDUSeS+YjTYnlGaK+MUrfMmy/lPZzSakIm
	qSpxEroqMZoMKcynjr3F4TD/a1G7JllgE2hGTA9YBwsMWEUXdckloenITYX5EU0/
	vhwLEQss1QjJSrk8SY2zTJy7ig8rihhmvonyFE67ukIGVH1Uu6NZuOzDjWlH1mAl
	GfevQzGWlkfxISFBUhNqt9t+6tLrwqZY4yrAYNdR/noTQ+eHHBy/uvxP73s43WF8
	lQx8dYTvFFr7GLe54T4DfymVPmT09k4lHjRh6e6czMs3UiGSXoK+5SKrvmbgrSxs
	urnCldWSI0OlC69DmlLZwQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1777262857; x=1777349257; bh=/
	lh7HUK0TKvg2/UYrerSNegrbJ1j2gtRpk+NrmqwPSE=; b=urpFUAP1WTt4BiS5v
	RwpHBxcuy02t5Rs5R0Rmq7j3UXSp2BSHyEjcDzmFrgoRQZirjIl15YizH3fzFsUq
	B+U8F/S/2Yj7fmp8v+/jOaGHodt96ivrgEcRehNe1CKnmOZ7FRnYL4GKmOitSTkT
	fmIubIbqmpttb1IhIMPKcFaoBnp5vaISfsk1yHXfcyAvK92Aeye5yJcWsmix6KsR
	XhDJeyYaknB7oZGXM5iUgA6ROuUPYkPDtPNNlRX4z+2z8ljDh7BvpM2bLe0milI4
	vwO2ErvrIeQVSKJlu8Be8O4Po7w+OEgkdUGh+nXDWQLVimvsy4IOUenIq1G4MlZZ
	bo3rA==
X-ME-Sender: <xms:COHuaf4_Yv5nWglji9n50OiAgY7-OHxc3z4jYTT-BEg8Mtlka8mtWA>
    <xme:COHuaRM9_YQ2dWMJBm4WXDpwnxh87rYr6szfjPrSteGPYmR-fLAvs804AMebrqfxc
    mUMKgG-10kji_mYidjoMtp6aQha_L_TkmRto_SARk6zJ0e0>
X-ME-Received: <xmr:COHuaYG1K6ZJkJeme4lQzvewOhfI6t07B_aauQ4nbc5xDvgiZfievUa-O51HctlCG5FjDid7mzuoE-sKYxH00Pmx3tM5qxs>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejjeeikecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefhvfevufffkffojghfrhgggfestdekredtredttdenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    evveekffduueevhfeigefhgfdukedtleekjeeitdejudfgueekvdekffdvfedvudenucev
    lhhushhtvghrufhiiigvpeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehnvghilhgsse
    hofihnmhgrihhlrdhnvghtpdhnsggprhgtphhtthhopeduiedpmhhouggvpehsmhhtphho
    uhhtpdhrtghpthhtohepvhhirhhoseiivghnihhvrdhlihhnuhigrdhorhhgrdhukhdprh
    gtphhtthhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
    pdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprh
    gtphhtthhopehlihhnuhigqdhkvghrnhgvlhesvhhgvghrrdhkvghrnhgvlhdrohhrghdp
    rhgtphhtthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorh
    hgpdhrtghpthhtoheplhhinhhugidqvghfihesvhhgvghrrdhkvghrnhgvlhdrohhrghdp
    rhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhrtghpthhtohepjhgrtg
    hksehsuhhsvgdrtgiipdhrtghpthhtohepjhhksehoiihlrggsshdrohhrgh
X-ME-Proxy: <xmx:COHuadTs3n-Lmkm6UbE9iAaqn043Crm5IY8DN29AXPGNdD4NY-_3aw>
    <xmx:CeHuaYTqAqm-PpM0P0ic52ZG-e4zsf9kQofQ1Rz1Wb4RzmzyiyroPw>
    <xmx:CeHuaQdLRmHGXITfwqfwfDdIjhjGBDfZ7ElKTfvXOgziUAxFsC9cvw>
    <xmx:CeHuacfuids3q5hk_EisJw4yk5oTH0LDZc0KFGeBV8Z9oh_lodCqYg>
    <xmx:CeHuaeLnTa8tGq_up0_uaoUnlNUGMFrzZlz3BinCBhzuFUoZ6EXhDvVZ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 27 Apr 2026 00:07:32 -0400 (EDT)
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
	Ard Biesheuvel <ardb@kernel.org>
Cc: linux-efi@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 12/19] shmem: use d_duplicate()
Date: Mon, 27 Apr 2026 14:01:30 +1000
Message-ID: <20260427040517.828226-13-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260427040517.828226-1-neilb@ownmail.net>
References: <20260427040517.828226-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

To prepare for d_alloc_parallel() being permitted without a directory
lock, use d_duplicate() when duplicating a dentry in order to create a
whiteout.

Signed-off-by: NeilBrown <neil@brown.name>
---
 mm/shmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 3b5dc21b323c..8b0d2340dee7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -4006,11 +4006,12 @@ static int shmem_whiteout(struct mnt_idmap *idmap,
 	struct dentry *whiteout;
 	int error;
 
-	whiteout = d_alloc(old_dentry->d_parent, &old_dentry->d_name);
+	whiteout = d_duplicate(old_dentry);
 	if (!whiteout)
 		return -ENOMEM;
 	error = shmem_mknod(idmap, old_dir, whiteout,
 			    S_IFCHR | WHITEOUT_MODE, WHITEOUT_DEV);
+	d_lookup_done(whiteout);
 	dput(whiteout);
 	return error;
 }
-- 
2.50.0.107.gf914562f5916.dirty

