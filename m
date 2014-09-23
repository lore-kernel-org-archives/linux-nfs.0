Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbaIWQ0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:26:21 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGQLAd015087
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:26:21 -0400
Received: from bcodding-csb.redhat.com (vpn-55-195.rdu2.redhat.com [10.10.55.195])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGQKDu003140
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:26:20 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] lockd: Try to reconnect if statd has moved
Date: Tue, 23 Sep 2014 12:26:20 -0400
Message-Id: <005770f212b347da4f3842224cc94743567dcf31.1411486371.git.bcodding@redhat.com>
In-Reply-To: <cover.1411486371.git.bcodding@redhat.com>
References: <cover.1411486371.git.bcodding@redhat.com>
In-Reply-To: <cover.1411486371.git.bcodding@redhat.com>
References: <cover.1411486371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If rpc.statd is restarted, upcalls to monitor hosts can fail with
ECONNREFUSED.  In that case force a lookup of statd's new port and retry the
upcall.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/mon.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index daa8e75..9106f42 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -159,6 +159,12 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
 
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
 	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFTCONN);
+	if (status == -ECONNREFUSED) {
+		dprintk("lockd:	NSM upcall RPC failed, status=%d, forcing rebind\n",
+				status);
+		rpc_force_rebind(clnt);
+		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFTCONN);
+	}
 	if (status < 0)
 		dprintk("lockd: NSM upcall RPC failed, status=%d\n",
 				status);
-- 
1.7.1

