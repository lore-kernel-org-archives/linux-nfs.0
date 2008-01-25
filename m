From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 082/112] NFS: Ensure that we respect NFS_MAX_TCP_TIMEOUT
Date: Fri, 25 Jan 2008 11:37:53 -0500
Message-ID: <20080125163752.31887.50494.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50284 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122AbYAYRCO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:14 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HAA020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:02:01 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It isn't sufficient just to limit timeout->to_initval, we also need to
limit to_maxval.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9066133..59a6dcc 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -387,12 +387,16 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 	switch (proto) {
 	case XPRT_TRANSPORT_TCP:
 	case XPRT_TRANSPORT_RDMA:
-		if (!to->to_initval)
+		if (to->to_initval == 0)
 			to->to_initval = 60 * HZ;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
 			to->to_initval = NFS_MAX_TCP_TIMEOUT;
 		to->to_increment = to->to_initval;
 		to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
+		if (to->to_maxval > NFS_MAX_TCP_TIMEOUT)
+			to->to_maxval = NFS_MAX_TCP_TIMEOUT;
+		if (to->to_maxval < to->to_initval)
+			to->to_maxval = to->to_initval;
 		to->to_exponential = 0;
 		break;
 	case XPRT_TRANSPORT_UDP:
