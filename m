From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] sunrpc: make warning in svc_check_conn_limits() more generic
Date: Fri, 12 Sep 2008 09:12:07 -0400
Message-ID: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47065 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbYILNMz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2008 09:12:55 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id m8CDCJCX014036
	for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2008 09:12:39 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m8CDC8so003572
	for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2008 09:12:08 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id m8CDC7Xw014944
	for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2008 09:12:07 -0400
Received: from dantu.rdu.redhat.com ([127.0.0.1])
	by dantu.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id m8CDC7sM006063
	for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2008 09:12:07 -0400
Received: (from jlayton@localhost)
	by dantu.rdu.redhat.com (8.13.8/8.13.8/Submit) id m8CDC7cx006062
	for linux-nfs@vger.kernel.org; Fri, 12 Sep 2008 09:12:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got a bug report from a user who got this message in his logs:

    lockd: too many open TCP sockets, consider increasing number of nfsd
           threads.

...lockd also started refusing connections at this point. He was
apparently doing some testing with a highly contended lock. lockd
started refusing connections after the first 80 and started printing
this warning. He tried increasing the number of nfsd threads, which of
course didn't do any good. This patch removes the "nfsd" from the
message to make this a little less confusing.

There is still an artificial limit of 80 concurrent clients with lockd.
svc_check_conn_limits has this hardcoded check:

    if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {

...my feeling is that we need to either raise the number or eliminate
this check for single-threaded services like lockd. I'd first like to
understand the rationale for setting the limit here, however. Can anyone
clarify?

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svc_xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b5cd..340f549 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -536,7 +536,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 				/* Try to help the admin */
 				printk(KERN_NOTICE "%s: too many open  "
 				       "connections, consider increasing the "
-				       "number of nfsd threads\n",
+				       "number of threads\n",
 				       serv->sv_name);
 			}
 			/*
-- 
1.5.5.1

