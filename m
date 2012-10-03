Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8246 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932882Ab2JCAS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 20:18:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: nfs4_open_done first must check that GETATTR decoded a file type
Date: Tue,  2 Oct 2012 17:18:25 -0700
Message-Id: <1349223505-59248-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349223505-59248-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1349223505-59248-1-git-send-email-Trond.Myklebust@netapp.com>
 <1349223505-59248-2-git-send-email-Trond.Myklebust@netapp.com>
 <1349223505-59248-3-git-send-email-Trond.Myklebust@netapp.com>
 <1349223505-59248-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...before it can check the validity of that file type.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 21cfac7..68438aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1537,7 +1537,8 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 		return;
 
 	if (task->tk_status == 0) {
-		switch (data->o_res.f_attr->mode & S_IFMT) {
+		if (data->o_res.f_attr->valid & NFS_ATTR_FATTR_TYPE) {
+			switch (data->o_res.f_attr->mode & S_IFMT) {
 			case S_IFREG:
 				break;
 			case S_IFLNK:
@@ -1548,6 +1549,7 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 				break;
 			default:
 				data->rpc_status = -ENOTDIR;
+			}
 		}
 		renew_lease(data->o_res.server, data->timestamp);
 		if (!(data->o_res.rflags & NFS4_OPEN_RESULT_CONFIRM))
-- 
1.7.11.4

