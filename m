Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51331 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757832Ab1BKSAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:44 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 08/17] SQUASHME reset offset to mds_offset
Date: Thu, 10 Feb 2011 20:52:41 -0500
Message-Id: <1297389170-26702-9-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-8-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
 <1297389170-26702-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into: pnfs-submit wave3 filelayout read done

Update the mds_offset in nfs_readpage_retry so that a failed short-read retry
to a DS gets correctly resent through the MDS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    4 +++-
 fs/nfs/read.c     |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 64a0d4f..f396853 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3108,10 +3108,12 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
 }
 
-/* Reset the the nfs_read_data to send the read to another server. */
+/* Reset the the nfs_read_data to send the read to the MDS. */
 void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 {
 	dprintk("%s Reset task for i/o through \n", __func__);
+	/* offsets will differ in the dense stripe case */
+	data->args.offset = data->mds_offset;
 	data->ds_clp = NULL;
 	data->args.fh     = NFS_FH(data->inode);
 	data->read_done_cb = nfs4_read_done_cb;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index cb0b239..896dc4e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -393,6 +393,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 		return;
 
 	/* Yes, so retry the read at the end of the data */
+	data->mds_offset += resp->count;
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-- 
1.6.6

