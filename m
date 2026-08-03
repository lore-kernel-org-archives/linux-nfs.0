Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8156C234994;
	Mon,  3 Aug 2026 01:37:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721024; cv=none; b=GXXz65ywOpoGoeZyUYkYFypKYGuJjQe1A3GZ8otGwsGZ+F0fcf413AkzshbZDSTnLNjI25Ab/Gw0yyzq0SH5yIFPmXD+K8X5hZYQE7qun9E/s+WtyKsVZrkW/TPjjaSCFsvYX9+ZmGqkgq5eoqEBmSiON0T8mnxTDBBuJv4wr6E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721024; c=relaxed/simple;
	bh=pC3W2Vu/zXCsiSoWjl25+t1uFdTl040qXYOdTe2P1Ec=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qOp0yjYIx2z07kWCS17ZTCfdm6oGyRzbePWz47oNOl5RvBSGoswElHvBTnYzHBxAZKE6u29mepjVVNnngweb7mN1aucS9v8wgJiyzMJBbudzptf3XKvxgJ4aD5ZGOK7LCxYLbJsMF2mwEQ1eJEQyt70nI4ww+rL7tanxzS76AL8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Jr5gtqj+; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=BJZgfqtM; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Jr5gtqj+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BJZgfqtM"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.stl.internal (Postfix) with ESMTP id ED10A13000EC;
	Sun,  2 Aug 2026 21:36:59 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Sun, 02 Aug 2026 21:37:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm3; t=1785721019; x=1785728219; bh=hj7vVySkI2
	yxJswQO8e4CqCndOSm6xw5GmVI7rCuyQ0=; b=Jr5gtqj+mqViXSntRhXXXORkxy
	bQv0Muvcz5NXHgqNKLgnxM8aj2no1pyGjnqp7bWbueOahx19iIH5wW6G7FQwn1Sp
	m/X7d9ZXB8FPA71WOuxSfzhgj+3RSYl+2rgQpsfbcK1oej+W5y4D0+OUaaEwtGzy
	DNHEq3Gvzrdly0NnKGMpkgeKpijeCre3Ui6AZc/rdt9xqHrBfmnR2rg3CHpBTb4s
	krj0hGE5WbEQmVrfWPffyPv61OO8DN4C8k73+tPXHOxWMFuw9LubjZkvSI3wRvmU
	jobA88xziQiKpXnlFV4+ogLG0viSvPsnVb3jAiCFRwPj361xrYQrteZfKIFg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm3; t=1785721019; x=1785728219; bh=hj7vVySkI2yxJswQO8e4CqCndOSm
	6xw5GmVI7rCuyQ0=; b=BJZgfqtMe7SiJUu+KulwM9I29Li6db5BftC3XwemXo1G
	/WEIHDz8Xi2yoALKaaGfGZtrcQoNXrIIVpfuYIe/4VCcS66thzJmlXNfOKa/nRMM
	4Y6AV+MEY91KcYAr205ykapEEgYWsEE9RXFAV4J89pgGVTJUIFHPGF+TQpYcrVfj
	ix4iQQSBRszDbV34zyx6m8621ChduYRV5nyakTL4uqb2U8nntrsk9ti/Gj/VrjPW
	7JSymljtdFbOjqTIkUuuHY3K1uK07IT5H5iyLhk+GzkiLJSJwyqwilQf9BByDk+H
	Hy1SaNgLD8pJ8kh1iYPaAXNGZUOXcvwxyWDYhHkkwQ==
X-ME-Sender: <xms:u_BvatX-v2807U49m5G6pYxqtr06ooUSdlyFrIU8L16W2if5g8vC3Q>
    <xme:u_Bvaonv6ifXwAShCuu6vAhDkQfhkWC5VFU2MrdthQxk086c_HFKYDTb4UreJP3jy
    yAS5-kk5GkSecNyfiJBfCks_3ncCTUmFvFGlkah3wI1enohx2k>
