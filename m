Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:48868 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab0KVMoA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Nov 2010 07:44:00 -0500
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id oAMChxdw000433
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 12:44:00 GMT
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by rcsinet13.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id oAM931FO003822
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 12:43:58 GMT
Message-Id: <201011221243.oAM931FO003822@rcsinet13.oracle.com>
Date: Mon, 22 Nov 2010 20:40:42 +0800
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] lockd: release memory for non-normal situation
To: linux-nfs@vger.kernel.org
Cc: greg.marsden@oracle.com, joe.jin@oracle.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nlmclnt_proc() is neither releasing nlm_rqst nor dropping the ref on nlm_host.
Do the release work though I am not sure if it can really hit the situation.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 fs/lockd/clntproc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 332c54c..ec9f0f5 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -173,8 +173,10 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 			status = nlmclnt_unlock(call, fl);
 	} else if (IS_GETLK(cmd))
 		status = nlmclnt_test(call, fl);
-	else
+	else {
+		nlm_release_call(call);
 		status = -EINVAL;
+	}
 	fl->fl_ops->fl_release_private(fl);
 	fl->fl_ops = NULL;
 
-- 
1.7.2.3

