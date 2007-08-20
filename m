From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 19/20] knfsd: call svc_create_svcsock
Date: Mon, 20 Aug 2007 11:24:01 -0500
Message-ID: <20070820162401.15224.9446.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2u-0006SJ-GT
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:04 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2x-0004AO-Od
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:08 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id F0B5D7C79D
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:24:01 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Change the call to the socket specific svc_makesock to a call to the
transport independent svc_create_svcsock function. This avoids 
conditional #ifdef's for the rdma transport in the nfsd code. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfssvc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ff55950..1499beb 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -235,8 +235,8 @@ static int nfsd_init_socks(int port)
 
 	error = lockd_up(IPPROTO_UDP);
 	if (error >= 0) {
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port,
-					SVC_SOCK_DEFAULTS);
+		error = svc_create_svcsock(nfsd_serv, "udp", port,
+					   SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
 	}
@@ -246,8 +246,8 @@ static int nfsd_init_socks(int port)
 #ifdef CONFIG_NFSD_TCP
 	error = lockd_up(IPPROTO_TCP);
 	if (error >= 0) {
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port,
-					SVC_SOCK_DEFAULTS);
+		error = svc_create_svcsock(nfsd_serv, "tcp", port,
+					   SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
 	}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
