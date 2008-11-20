From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Thu, 20 Nov 2008 15:37:35 -0500
Message-ID: <20081120203735.GB30808@fieldses.org>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54764 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757402AbYKTUhh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Nov 2008 15:37:37 -0500
In-Reply-To: <x498wrokjj8.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2008 at 11:15:23AM -0500, Jeff Moyer wrote:
> Hi,
> 
> I'm doing some testing which involves roughly the following:
> 
> o mount a file system on the server
> o start the nfs service
> - mount the nfs-exported file system from a client
> - perform a dd from the client
> - umount the nfs-exported file system from a client
> o stop the nfs service
> o unmount the file system on the server
> 
> After several iterations of this, varying the number of nfsd threads
> started, I get the attached backtrace.  I've reproduced it twice, now.
> 
> Let me know if I can be of further help.

Apologies for the delay, and thanks for the report.  Does the following
help?  (Untested).

--b.

commit 77b810d52cc07212c79848b98bb992f0541afefb
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Nov 20 14:36:17 2008 -0600

    nfsd: clean up grace period on early exit
    
    If nfsd was shut down before the grace period ended, we could end up
    with a freed object still on grace_list.  Thanks to Jeff Moyer for
    reporting the resulting list corruption warnings.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: Jeff Moyer <jmoyer@redhat.com>

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c631a83..56b0767 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -181,6 +181,7 @@ lockd(void *vrqstp)
 	}
 	flush_signals(current);
 	cancel_delayed_work_sync(&grace_period_end);
+	locks_end_grace(&lockd_manager);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b0bebc5..1a052ac 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3261,6 +3261,7 @@ nfs4_state_shutdown(void)
 {
 	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
 	destroy_workqueue(laundry_wq);
+	locks_end_grace(&nfsd4_manager);
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
