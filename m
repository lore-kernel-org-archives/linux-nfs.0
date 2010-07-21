From: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] nfsd: fix error handling when starting nfsd with rpcbind down
Date: Wed, 21 Jul 2010 19:26:46 -0400
Message-ID: <1279754811-8328-2-git-send-email-bfields@redhat.com>
References: <20100721232432.GA6689@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46644 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755292Ab0GUX1s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 19:27:48 -0400
In-Reply-To: <20100721232432.GA6689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

The refcounting for nfsd is a little goofy. What happens is that we
create the nfsd RPC service, attach sockets to it but don't actually
start the threads until someone writes to the "threads" procfile. To do
this, __write_ports_addfd will create the nfsd service and then will
decrement the refcount when exiting but won't actually destroy the
service.

This is fine when there aren't errors, but when there are this can
cause later attempts to start nfsd to fail. nfsd_serv will be set,
and that causes __write_versions to return EBUSY.

Fix this by calling svc_destroy on nfsd_serv when this function is
going to return error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 508941c..af7469e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -950,14 +950,18 @@ static ssize_t __write_ports_addfd(char *buf)
 		return err;
 
 	err = lockd_up();
-	if (err != 0)
-		goto out;
+	if (err != 0) {
+		svc_destroy(nfsd_serv);
+		return err;
+	}
 
 	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
-	if (err < 0)
+	if (err < 0) {
 		lockd_down();
+		svc_destroy(nfsd_serv);
+		return err;
+	}
 
-out:
 	/* Decrease the count, but don't shut down the service */
 	nfsd_serv->sv_nrthreads--;
 	return err;
-- 
1.7.0.4

