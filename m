From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/27] NSM: Move nsm_use_hostnames to mon.c
Date: Fri, 05 Dec 2008 19:04:48 -0500
Message-ID: <20081206000447.24075.95139.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17339 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543AbYLFAG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:06:29 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Treat the nsm_use_hostnames global variable like nsm_local_state.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    3 ++-
 fs/lockd/svc.c |    1 -
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 2e0ec9f..38b8d51 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -51,7 +51,8 @@ static				DEFINE_SPINLOCK(nsm_lock);
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

