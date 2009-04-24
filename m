From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] mountd: Check host alias with netgroups
Date: Fri, 24 Apr 2009 14:28:08 -0400
Message-ID: <49F204B8.30003@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42119 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbZDXSbD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Apr 2009 14:31:03 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n3OIV1tv004666
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 14:31:01 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n3OIV1f3002698
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 14:31:01 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-113.bos.redhat.com [10.16.10.113])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n3OIV0T2003223
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 14:31:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

exportfs and mountd needs check host aliases when checking
for hosts in net groups. 

See https://bugzilla.redhat.com/show_bug.cgi?id=478952 for details

Signed-off-by: Steve Dickson <steved@redhat.com>
---------------------------

diff --git a/support/export/client.c b/support/export/client.c
index 1cb242f..5fcf355 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -371,7 +371,7 @@ client_check(nfs_client *clp, struct hostent *hp)
 #ifdef HAVE_INNETGR
 		{
 			char	*dot;
-			int	match;
+			int	match, i;
 			struct hostent *nhp = NULL;
 			struct sockaddr_in addr;
 
@@ -380,6 +380,12 @@ client_check(nfs_client *clp, struct hostent *hp)
 			if (innetgr(cname+1, hname, NULL, NULL))
 				return 1;
 
+			/* try the aliases as well */
+			for (i = 0; hp->h_aliases[i]; i++) {
+				if (innetgr(cname+1, hp->h_aliases[i], NULL, NULL))
+					return 1;
+			}
+
 			/* If hname is ip address convert to FQDN */
 			if (inet_aton(hname, &addr.sin_addr) &&
 			   (nhp = gethostbyaddr((const char *)&(addr.sin_addr),
