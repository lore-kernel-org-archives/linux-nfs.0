From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Tue, 23 Nov 2004 15:28:07 -0500
Message-ID: <41A39D57.8060902@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070006090208070506070804"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWhH5-0002IQ-Rd
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 12:28:31 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWhH3-0001cO-Gq
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 12:28:31 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id iANKSHZr032058
	for <nfs@lists.sourceforge.net>; Tue, 23 Nov 2004 15:28:17 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id iANKS7r31701
	for <nfs@lists.sourceforge.net>; Tue, 23 Nov 2004 15:28:07 -0500
Received: from [172.16.80.110] (IDENT:U2FsdGVkX1+RACZbMTbTtATxh5hTHpZ0R0PGxAqsrKA@dickson.boston.redhat.com [172.16.80.110])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id iANKS7a01784
	for <nfs@lists.sourceforge.net>; Tue, 23 Nov 2004 15:28:07 -0500
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------070006090208070506070804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a patch that make sure the correct hostname is used
in the SM_NOTIFY message what is sent from a rebooted server
that has multiple network interfaces.

Using the network part of the destination address, the correct network
interface is found. Then a gethostbyaddr() on that interface is done,
which yields the correct hostname that should be sent in the notify
message....

Comments?

SteveD.


--------------070006090208070506070804
Content-Type: text/x-patch;
 name="nfs-utils-1.0.6-statd-notify-hostname.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-statd-notify-hostname.patch"

--- nfs-utils-1.0.6/utils/statd/rmtcall.c.orig	2004-11-08 11:03:49.352146000 -0500
+++ nfs-utils-1.0.6/utils/statd/rmtcall.c	2004-11-23 13:43:34.751897000 -0500
@@ -26,6 +26,7 @@
 #include <sys/socket.h>
 #include <sys/time.h>
 #include <netinet/in.h>
+#include <net/if.h>
 #include <arpa/inet.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
@@ -34,6 +35,7 @@
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>
+#include <ifaddrs.h>
 #include "sm_inter.h"
 #include "statd.h"
 #include "notlist.h"
@@ -73,7 +75,44 @@
 
 	return sockfd;
 }
-
+/*
+ * Using the NL_ADDR(lp), reset (if needed) the hostname
+ * that will be put in the SM_NOTIFY to the hostname
+ * that is associated with the network interface 
+ * that was monitored
+ */
+static void
+reset_my_name(notify_list *lp)
+{
+	struct ifaddrs *ifa = NULL, *ifap;
+	struct in_addr netaddr, tmp;
+	struct sockaddr_in *sin, *nsin;
+	struct hostent *hp;
+
+	netaddr.s_addr = inet_netof(NL_ADDR(lp));
+	if (getifaddrs(&ifa) >= 0) {
+		for (ifap = ifa; ifap != NULL; ifap = ifap->ifa_next) {
+			if (ifap->ifa_addr->sa_family != AF_INET)
+				continue;
+			if (!(ifap->ifa_flags & IFF_UP))
+				continue;
+			sin = (struct sockaddr_in *)ifap->ifa_addr;
+			nsin = (struct sockaddr_in *)ifap->ifa_netmask;
+			tmp.s_addr = sin->sin_addr.s_addr & nsin->sin_addr.s_addr;
+			if (memcmp(&tmp.s_addr, &netaddr.s_addr, sizeof(netaddr.s_addr)))
+				continue;
+			hp = gethostbyaddr((char *)&sin->sin_addr, 
+				sizeof(sin->sin_addr), AF_INET);
+			if (hp == NULL)
+				continue;
+			if (strcmp(NL_MY_NAME(lp), hp->h_name)) {
+				free(NL_MY_NAME(lp));
+				NL_MY_NAME(lp)= strdup(hp->h_name);
+			}
+		}
+	}
+	return;
+}
 /*
  * Try to resolve host name for notify/callback request
  *
@@ -283,6 +322,7 @@
 {
 	struct sockaddr_in	sin;
 	struct status		new_status;
+	stat_chge           new_stat;
 	xdrproc_t		func;
 	void			*objp;
 	u_int32_t		proc, vers, prog;
@@ -309,9 +349,14 @@
 
 		/* Use source address for notify replies */
 		sin.sin_addr   = lp->addr;
+		/* Make sure the correct hostname is sent */
+		reset_my_name(lp);
 
 		func = (xdrproc_t) xdr_stat_chge;
-		objp = &SM_stat_chge;
+		new_stat.state = MY_STATE;
+		new_stat.mon_name = NL_MY_NAME(lp);
+
+		objp = &new_stat;
 		break;
 	case NOTIFY_CALLBACK:
 		prog = NL_MY_PROG(lp);

--------------070006090208070506070804--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
