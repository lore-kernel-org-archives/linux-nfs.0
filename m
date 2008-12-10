From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/27] NSM: Add dprintk() calls in nsm_find and
	nsm_release
Date: Wed, 10 Dec 2008 16:05:01 -0500
Message-ID: <20081210210501.GG1212@fieldses.org>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000252.24075.51827.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36512 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754851AbYLJVFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 16:05:02 -0500
In-Reply-To: <20081206000252.24075.51827.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2008 at 07:02:53PM -0500, Chuck Lever wrote:
> Introduce some dprintk() calls in fs/lockd/mon.c that are enabled by
> the NLMDBG_MONITOR flag.  These report when we find, create, and
> release nsm_handles.
> 
> Since printk() can sleep, these are placed outside the nsm_lock
> spinlock.

Nope, printk() is designed to be callable from anywhere.  (This is
documented e.g. in kernel/printk.c:printk().)  I've applied the
following; look OK?

--b.

commit dfe441d67b96543eb8cdebd5323c3239e5460213
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 5 19:02:53 2008 -0500

    NSM: Add dprintk() calls in nsm_find and nsm_release
    
    Introduce some dprintk() calls in fs/lockd/mon.c that are enabled by
    the NLMDBG_MONITOR flag.  These report when we find, create, and
    release nsm_handles.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index d5bd847..c332c50 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -250,10 +250,15 @@ retry:
 		atomic_inc(&pos->sm_count);
 		kfree(nsm);
 		nsm = pos;
+		dprintk("lockd: found nsm_handle for %s (%s), cnt %d\n",
+				pos->sm_name, pos->sm_addrbuf,
+				atomic_read(&pos->sm_count));
 		goto found;
 	}
 	if (nsm) {
 		list_add(&nsm->sm_link, &nsm_handles);
+		dprintk("lockd: created nsm_handle for %s (%s)\n",
+				nsm->sm_name, nsm->sm_addrbuf);
 		goto found;
 	}
 	spin_unlock(&nsm_lock);
@@ -292,6 +297,8 @@ void nsm_release(struct nsm_handle *nsm)
 	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
 		list_del(&nsm->sm_link);
 		spin_unlock(&nsm_lock);
+		dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
+				nsm->sm_name, nsm->sm_addrbuf);
 		kfree(nsm);
 	}
 }
