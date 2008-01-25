From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 098/112] NLM: Fix a bogus 'return' in nlmclnt_rpc_release
Date: Fri, 25 Jan 2008 11:37:59 -0500
Message-ID: <20080125163759.31887.48164.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756562AbYAYRAY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:24 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UY010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:22 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index b1a4dba..b6b74a6 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -244,7 +244,7 @@ void nlm_release_call(struct nlm_rqst *call)
 
 static void nlmclnt_rpc_release(void *data)
 {
-	return nlm_release_call(data);
+	nlm_release_call(data);
 }
 
 static int nlm_wait_on_grace(wait_queue_head_t *queue)
