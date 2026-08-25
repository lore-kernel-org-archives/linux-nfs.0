Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F013333E36A;
	Tue, 25 Aug 2026 22:15:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696144; cv=none; b=YXmEMXB3de5HBpzx3F0+T1o0buHsrmslg/HkdjGf6dw+igBYOJWjfyDWLQmPv2wvN0lOY6Nf7W0bTXmHeBPtr/yEpB+ke58CKmAEQXtMOLLC3jPGReALe3FoT7Txu8bcpKerGhlrRBIl/dUfd5s0SgZAFCW0NEpqZsZ+hOppCYs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696144; c=relaxed/simple;
	bh=guQkIoS1l8htr3RCMoG3z4liCpuh1HCDjdXnUnFnkTI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=A2BYq/m5axL9IZBtNddj/IOMFVy7wC1yqM+2caqx0WXfzZB65hRXvpf302P+qzz4GViSeL7l9hXn/aAKUeYHRiRr5eLRe+l+++WBIBDv/QtIJ2SZiWx52bbqXOhJkKS4vo+J4e7nhL9IdgY7Jk89JAUUIWNOKtJ1rp3iOejaDjM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=mZggEozW; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UV6uf/Zl; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="mZggEozW";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UV6uf/Zl"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.stl.internal (Postfix) with ESMTP id 631B41300170;
	Tue, 25 Aug 2026 18:15:41 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Tue, 25 Aug 2026 18:15:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm3; t=1787696141; x=1787703341; bh=AGSaqyf8Gr
	rxzu47IGlioN28N+mexknHz5f3kqFnz5A=; b=mZggEozWsifKGP6AlktFRQEj5x
	867hO/itD1bb35JaaD6kLHra9pkTrMnyP5g/nZCsKnBPsZiHCiZQS1MpfwDcL1dG
	FIHXFJawQvm6gu/0gSot4zd+KYVUvA8X/GBox1nuPDQqkSMufBqsu70R1LDeVwur
	N69fpCFPdew9AQ7ZcnnePBgnhKRYZ3DYHyna2BfuWG50LqPntbBMi1+yf5oTh23k
	2ZznJHw5bjiPJzEom4yZPqDaVWu07ALrujtEtxX1qltaDX/OOT5dif5EQAZHPNmP
	d2dCWCwxdLrImNDzk5wK3BcHxbLL0OIuCZBgY4/NKxLETroV7tv/LpydKeUw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm3; t=1787696141; x=1787703341; bh=AGSaqyf8Grrxzu47IGlioN28N+me
	xknHz5f3kqFnz5A=; b=UV6uf/ZlXG4q+wwvQg8JQxOt8c6Km6/iFmJ8Xc23kRzq
	SZCWCEja+qQT66XnEFI6Y64KppUrr4eUSRDlkvZWFShJ8f0Ppt/2HID3r/yP6MJn
	72s8ycZD5d5pLhTWKGykx/zVUd8wyKBj34hZtJFlpQhBj+M2qpokcet//GN/T4b7
	1DiQHp5CQVX+LNkZIhGwTJ/aoImCmFCDPe3OYkslrkKp1/LwkxTyJrfSwNZeDxHO
	q0m6ir0NZ9XoF/5DWMNW+U/ExLwDJijgS87/3HKb6dfXPEoblK7R6YVBBfTp0vHI
	6xWQJa9UyAmdmw3Cjp02MyUWRQ/kyIBF5azYzp3DQQ==
X-ME-Sender: <xms:DBSOanyIBg-QocKv8rGWGetLG_NuWIvcDLPDNOMEdigrmkGvtZ-1bw>
    <xme:DBSOanfXf21pHXRJdy2hmu_Cn9aFcOpGxlLeBV7SIptKXeCz8CFGTW0Jc2k7DEaCW
    Q1dvC2Fut2dI59CarmLOwrn50lIJS9bR2oydkbjO8eDtoOf>
