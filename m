Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36F5B2222CC;
	Sat, 15 Aug 2026 04:28:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768092; cv=none; b=mGrJoHC7Q0VbN8gLZkicZZO15N+WDSB4BshJWeDRKevim6gB+XiCsYgEgjqsM0UGoZY8K0pSuWwpSuwniCiCmBlATdTenIEkEpf3bnJNMXFZg/dZkOvCfwysie+BHKYrbPvCnrSLSD2XCiMuMCV8/23z/kPswE2/y0zD/gfG/xU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768092; c=relaxed/simple;
	bh=jc0tYsNvGIremEBg2UeiOFWuN/l1ae60gQxpF6jhkRU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aB5X99174Z4gtqEgwqt3vAoEmR11ahxOhXpBLuuLeq6iQGeDrdqqzEhTKdmpQHQ1wG+0q/9Ca76sVyqJ2iig+O5iZDsF7b5nAUG23HjzwgcNeACOgzRCBth4bh4O+U/QXj/T0TPh1mrYbA/tTmIex3F9JqlafOLI7K4X0OeIIog=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=cfkk6VEn; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=kFO4t/Ed; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="cfkk6VEn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kFO4t/Ed"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id 229FD13803F8;
	Sat, 15 Aug 2026 00:28:09 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:28:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm3; t=1786768089; x=1786775289; bh=a8JWgrgM6B
	bZE0JrClCgbSTzkHS9cn3VgvmGsMdN8+E=; b=cfkk6VEnfCP7FiXRXX1mbBsIiU
	gUlDFvUJ1bXAIof7//2FhWMsmSLO5ZLIWspvTO/z0o8VciI3WWyK3pt8aPp2dDDm
	jgBSqSxM2Ak1llCyJF3b85/v/E5IkjcvzBTYBGvpjSvpe/wKQbdK5NSIbfwNxvmV
	EMfg2JVNKQXO+lVxsKC77DRPr81jSDqFzpMZnUZ41OayOKQXTJI2gwwjM4N6WlRe
	FNpo05QHW297iElZh3Uo7ipj/HL1tyC7xw2kEHyjcTZDYDuF9XAUSUX0NfoOr6Ci
	0kQYb7T6pFsKMQ1wTXnSBjjRWe4uRwT89lMbczFKscPGVu10kG/evMW1ZIew==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm3; t=1786768089; x=1786775289; bh=a8JWgrgM6BbZE0JrClCgbSTzkHS9
	cn3VgvmGsMdN8+E=; b=kFO4t/EdGDsf7oRJfnoTSxiO+2U73KZ31i60mNqx4MNj
	cVZg+rzhzGlxmDl56sG1XS91P/oMtIlty02rHGJr6qVC1yGBV3x9BuQg2S85eyeJ
	0P61eTEhdld7FyHCvUZXpf0LDWZPVfdmp33R++0dBGUYeVZx3StL0oJZlAnHN/Lu
	WSjfgh7iM1fjXYog7aa4AMDJ/OHtdjv73xUCWccw3u0DmvP/QEaKAUCVDTytybxM
	n+sxKwWqtX18MMiXZXiA2pW4gvuS5GQ91JpLx9rnYpxXKAJLbdKJ1CmyHb5bNrB8
	eFOy23FB+YJHpCB45bkgZelmAueoRTDjHjyvRVjhTg==
X-ME-Sender: <xms:2Op_apiz4x9XnL26Rd5WxkZETUTadvl118O79DMrVeXkIUHN_elDlQ>
    <xme:2Op_apAYSvldfY3FKtRH4B3ZiKCW5eK_OzIS5xH-3gsgxEjc0Qdm0X8KNBBHT6rI3
    BL4spTEcMmFIQ91HoxR5uZsHUdnIl6f43CFlUKfwiF2f7an>
X-ME-Received: <xmr:2Op_avsnJgqOrU_jQLANnr2NVSIoUJMHQNB_T0mHK4xd41x4lAO9-2Inlw7bwhy2vzKl2vHy3gJIQ09PgND1SFX84BzRwR0>
X-ME-Proxy-Cause: dmFkZTGcXujApbzs2X0Kim5LmHFFJRK2MPxvQbJLuIcq6DqOQsPEjFndvG2M+i5ESwxbnz
    XNluEuYLJShxkiJ7L9K1fdymGwva0oXIlas8Vi7ifHENRFWAh5XmWoEwPQuKLshHqI7DEV
    acHThbsM/tzTNsUfnVy3KPg3QGrW9h1yiw1B3nXrD1KV2Sz1M6C2GPcIBD42zWeOl8sxtE
    v4igMi92DmfqDD+5NgQ/wWpXUOKZFAUVjS8wxjEJSRBim8i/KShbqb3L7hRFo5ssBVel3I
    L/pmLzWC0WLpEjV80fAz+OLf4hhLML2sdY2g5pRkdSyBWOaZ0d62+gRnIcIhJUtjSQfpDT
    cxYf8pO9nCKfPH2eeOix7b3tfrlcktJasqFnn/ucawRnTE4k8n62W3p45CNyjQ/UeGry1d
    IFTPJBMzqAFvVkG9ATmu+fgeuaOftShTtfTICiJiYc0iKTFCetDFZoy6QijYPVZeLK1K1h
    RXQz6XRrJz5jl7nfhmCkmWHGhDvYyNmvBXwn4EynSaG69kUYWym9q+S7scHCWI8IhHdtso
    U4+/MyCkyl7Hcor9DFt65cWT5gF4oyak4yFC4vtI/QdmseJQobio2/zkOvocIJFXdMKZj5
    dn4uRlkAuth9XVS4ixxMNgZenQkIrO2+YWG+3oAJ6xyLYZz23GbpBsFZRuRw
