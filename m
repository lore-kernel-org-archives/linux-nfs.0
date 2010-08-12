Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35489 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298Ab0HLHF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 03:05:27 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 17:04:05 +1000
Subject: [PATCH 0/6] Cache deferral improvements - try N+2
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812065722.11459.18978.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I don't think it is quite 6 months since I last posted these, but I've
definitely dropped the ball... so here they are again.

This set allows kernel threads to wait a short while for an upcall (to
get auth info) to complete rather than having to queue and retry the
whole request.
It also changes NFSv4 to never use the old deferral scheme at all.

The last two patches are just little clean-ups that I found while
wandering around the code.

I think I have address all the concern raised previously, e.g.
  http://www.spinics.net/lists/linux-nfs/msg12253.html

Note that there is a conflict between this patch set and the other
one.  The other changes someing in nfs4idmap.c, and this one removes
all the code that was changed.  Very easy to resolve.

Thanks,
NeilBrown

---

NeilBrown (6):
      sunrpc/cache: allow threads to block while waiting for cache update.
      nfsd/idmap: drop special request deferal in favour of improved default.
      sunrpc: close connection when a request is irretrievably lost.
      nfsd: disable deferral for NFSv4
      svcauth_gss: replace a trivial 'switch' with an 'if'
      sunrpc/cache: change deferred-request hash table to use hlist.


 fs/nfsd/nfs4idmap.c               |  105 ++++---------------------------------
 fs/nfsd/nfs4proc.c                |    4 +
 include/linux/sunrpc/cache.h      |    5 +-
 include/linux/sunrpc/svcauth.h    |   10 ++--
 net/sunrpc/auth_gss/svcauth_gss.c |   51 ++++++++----------
 net/sunrpc/cache.c                |   71 +++++++++++++++++++------
 net/sunrpc/svc.c                  |    3 +
 net/sunrpc/svc_xprt.c             |   11 ++++
 net/sunrpc/svcauth_unix.c         |   11 +++-
 9 files changed, 125 insertions(+), 146 deletions(-)

-- 
Signature

