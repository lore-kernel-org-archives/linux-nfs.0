Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966728Ab0GSUuw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 16:50:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] nfsd: fix error handling when starting nfsd with rpcbind down
Date: Mon, 19 Jul 2010 16:50:05 -0400
Message-Id: <1279572608-7234-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

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
1.5.5.6

