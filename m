From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: don't take nfsd_mutex twice when setting number of threads
Date: Thu, 18 Jun 2009 12:43:38 -0400
Message-ID: <20090618164338.GB9679@fieldses.org>
References: <20090618164137.GA9679@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35688 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbZFRQnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 12:43:35 -0400
Received: from bfields by pickle.fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1MHKiA-0002eb-Of
	for linux-nfs@vger.kernel.org; Thu, 18 Jun 2009 12:43:38 -0400
In-Reply-To: <20090618164137.GA9679@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2009 at 12:41:37PM -0400, bfields wrote:
> I'm applying the following patch for 2.6.31.

And this.

commit 671e1fcf63fd115eabcb693b06cbc2e4a3d1a3a3
Author: NeilBrown <neilb@suse.de>
Date:   Tue Jun 16 11:03:20 2009 +1000

    nfsd: optimise the starting of zero threads when none are running.
    
    Currently, if we ask to set then number of nfsd threads to zero when
    there are none running, we set up all the sockets and register the
    service, and then tear it all down again.
    This is pointless.
    
    So detect that case and exit promptly.
    (also remove an assignment to 'error' which was never used.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Acked-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 209eaa0..d4c9884 100644
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
