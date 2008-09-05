From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/19] nfs-utils: Remove unused function rpc_svcrun()
Date: Fri, 05 Sep 2008 17:07:58 -0400
Message-ID: <20080905210758.10001.68970.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47133 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbYIEVJH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:09:07 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: remove function that has been disabled (via #if 0) for almost a
decade.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/rpcmisc.h |    1 -
 support/nfs/rpcdispatch.c |   51 ---------------------------------------------
 2 files changed, 0 insertions(+), 52 deletions(-)

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index 665df8e..35c5011 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -46,7 +46,6 @@ int		makesock(int port, int proto);
 void		rpc_init(char *name, int prog, int vers,
 				void (*dispatch)(struct svc_req *, SVCXPRT *),
 				int defport);
-void		rpc_svcrun(void);
 void		rpc_dispatch(struct svc_req *rq, SVCXPRT *xprt,
 				struct rpc_dtable *dtable, int nvers,
 				void *argp, void *resp);
diff --git a/support/nfs/rpcdispatch.c b/support/nfs/rpcdispatch.c
index 3d34774..502fc5f 100644
--- a/support/nfs/rpcdispatch.c
+++ b/support/nfs/rpcdispatch.c
@@ -61,54 +61,3 @@ rpc_dispatch(struct svc_req *rqstp, SVCXPRT *transp,
 		exit (2);
 	}
 }
-
-#if 0
-/*
- * This is our replacement for svc_run. It turns off some signals while
- * executing the server procedures to avoid nasty race conditions.
- */
-void
-rpc_svcrun(fd_set *morefds, void (*func)(int fd))
-{
-	sigset_t	block, current;
-	fd_set		readfds;
-
-	for (;;) {
-		readfds = svc_fdset;
-		if (morefds) {
-			int	i;
-
-			/* most efficient */
-			for (i = 0; i < FD_SETSIZE; i++)
-				if (FD_ISSET(i, morefds))
-					FD_SET(i, &readfs);
-		}
-		switch (select(FD_SETSIZE, &readfds, NULL, NULL, NULL)) {
-		case -1:
-			if (errno == EINTR)
-				continue;
-			xlog(L_ERROR, "svc_run: - select failed");
-			break;
-		case 0:
-			continue;
-		default:
-			if (morefds) {
-				int	i;
-
-				/* most efficient */
-				for (i = 0; i < FD_SETSIZE; i++)
-					if (FD_ISSET(i, morefds) &&
-					    FD_ISSET(i, &readfds))
-						func(i);
-			}
-			sigemptyset(&block);
-			sigaddset(&block, SIGALRM);
-			sigaddset(&block, SIGVTALRM);
-			sigaddset(&block, SIGIO);
-			sigprocmask(SIG_BLOCK, &block, &current);
-			svc_getreqset(&readfds);
-			sigprocmask(SIG_SETMASK, &current, NULL);
-		}
-	}
-}
-#endif

