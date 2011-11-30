Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47340 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3A44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Nov 2011 19:56:56 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 30 Nov 2011 11:52:51 +1100
Subject: [PATCH 0/2] Resent of two NFS patches.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20111130005231.23632.87382.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,
 Following are two patches have already been sent in some form,
 but don't seem to be in your tree yet.

 First is a simple bug fix for a recent breakage.

 The second allows SOFTCONN connections to fail quickly on a fatal
 error (such as net-unreachable).  You did comment on the first version 
 and wondered about merging some similar functions, so this version
 does that merge.

Thanks,
NeilBrown

---

NeilBrown (2):
      sunrpc: wake up SOFTCONN tasks when a connection error happens.
      NFS - fix recent breakage to NFS error handling.


 fs/nfs/file.c                  |    4 ++--
 include/linux/sunrpc/sched.h   |    7 +++++--
 net/sunrpc/auth_gss/auth_gss.c |    4 ++--
 net/sunrpc/rpcb_clnt.c         |    2 +-
 net/sunrpc/sched.c             |   39 +++++++++------------------------------
 net/sunrpc/xprt.c              |    2 +-
 net/sunrpc/xprtsock.c          |    6 +++++-
 7 files changed, 25 insertions(+), 39 deletions(-)

-- 
Signature

