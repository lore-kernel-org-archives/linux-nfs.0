Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45401 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757116Ab0HCQZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 12:25:59 -0400
Date: Tue, 3 Aug 2010 12:24:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100803162438.GB23467@fieldses.org>
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp>
 <20100802103214.7eea09eb@corrin.poochiereds.net>
 <20100802103620.5638dac1@corrin.poochiereds.net>
 <20100802181634.GD12637@fieldses.org>
 <201008030109.o73193bp094241@www262.sakura.ne.jp>
 <20100803154851.GA23467@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803154851.GA23467@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 11:48:51AM -0400, J. Bruce Fields wrote:
> On Tue, Aug 03, 2010 at 10:09:03AM +0900, Tetsuo Handa wrote:
> > Hello.
> > 
> > That patch solved the NULL pointer dereference problem. Thank you.
> > 
> > But I got another problem. After applying that patch on 2.6.35-next-20100802 ,
> > mount operation fails with timeout error.
> 
> Argh, yes, problem found, I think--I'll do some more testing and send
> you another attempt....

How about this?

(By the way, are you using something other than the standard
/etc/init.d/nfs-kernel-server to start/stop the server?  Or have you
customized your installation in any way?  Just curious, as the bugs
you're finding are good, but I'd expect different symptoms from the
default setup.)

--b.

commit 3deb279d6e5625407919a875db3a2461199566b3
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Aug 2 14:12:44 2010 -0400

    nfsd: fix startup/shutdown order bug
    
    We must create the server before we can call init_socks or check the
    number of threads.
    
    Symptoms were a NULL pointer dereference in nfsd_svc().  Problem
    identified by Jeff Layton.
    
    Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 92173bd..58e3d4c 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -420,7 +420,7 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	bool	first_thread;
+	bool	unstarted, first_thread;
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
@@ -432,29 +432,31 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
-	first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
+	unstarted = nfsd_serv == NULL || nfsd_serv->sv_nrthreads == 0;
+	first_thread = unstarted && (nrservs != 0);
+
+	error = nfsd_create_serv();
+	if (error)
+		goto out;
 
 	if (first_thread) {
 		error = nfsd_startup(port, nrservs);
 		if (error)
-			goto out;
+			goto out_destroy;
 	}
-	error = nfsd_create_serv();
-	if (error)
-		goto out_shutdown;
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
 	if (error)
-		goto out_destroy;
+		goto out_shutdown;
 	/* We are holding a reference to nfsd_serv which
 	 * we don't want to count in the return value,
 	 * so subtract 1
 	 */
 	error = nfsd_serv->sv_nrthreads - 1;
-out_destroy:
-	svc_destroy(nfsd_serv);		/* Release server */
 out_shutdown:
 	if (error < 0 && first_thread)
 		nfsd_shutdown();
+out_destroy:
+	svc_destroy(nfsd_serv);		/* Release server */
 out:
 	mutex_unlock(&nfsd_mutex);
 	return error;
