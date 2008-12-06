From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/27] NSM: Add dprintk() calls in nsm_find and nsm_release
Date: Fri, 05 Dec 2008 19:02:53 -0500
Message-ID: <20081206000252.24075.51827.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:30606 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787AbYLFAEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:51 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce some dprintk() calls in fs/lockd/mon.c that are enabled by
the NLMDBG_MONITOR flag.  These report when we find, create, and
release nsm_handles.

Since printk() can sleep, these are placed outside the nsm_lock
spinlock.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index d5bd847..8628d31 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -248,14 +248,22 @@ retry:
 		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
 			continue;
 		atomic_inc(&pos->sm_count);
+		spin_unlock(&nsm_lock);
 		kfree(nsm);
-		nsm = pos;
-		goto found;
+		dprintk("lockd: found nsm_handle for %s (%s), cnt %d\n",
+				pos->sm_name, pos->sm_addrbuf,
+				atomic_read(&pos->sm_count));
+		return pos;
 	}
+
 	if (nsm) {
 		list_add(&nsm->sm_link, &nsm_handles);
-		goto found;
+		spin_unlock(&nsm_lock);
+		dprintk("lockd: created nsm_handle for %s (%s)\n",
+				nsm->sm_name, nsm->sm_addrbuf);
+		return nsm;
 	}
+
 	spin_unlock(&nsm_lock);
 
 	if (!create)
@@ -274,10 +282,6 @@ retry:
 				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
 	atomic_set(&nsm->sm_count, 1);
 	goto retry;
-
-found:
-	spin_unlock(&nsm_lock);
-	return nsm;
 }
 
 /**
@@ -292,6 +296,9 @@ void nsm_release(struct nsm_handle *nsm)
 	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
 		list_del(&nsm->sm_link);
 		spin_unlock(&nsm_lock);
+
+		dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
+				nsm->sm_name, nsm->sm_addrbuf);
 		kfree(nsm);
 	}
 }

