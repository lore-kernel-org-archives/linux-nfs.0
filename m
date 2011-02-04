Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab1BDVe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:58 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 39/40] pnfs-submit wave3 new flag for lease time check
Date: Fri,  4 Feb 2011 16:34:01 -0500
Message-Id: <1296855242-2592-40-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-39-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
 <1296855242-2592-31-git-send-email-andros@netapp.com>
 <1296855242-2592-32-git-send-email-andros@netapp.com>
 <1296855242-2592-33-git-send-email-andros@netapp.com>
 <1296855242-2592-34-git-send-email-andros@netapp.com>
 <1296855242-2592-35-git-send-email-andros@netapp.com>
 <1296855242-2592-36-git-send-email-andros@netapp.com>
 <1296855242-2592-37-git-send-email-andros@netapp.com>
 <1296855242-2592-38-git-send-email-andros@netapp.com>
 <1296855242-2592-39-git-send-email-andros@netapp.com>
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
 fs/nfs/client.c            |    9 +++++++++
 fs/nfs/nfs4filelayoutdev.c |    4 ++--
 fs/nfs/nfs4state.c         |    2 +-
 include/linux/nfs_fs_sb.h  |    1 +
 4 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c2ba883..842c288 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1412,6 +1412,15 @@ static int nfs4_set_client(struct nfs_server *server,
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
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 8642109..96e9e6a 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -142,8 +142,8 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	}
 
 	/*
-	 * Set DS lease equal to the MDS lease, renewal is scheduled in
-	 * create_session
+	 * Do not set NFS_CS_CHECK_LEASE_TIME instead set the DS lease to
+	 * be equal to the MDS lease. Renewal is scheduled in create_session.
 	 */
 	spin_lock(&mds_srv->nfs_client->cl_lock);
 	clp->cl_lease_time = mds_srv->nfs_client->cl_lease_time;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 346fb97..6da026a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -153,7 +153,7 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 	int status;
 	struct nfs_fsinfo fsinfo;
 
-	if (is_ds_only_client(clp)) {
+	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
 		nfs4_schedule_state_renewal(clp);
 		return 0;
 	}
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
1.6.6

