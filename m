Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:53558 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933297AbeFUQeA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2018 12:34:00 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5LGP7bf182975
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:33:59 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2jmu6y1g04-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:33:59 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5LGXwJF007591
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:33:58 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5LGXvuC007714
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:33:58 GMT
From: Manjunath Patil <manjunath.b.patil@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: manjunath.b.patil@oracle.com
Subject: [PATCH nfs-utils] mount: handle ENOSPC in nfs_autonegotiate()
Date: Thu, 21 Jun 2018 09:34:20 -0700
Message-Id: <1529598860-1960-1-git-send-email-manjunath.b.patil@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server may return NFS4ERR_NOSPC during NFSv4.1+ mount if there is a
memory pressure to allocate a DRC slot for session being created. In
such cases, try with lower nfs versions, which may succeed as DRC is
shared by clients.

Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
---
 utils/mount/stropts.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d1b0708..7e97a88 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -881,6 +881,10 @@ check_result:
 	case EINVAL:
 		/* A less clear indication that our client
 		 * does not support NFSv4 minor version. */
+	case ENOSPC:
+		/* Server returned NFS4ERR_NOSPC for create session [NFSv4.1+].
+		 * Try with lower NFS versions which share DRC amoung clients and
+		 * hence low memory may be ok. */
 	case EACCES:
 		/* An unclear indication that the server
 		 * may not support NFSv4 minor version. */
-- 
1.8.3.1

