From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 5 of 10 - make sure the correct hostname is used
 in the SM_NOTIFY
Date: Fri, 23 Sep 2005 10:46:40 -0400
Message-ID: <43341550.9010002@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060008080807070303040500"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIop0-0005yk-QO
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:46:42 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIop0-0002yZ-Il
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:46:43 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEkfdM014786
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:46:41 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEkeV13599
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:46:41 -0400
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
--------------060008080807070303040500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------060008080807070303040500
Content-Type: text/x-patch;
 name="nfs-utils-1.0.6-statd-notify-hostname.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-statd-notify-hostname.patch"

make sure the correct hostname is used in the SM_NOTIFY
message that is sent from a rebooted server which has
multiple network interfaces. (bz 139101)

Details can be found in:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=139101

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.6/utils/statd/rmtcall.c.orig	2005-03-28 21:02:14.147173872 -0500
+++ nfs-utils-1.0.6/utils/statd/rmtcall.c	2005-03-28 21:03:32.401277440 -0500
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
@@ -73,7 +75,50 @@ statd_get_socket(int port)
 
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
+			if (!(ifap->ifa_flags & IFF_UP))
+				continue;
+
+			note(N_DEBUG, "ifa_name %s\n", ifap->ifa_name);
+			if (ifap->ifa_addr == NULL)
+				continue;
+			if (ifap->ifa_addr->sa_family != AF_INET)
+				continue;
+
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
+				note(N_DEBUG, "NL_MY_NAME %s\n", NL_MY_NAME(lp));
+			}
+		}
+	}
+	return;
+}
 /*
  * Try to resolve host name for notify/callback request
  *
@@ -283,6 +328,7 @@ process_entry(int sockfd, notify_list *l
 {
 	struct sockaddr_in	sin;
 	struct status		new_status;
+	stat_chge           new_stat;
 	xdrproc_t		func;
 	void			*objp;
 	u_int32_t		proc, vers, prog;
@@ -309,9 +355,19 @@ process_entry(int sockfd, notify_list *l
 
 		/* Use source address for notify replies */
 		sin.sin_addr   = lp->addr;
+		/* 
+		 * Unless a static hostname has been defined
+		 * set the NL_MY_NAME(lp) hostname to the 
+		 * one associated with the network interface
+		 */
+		if (!(run_mode & STATIC_HOSTNAME))
+			reset_my_name(lp);
 
 		func = (xdrproc_t) xdr_stat_chge;
-		objp = &SM_stat_chge;
+		new_stat.state = MY_STATE;
+		new_stat.mon_name = NL_MY_NAME(lp);
+
+		objp = &new_stat;
 		break;
 	case NOTIFY_CALLBACK:
 		prog = NL_MY_PROG(lp);
--- nfs-utils-1.0.6/utils/statd/statd.c.orig	2005-03-28 21:02:15.575956664 -0500
+++ nfs-utils-1.0.6/utils/statd/statd.c	2005-03-28 21:02:39.200365208 -0500
@@ -288,6 +288,7 @@ int main (int argc, char **argv)
 			}
 			break;
 		case 'n':	/* Specify local hostname */
+			run_mode |= STATIC_HOSTNAME;
 			MY_NAME = xstrdup(optarg);
 			break;
 		case 'P':
--- nfs-utils-1.0.6/utils/statd/statd.h.orig	2005-03-28 21:02:15.256005304 -0500
+++ nfs-utils-1.0.6/utils/statd/statd.h	2005-03-28 21:02:39.237359584 -0500
@@ -79,6 +79,7 @@ extern int run_mode;
 /* LH - notify_only mode would be for notifying hosts on an IP alias
  * that just came back up, for ex, when failing over a HA service to
  * another host.... */
+#define STATIC_HOSTNAME 8	/* Always use the hostname set by -n */
 
 /*
  * Program name and version pointers -- See statd.c for the reasoning

--------------060008080807070303040500--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