X-ME-Proxy: <xmx:2Op_ar6Z1x65Bkn_FSj0ibU9IL3rnNUB3JxQp7HjnKZ_y7QbEjC0KA>
    <xmx:2Op_ahdQBqUzNyk0YVLh2qLYcPm06uj6-BWRtvrZeStswPkrlKdcbA>
    <xmx:2Op_arXyeg_FMsmS1ooHOz393zOIV73ASIumT_qFq-bQrX1I-fF9MA>
    <xmx:2Op_amVBjupFj67oiBtekxayfiNQa--B1F7UmDfxUK9m4oKFMEZ28w>
    <xmx:2ep_aoZG9yahWcuepodSoUHG5VB6An9Iq-1vx1eSN7xEhCQ4whzE8m0U>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:28:02 -0400 (EDT)
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
Subject: [PATCH RFC/RFT v2 00/18] Fix easy bits of the negative dentry problem
Date: Sat, 15 Aug 2026 14:21:17 +1000
Message-ID: <20260815042707.2535717-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Greetings all,
 following a v2 - which has grown a bit.  Thanks a log to Miklos for
 some great review - though I would still be happy for me (and maybe
 sashiko will manage to apply this time).
 I'd also be very happy to hear of testing in anyone is able to
 trigger the reported problems with excess negative dentries.

 There are no significant changes here, just a few bug fixes and
 clarification and splitting up of some patches.  The last three
 patches come from Miklos suggesting that positive_after() in
 autofs could be in common code - in fact it already was :-)

 Original comment, though without the per-patch highlights, is below.

Thanks,
NeilBrown

 I was reading about the negative dentry problem in
 https://lwn.net/Articles/1079407/ and thought I would have ago at the
 easy bits.  Given how involved some of that was I'm glad I didn't try
 the tricky bits!

 So I didn't try to reduce the number of negative dentries or handle
 them differently to positive dentries.  I just tried to address
 specific symptoms.

 This series addresses two reported symptoms.
  1/ refcounts on parents can potentially overflow if there are billions
     of (negative) children.  This was the easiest easy bit.  The first
     patch is all that is needed.

  2/ Walking the ->d_children list can take arbitrarily long and can
     trigger soft lockups.  I haven't addresses the "arbitrarily long"
     part, but the "soft lockups" only takes another 11 patches.
     With these in place I would feel more confident addressing
     the "arbitrarily long" part.

 The core idea is to use a common helper for all walking of
 ->d_children, and teach it to drop the lock and schedule when needed,
 inserting a cursor to keep its place.
 This simple idea requires:
   - nothing should be holding any other lock while walking ->d_children
   - dentries shouldn't be moved around needlessly, else things might
     get missed.
   - quite a bit of refactoring in libfs for readdir code.

 so I have probably missed some bits and would be very happy to be told
 what I have missed.
 I would also be very happy if someone who can trigger the soft lockups
 can try this code and confirm that the locks are gone, and nothing bad
 happens.
 I have done some basic testing including the "notify" parts of
 ltp, but that is all.

 I haven't addressed d_walk() in this series - I thought it was big
 enough for now.  Most of d_walk() already schedules as needed, but I
 think there is still room for improvement, but that can come later.


 [PATCH v2 01/18] VFS: don't count references through ->d_parent
 [PATCH v2 02/18] autofs: change positive_after() so it takes d_lock
 [PATCH v2 03/18] coda: don't take rcu_read_lock() in
 [PATCH v2 04/18] nfs: separate locked regions in
 [PATCH v2 05/18] Add and use d_for_each_positive_child family of
 [PATCH v2 06/18] fsnotify: don't hold a spin_lock across
 [PATCH v2 07/18] fsnotify: reduce i_lock hold time in
 [PATCH v2 08/18] libfs: simplify scan_positives()
 [PATCH v2 09/18] libfs: change scan_positives() to use
 [PATCH v2 10/18] libfs: allow scan_positives() to be called without a
 [PATCH v2 11/18] libfs: replace find_positive_dentry() with
 [PATCH v2 12/18] autofs: don't hold ->lookup_lock in
 [PATCH v2 13/18] VFS: don't move dentries in d_sib list when they
 [PATCH v2 14/18] Call cond_reshed() as needed in
 [PATCH v2 15/18] libfs: remove cond_resched() from scan_positives()
 [PATCH v2 16/18] libfs: rename and export scan_positives()
 [PATCH v2 17/18] autofs: replace positive_after() with
 [PATCH v2 18/18] autofs: change get_next_positive_dentry() to NOT
