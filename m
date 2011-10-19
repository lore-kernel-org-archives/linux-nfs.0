Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439Ab1JSUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] NFSv4: Translate NFS4ERR_BADNAME into ENOENT when applied to a lookup
Date: Wed, 19 Oct 2011 13:50:12 -0700
Message-Id: <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both LOOKUP and OPEN operations may return NFS4ERR_BADNAME if we send a
an invalid name as a filename argument. As far as the application is
concerned, it just has to know that the file doesn't exist, and so
ENOENT would be the appropriate reply. We should only return EINVAL
if the filename is being used to _create_ a new object on the
remote filesystem.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b0c01b2..ba0da50 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1593,8 +1593,14 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	int status;
 
 	status = nfs4_run_open_task(data, 0);
-	if (status != 0 || !data->rpc_done)
+	if (!data->rpc_done)
+		return status;
+	if (status != 0) {
+		if (status == -NFS4ERR_BADNAME &&
+				!(o_arg->open_flags & O_CREAT))
+			return -ENOENT;
 		return status;
+	}
 
 	if (o_arg->open_flags & O_CREAT) {
 		update_changeattr(dir, &o_res->cinfo);
@@ -2455,6 +2461,8 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 
 		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
 		switch (status) {
+		case -NFS4ERR_BADNAME:
+			return -ENOENT;
 		case -NFS4ERR_MOVED:
 			err = nfs4_get_referral(dir, name, fattr, fhandle);
 			break;
-- 
1.7.6.4

