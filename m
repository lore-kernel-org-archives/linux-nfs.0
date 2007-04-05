From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 4/4 Revised] NLM - user mode statd changes
Date: Thu, 05 Apr 2007 17:52:59 -0400
Message-ID: <46156FBB.2060701@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000902090305070308010506"
Cc: Lon Hohberger <lhh@redhat.com>
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZaD0-0003pq-LL
	for nfs@lists.sourceforge.net; Thu, 05 Apr 2007 15:13:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZaD2-0007EX-Pb
	for nfs@lists.sourceforge.net; Thu, 05 Apr 2007 15:13:37 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l35MDaKd015382
	for <nfs@lists.sourceforge.net>; Thu, 5 Apr 2007 18:13:36 -0400
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
--------------000902090305070308010506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

User mode nfs-utils changes (nfs-utils-1.1.0-rc1) - it re-enables 
my_name to the correct ip interface passed by kernel (via patch 4-3) 
that accepts the relevant lock request.  Check out "man rpc.statd" and 
"man sm-notify" for details.

Also included a minor bug fix with sm_unmon_1_svc() where it should have 
used dns_name.

-- Wendy


--------------000902090305070308010506
Content-Type: text/x-patch;
 name="004_user_statd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="004_user_statd.patch"

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 monitor.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- nfs-utils-1.1.0-rc1/utils/statd/monitor.c	2007-03-28 23:55:33.000000000 -0400
+++ nfs-utils/utils/statd/monitor.c	2007-04-05 11:52:11.000000000 -0400
@@ -70,7 +70,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 		goto failure;
 	}
 	my_addr.s_addr = htonl(INADDR_LOOPBACK);
-	my_name = "127.0.0.1";
+	note(N_DEBUG, "sm_mon_1_svc my_name=%s\n", my_name);
 
 	/* 2.	Reject any registrations for non-lockd services.
 	 *
@@ -327,7 +327,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 			inet_ntoa(caller));
 		goto failure;
 	}
-	my_name = "127.0.0.1";
+	note(N_DEBUG, "sm_unmon_1_svc my_name=%s\n", my_name);
 #endif
 
 	/* Check if we're monitoring anyone. */
@@ -357,7 +357,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 			ha_callout("del-client", mon_name, my_name, -1);
 
 			nlist_free(&rtnl, clnt);
-			xunlink(SM_DIR, mon_name, 1);
+			xunlink(SM_DIR, clnt->dns_name, 1);
 
 			return (&result);
 		} else
@@ -394,7 +394,7 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 			inet_ntoa(caller));
 		goto failure;
 	}
-	my_name = "127.0.0.1";
+	note(N_DEBUG, "sm_unmon_all_1_svc my_name=%s\n", my_name);
 #endif
 
 	result.state = MY_STATE;




--------------000902090305070308010506
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------000902090305070308010506
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000902090305070308010506--
