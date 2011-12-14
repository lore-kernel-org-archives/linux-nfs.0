Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757211Ab1LNN5N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:57:13 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvDQ8026816
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:13 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvC3b005913
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:13 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] clstated: reattempt the pipe open if it fails on ENOENT
Date: Wed, 14 Dec 2011 08:57:07 -0500
Message-Id: <1323871032-3191-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Generally, we want this daemon started before nfsd starts. Deal with the
situation where the pipe hasn't shown up yet.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/clstated/clstated.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
index 93a2710..aab09a7 100644
--- a/utils/clstated/clstated.c
+++ b/utils/clstated/clstated.c
@@ -75,10 +75,17 @@ usage(char *progname)
 static int
 clstate_pipe_open(struct clstate_client *clnt)
 {
-	clnt->cl_fd = open(pipepath, O_RDWR, 0);
-	if (clnt->cl_fd < 0) {
-		xlog(L_ERROR, "%s: unable to open %s: %m", __func__, pipepath);
-		return clnt->cl_fd;
+	/* loop until the pipe is present or open fails for another reason */
+	for (;;) {
+		clnt->cl_fd = open(pipepath, O_RDWR, 0);
+		if (clnt->cl_fd >= 0) {
+			break;
+		} else if (errno != ENOENT) {
+			xlog(D_GENERAL, "%s: unable to open %s: %m", __func__,
+					pipepath);
+			return clnt->cl_fd;
+		}
+		sleep(1);
 	}
 
 	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, clstatecb, clnt);
-- 
1.7.1

