From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 1/3] nfs-utils: remove xflock timeout
Date: Thu, 28 Jan 2010 15:26:29 -0600
Message-ID: <20100128212629.29681.53047.stgit@case.americas.sgi.com>
References: <20100128211454.29681.24752.stgit@case.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: SteveD@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:32935 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753344Ab0A1V0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 16:26:30 -0500
In-Reply-To: <20100128211454.29681.24752.stgit-PhfrMOq4MEUPybYDWDrblq0bRtRcJeJQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove this 10 second timeout which can cause unexpected behavior and
corruption in the rmtab when hit.
---
 support/nfs/xio.c |   18 +-----------------
 1 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/support/nfs/xio.c b/support/nfs/xio.c
index 5e2e1e9..e3d27d2 100644
--- a/support/nfs/xio.c
+++ b/support/nfs/xio.c
@@ -44,16 +44,9 @@ xfclose(XFILE *xfp)
 	xfree(xfp);
 }
 
-static void
-doalarm(int sig)
-{
-	return;
-}
-
 int
 xflock(char *fname, char *type)
 {
-	struct sigaction sa, oldsa;
 	int		readonly = !strcmp(type, "r");
 	struct flock	fl = { readonly? F_RDLCK : F_WRLCK, SEEK_SET, 0, 0, 0 };
 	int		fd;
@@ -68,21 +61,12 @@ xflock(char *fname, char *type)
 		return -1;
 	}
 
-	sa.sa_handler = doalarm;
-	sa.sa_flags = 0;
-	sigemptyset(&sa.sa_mask);
-	sigaction(SIGALRM, &sa, &oldsa);
-	alarm(10);
 	if (fcntl(fd, F_SETLKW, &fl) < 0) {
-		alarm(0);
 		xlog(L_WARNING, "failed to lock %s: errno %d (%s)",
 				fname, errno, strerror(errno));
 		close(fd);
-		fd = 0;
-	} else {
-		alarm(0);
+		fd = -1;
 	}
-	sigaction(SIGALRM, &oldsa, NULL);
 
 	return fd;
 }

