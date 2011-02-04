Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab1BDVei (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:38 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 18/40] SQUASHME pnfs-submit: wave3 make pnfs_initiate_read static
Date: Fri,  4 Feb 2011 16:33:40 -0500
Message-Id: <1296855242-2592-19-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-18-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

into: pnfs_submit: generic read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h |    2 --
 fs/nfs/read.c     |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 657b71c..5c156d3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,8 +276,6 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 /* read.c */
 extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 			     const struct rpc_call_ops *call_ops);
-extern int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
-			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 345e51e..43eb6a2 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -199,7 +199,7 @@ int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL(nfs_initiate_read);
 
-int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+static int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops)
 {
 	if (data->req->wb_lseg &&
-- 
1.6.6

