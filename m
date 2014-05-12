Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47580 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810AbaELBXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 21:23:32 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 12 May 2014 11:22:47 +1000
Subject: [PATCH 0/2] NFSD: restrict PF_LESS_THROTTLE to loop-back requests.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140512012120.20840.68685.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As PF_LESS_THROTTLE now has a slightly broader meaning it makes sense
to restrict it to only the times it is actually needed - when write
requests come from the local host.

Thanks,
NeilBrown

---

NeilBrown (2):
      SUNRPC: track whether a request is coming from a loop-back interface.
      nfsd: Only set PF_LESS_THROTTLE when really needed.


 fs/nfsd/nfssvc.c                |    6 ------
 fs/nfsd/vfs.c                   |   12 ++++++++++++
 include/linux/sunrpc/svc.h      |    1 +
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/sunrpc.h             |   13 +++++++++++++
 net/sunrpc/svcsock.c            |    5 +++++
 6 files changed, 32 insertions(+), 6 deletions(-)

-- 
Signature

