Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932985Ab0HFWLb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 18:11:31 -0400
Date: Fri, 6 Aug 2010 18:10:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100806221000.GF29536@fieldses.org>
References: <20100802181634.GD12637@fieldses.org>
 <201008030109.o73193bp094241@www262.sakura.ne.jp>
 <20100803154851.GA23467@fieldses.org>
 <201008040013.o740DmYK024832@www262.sakura.ne.jp>
 <20100804194045.GD18200@fieldses.org>
 <201008050110.o751AG18066496@www262.sakura.ne.jp>
 <20100805204612.GA13821@fieldses.org>
 <20100805213107.GB13821@fieldses.org>
 <20100806212727.GC29536@fieldses.org>
 <20100806220537.GE29536@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100806220537.GE29536@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 06, 2010 at 06:05:37PM -0400, J. Bruce Fields wrote:
> On Fri, Aug 06, 2010 at 05:27:28PM -0400, J. Bruce Fields wrote:
> > Bah, so what you were hitting was simple--I just moved the
> > nfsd_reset_versions() call to the wrong place; the below should fix it.
> > 
> > There's also a couple other bugs in the area.

And also there was one more problem with my original "nfsd: fix
startup/shutdown order bug": it doesn't work to use sv_nrthreads
changing from zero to nonzero as the signal for when to do all this
startup, because write_pool_threads() adjusts the number of threads
without calling nfsd_svc().  (Maybe that should be fixed.)

For now, just use the nfsd_up variable to keep track of this (which is a
little closer to Jeff's original solution).

This is a replacement.

--b.

commit 4cd7eb015e92f7cefb43eaab3e111d1b3c7b3cbf
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Aug 2 14:12:44 2010 -0400

    nfsd: fix startup/shutdown order bug
    
    We must create the server before we can call init_socks or check the
    number of threads.
    
    Symptoms were a NULL pointer dereference in nfsd_svc().  Problem
    identified by Jeff Layton.
    
    Also fix a minor cleanup-on-error case in nfsd_startup().
    
    Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 92173bd..2a20f89 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -204,6 +204,9 @@ static bool nfsd_up = false;
 static int nfsd_startup(unsigned short port, int nrservs)
 {
 	int ret;
+
+	if (nfsd_up)
+		return 0;
 	/*
 	 * Readahead param cache - will no-op if it already exists.
 	 * (Note therefore results will be suboptimal if number of
@@ -217,7 +220,7 @@ static int nfsd_startup(unsigned short port, int nrservs)
 		goto out_racache;
 	ret = lockd_up();
 	if (ret)
-		return ret;
+		goto out_racache;
 	ret = nfs4_state_start();
 	if (ret)
 		goto out_lockd;
@@ -420,7 +423,7 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	bool	first_thread;
+	bool	nfsd_up_before;
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
@@ -432,29 +435,29 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
-	first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
-
-	if (first_thread) {
-		error = nfsd_startup(port, nrservs);
-		if (error)
-			goto out;
-	}
 	error = nfsd_create_serv();
 	if (error)
-		goto out_shutdown;
-	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
+		goto out;
+
+	nfsd_up_before = nfsd_up;
+
+	error = nfsd_startup(port, nrservs);
 	if (error)
 		goto out_destroy;
+	}
+	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
+	if (error)
+		goto out_shutdown;
 	/* We are holding a reference to nfsd_serv which
 	 * we don't want to count in the return value,
 	 * so subtract 1
 	 */
 	error = nfsd_serv->sv_nrthreads - 1;
-out_destroy:
-	svc_destroy(nfsd_serv);		/* Release server */
 out_shutdown:
-	if (error < 0 && first_thread)
+	if (error < 0 && !nfsd_up_before)
 		nfsd_shutdown();
+out_destroy:
+	svc_destroy(nfsd_serv);		/* Release server */
 out:
 	mutex_unlock(&nfsd_mutex);
 	return error;
