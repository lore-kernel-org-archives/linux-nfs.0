Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54442 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab0IVC5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:57:38 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:06 +1000
Subject: [PATCH 0/7] Assorted nfsd patches for 2.6.37
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce

 Thanks for pushing your latest tree out.  I wouldn't normally be so
 impatient, but i seem to be in the mood to work on nfsd at the moment
 and I don't want to waste the opportunity.

 Following are some patches you might like to consider.  They have
 only been lightly tested (if at all), and the "allow thread
 manager..." one particularly needs "is this even a good idea"-type
 review.

 First two fix clear bugs - one introduced by me, one by you :-)
 Then some (arguable) improvements to the cache deferral stuff (one of
 which is a resend).
 Then deprecation of the legacy syscall interface. :-)

Thanks,
NeilBrown

---

NeilBrown (7):
      sunrpc: fix race in new cache_wait code.
      sunrpc/cache: fix recent breakage of cache_clean_deferred
      sunrpc/cache: change deferred-request hash table to use hlist.
      sunrpc/cache: centralise handling of size limit on deferred list.
      sunrpc/cache: allow thread manager more control of whether threads can wait for upcalls
      nfsd: formally deprecate legacy nfsd syscall interface
      nfsd: allow deprecated interface to be compiled out.


 Documentation/feature-removal-schedule.txt |   10 ++
 fs/Makefile                                |    5 -
 fs/compat.c                                |    2 
 fs/nfsd/Kconfig                            |   12 +++
 fs/nfsd/export.c                           |   22 +++++
 fs/nfsd/nfsctl.c                           |   20 +++++
 include/linux/sunrpc/cache.h               |   10 +-
 include/linux/sunrpc/svc.h                 |    1 
 net/sunrpc/cache.c                         |  117 +++++++++++++++++-----------
 net/sunrpc/svc_xprt.c                      |   54 ++++++++++---
 10 files changed, 181 insertions(+), 72 deletions(-)

-- 
Signature

