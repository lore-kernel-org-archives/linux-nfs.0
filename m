From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/16] NSM: Use sockaddr_storage for sm_addr field
Date: Mon, 30 Jun 2008 18:59:10 -0400
Message-ID: <20080630225909.25407.18045.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:16612 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381AbYF3XBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:01:16 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To store larger addresses in the nsm_handle structure, make sm_addr a
sockaddr_storage.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    5 +++--
 fs/lockd/mon.c              |    2 +-
 include/linux/lockd/lockd.h |   13 ++++++++++++-
 3 files changed, 16 insertions(+), 4 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 290358b..c2efbfb 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -544,7 +544,7 @@ retry:
 			if (strlen(pos->sm_name) != hostname_len
 			 || memcmp(pos->sm_name, hostname, hostname_len))
 				continue;
-		} else if (!nlm_cmp_addr(&pos->sm_addr, sin))
+		} else if (!nlm_cmp_addr(nsm_addr_in(pos), sin))
 			continue;
 		atomic_inc(&pos->sm_count);
 		kfree(nsm);
@@ -564,7 +564,8 @@ retry:
 	if (nsm == NULL)
 		return NULL;
 
-	nsm->sm_addr = *sin;
+	memcpy(nsm_addr(nsm), sin, sizeof(*sin));
+	nsm->sm_addrlen = sizeof(*sin);
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e4d5635..4e7e958 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -51,7 +51,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 
 	memset(&args, 0, sizeof(args));
 	args.mon_name = nsm->sm_name;
-	args.addr = nsm->sm_addr.sin_addr.s_addr;
+	args.addr = nsm_addr_in(nsm)->sin_addr.s_addr;
 	args.prog = NLM_PROGRAM;
 	args.vers = 3;
 	args.proc = NLMPROC_NSM_NOTIFY;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 8834d31..a1eecf5 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -71,7 +71,8 @@ struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
 	char *			sm_name;
-	struct sockaddr_in	sm_addr;
+	struct sockaddr_storage	sm_addr;
+	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
 };
@@ -99,6 +100,16 @@ static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
 	return (struct sockaddr *)&host->h_srcaddr;
 }
 
+static inline struct sockaddr_in *nsm_addr_in(const struct nsm_handle *handle)
+{
+	return (struct sockaddr_in *)&handle->sm_addr;
+}
+
+static inline struct sockaddr *nsm_addr(const struct nsm_handle *handle)
+{
+	return (struct sockaddr *)&handle->sm_addr;
+}
+
 /*
  * Map an fl_owner_t into a unique 32-bit "pid"
  */

