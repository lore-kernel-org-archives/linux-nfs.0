Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45533 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893Ab0HBSR5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Aug 2010 14:17:57 -0400
Date: Mon, 2 Aug 2010 14:16:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100802181634.GD12637@fieldses.org>
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp>
 <20100802103214.7eea09eb@corrin.poochiereds.net>
 <20100802103620.5638dac1@corrin.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100802103620.5638dac1@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 02, 2010 at 10:36:20AM -0400, Jeff Layton wrote:
> nevermind...that patch will probably fix this panic, but there's another
> possible one in nfsd_init_socks. We'll have to fix that one too.

(After private conversation with Jeff): something like this?
Compile-tested only.

--b.

commit 86d0cc3b91315c475c1c38ee7a06b5ebe5c01755
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
index 92173bd..1de1cb3 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -432,29 +432,30 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
+	error = nfsd_create_serv();
+	if (error)
+		goto out;
+
 	first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
 
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
