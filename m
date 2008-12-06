From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] sm-notify: always exiting without any notification
Date: Sat, 06 Dec 2008 08:44:02 -0500
Message-ID: <493A81A2.5050904@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34793 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755327AbYLFNqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Dec 2008 08:46:16 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mB6DkGD0031642
	for <linux-nfs@vger.kernel.org>; Sat, 6 Dec 2008 08:46:16 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mB6DkF3f022006
	for <linux-nfs@vger.kernel.org>; Sat, 6 Dec 2008 08:46:15 -0500
Received: from [10.16.10.21] (vpn-10-21.bos.redhat.com [10.16.10.21])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mB6DkDp5005862
	for <linux-nfs@vger.kernel.org>; Sat, 6 Dec 2008 08:46:14 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In my recent trials and tribulations on dealing with
the state file I found this fairly obvious bug:

commit 5d8b800b8438222a55c4698c86b558b15717aa21
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Dec 6 08:31:29 2008 -0500

    sm-notify: always exiting without any notification
    
    Added curly brackets around the record_pid() check which
    stops sm-notify from exiting when a pid file does not
    exist.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 7a7ae1a..d8e2c01 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -193,10 +193,11 @@ usage:		fprintf(stderr,
 	openlog("sm-notify", LOG_PID, LOG_DAEMON);
 
 	if (strcmp(_SM_BASE_PATH, BASEDIR) == 0) {
-		if (record_pid() == 0 && force == 0 && opt_update_state == 1)
+		if (record_pid() == 0 && force == 0 && opt_update_state == 1) {
 			/* already run, don't try again */
 			nsm_log(LOG_NOTICE, "Already notifying clients; Exiting!");
 			exit(0);
+		}
 	}
 
 	if (opt_srcaddr) {
