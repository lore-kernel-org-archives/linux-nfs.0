Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52677 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbaHDGZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 02:25:00 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 04 Aug 2014 16:24:00 +1000
Subject: [PATCH 0/2] Two fixes for NFS RCU-walk support
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140804062225.7621.70050.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks to the Feng Wu and the kbuild test robot I see
that some uses for rcu_dereference are wrong.
This two patches resolve the issue and also fix an
embarrassing but harmless bug.

---

NeilBrown (2):
      NFS: fix two problems in lookup_revalidate in RCU-walk
      SUNRPC: remove all refcounting of groupinfo from rpcauth_lookupcred


 fs/nfs/dir.c      |    8 ++++----
 net/sunrpc/auth.c |    8 +-------
 2 files changed, 5 insertions(+), 11 deletions(-)

-- 
Signature

