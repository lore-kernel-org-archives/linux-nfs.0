Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76518547073;
	Sat, 26 Sep 2026 00:10:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381455; cv=none; b=OBO8RmlTvcq11ptACE57S9hOLLapaQIoUegJ8djP/GbWkuBmyAC4tWZrUMR4rSBUQinRDiW7fFHnUSMBoqXyr12WtP0UBMg9MN/WK20gN30+vpBMprMJ0UXj92FDVHHo5E1JDXQzmcw3u0NmIi9ShOR1d1P9fIqA0EeZxIV1ZQM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381455; c=relaxed/simple;
	bh=vmcevMAsx/FiJfTdhkhmf63RRm1fIoIQVOcFnjch//4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YeQQtR6Xj+z37b137V5irNbDWCifmW5RRXLcwOsRqSy8g6GQfpNF9FK/PvGnL624d0jvsKU/OcUbUbwxep2GGmaV4SBM2uzD8qtxF8IQF5Ls3jb6GCokABl1ayvWSAuiV2YclkBBWlJIZ7DH8JJYCynMJexah8Jqx3dR0ONswcc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ntEmLKk8; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=nYPCP9UD; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ntEmLKk8";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nYPCP9UD"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 529521D0006B;
	Fri, 25 Sep 2026 20:10:52 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 25 Sep 2026 20:10:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm1; t=1790381452; x=1790467852; bh=r6FFhFc3nI
	ElbVqBpOo/qsWHQ7d8PBRdoKoq/X9nKLk=; b=ntEmLKk82L59M4qdbOx66njzq1
	e1ULX8Q6dfdMGu3W7QGeJlxeaIKtOMm2sbzZe2Mo2COMIhGUEv+c8XZF4Xpx5CYt
	4m0bikBAbtSHitQRz+FoKbTTHvxizubusgyaCnKLjK4PFpr3mgP6A8oxo80bRjMt
	hLLd9pppLRj+mVFizTGGq5slUdeffrvQL0Ac1jQuUQRGlZDyeVrydkqjTWEEJTQU
	oQkp1rVSZr35Lyg7uuwIGlRO4jJ+4N7+d7fUmBUxRMZVxwF5Bnv5UtG6AAX3EvCZ
	GxhXczGvOsg9Up7lBXKnvxMiUIMrjRfm+et1PEBQVVeHc5ZYsZUkGTV19hMg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; t=1790381452; x=1790467852; bh=r6FFhFc3nIElbVqBpOo/qsWHQ7d8
	PBRdoKoq/X9nKLk=; b=nYPCP9UDlGqsAqR0eJU1Z8BS+1uSe/YJYp5Z7o4+We+p
	XsN+tufuY+ReLAeYNGyugUbWPRV957gWvd9axcF9+SFlGMQuQZl2H8WghJCRqNy4
	n7oqeJ5sgOwAnr8fwXGuwjUtu7iRO+ECvrQFb7lwoUwYb3BQOrnMJoLcWRtzXVy4
	g3CEFAsSa8ciXtqO+uuetFZg/bRmMEKR//6QKR9zGjY8KtcSUQned0Zer6TN0Xum
	9D6rnZ+gWH/TE1ioBoy/F28SO7ZkKltOTLf2s6aJIx2t4q/uXXnqcn1Da5Cs+glQ
	+DkPN9/5RfYGF66OjmBIF8vqToyg7N+tJ1CaCh4UlA==
X-ME-Sender: <xms:iw23aohWeO_v8Px1CZUmMfMebccEwmtNw3R0B6ExxWVgMaWLzxTNig>
    <xme:iw23ajnoDvxnVPZ4Xxd-kKYTa7JceOyfQMEfpw9hYM1fUQk-qcWOv4stfzd5f_2CP
    VxOVZdF75kTLr3JwEkbru0o-UaWSzzvyP8xkC-P4PWjHsfoaHE>
