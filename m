From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 045/112] NFS: Clean up: copy hostname with kstrndup during
	mount processing
Date: Fri, 25 Jan 2008 11:37:37 -0500
Message-ID: <20080125163737.31887.91972.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15284 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757070AbYAYRCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:00 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0WPX020490
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:46 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: mount option parsing uses kstrndup in several places, rather than
using kzalloc.  Replace the few remaining uses of kzalloc with kstrndup,
for consistency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 330c392..a3492d6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1648,21 +1648,16 @@ static int nfs4_validate_mount_data(void *options,
 		len = c - dev_name;
 		if (len > NFS4_MAXNAMLEN)
 			return -ENAMETOOLONG;
-		args->nfs_server.hostname = kzalloc(len, GFP_KERNEL);
-		if (args->nfs_server.hostname == NULL)
-			return -ENOMEM;
-		strncpy(args->nfs_server.hostname, dev_name, len - 1);
+		/* N.B. caller will free nfs_server.hostname in all cases */
+		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
 
 		c++;			/* step over the ':' */
 		len = strlen(c);
 		if (len > NFS4_MAXPATHLEN)
 			return -ENAMETOOLONG;
-		args->nfs_server.export_path = kzalloc(len + 1, GFP_KERNEL);
-		if (args->nfs_server.export_path == NULL)
-			return -ENOMEM;
-		strncpy(args->nfs_server.export_path, c, len);
+		args->nfs_server.export_path = kstrndup(c, len, GFP_KERNEL);
 
-		dprintk("MNTPATH: %s\n", args->nfs_server.export_path);
+		dprintk("NFS: MNTPATH: '%s'\n", args->nfs_server.export_path);
 
 		if (args->client_address == NULL)
 			goto out_no_client_address;
