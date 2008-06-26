From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NFS: Move the nfs_set_port() call out of
	nfs_parse_mount_options()
Date: Thu, 26 Jun 2008 17:47:05 -0400
Message-ID: <20080626214704.3129.844.stgit@ellison.1015granger.net>
References: <20080626214451.3129.85650.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50405 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbYFZVsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 17:48:00 -0400
In-Reply-To: <20080626214451.3129.85650.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The remount path does not need to set the port in the server address.
Since it's not really a part of option parsing, move the nfs_set_port()
call to nfs_parse_mount_options()'s callers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 396a12e..d3be1fa 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1215,9 +1215,6 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
-	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address,
-				mnt->nfs_server.port);
-
 	return 1;
 
 out_nomem:
@@ -1568,6 +1565,9 @@ static int nfs_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
+		nfs_set_port((struct sockaddr *)&args->nfs_server.address,
+				args->nfs_server.port);
+
 		nfs_set_transport_defaults(args);
 
 		status = nfs_parse_devname(dev_name,
@@ -2196,6 +2196,9 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			return -EINVAL;
 
+		nfs_set_port((struct sockaddr *)&args->nfs_server.address,
+				args->nfs_server.port);
+
 		nfs_set_transport_defaults(args);
 
 		switch (args->auth_flavor_len) {

