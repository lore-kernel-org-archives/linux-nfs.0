Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44742 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758709Ab3JQSMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:46 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICjHr004996
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:46 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICjrl019321
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:45 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/21] NFS: Export _nfs_display_fhandle()
Date: Thu, 17 Oct 2013 14:12:45 -0400
Message-Id: <20131017181245.1073.49764.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow code in nfsv4.ko to use _nfs_display_fhandle().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/inode.c      |    2 ++
 fs/nfs/nfs4client.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index eda8879..4bc7538 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1209,6 +1209,7 @@ u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh)
 	 * not on the result */
 	return nfs_fhandle_hash(fh);
 }
+EXPORT_SYMBOL_GPL(_nfs_display_fhandle_hash);
 
 /*
  * _nfs_display_fhandle - display an NFS file handle on the console
@@ -1253,6 +1254,7 @@ void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(_nfs_display_fhandle);
 #endif
 
 /**
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 299cf6b..b19c94f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -924,7 +924,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	dprintk("Server FSID: %llx:%llx\n",
 			(unsigned long long) server->fsid.major,
 			(unsigned long long) server->fsid.minor);
-	dprintk("Mount FH: %d\n", mntfh->size);
+	nfs_display_fhandle(mntfh, "Pseudo-fs root FH");
 
 	nfs4_session_set_rwsize(server);
 