X-ME-Received: <xmr:DBSOaoq5AE6cUSfzmMjlmDlMvlWCsSblNS7sELz9JHkFcMOkM4ouKa_GWXnecOqg5l1ccvOIwFlGohaIIZQp6VE-DQWV9M4>
X-ME-Proxy-Cause: dmFkZTErUDoFH+M4+lpIrhtcyslDVxY+x0suG//2hYze5i44iRPP6phuAZVqJlhfR8SZPs
    xbfCoNkAPIpwOuTn0rAQsq2v1cVQPsRNSSYy7rU8+zALJHx6h6TKSMldu0qN8eIE76wb4L
    rlMyp9glYXUVggz4tDbupPkd+EETeacDw3lidg54zEyQu6YmfWf4NFqtmaIrp93DBoYgpp
    Zf9U2MbKFy/PfvneNuFazr+QkumiASiHTribPOFKZ+dYTZ5Siyt+spLt4l4093TzFjt48D
    rXjRxZOd1PUpayaRKrVxpQlUW7mby6bEOBDztz1HBgHAjnQjWvMMusqCYMImvLvG/FScnL
    mRLVuYRBEP1x0beOxFDe2DCO7WpP8L7by3E4Ru1ISKTGnSOti+GiciGtppHy01Dn0tj8gZ
    Wh5UvK7UBP0CjwqqX1BbMBvpQYG7ij5ylpYgQONIKghS+Qf8/btbV5ghQdtPnQ9w3lkMJu
    GHXnI+qvgoTWatEux/ad9IHWlRhdkKvB2z0k8N4Rdyyi57diQO7ezbFaYgWoWJnTNuVMev
    edXrV9Y3euwnqgAHskbWqghTp3BjehjJNr3hVvWymnO61RYxM1gEmf7t2rO2c8SxjFIp+K
    qHcgBDpfmkJMC3c5ZLXKjpOiH8+MsePgSKLUEHkTf3Gi+tBVu6VgqlrxinUw
X-ME-Proxy: <xmx:DBSOavMhKuRVKJwUCuI-lDzS97pJdJcyx1xWzt9oxN09Neai0-GMOQ>
    <xmx:DBSOamH1Fl-eROWeAn2Sc-Qcf-3Wbns8x5Sfz5fBWpsJ06jocCE-nQ>
    <xmx:DBSOaqHs8ZinwwrXTHM47AIRVBoOhAiFQ8OIYn2wLSwDAF_U_h3qXQ>
    <xmx:DBSOatABY891HCFd3pN0UUD1xVMgibYQAi7vGUlgluzUi2AHIOc6UA>
    <xmx:DRSOali8gTOkiidAaZjfyDkGEUqrKsfBIV2CnAP1bJLU1AuwlcLeHx3c>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:15:34 -0400 (EDT)
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
Subject: [PATCH RFC/RFT v3 00/11] Fix easy bits of the negative dentry problem
Date: Wed, 26 Aug 2026 08:06:17 +1000
Message-ID: <20260825221459.966875-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Here is v3 which I hope will be the last RFC.  I'd like to submit this
for inclusion in a couple of weeks.
This version:
 - drops the changes to libfs.c.  They aren't strictly needed here
   and serve to bloat the series. I still want to pursue those but
   will do it separately.
 - revises the first fsnotify patch to be more cautious about what I take
   outside of existing locks
 - fixes the nfs i_lock problem Chuck reported
 - fixes a few things sashiko.dev found

Thanks for any review and/or testing.

NeilBrown

Original intro - slightly revised:

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

 so I have probably missed some bits and would be very happy to be told
 what I have missed.
 I would also be very happy if someone who can trigger the soft lockups
 can try this code and confirm that the locks are gone, and nothing bad
 happens.
 I have done some basic testing including the "notify" parts of
 ltp, but that is all.

 I haven't addressed d_walk() or scan_positives() in this series - I
 thought it was big enough for now.  There are already some
 cond_reshed() calls in this code so it isn't clear it *needs* fixing.


[PATCH v3 01/11] VFS: don't count references through ->d_parent
[PATCH v3 02/11] autofs: change positive_after() so it takes d_lock
[PATCH v3 03/11] coda: don't take rcu_read_lock() in
[PATCH v3 04/11] nfs: separate locked regions in
[PATCH v3 05/11] Add and use d_for_each_positive_child family of
[PATCH v3 06/11] fsnotify: don't hold a spin_lock across
[PATCH v3 07/11] fsnotify: don't hold i_lock while walking d_children
[PATCH v3 08/11] nfs: Don't hold i_lock while walking ->d_children
[PATCH v3 09/11] autofs: don't hold ->lookup_lock in
[PATCH v3 10/11] VFS: don't move dentries in d_sib list when they
[PATCH v3 11/11] Call cond_reshed() as needed in
