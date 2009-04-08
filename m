From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/3] nfsstat: -Z showing incorrect server stats
Date: Wed, 08 Apr 2009 12:03:07 -0400
Message-ID: <49DCCABB.7080306@RedHat.com>
References: <49DCB9DA.5000300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48334 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757347AbZDHQFy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2009 12:05:54 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n38G5sFN027093
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:05:54 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n38G5tLW029889
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:05:55 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-147.bos.redhat.com [10.16.10.147])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n38G5rwd000659
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:05:53 -0400
In-Reply-To: <49DCB9DA.5000300-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server stats were not being updated with the
-Z options causing the stats to be incorrect.
    
Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 6d81f66..5adb571 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -442,7 +442,11 @@ main(int argc, char **argv)
 			}
 			fflush(stdout);
 
-			update_old_counters(clientinfo_tmp, clientinfo);
+			if (opt_srv)
+				update_old_counters(serverinfo_tmp, serverinfo);
+			if (opt_clt)
+				update_old_counters(clientinfo_tmp, clientinfo);
+
 			sleep(sleep_time);
 		}	
 	} else {
