From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/11] NSM: Move nsm_use_hostnames to mon.c
Date: Thu, 11 Dec 2008 17:56:29 -0500
Message-ID: <20081211225629.21468.12521.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36992 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759553AbYLKW4p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:45 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Treat the nsm_use_hostnames global variable like nsm_local_state.
Note that the default value of nsm_use_hostnames is still zero.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    3 ++-
 fs/lockd/svc.c |    1 -
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 534d6de..cd8db11 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -53,7 +53,8 @@ static				DEFINE_SPINLOCK(nsm_lock);
 /*
  * Local NSM state
  */
-int				nsm_local_state;
+int	__read_mostly		nsm_local_state;
+int	__read_mostly		nsm_use_hostnames;
 
 static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
 {
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 50de426..8283b0e 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -59,7 +59,6 @@ unsigned long			nlmsvc_timeout;
 static unsigned long		nlm_grace_period;
 static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
 static int			nlm_udpport, nlm_tcpport;
-int				nsm_use_hostnames = 0;
 
 /*
  * Constants needed for the sysctl interface.

