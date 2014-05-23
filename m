Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53752 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbaEWNXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 09:23:21 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4: Use error handler on failed GETATTR with successful OPEN
Date: Fri, 23 May 2014 06:22:59 -0700
Message-ID: <1400851379-34474-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Place the call to resend the failed GETATTR under the error handler so that
when appropriate, the GETATTR is retried more than once.

The server can fail the GETATTR op in the OPEN compound with a recoverable
error such as NFS4ERR_DELAY. In the case of an O_EXCL open, the server has
created the file, so a retrans of the OPEN call will fail with NFS4ERR_EXIST.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 397be39..be1b305 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2027,7 +2027,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 			return status;
 	}
 	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
-		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
+		nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
 	return 0;
 }
 
-- 
1.8.3.1

