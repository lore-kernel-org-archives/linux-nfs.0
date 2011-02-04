Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233Ab1BDVen (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:43 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 23/40] SQUASHME pnfs-submit wave3 new function for ds expired lease
Date: Fri,  4 Feb 2011 16:33:45 -0500
Message-Id: <1296855242-2592-24-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-23-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9c50be7..fb22cbf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1574,7 +1574,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	return 0;
 }
 
-int nfs4_recover_expired_lease(struct nfs_client *clp)
+static int nfs4_client_recover_expired_lease(struct nfs_client *clp)
 {
 	unsigned int loop;
 	int ret;
@@ -1593,6 +1593,11 @@ int nfs4_recover_expired_lease(struct nfs_client *clp)
 }
 EXPORT_SYMBOL(nfs4_recover_expired_lease);
 
+static int nfs4_recover_expired_lease(struct nfs_server *server)
+{
+	return nfs4_client_recover_expired_lease(server->nfs_client);
+}
+
 /*
  * OPEN_EXPIRED:
  * 	reclaim state on the server after a network partition.
@@ -1680,7 +1685,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 		dprintk("nfs4_do_open: nfs4_get_state_owner failed!\n");
 		goto out_err;
 	}
-	status = nfs4_recover_expired_lease(server->nfs_client);
+	status = nfs4_recover_expired_lease(server);
 	if (status != 0)
 		goto err_put_state_owner;
 	if (path->dentry->d_inode != NULL)
@@ -5075,7 +5080,7 @@ int nfs4_init_session(struct nfs_server *server)
 	session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
 	session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
 
-	ret = nfs4_recover_expired_lease(server->nfs_client);
+	ret = nfs4_recover_expired_lease(server);
 	if (!ret)
 		ret = nfs4_check_client_ready(clp);
 	return ret;
-- 
1.6.6

