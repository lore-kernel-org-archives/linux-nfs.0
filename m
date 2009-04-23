From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/19] NFSD: move lockd_up() before svc_addsock()
Date: Thu, 23 Apr 2009 19:32:18 -0400
Message-ID: <20090423233217.17283.96414.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:29513 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106AbZDWXeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:36 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

A couple of years ago, a series of commits, finishing with commit
5680c446, swapped the order of the lockd_up() and svc_addsock() calls
in __write_ports().  At that time lockd_up() needed to know the
transport protocol of the passed-in socket to start a listener on the
same transport protocol.

These days, lockd_up() doesn't take a protocol argument; it always
starts both a UDP and TCP listener.  It's now more straightforward to
try the lockd_up() first, then do a lockd_down() if the svc_addsock()
fails.

Careful review of this code shows that the svc_sock_names() call is
used only to close the just-opened socket in case lockd_up() fails.
So it is no longer needed if lockd_up() is done first.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index caf4fdc..e051847 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -939,17 +939,18 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0)
 		return err;
 
-	err = svc_addsock(nfsd_serv, fd, buf);
-	if (err >= 0) {
-		err = lockd_up();
-		if (err < 0)
-			svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
+	err = lockd_up();
+	if (err != 0)
+		goto out;
 
-		/* Decrease the count, but don't shut down the service */
-		nfsd_serv->sv_nrthreads--;
-	}
+	err = svc_addsock(nfsd_serv, fd, buf);
+	if (err < 0)
+		lockd_down();
 
-	return err < 0 ? err : 0;
+out:
+	/* Decrease the count, but don't shut down the service */
+	nfsd_serv->sv_nrthreads--;
+	return err;
 }
 
 /*