X-ME-Received: <xmr:u_BvagBmUYFnMOTS0MRZhuHhTTj4iEJzJkarzdgq9N-E9qSs3WCnva_lyPV2ZnIOVnNMxdJdj5rve4omUbsZJQ3A9BiKFrc>
X-ME-Proxy-Cause: dmFkZTEAF9WySxFfIy8Gk965K95nE0ICFQuQ0ULZDgfyo7FS1VDKhQiDFOZkmr+/yfa228
    0uHag9iZbVDyTRCWbp3YAZHBJLzuisMukqt345UCr18E5mngdaf/ZkoC4Pj7ucKKYC4/Ka
    3JH0/Y+49i1w31Mc/C60fAt4CYeoJeNGsr2foDqAlREFYOuYElde+cD6PeV/1i5RgvQnqe
    BDTZCcBeexnhv2Egd4X3qE2IRfzCmi08Zv6FthHZ+i96zKuqZ5piAwEQ4fsf3w5QbVAZWM
    AhLeVfidI8dToCizssD4jm1KOf0GWVcspGYuYtAE11Xwh/i70QxLzQXV5cfhGgh214SucF
    oA349+sio/1YV8B8Q+PAhlFXOceAkh53ncW7C01Ly8TfeMyYoug8f2g46vX+BacrEVs5jM
    ao1pSRdOPsgflqF8M0JWYSahkCHraY+bKqqSl6O6Lel7EIrUd18HbNAbJt0qtq5ZtkdgrH
    c4cJTpAThslvE+btweu/ULGxXEnV1uKbuGNoIjDaSudeJFt0C1/iTFnr9WteXapiC0DFIC
    p7eQ+rmB9u0XSrnGw62ZUWYfbl/5/2CUr7o8XYZvLlXFmzVLm2dyy8Itv5BKqNACTMM8Oo
    jqqT6nWD8kTDFJeEJx+XCXJOOngjBTewoPpaDwPdB0HtfgFlnVkIHu31WAkA
X-ME-Proxy: <xmx:u_Bvat9_lTiWDDf24LJJWdMa6OUngS9FBzp4lRfffFrkc_CrygVntw>
    <xmx:u_BvaiTyDvzhRWUK5iYsor4rxYiYcS2OXW8WjkTaWc7dD1vf8qD2Kw>
    <xmx:u_Bvaj6gu4kCeWW_pc117kEWWeD2CIFmvIvFshUbBcjldGBlBoQ7qg>
    <xmx:u_Bvaro6TdwLtIQ55ISJdX-nwg2RA2WcNDIG5KqX3_tHmDfMpQeQ3w>
    <xmx:u_Bvah9nXjoLwYG9k0TGvibnQa0jGIcg1-0pT-zMRHlmM9CgXbn2W8ap>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:36:51 -0400 (EDT)
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
Subject: [PATCH RFC/RFT v1 00/12] Fix easy bits of the negative dentry problem
Date: Mon,  3 Aug 2026 11:21:09 +1000
Message-ID: <20260803012648.2195405-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi all,

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

Details worth checking in various modules:

NFS: patch 02 drops the parent lock between calling
        nfs_unset_verifier_delegated()
     on the parent and calling it on all the children.  I don't
     think this is significant.

autofs:  patch 09 removes the ->lookup_lock from
             get_next_positive_subdir() 
         and
             get_next_positive_dentry()
         I cannot see that this is serving any purpose

cephfs:  nothing interesting
coda:  patch 02 dropped the rcu_read_lock() because the spinlock() implies it.

libfs: the offset_dir code has been changed (08) quite a bit but should
      have identical behaviour.  It now uses scan_positives() (which has
      been substantially refactored (05, 06, 07, 12)) in place of
      find_positive_dentry()

fsnotify: a few changes (03 04) to move the ->d_children walk out from under
     various spinlocks.  This is the change I'm least confident of
     as it is non-trivial code that I'm not familiar with.

dcache: patch 11 uses an on-stack dentry as a dcache cursor.  This is
     not something that other code does so I would appreciate it if
     someone checked my logic.

dcache: patch 10 changed d_move to *not* move dentries in the
     ->d_children list when they are both in the same parent.
     This brings no value and could cause some instability in
     a d_children walk.

Thanks for any review or testing that you have time for.

NeilBrown

This series is against v7.2-rc6 and can be found at the 
   vfs-neg-dentries
branch of
   https://github.com/neilbrown/linux
where top commit is
   56768a600dd9145fea601649dbc74031aa25e459

 [PATCH v1 01/12] VFS: don't count references through ->d_parent
 [PATCH v1 02/12] Add and use d_for_each_positive_child family of
 [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 [PATCH v1 04/12] fsnotify: reduce i_lock hold time in
 [PATCH v1 05/12] libfs: simplify scan_positives()
 [PATCH v1 06/12] libfs: change scan_positives() to use
 [PATCH v1 07/12] libfs: allow scan_positives() to be called without a
 [PATCH v1 08/12] libfs: replace find_positive_dentry() with
 [PATCH v1 09/12] autofs: don't hold ->lookup_lock in
 [PATCH v1 10/12] VFS: don't move dentries in d_sib list when they
 [PATCH v1 11/12] Call cond_reshed() as needed in
 [PATCH v1 12/12] libfs: remove cond_resched() from scan_positives()
