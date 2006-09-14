From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 4/4 Reference] NLM failover - user mode statd
Date: Thu, 14 Sep 2006 00:53:01 -0400
Message-ID: <4508E02D.8080805@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020707060902000403020509"
Cc: lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNj1X-0006hw-RC
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:40:27 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GNj1Y-0005BD-Ae
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:40:28 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k8E4eRwt021503
	for <nfs@lists.sourceforge.net>; Thu, 14 Sep 2006 00:40:27 -0400
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------020707060902000403020509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is nfs-utils user mode patch based on nfs-utils-1.0.8-rc4. It 
re-enables my_name to the correct ip interface passed by kernel (via 
patch 5-3) that accepts the relevant lock request.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 nfs-utils-1.0.8-rc4/utils/statd/monitor.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)



--------------020707060902000403020509
Content-Type: text/x-patch;
 name="gfs_statd_user.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_statd_user.patch"

--- nfs-util/nfs-utils-1.0.8-rc4/utils/statd/monitor.c	2006-07-07 17:58:22.000000000 -0400
+++ nfs-user/nfs-utils-1.0.8-rc4/utils/statd/monitor.c	2006-08-13 02:06:52.000000000 -0400
@@ -68,7 +68,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 		goto failure;
 	}
 	my_addr.s_addr = htonl(INADDR_LOOPBACK);
-	my_name = "127.0.0.1";
+	note(N_DEBUG, "sm_mon_1_svc my_name=%s\n", my_name);
 
 	/* 2.	Reject any registrations for non-lockd services.
 	 *
@@ -181,6 +181,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 		goto failure;
 	}
 	free(path);
+
 	/* PRC: do the HA callout: */
 	ha_callout("add-client", mon_name, my_name, -1);
 	nlist_insert(&rtnl, clnt);
@@ -231,7 +232,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 			inet_ntoa(caller));
 		goto failure;
 	}
-	my_name = "127.0.0.1";
+	note(N_DEBUG, "sm_unmon_1_svc my_name=%s\n", my_name);
 #endif
 
 	/* Check if we're monitoring anyone. */
@@ -296,7 +297,7 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 			inet_ntoa(caller));
 		goto failure;
 	}
-	my_name = "127.0.0.1";
+	note(N_DEBUG, "sm_unmon_all_1_svc my_name=%s\n", my_name);
 #endif
 
 	result.state = MY_STATE;

--------------020707060902000403020509
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------020707060902000403020509
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020707060902000403020509--
