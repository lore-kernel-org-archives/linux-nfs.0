From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH] nfs-utils-1.1.0-rc1 - sm_unmon_1_svc should use
	dnsname
Date: Wed, 18 Apr 2007 11:12:45 -0400
Message-ID: <1176909165.8837.16.camel@wendyc-t.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeCEm-0003UG-Mq
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:38:28 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeCEn-0005e7-2X
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:38:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1HeCEb-0005rY-PV
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:38:18 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3IFXC9h027731
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 11:33:12 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3IFXCTn004089
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 11:33:12 -0400
Received: from [172.16.59.29] (wendyc-t.rdu.redhat.com [172.16.59.29])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3IFXALK012954
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 11:33:11 -0400
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

The sm_unmon_1_svc() should have used dnsname.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>

--- nfs-utils-1.1.0-rc1/utils/statd/monitor.c	2007-03-28 23:55:33.000000000 -0400
+++ nfs-utils-t/utils/statd/monitor.c	2007-04-18 10:59:34.000000000 -0400
@@ -357,7 +357,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 			ha_callout("del-client", mon_name, my_name, -1);
 
 			nlist_free(&rtnl, clnt);
-			xunlink(SM_DIR, mon_name, 1);
+			xunlink(SM_DIR, clnt->dns_name, 1);
 
 			return (&result);
 		} else



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
