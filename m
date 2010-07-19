Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966739Ab0GSUur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 16:50:47 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] nfsd: fix error handling in __write_ports_addxprt
Date: Mon, 19 Jul 2010 16:50:06 -0400
Message-Id: <1279572608-7234-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

__write_ports_addxprt calls nfsd_create_serv. That increases the
refcount of nfsd_serv (which is tracked in sv_nrthreads). The service
only decrements the thread count on error, not on success like
__write_ports_addfd does, so using this interface leaves the nfsd
thread count high.

Fix this by having this function call svc_destroy() on error to release
the reference (and possibly to tear down the service) and simply
decrement the refcount without tearing down the service on success.

This makes the sv_threads handling work basically the same in both
__write_ports_addxprt and __write_ports_addfd.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfsctl.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index af7469e..9e8645a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1018,6 +1018,9 @@ static ssize_t __write_ports_addxprt(char *buf)
 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
 	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_close;
+
+	/* Decrease the count, but don't shut down the service */
+	nfsd_serv->sv_nrthreads--;
 	return 0;
 out_close:
 	xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
@@ -1026,8 +1029,7 @@ out_close:
 		svc_xprt_put(xprt);
 	}
 out_err:
-	/* Decrease the count, but don't shut down the service */
-	nfsd_serv->sv_nrthreads--;
+	svc_destroy(nfsd_serv);
 	return err;
 }
 
-- 
1.5.5.6

