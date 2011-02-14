Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab1BNTSq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:46 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 06/16] pnfs: wave 3: new flag for lease time check
Date: Mon, 14 Feb 2011 14:18:26 -0500
Message-Id: <1297711116-3139-7-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Data servers cannot send nfs4_proc_get_lease_time. but still need to setup
state renewal. Add the NFS_CS_CHECK_LEASE_TIME bit to indicate if the lease
time can be checked.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |    9 +++++++++
 fs/nfs/nfs4state.c        |    5 +++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5891cf8..4d15331 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1413,6 +1413,15 @@ static int nfs4_set_client(struct nfs_server *server,
 		goto error;
 	}
 
+	/*
+	 * Query for the lease time on clientid setup or renewal
+	 *
+	 * Note that this will be set on nfs_clients that were created
+	 * only for the DS role and did not set this bit, but now will
+	 * serve a dual role.
+	 */
+	set_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state);
+
 	server->nfs_client = clp;
 	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
 	return 0;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e6742b5..9e33e88 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -153,6 +153,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 	int status;
 	struct nfs_fsinfo fsinfo;
 
+	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
+		nfs4_schedule_state_renewal(clp);
+		return 0;
+	}
+
 	status = nfs4_proc_get_lease_time(clp, &fsinfo);
 	if (status == 0) {
 		/* Update lease time and schedule renewal */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2c2dc18..2669a9a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -31,6 +31,7 @@ struct nfs_client {
 #define NFS_CS_IDMAP		2		/* - idmap started */
 #define NFS_CS_RENEWD		3		/* - renewd started */
 #define NFS_CS_STOP_RENEW	4		/* no more state to renew */
+#define NFS_CS_CHECK_LEASE_TIME	5		/* need to check lease time */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
-- 
1.7.2.3

