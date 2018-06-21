Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:42962 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933297AbeFUQfb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2018 12:35:31 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5LGYmUp167691
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:30 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2jmt01skf6-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:30 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5LGZUjW020791
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:30 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5LGZTNM028243
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:29 GMT
From: Manjunath Patil <manjunath.b.patil@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: manjunath.b.patil@oracle.com
Subject: [PATCH 1/2] nfsv4: handle ENOSPC during create session
Date: Thu, 21 Jun 2018 16:35:32 +0000
Message-Id: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Presently the client mount hangs for NFS4ERR_NOSPC repsonse from server
during create session operation. Handle this error at the client side
and pass it back to user-space, which may chose to mount with lower nfs
versions.

Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
---
 fs/nfs/nfs4state.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2bf2eaa..2134cf5 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -381,6 +381,8 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	}
 	nfs4_schedule_state_manager(clp);
 	status = nfs_wait_client_init_complete(clp);
+	if (!status) /* -ERESTARTSYS */
+		status = nfs_client_init_status(clp);
 	if (status < 0)
 		nfs_put_client(clp);
 	return status;
@@ -1919,6 +1921,9 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		dprintk("%s: exit with error %d for server %s\n",
 				__func__, -EPROTONOSUPPORT, clp->cl_hostname);
 		return -EPROTONOSUPPORT;
+	case -NFS4ERR_NOSPC:
+		nfs_mark_client_ready(clp, status);
+		/*fall through*/
 	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
 				 * in nfs4_exchange_id */
 	default:
@@ -2186,6 +2191,7 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	case 0:
 	case -EINTR:
 	case -ERESTARTSYS:
+	case -NFS4ERR_NOSPC:
 		break;
 	case -ETIMEDOUT:
 		if (clnt->cl_softrtry)
-- 
1.8.3.1

