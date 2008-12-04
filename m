From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/17] NSM: Release nsmhandle in nlm_destroy_host
Date: Thu, 04 Dec 2008 14:21:31 -0500
Message-ID: <20081204192131.8039.19250.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50403 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbYLDTVx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:53 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nsm_handle's reference count is bumped in nlm_lookup_host().  It
should be decremented in nlm_destroy_host() to make it easier to see
the balance of these two operations.

Move the nsm_release() call to fs/lockd/host.c.

The h_nsmhandle pointer is set in nlm_lookup_host(), and never cleared.
The nlm_destroy_host() function is never called for the same nlm_host
twice, so h_nsmhandle won't ever be NULL when nsm_unmonitor() is
called.

All references to the nlm_host are gone before it is freed.  We can
skip making h_nsmhandle NULL just before the nlm_host is deallocated.

It's also likely we can remove the h_nsmhandle NULL check in
nlmsvc_is_client() as well, but we can do that later when rearchitect-
ing the nlm_host cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    8 +++-----
 fs/lockd/mon.c              |    5 -----
 include/linux/lockd/lockd.h |    1 -
 3 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 417e071..316241a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -37,6 +37,7 @@ static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
 						const char *hostname,
 						const size_t hostname_len,
 						const int create);
+static void			nsm_release(struct nsm_handle *nsm);
 
 struct nlm_lookup_host_info {
 	const int		server;		/* search for server|client */
@@ -264,10 +265,8 @@ nlm_destroy_host(struct nlm_host *host)
 	BUG_ON(!list_empty(&host->h_lockowners));
 	BUG_ON(atomic_read(&host->h_count));
 
-	/*
-	 * Release NSM handle and unmonitor host.
-	 */
 	nsm_unmonitor(host);
+	nsm_release(host->h_nsmhandle);
 
 	clnt = host->h_rpcclnt;
 	if (clnt != NULL)
@@ -712,8 +711,7 @@ found:
 /*
  * Release an NSM handle
  */
-void
-nsm_release(struct nsm_handle *nsm)
+static void nsm_release(struct nsm_handle *nsm)
 {
 	if (!nsm)
 		return;
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index aaaa08e..15fab22 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -117,10 +117,6 @@ nsm_unmonitor(struct nlm_host *host)
 	struct nsm_res	res;
 	int		status = 0;
 
-	if (nsm == NULL)
-		return 0;
-	host->h_nsmhandle = NULL;
-
 	if (atomic_read(&nsm->sm_count) == 1
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
 		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
@@ -132,7 +128,6 @@ nsm_unmonitor(struct nlm_host *host)
 		else
 			nsm->sm_monitored = 0;
 	}
-	nsm_release(nsm);
 	return status;
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index f15a4f5..30a6a9c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -240,7 +240,6 @@ void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
 extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
 					unsigned int, u32);
-void		  nsm_release(struct nsm_handle *);
 
 /*
  * Host monitoring

