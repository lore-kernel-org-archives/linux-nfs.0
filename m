From: NeilBrown <neilb@suse.de>
Subject: [PATCH 0/2] NFS: allow remount to change some parameters
Date: Fri, 11 Sep 2009 16:56:03 +1000
Message-ID: <20090911065428.8193.8170.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58856 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbZIKGz3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 02:55:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches allow soft, hard, timeo, and retrans to be changed
by "mount -o remount" on an NFS filesystems.

I have lightly tested them and they work, providing the server is
responsive.
However I don't plan to be using this functionality after all, so I
wont be likely to test them any more.

NeilBrown


---

NeilBrown (2):
      NFS: support changing timeout and retransmit values with remount
      NFS: support changing the soft/hard flag with remount


 fs/nfs/client.c              |    4 ++--
 fs/nfs/internal.h            |    2 ++
 fs/nfs/super.c               |   39 ++++++++++++++++++++++++++++++++++++---
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   21 +++++++++++++++++++++
 5 files changed, 62 insertions(+), 5 deletions(-)

-- 
Signature