X-ME-Received: <xmr:iw23ajvrpcBzkQTZ_Z64uY_lhznOOBvujjUwLql3fv0LrzUfO50Y8sFb99qKOvr05fPORsew8i36PrquOTTmnRUfqHPXykk>
X-ME-Proxy-Cause: dmFkZTE34P3WN1PHDdJcZiIcc9do65MPbFMIbetXZohiCyipEk5KzFu84uLC4Sy6adt7OC
    2KHohU/uTPaM6FNB9SSuWWuI5ltczlIXbIEJ+EuNZVas3Uw/DB2Zyqqp7wtAO5fLQp/dFu
    0BZ5tJ73Xt2haQaHm/T+d+bgN0OGryWUiseTrKp/dfQqmGEmIGyfSxXvzsrw2oqvEYRo4x
    kRTLPPSX+4MFmwbhnQz1o9mpV3ikuYvHRiMAb5DmPWHqWdBLG0u04W0MYyytvPsMPBXAKf
    +X2IDyve83a2a0hZib9r6i4lP8HWF8qmQf93x2d2pwYhmqMOgDJP5nPKE4fm3rNjxyspYi
    qV+RABdaZBHpsHGAJzrIcV+Fy+bxnRJcXA3lUgy/TXCe74AphZCnod/fCDPXqA6SRdj1pM
    EFlL1i6Q+fVRC829Y3fRrefIwOXuRf55sT+sbxOdg2zy8C/1XmbtucJv9Ar99uWdeNJ0Mw
    hucFmBeOVQsK2m4CVjLUS2gBqhS0/N7WKz8M6Hifd3ouD5D9QChlnMEfSNTb9CDVJctZca
    U1XsGVf3uj1obfoue3z3Z3F2ddTCcY/0tZPolDOAKaXqRpTw8n+tg+Hflb88k41BkOqjAP
    JnxkISvnYny/u8XH1HVuYnO0+jKygkPPSqb6FeG/XaZuVIdhXeRvHbRHlVGQ
X-ME-Proxy: <xmx:iw23apbf7CmmiRCDLa9L_iftlEPkPpjc7cINnidJMRh2-vj51vY_Nw>
    <xmx:iw23arAmhF6yO-QFI3dtV2QezmjAaqRB6s05ZvCirTUbiQ3uEkf7Nw>
    <xmx:iw23ah9P6FRNCLgYlgPoiaOEHn4SCIaft0pJYm5hJ8M4tIZ2bqJU7Q>
    <xmx:iw23anSGmnkQbuG6E0bH0aWc1AbuyrcvTdemlpsB1aC613SRcmJayA>
    <xmx:jA23alWf0sZGMk1N27V4BD_Z5cfFofGXq1XDvjG48wcfmOBHWiU292R_>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:10:49 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] nfs preparing for locking changes.
Date: Sat, 26 Sep 2026 10:01:17 +1000
Message-ID: <20260926001011.401824-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I am working on changes to directory locking.  The medium term goal is
to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
can be run unlocked, and consequently cannot be called when ->i_rwsem is
held.

The requires:
 1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
    this in a few places. New interfaces d_alloc_trylock() and d_duplicate()
    are now available and can be used instead.

 2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
    unlocked d_alloc_parallel() would then be able to create a new
    dentry with the same name.  In particular d_rehash() must be phased
    out as it won't be safe.  Various techiniques are used to avoid the
    need for d_drop(), particularly that d_splice_alias() is now able to
    splice a hashed alias.

Further, the first two patches here fixes bugs that I found while
developing and reviewing these changes.

The patches depend on patches recently added to the vfs tree.  I would
prefer these land in that tree too with an Acked-by or similar from NFS
maintainers.

Thanks,
NeilBrown


 [PATCH 1/9] nfs: fix open-blocking with d_fsdata
 [PATCH 2/9] nfs: fix nfs_call_unlink()
 [PATCH 3/9] nfs: remove d_drop()/d_alloc_parallel() from
 [PATCH 4/9] nfs: use d_splice_alias() in nfs_link()
 [PATCH 5/9] nfs: don't d_drop() before d_splice_alias()
 [PATCH 6/9] nfs: don't d_drop() before d_splice_alias() in
 [PATCH 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
 [PATCH 8/9] nfs: use d_alloc_trylock() in silly-rename
 [PATCH 9/9] nfs: use d_duplicate()
