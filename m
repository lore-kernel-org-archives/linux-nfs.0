From: NeilBrown <neilb@suse.de>
Subject: [nfsd PATCH 0/3] address issues with shutdown while portmap is dead
Date: Thu, 28 May 2009 16:33:03 +1000
Message-ID: <20090528062730.15937.70579.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47237 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbZE1Gdm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2009 02:33:42 -0400
Received: from relay2.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id B87F274609
	for <linux-nfs@vger.kernel.org>; Thu, 28 May 2009 08:33:43 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all.
Currently if you shutdown nfsd while portmap is dead, it takes about
3.5 minutes.  This isn't ideal.

The following patch series address some issues surrounding that.
The first two a minor fixes to nfsd which get it behave a little bit
more consistently.  They don't directly affect the issue.

The third changes the timeouts used when rpcb_client talks to
portmap or rpcbind to unregister a service.  It simply reduces the
timeout to 0.5 seconds with no retries.
As there should be no packet loss, this should only fail if
portmap/rpcbind isn't working.  And in that case unregistering
wont serve any purpose anyway.

And as unregistering is merely for cleanliness, not for correctness,
there wouldn't be a problem even if something did go wrong.

With this patch, the 3.5 minutes drops to 3 seconds.

Comments welcome.

Thanks,
NeilBrown


---

NeilBrown (3):
      sunrpc: reduce timeout when unregistering rpcbind registrations.
      nfsd: optimise the starting of zero threads when none are running.
      nfsd: don't take nfsd_mutex twice when setting number of threads.


 fs/nfsd/nfsctl.c       |   13 +++++++++----
 fs/nfsd/nfssvc.c       |    8 ++++++--
 net/sunrpc/rpcb_clnt.c |   17 +++++++++++++++--
 3 files changed, 30 insertions(+), 8 deletions(-)

-- 
Signature

