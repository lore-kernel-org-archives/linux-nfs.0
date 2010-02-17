Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49825 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190Ab0BQGsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2010 01:48:42 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Date: Wed, 17 Feb 2010 17:47:30 +1100
Subject: [PATCH 0/2] sunrpc: use monotonic time for expiry times
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100217064330.13656.61404.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've always known I would pay for this some day ....

The authentication cache uses wall-clock time for expiry times and
related time stamps.

This can cause problems if the wall-clock time changes suddenly.
e.g. if you set the time forward one hour, the export cache is
immediately flushed.  This isn't an enormous problem, but it should be
fixed.

Currently, it can cause clients to have to resend requests which can
cause a delay of several timeouts.  Once we get the improvements in
which allow a thread to wait for a while rather than dropping a
request, this will be less of an issue.  But I think it is worth
fixing anyway.

So: two patches.  One moves come common code to an inline, the other
makes the change.

comments?

Thanks,
NeilBrown

---

NeilBrown (2):
      sunrpc: extract some common sunrpc_cache code from nfsd
      sunrpc: use monotonic time in expiry cache


 fs/nfs/dns_resolve.c         |    6 +++---
 fs/nfsd/export.c             |    9 +++------
 fs/nfsd/nfs4idmap.c          |    2 +-
 include/linux/sunrpc/cache.h |   23 ++++++++++++++++++++++-
 net/sunrpc/cache.c           |   33 ++++++++++++++++++---------------
 5 files changed, 47 insertions(+), 26 deletions(-)


