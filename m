From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] statd: not unlinking host files
Date: Sat, 06 Dec 2008 09:34:25 -0500
Message-ID: <493A8D71.20603@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52566 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756377AbYLFOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Dec 2008 09:36:47 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mB6EaaK8005601
	for <linux-nfs@vger.kernel.org>; Sat, 6 Dec 2008 09:36:36 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mB6EaaPn027770
	for <linux-nfs@vger.kernel.org>; Sat, 6 Dec 2008 09:36:36 -0500
Received: from [10.16.10.21] (vpn-10-21.bos.redhat.com [10.16.10.21])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mB6EaZ3Q009130
	for <linux-nfs@vger.kernel.org>; Sat, 6 Dec 2008 09:36:35 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again working with the state file code, I notice that statd was
not unlinking hosts files when the kernel sent up the 
sm_unmon messages. This following patch address the reason why... 

Comments?

steved.

commit f8536d0e210a8151900f8c68185927790239eb62
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Dec 6 09:30:43 2008 -0500

    statd: not unlinking host files
    
    Statd is not unlinking host files during SM_UNMON and
    SM_UNMON_ALL calls because the given host is still on the run-time
    notify list (rtnl) and the check flag is set when xunlink() is
    called. But the next thing the caller of xunlink() does is
    remove the host from the rtnl list which means the
    unlink will never happen.
    
    So in cases where xunlink() is immediately follow by a call
    to nlist_free() (which removes the host from the list) the
    check flag to xunlink() is not set.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index a6a1d9c..7d6e4da 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -352,7 +352,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
 
-			xunlink(SM_DIR, clnt->dns_name, 1);
+			xunlink(SM_DIR, clnt->dns_name, 0);
 			nlist_free(&rtnl, clnt);
 
 			return (&result);
@@ -404,7 +404,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 			temp = NL_NEXT(clnt);
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
-			xunlink(SM_DIR, clnt->dns_name, 1);
+			xunlink(SM_DIR, clnt->dns_name, 0);
 			nlist_free(&rtnl, clnt);
 			++count;
 			clnt = temp;
