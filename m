From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/33] NFSv4: Ensure we don't corrupt fl->fl_flags in
	nfs4_proc_unlck
Date: Sat, 19 Apr 2008 16:40:50 -0400
Message-ID: <20080419204050.14124.91282.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757064AbYDSUuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:35 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoZLJ026119
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:35 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9f2759d..a106932 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3263,6 +3263,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	struct nfs4_lock_state *lsp;
 	struct rpc_task *task;
 	int status = 0;
+	unsigned char fl_flags = request->fl_flags;
 
 	status = nfs4_set_lock_state(state, request);
 	/* Unlock _before_ we do the RPC call */
@@ -3286,6 +3287,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = nfs4_wait_for_completion_rpc_task(task);
 	rpc_put_task(task);
 out:
+	request->fl_flags = fl_flags;
 	return status;
 }
 

