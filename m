From: NeilBrown <neilb@suse.de>
Subject: [PATCH 2/3] nfsd: optimise the starting of zero threads when none are
	running.
Date: Thu, 28 May 2009 16:33:03 +1000
Message-ID: <20090528063303.15937.57966.stgit@notabene.brown>
References: <20090528062730.15937.70579.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: NeilBrown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43859 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbZE1Gdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2009 02:33:54 -0400
Received: from relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 2B7A98655F
	for <linux-nfs@vger.kernel.org>; Thu, 28 May 2009 08:33:55 +0200 (CEST)
In-Reply-To: <20090528062730.15937.70579.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if we ask to set then number of nfsd threads to zero when
there are none running, we set up all the sockets and register the
service, and then tear it all down again.
This is pointless.

So detect that case and exit promptly.
(also remove an assignment to 'error' which was never used.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfsd/nfssvc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index df6c59e..83b7d41 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -390,12 +390,14 @@ nfsd_svc(unsigned short port, int nrservs)
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
-	error = -EINVAL;
 	if (nrservs <= 0)
 		nrservs = 0;
 	if (nrservs > NFSD_MAXSERVS)
 		nrservs = NFSD_MAXSERVS;
-	
+	error = 0;
+	if (nrservs == 0 && nfsd_serv == NULL)
+		goto out;
+
 	/* Readahead param cache - will no-op if it already exists */
 	error =	nfsd_racache_init(2*nrservs);
 	if (error<0)


