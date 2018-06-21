Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:54546 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933388AbeFUQfc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2018 12:35:32 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5LGYQOf189101
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:31 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2jmu6y1g62-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:31 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5LGZUvB013432
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:30 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5LGZU8x020120
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2018 16:35:30 GMT
From: Manjunath Patil <manjunath.b.patil@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: manjunath.b.patil@oracle.com
Subject: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session slot
Date: Thu, 21 Jun 2018 16:35:33 +0000
Message-Id: <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
In-Reply-To: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Presently nfserr_jukebox is being returned by nfsd for create_session
request if server is unable to allocate a session slot. This may be
treated as NFS4ERR_DELAY by the clients and which may continue to re-try
create_session in loop leading NFSv4.1+ mounts in hung state. nfsd
should return nfserr_nospc in this case as per rfc5661(section-18.36.4
subpoint 4. Session creation).

Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8571414..3734e08 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2716,7 +2716,7 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
 	 */
 	ca->maxreqs = nfsd4_get_drc_mem(ca);
 	if (!ca->maxreqs)
-		return nfserr_jukebox;
+		return nfserr_nospc;
 
 	return nfs_ok;
 }
-- 
1.8.3.1

